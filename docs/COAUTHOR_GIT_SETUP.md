# Git Setup Guide for Coauthors

## Prerequisites

1. **GitHub account** -- create at github.com if you don't have one
2. **Git installed** -- download from git-scm.com (Windows installer)
3. **VS Code** (recommended) -- download from code.visualstudio.com
4. **Claude Code** (optional but powerful) -- see claude.ai/code

## Step 1: Get Repository Access

Ask Jensen to add your GitHub username as a collaborator:
- Repository: `github.com/naj2r/JuryTrial_Redux`
- You'll receive an email invitation. Accept it.

## Step 2: Set Up SSH Key (one-time)

Open Git Bash (installed with Git) and run:

```bash
ssh-keygen -t ed25519 -C "your_email@example.com"
```

Press Enter for all prompts (default location, no passphrase is fine).

Then add the key to GitHub:
```bash
cat ~/.ssh/id_ed25519.pub
```

Copy the output. Go to GitHub > Settings > SSH and GPG Keys > New SSH Key. Paste it.

## Step 3: Clone the Repository

```bash
cd ~/Documents  # or wherever you keep projects
git clone git@github.com:naj2r/JuryTrial_Redux.git
cd JuryTrial_Redux
```

## Step 4: Switch to the Working Branch

```bash
git checkout claude/optimistic-visvesvaraya
```

This is where all current work lives. Do NOT work on `main` directly.

## Step 5: Create Your Own Branch (recommended)

```bash
git checkout -b josh/prose-fixes
```

This creates a branch for your edits that won't conflict with ongoing work.

## Daily Workflow

### Before you start working:
```bash
git pull origin claude/optimistic-visvesvaraya
```

### After making edits:
```bash
git add -A
git commit -m "fix: brief description of what you changed"
git push origin josh/prose-fixes
```

### Key rules:
- **Never edit files in `files/tab/paper/`** -- these are code-generated tables
- **Never edit `.claude/` files** unless you know what you're doing
- **Always pull before starting work** to avoid merge conflicts
- **Commit often** with descriptive messages

## Repository Structure (what's where)

```
JuryTrial_Redux/
├── CLAUDE.md              # Project rules (read this first)
├── MEMORY.md              # Accumulated project knowledge
├── .claude/
│   ├── rules/             # Study parameters, variable codebook, etc.
│   ├── agents/            # AI agent definitions
│   └── skills/            # AI skill definitions
├── scripts/
│   └── stata/michigan/    # All Stata do-files (01-14)
├── Paper/sections/        # Local .tex stubs (Overleaf is authoritative)
├── quality_reports/       # Review reports, plans, session logs
├── master_supporting_docs/# Scanned paper notes (12 papers)
├── explorations/          # Research sandbox
└── docs/                  # This guide and other docs
```

## Important: The Paper Lives on Overleaf

The actual `.tex` files you edit are on Overleaf, synced via Jensen's Dropbox:
- `C:\Users\jensenn\Dropbox\Apps\Overleaf\Voir Dire 2-20-26\`

If you have Overleaf access, edit there. The repo has local stubs in `Paper/sections/` but Overleaf is authoritative.

## Using Claude Code (optional but recommended)

If you install Claude Code, run it from the repo root:
```bash
cd JuryTrial_Redux
claude
```

It automatically loads CLAUDE.md and all rules. You can ask it:
- "What are the current study parameters?"
- "Show me the variable codebook"
- "What does Table 2b show?"
- "Check if this number matches the tables"

Available skills: `/review --paper`, `/validate-bib`, `/commit`
