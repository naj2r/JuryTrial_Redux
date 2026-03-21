---
name: lit-organizer
description: Organize, rate, filter, and synthesize paper notes into a curated literature review. Run AFTER split-pdf or cheap-scan1 reading is complete. Single-pass pipeline replaces the old lit-filter + lit-synthesizer two-step.
allowed-tools: Read, Write, Edit, Glob, Grep, Task
argument-hint: [path-to-paper-notes-directory or "all"]
---

# Literature Organizer: Rate, Filter, and Synthesize

**Single-pass pipeline** — collects all paper notes, scores relevance, identifies redundancy, and produces a synthesized narrative. Replaces the old `/lit-filter` + `/lit-synthesizer` two-step workflow.

## When to Use
Run this skill AFTER all (or most) papers have been read via `split-pdf` or `cheap-scan1` and have `notes.md` files in their output directories.

## Input

`$ARGUMENTS` — one of:
- Path to a directory containing `notes.md` files (from split-pdf or cheap-scan1)
- Path to `paper_skims.md` or similar collection file
- `all` — process everything in `docs/` and `articles/` directories

If no argument is given, default to scanning all available sources.

## Step 1: Collect All Paper Notes (haiku — pure lookup)

Read all available paper notes from:
1. `articles/split_*/notes.md` — deep-read notes from split-pdf
2. `articles/scanned_*/notes.md` — deep-read notes from cheap-scan1
3. `$RB/docs/paper_skims.md` — the master skim file
4. Any other `.md` files in `docs/` containing paper summaries

If a paper has both a skim AND deep-read notes, **use the deeper notes**. If both split-pdf and cheap-scan1 notes exist, use whichever has more complete section coverage.

Build a quick-reference table:
```markdown
| # | Paper | Triage Score | Subtopic | Pages | Connection Summary |
```

## Step 2: Launch Literature Organizer Agent (sonnet)

Spawn the `literature-organizer` agent with:
- The collected table from Step 1
- The study parameters (key findings, treatment tiers) from `study-parameters.md`
- Instructions to produce `articles/literature_organized.md`

**Agent prompt template:**
```
You are the literature-organizer agent. Read your specification at:
.claude/agents/literature-organizer.md

Study context: [Load from study-parameters.md — paper title, method, key findings, treatment variables]

[PAPER NOTES/SUMMARIES HERE]

Write the output to: $RB/articles/literature_organized.md
```

The agent will, in a single pass:
1. **Score** each paper 1-5 by relevance
2. **Assign** inclusion tier (A-D) and subtopic codes
3. **Identify** redundancy clusters
4. **Write** shortened summaries and synthesized narrative by subtopic
5. **Flag** coverage gaps

## Step 3: Apply to QMD (main conversation)

After the agent returns:
1. Read `articles/literature_organized.md`
2. Use tier assignments to structure the literature sources QMD chapter
3. Use synthesized subtopic narratives as prose basis
4. Use gap analysis to target further literature searches

## Bloat Detection Rules

The organizer MUST compress these patterns:

| Pattern | Action |
|---------|--------|
| Multiple papers making the same empirical point | Merge into one sentence citing all |
| Repeated "Connection to Our Study" sections | State relevance ONCE per subtopic |
| Abstract-length summaries of similar papers | Condense to 1-2 sentences within narrative |
| Redundant institutional background | One paragraph max |
| Repeated theoretical mechanism explanations | One theoretical paragraph, cite all |
| Papers with similar methods and findings | Lead with highest-impact, parenthetically cite rest |

## Target Compression

| Input | Target Output |
|-------|--------------|
| Many individual paper summaries (~300 lines each) | ~150-200 lines of synthesized narrative |
| Repeated per-paper "Connection" sections | ~20 lines of grouped connection text |
| Multi-dimension extraction per paper | Selective dimensions only |

## Output Quality Check

Before finalizing, verify:
- [ ] Every Tier A paper appears prominently in the synthesis
- [ ] No subtopic section exceeds ~40 lines of prose
- [ ] No two consecutive paragraphs make the same point
- [ ] All BibTeX keys use `authorYYYYdescriptor` format
- [ ] Effect sizes and p-values are preserved exactly

## Model Routing

| Task | Model | Why |
|------|-------|-----|
| Globbing/collecting notes | haiku | Pure file lookup |
| Scoring, filtering, synthesizing | sonnet | Requires domain judgment |
| Applying to QMD narrative | opus | Restructuring into argumentative prose |

## Output
`articles/literature_organized.md` — the single artifact this skill produces.
