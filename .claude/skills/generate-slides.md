# Skill: Generate Slide Decks from Teaching Content

Generate sli.dev slide decks from teaching content files for the Application Hosting Strategies course.

## Usage

```
/generate-slides day-2          # Generate all slide decks for day 2
/generate-slides day-3/04       # Generate slides for a specific file
/generate-slides day-2 day-3    # Generate slides for multiple days
```

## What this skill does

Converts teaching content markdown files (`day-N/XX-topic.md`) into sli.dev slide decks (`slides/day-N/XX-topic.md`) using the custom template at `slides/template/`.

## Step-by-step process

### 1. Preparation

- Read `CLAUDE.md` for the full slide generation methodology, layout mapping rules, and frontmatter template
- Read 1-2 completed Day 1 slide decks as reference:
  - `slides/day-1/01-understanding-hosting-models.md` (66 slides, broad variety of layouts)
  - `slides/day-1/04-cloud-service-models.md` (88 slides, most comprehensive)
- List the source content files for the requested day(s)

### 2. Generate slide decks

For each content file, either directly or via parallel agents:

**If generating a single file:** Read the source content and generate the slide deck directly.

**If generating multiple files (recommended approach):** Launch one agent per file using the Task tool:
- `subagent_type: "general-purpose"`
- `isolation: "worktree"` (each agent works in an isolated git worktree)
- Each agent receives in its prompt:
  - The source content file path to read
  - The frontmatter template (from CLAUDE.md)
  - Instruction to read 1-2 Day 1 reference slide decks before generating
  - The complete layout mapping rules and slide philosophy

**Agent prompt template:**

```
Generate a sli.dev slide deck from the teaching content.

SOURCE: day-N/XX-topic.md → OUTPUT: slides/day-N/XX-topic.md

BEFORE WRITING, read these reference files:
1. slides/day-1/01-understanding-hosting-models.md (reference slide deck — study the patterns)
2. slides/day-1/04-cloud-service-models.md (second reference — most comprehensive)
3. The source content file listed above

FRONTMATTER:
---
theme: ../template
title: "N. Title Here"
info: "Day X — Application Hosting Strategies"
aspectRatio: "16/10"
canvasWidth: 960
fonts:
  sans: Plus Jakarta Sans
  serif: Plus Jakarta Sans
  mono: Fira Code
---

COVER SLIDE FORMAT:
## Application Hosting Strategies - Day X

# Slide Deck Title

SLIDE PHILOSOPHY:
- ONE idea per slide — never pack multiple concepts
- 3-5 short bullet points max (one sentence each), NO paragraphs
- Mermaid diagrams get their own `image` layout slide
- Discussion prompts get `center-phrase` layout
- Case studies split across multiple slides (context → constraint → decision → lesson)
- Instructor notes (### Instructor Notes: in blockquotes) → speaker notes <!-- -->
- Discussion prompts (> **Discussion prompt:**) → center-phrase slides
- Tables preserved where small; large tables split across slides

LAYOUT MAPPING:
- Standard content → layout: default, slots: ::title::, ::content::
- Mermaid diagrams → layout: image, slots: ::title::, ::image::
- Discussion prompts → layout: center-phrase, slots: ::title::, ::phrase::
- Section headers → layout: section, anonymous slot
- Side-by-side → layout: two-columns, slots: ::title::, ::left::, ::right::
- 3-way comparison → layout: three-items, slots: ::title::, ::item1::–::item3::
- 4-way comparison → layout: four-items, slots: ::title::, ::item1::–::item4::
- Content + illustration → layout: left-column, slots: ::title::, ::content::, ::image:: (optional)

MERMAID COLOR PALETTE (use ONLY these):
#d32f2f (red), #1976d2 (blue), #388e3c (green), #7b1fa2 (purple), #f57c00 (orange), #e64a19 (deep orange)

IMPORTANT:
- Preserve ALL mermaid diagrams from the source — wrap each in image layout
- Convert `graph TD` to `graph LR` where horizontal layout fits better on 16:10 slides
- Every slide separator is exactly: a blank line, ---, layout frontmatter, ---, blank line
- Do NOT add images — leave *Visual:* suggestions in speaker notes for the user to add later
- Match the Day 1 reference decks in style, density, and structure
```

### 3. Coherency review

After all agents complete, run a coherency check across all generated decks:

- **Frontmatter:** Same structure, correct day number, correct title from source H1
- **Layout syntax:** All `---` separators properly formatted, all slot markers (`::name::`) correct
- **Mermaid colors:** Only the 6 approved colors used
- **Speaker notes:** Instructor notes preserved as `<!-- -->`, not lost
- **Slide density:** No slides with more than 5-6 bullets, no paragraph text
- **Cross-references:** No numeric section references ("Section 4"), only descriptive ("the previous session on...")

### 4. Report results

For each generated deck, report:
- File path
- Number of slides
- Number of lines
- Any issues found during coherency review

## Directory structure

```
slides/
├── template/          # Custom sli.dev theme (11 layouts)
├── package.json       # Shared node_modules for all decks
├── day-1/             # COMPLETE — 6 decks, user-reviewed
│   ├── 01-understanding-hosting-models.md
│   ├── 02-deployment-strategies.md
│   ├── 03-hands-on-hosting-decision-matrix.md
│   ├── 04-cloud-service-models.md
│   ├── 05-cloud-cost-and-finops.md
│   ├── 06-hands-on-cost-optimization.md
│   └── assets/        # Hand-drawn illustrations (added by user)
├── day-2/             # TO GENERATE
└── day-3/             # TO GENERATE
```

## Running generated decks

```bash
cd slides && npx slidev day-N/XX-topic.md --open
```
