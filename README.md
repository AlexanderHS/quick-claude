# quick-claude

Quick launcher to jump into a repo and start coding with Claude.

## Install

```bash
git clone git@github.com:AlexanderHS/quick-claude.git
cd quick-claude
./install.sh        # creates alias 'w'
# or
./install.sh qc     # creates alias 'qc' instead
```

Then restart your shell or `source ~/.bashrc`.

## Usage

```
w
```

Arrow keys to select, Enter to confirm.

## Configuration

Copy `.env.example` to `.env` to customize:

```bash
cp .env.example .env
```

```bash
# .env
REPOS_DIR="$HOME/projects"  # default: ~/repos
```

## Uninstall

```bash
./uninstall.sh
```

## Requirements

- Bash
- Git
- [Claude Code](https://github.com/anthropics/claude-code)
