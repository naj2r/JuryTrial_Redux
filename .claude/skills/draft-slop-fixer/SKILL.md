---
name: draft-slop-fixer
description: Clean up stream-of-consciousness academic drafts — resolve citation gaps, reword copy-paste chunks, fill in TODO markers, and delegate sourcing tasks. Stage 1 of the writing pipeline; must run BEFORE any reviewer or prose-quality pass.
argument-hint: "[path to drafting document]"
allowed-tools: ["Read", "Grep", "Glob", "Edit", "Write", "Task", "Bash", "WebSearch", "WebFetch"]
---

# Draft Slop Fixer

**Purpose:** Take the user's flow-state academic draft and do the grunt work they deferred while writing — the tedious citation lookups, the "need more info" placeholders, the copy-paste insertions that need rewording, and the organizational scaffolding that needs condensing.

**This is Stage 1 of the pipeline.** Do NOT attempt to improve prose quality, restructure arguments, or compress length. That's for later stages. Your only job is mechanical cleanup so the draft is ready for reviewers.

**Input:** `$ARGUMENTS` — path to the drafting markdown file.

---

## Phase 1: Scan & Classify Issues

Read the entire drafting document. Build a categorized issue list:

### Category A: TODO/Placeholder Markers
Patterns to find:
- `(need more info)`, `(need to expand)`, `(need to expand on this)`
- `(CITE)`, `(cite)`, `(citation needed)`, `[?]`, `[TODO]`, `(TODO)`
- `(find this)`, `(look up)`, `(check this)`, `(verify)`
- `(need exact quote)`, `(get page number)`
- Any parenthetical that reads as a note-to-self rather than content

**Action:** Search the project's notes infrastructure:
1. `articles/split_*/notes.md` — paper reading notes
2. `articles/theory_notes_*.md` — deep theory extractions
3. `articles/notes_*.md` — web-sourced notes
4. `docs/paper_skims.md` — comprehensive paper summaries
5. `replication_book/literature_sources.qmd` — synthesized lit review
6. `articles/literature_filter_report.md` — tier assignments
7. Your project's `.bib` file — existing bibliography keys

Fill in the gap with sourced content. If the needed information isn't in any project file, flag it for manual resolution (don't hallucinate citations).

### Category B: Uncited Claims
Statements that reference specific papers without proper citation syntax.
**Action:** Match to existing bib keys. If no key exists, flag for bib addition.

### Category C: Copy-Paste Insertions
Chunks clearly verbatim from notes — identifiable by sudden tone shifts, embedded bullet lists, or encyclopedic density.
**Action:** Reword to match the surrounding narrative voice. Preserve factual content.

### Category D: Organizational Scaffolding
Markdown headers or inline notes that are structural reminders, not content.
**Action:** Replace with proper transitions or remove if obvious.

---

## Phase 2: Execute Fixes

Work through issues **in document order**. For each fix:
1. Read surrounding context (2-3 paragraphs)
2. Source needed information from project files
3. Write the fix in the author's voice
4. Mark with `<!-- SLOP-FIX: [description] -->` comment

### Citation Format
- In markdown drafts: use `@authorYYYYdescriptor` Quarto syntax
- Convert informal references to proper keys
- If paper isn't in bib, flag for addition

---

## Phase 3: Delegate

Produce a delegation report for remaining issues:
- Missing citations → hand to **bib-fixer** agent
- Missing paper content → flag for user
- Claims needing PDF verification → flag for user
- Organizational decisions → flag for user

---

## Phase 4: Output

1. Copy original to `[filename]_BACKUP_[date].md`
2. Write cleaned version with `<!-- SLOP-FIX -->` markers
3. Produce summary report with issue counts and delegation list

## What This Skill Does NOT Do

- **Does not restructure arguments** — that's the organizer
- **Does not improve prose quality** — that's McCloskey
- **Does not compress length** — that's the compressor
- **Does not check economic logic** — that's the domain-reviewer

This skill is the **minimum viable cleanup** so that everything downstream has clean input.
