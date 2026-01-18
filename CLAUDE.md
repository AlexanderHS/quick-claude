# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

quick-claude is a bash-based interactive launcher that displays a list of repositories sorted by last commit date, allowing quick navigation and immediate launch of Claude Code in the selected repository.

## Architecture

- **quick-claude.sh**: Main script that must be sourced (not executed) to allow `cd` to affect the parent shell. Displays an interactive arrow-key menu of repos from `$REPOS_DIR`, sorted by most recent commit, then runs `claude` in the selected directory.
- **install.sh**: Adds a shell alias (default: `w`) to the user's `.bashrc` or `.zshrc`
- **uninstall.sh**: Removes the alias from the shell config
- **.env**: Optional config file to override `REPOS_DIR` (default: `~/repos`)

## Key Implementation Details

- Uses ANSI escape codes for colors and cursor control
- Hides cursor during menu navigation, restores on exit via trap
- Escape key exits the menu without selection
- Git repos show last commit date; non-git directories show "not git"
- Cross-platform date handling (GNU and BSD `stat`/`date` variants)
