---
name: generate-slides
description: Generate sli.dev slide decks from teaching content files. Reads teaching material and intelligently converts to slides following your slide philosophy and layout patterns. Use when you have teaching content and need to create slide decks. Invoke as /generate-slides [file-path] or /generate-slides [day-N] for all modules in a day.
disable-model-invocation: false
user-invocable: true
argument-hint: "[file-path or day-N]"
allowed-tools: Read, Glob, Write, Bash
---

# Generate Slides Skill

Transform teaching content files (day-N/XX-topic.md) into sli.dev slide decks (slides/day-N/XX-topic.md). This skill reads your teaching material, understands your slide philosophy from CLAUDE.md and reference Day 1 slide decks, and intelligently converts content into visual presentations following your established patterns.

## How to Invoke

```bash
# Generate ONE slide deck
/generate-slides day-2/02-alternative-hosting.md

# Generate ALL slide decks in a day
/generate-slides day-2

# Auto-detect (if you say "generate slides for module 02" in a course project)
Claude will automatically load and invoke this skill if you ask for slide generation
```

## What This Skill Does

1. **Reads the teaching content file** (day-N/XX-topic.md)
2. **Reads CLAUDE.md** to understand:
   - Your slide philosophy and rules
   - Course metadata and context
   - Mermaid color palette
   - Expected structure
3. **Reads 1-2 Day 1 reference slide decks** to understand:
   - Layout mapping patterns (which content → which layout)
   - How paragraphs become bullets
   - How case studies are structured across multiple slides
   - Visual placeholders and speaker note format
   - Mermaid diagram handling
4. **Intelligently converts teaching content**:
   - Extracts key ideas from narrative paragraphs
   - Creates short, impactful bullet points (3-5 per slide)
   - Selects appropriate layouts (section, default, two-columns, center-phrase, image, three-items, etc.)
   - Converts Mermaid `graph TD` to `graph LR` for width
   - Expands case studies across multiple slides
   - Preserves instructor notes as speaker notes
   - Includes Visual placeholders
5. **Generates complete slide deck**:
   - Proper frontmatter (theme, title, info, fonts, aspect ratio)
   - Cover slide (course name, topic title)
   - Content slides following layout mapping
   - Speaker notes with pacing tips and instructor guidance
6. **Writes to disk**: `slides/day-N/XX-topic.md`
7. **Supports parallel generation**: If you invoke with `day-N`, detects all modules in that day and generates each in a parallel agent

## Architecture: Content → Slides Mapping

This mapping comes from analyzing Day 1 slide decks and comparing with teaching content:

### Layout Mapping Rules

| Teaching Content Pattern | Slide Layout | Slots | Key Points |
|---|---|---|---|
| H1 Title + opening intro | `cover` | (anonymous) | Centered, uses course name as header |
| H2 Section headers | `section` | (anonymous) | Section divider, optional image |
| Narrative paragraph → bullets | `default` | `::title::` `::content::` | Standard slide: title + 3-5 bullet points |
| Discussion prompt | `center-phrase` | `::title::` `::phrase::` | Centered italic text for group thinking |
| Mermaid diagram | `image` | `::title::` `::image::` | Full diagram, convert `graph TD` to `graph LR` |
| Side-by-side comparison | `two-columns` | `::title::` `::left::` `::right::` | Two columns of bullets |
| Content + illustration | `left-column` | `::title::` `::content::` `::image::` | Body on left, image on right |
| Table (small) | `default` or `two-columns` | varies | Preserve as-is if < 10 rows, split if larger |
| Table (large) | Split across slides | `default` | Create one slide per section of table |
| Case study company | `default` | `::title::` `::content::` | Slide 1: company name, 3-4 key facts, logo |
| Case study constraint | `default` | `::title::` `::content::` | Slide 2: problem/constraint, 3-4 bullets |
| Case study decision | `default` | `::title::` `::content::` | Slide 3: chosen solution, approach |
| Case study lesson | `default` | `::title::` `::content::` | Slide 4: key lesson/takeaway |
| Multiple items (3 items) | `three-items` | `::title::` `::item1::` `::item2::` `::item3::` | 3 boxes with optional images |
| Multiple items (4 items) | `four-items` | `::title::` `::item1::` `::item2::` `::item3::` `::item4::` | 2x2 grid with optional images |

### Content Conversion Principles

**Paragraph → Bullets:**
- Read full narrative paragraph from teaching content
- Extract 3-5 key points (avoid copying text verbatim)
- Use short, punchy language (1 sentence per bullet max)
- Group related ideas together
- Example:
  ```
  Teaching content: "The Public Cloud Era (2006-2018) brought radical change.
  AWS launched EC2 in 2006 with hourly billing. This shifted IT from capital
  expenditure (CapEx) to operational expenditure (OpEx)..."

  Becomes:
  - AWS EC2 (2006): rent servers by the hour
  - Shifted IT from CapEx to OpEx (like electricity)
  - Startups could launch globally on day one without hardware budget
  ```

**Case Studies → Multi-Slide Expansion:**
- Teaching file: "#### Case Study: Company Name" (H4 or subsection)
- Slides become 4 slides:
  1. "Company Name — The Company" (who they are, scale, revenue)
  2. "Company Name — The Constraint" (what was the problem)
  3. "Company Name — The Decision" (what they chose)
  4. "Company Name — The Lesson" (what we learn)
- Each slide uses `::title::` and `::content::` with 3-4 bullets + logo image

**Instructor Notes → Speaker Notes:**
- Teaching file: `### Instructor Notes: Section Name` followed by blockquotes
- Becomes: `<!-- Speaker notes here -->`  in slide
- Format: Keep bullets, remove blockquote syntax
- Example:
  ```
  Teaching:
  > **Pacing:** This section should take 10 minutes
  > **Common misconception:** Students often think...
  > **Engagement tip:** Ask them to...

  Becomes speaker notes:
  <!-- Pacing: 10 minutes. Common misconception: students think...
       Engagement: ask them to... -->
  ```

**Visual Placeholders:**
- Teaching file: `*Visual:* [description of illustration]`
- Becomes speaker note: `<!-- *Visual:* [description] -->`
- Example:
  ```
  Teaching:
  *Visual:* Architecture diagram showing cloud vs on-premises side-by-side

  Becomes:
  <!-- *Visual:* Architecture diagram comparing cloud vs on-premises -->
  ```

**Mermaid Diagrams:**
- Convert `graph TD` (top-down) → `graph LR` (left-right) for width
- Convert `graph LR` → `graph LR` (no change)
- Add `direction LR` inside each `subgraph` block for consistent internal flow
- Keep color styles: `fill:#d32f2f`, `fill:#1976d2`, etc.
- Wrap in `image` layout: `::image::` with code block containing mermaid
- When diagrams have contrasting subgraphs (good vs. bad), put the **positive/preferred** subgraph first
- Shorten node labels for slide readability (e.g., "Developer writes specification" → "Write spec")

### Frontmatter Template

Every slide deck uses this frontmatter (customize course name + day number):

```yaml
---
theme: ../template
title: "N. Topic Name"
info: "Day X — [Course Name from CLAUDE.md]"
aspectRatio: "16/10"
canvasWidth: 960
fonts:
  sans: Plus Jakarta Sans
  serif: Plus Jakarta Sans
  mono: Fira Code
---
```

### Cover Slide Format

First slide is always:
```markdown
## [Course Name] - Day X

# [Topic Title]
```

This uses the implicit `cover` layout (first H2 is course header, first H1 is main title).

### Section Slide Format

When a H2 appears in teaching content (like `## 1. First Topic (15 min)`):
```markdown
---
layout: section
---

# [Topic Title]

## Subtitle or context (optional)
```

### Default Slide Format

Most content becomes default slides:
```markdown
---
layout: default
---

::title::
## [Slide Title]

::content::

- Key point 1
- Key point 2
- Key point 3

<!-- Speaker notes: pacing, misconceptions, engagement tips, visual placeholders -->
```

### Discussion Prompt Format

Teaching content with "Discussion prompt:" becomes center-phrase slides. Follow these rules:
- **No quotation marks** — remove the `"..."` wrapping from the teaching content
- **Split long phrases into multiple italic lines** — each line is its own `*text*` block, separated by a blank line
- **Use `<br/>` for mid-line breaks** when a single thought needs a soft wrap but shouldn't be a separate line

```markdown
---
layout: center-phrase
---

::title::
## Discussion

::phrase::

*First part of the question*

*Second part of the question*
```

Example — teaching content:
```
> **Discussion prompt:** *"If the agent writes all the code, what exactly is your job?
> And if you can't answer that clearly, what happens to the quality of what gets shipped?"*
```

Becomes:
```markdown
::phrase::

*If the agent writes all the code, what exactly is your job?*

*And if you can't answer that clearly, <br/> what happens to the quality of what gets shipped?*
```

The same multi-line italic style applies to **thesis statements** and **key quotes** on center-phrase slides — not just discussion prompts.

### Diagram Format

Mermaid diagrams become:
```markdown
---
layout: image
---

::title::
## [Diagram Title]

::image::

```mermaid
[mermaid diagram, converted TD → LR if needed]
```
```

## Processing Steps

1. **Check prerequisites**: CLAUDE.md must exist (read it for context)
2. **Detect input**:
   - If file path provided (day-2/02-topic.md), generate that ONE file
   - If directory provided (day-2), detect all day-2/*.md files and generate each
3. **For each file**:
   - Read the teaching content
   - Identify structure: H1, H2, H3 sections, paragraphs, tables, mermaid, discussion prompts
   - Read 1-2 Day 1 reference slide decks to calibrate layout decisions
   - Convert teaching content to slides using layout mapping
   - Generate frontmatter with correct course name from CLAUDE.md
   - Create cover slide
   - Process each section, converting to appropriate layouts
   - Expand case studies into 4-slide format
   - Convert paragraphs to 3-5 bullet points
   - Preserve Mermaid diagrams (convert TD → LR)
   - Extract instructor notes → speaker notes
   - Extract Visual mentions → speaker notes with "Visual:" prefix
4. **Write to disk**: `slides/day-N/XX-topic.md`
5. **Report**: Show what was created

## Parallel Generation

If invoked with `/generate-slides day-2`:
1. Detect all files in `day-2/01-*.md`, `day-2/02-*.md`, etc.
2. Launch one parallel agent per file (in isolated git worktrees)
3. Each agent independently:
   - Reads the teaching file
   - Reads CLAUDE.md
   - Reads Day 1 reference slides
   - Generates the slide deck
   - Writes to disk
4. Collect results and report on all generated files

## Coherency Checks (After Parallel Generation)

If multiple files were generated in parallel:
1. Verify all frontmatter matches (same theme, fonts, aspect ratio)
2. Check that all use consistent slot syntax (::title::, ::content::, etc.)
3. Verify Mermaid color palette matches across all files (#d32f2f, #1976d2, etc.)
4. Confirm speaker note format is consistent (<!-- ... -->)
5. Alert user to any inconsistencies (but don't block — user can fix)

## Example: Converting a Section

**Teaching content:**
```markdown
## 1. The Cloud-Native Era (20 min)

Containers and serverless changed everything. Instead of thinking in servers,
developers now think in functions and microservices. Kubernetes became the
standard orchestration platform. This shift made infrastructure "invisible"
to application engineers.

### Discussion Prompt
> *"Invisible infrastructure sounds great, but what gets harder when ops is hidden
> from developers?"*

### Instructor Notes: Container Paradigm
> **Pacing:** 8 minutes for explanation, 2 minutes for discussion
> **Common misconception:** Students often think Kubernetes is just "the way
> to deploy containers." Emphasize it's a business decision, not a technical one.
> **Engagement tip:** Ask them: "What would break if your Kubernetes cluster
> went down for an hour?"
```

**Becomes slides:**
```markdown
---
layout: section
---

# The Cloud-Native Era

## Containers and Serverless

---
layout: default
---

::title::
## Infrastructure Gets Invisible

::content::

- Containers + serverless changed the paradigm
- Developers think in functions, not servers
- Kubernetes became standard orchestration
- Infrastructure "disappears" from the app team

<!-- Pacing: 8 minutes. Common misconception: Kubernetes is not just
     "the way to deploy" — it's a business decision. Engagement:
     "What breaks if Kubernetes goes down for an hour?" -->

---
layout: center-phrase
---

::title::
## Discussion

::phrase::

*Invisible infrastructure sounds great, <br/> but what gets harder when ops is hidden from developers?*
```

## Smart Auto-Invocation (When Claude Detects)

In a course project, if you say something like:
- "Generate slides for day-2/02-alternative-hosting.md"
- "Create slide decks for all of day 2"
- "Make slides from these teaching files"

Claude will:
1. Recognize you're asking for slide generation
2. Check that CLAUDE.md exists
3. Automatically load and invoke `/generate-slides` with the appropriate argument
4. Report results

## Error Handling

**CLAUDE.md missing:**
```
❌ Cannot generate slides — CLAUDE.md not found.

This skill requires a bootstrapped project. Run:
  /course-bootstrap

...to create CLAUDE.md and project structure.
```

**File not found:**
```
❌ File not found: day-2/02-alternative-hosting.md

Check the file path and try again. Available files in day-2/:
- day-2/01-cloud-provider-comparison.md
- day-2/02-alternative-hosting.md
```

**Directory has no teaching files:**
```
⚠️  No teaching files found in day-2/

Expected files like: day-2/01-*.md, day-2/02-*.md, etc.
Create teaching content files first, then generate slides.
```

## Success Report

```
✅ Slides generated successfully!

Created:
- slides/day-2/01-cloud-provider-comparison.md (6 slides)
- slides/day-2/02-alternative-hosting.md (12 slides)
- slides/day-2/03-hands-on-cloud-provider-choice.md (8 slides)

Total: 26 slides across 3 modules

Next steps:
1. Review the generated slides in slides/day-2/
2. Add custom illustrations (look for <!-- *Visual:* ... --> comments)
3. Adjust layouts if needed (change layout: default to layout: two-columns, etc.)
4. Run slides with: cd slides && npx slidev day-2/01-cloud-provider-comparison.md --open
```

## Slide Review Checklist

After generation, verify:
- [ ] Frontmatter matches your standards (theme, fonts, aspect ratio)
- [ ] Cover slide shows course name and topic title
- [ ] Sections have section layout (with optional images)
- [ ] Bullets are short (1 sentence max)
- [ ] No more than 5 bullets per slide
- [ ] Case studies are split into 4 slides (company, constraint, decision, lesson)
- [ ] Discussion prompts use center-phrase layout
- [ ] Mermaid diagrams use image layout with LR orientation
- [ ] Speaker notes include pacing, misconceptions, engagement tips
- [ ] Visual placeholders are present in speaker notes
- [ ] Color palette matches (#d32f2f, #1976d2, #388e3c, #7b1fa2, #f57c00, #e64a19)
