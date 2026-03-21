---
name: commit
description: Stage changes, create a descriptive commit, and optionally push
argument-hint: "[commit message or 'auto' for auto-generated message]"
allowed-tools: ["Bash"]
---

# Commit

Stage and commit changes with a descriptive message.

**Input:** `$ARGUMENTS` — a commit message, or "auto" to generate one from the diff.

## Steps

1. Run `git status` to see what's changed
2. Run `git diff --stat` to understand the scope
3. If message is "auto":
   - Analyze the diff to generate a descriptive message
   - Format: `type: short description` (e.g., `feat: add lit review bibliography`)
4. Stage relevant files (prefer specific files over `git add -A`)
5. Commit with the message
6. Show the commit hash and summary
7. Ask before pushing

## Commit Types

| Type | When |
|------|------|
| `feat` | New analysis, new chapter, new table |
| `fix` | Bug fix in code or correction in text |
| `docs` | Documentation, session logs, MEMORY.md |
| `refactor` | Code reorganization without changing output |
| `data` | Data pipeline changes |
| `style` | Formatting, no content change |

## Note

This project may not always use git (Dropbox sync is primary). If not in a git repo, skip this skill and note that changes are saved via Dropbox.
