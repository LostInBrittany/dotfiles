# dotfiles

My macOS configuration, managed with [yadm](https://yadm.io) – Yet Another Dotfiles Manager.

yadm is a thin wrapper around Git that uses `$HOME` as its work tree, so files stay where macOS and the tools expect them: no symlinks and no copying. This README lives in `~/.github/` so it shows up on GitHub without adding a `README.md` to my home directory.

## What's inside

| Path | What it configures |
| --- | --- |
| `.zshrc`, `.zprofile` | Zsh shell: environment, `PATH`, aliases |
| `.gitconfig` | Git identity and defaults |
| `.npmrc` | npm settings |
| `.config/ghostty/config` | [Ghostty](https://ghostty.org) terminal |
| `.config/iterm2/` | iTerm2 preferences |
| `.claude/settings.json`, `.claude/statusline.*` | [Claude Code](https://claude.com/claude-code) settings and custom status line |
| `.claude/skills/`, `.agents/skills/` | Claude Code and agent skills |

## Setting up a new Mac

1. Install [Homebrew](https://brew.sh), then yadm:

   ```sh
   brew install yadm
   ```

2. Make sure an SSH key registered on GitHub is available, then clone:

   ```sh
   yadm clone git@github.com:LostInBrittany/dotfiles.git
   ```

   yadm checks the files out straight into `$HOME`. If a file already exists locally, yadm keeps the local copy and shows it as modified: review with `yadm diff`, then either keep it or discard it with `yadm checkout -- <file>`.

3. Open a new terminal so the shell configuration is loaded.

## Everyday use

yadm takes the same commands as Git:

```sh
yadm status                 # what changed
yadm diff                   # see the changes
yadm add ~/.config/foo      # start tracking a new file
yadm commit -m "Update foo"
yadm push
```

To get changes made on another machine:

```sh
yadm pull
```

## Before committing

This repository is public. Check files like `.npmrc`, `.gitconfig` and `.claude/settings.json` for tokens, API keys or private paths before committing them. For anything secret, use [yadm's encryption](https://yadm.io/docs/encryption) or keep it out of the repository.
