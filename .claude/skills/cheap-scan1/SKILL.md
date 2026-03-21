---
name: cheap-scan1
description: Token-efficient PDF processing pipeline. Extracts text locally (zero tokens), routes content to cheapest capable model, only uses vision on pages that need it. Expected 55-76% token savings vs split-pdf with ≥90% information retention.
allowed-tools: Read, Write, Edit, Glob, Grep, Task, Bash
---

# cheap-scan1 — Token-Efficient PDF Processing

## Overview

Replaces the expensive split-pdf approach (every page as image → ~2,000 tokens/page) with a four-stage pipeline:

```
STAGE 0: Local Python Extraction (zero tokens)
  pymupdf extracts text + splits into per-section markdown files
  ↓
STAGE 1: Progressive Triage Funnel (default) or skip (--safe)
  1a: Abstract → score → ELIMINATE if clearly irrelevant (~200 tokens)
  1b: Introduction → re-score → ELIMINATE if scope drops (~800 tokens)
  1c: Conclusion (non-linear jump) → final scope decision (~1,500 tokens)
  1d: Selective section filtering via TOC (if partially relevant)
  ↓  [papers that survive; --safe sends ALL sections]
STAGE 1 (cont): Text Summarizer — haiku (cheapest model)
  Reads selected prose sections (or all in --safe mode)
  [--safe mode: tags each section CORE/TANGENTIAL/OUT-OF-SCOPE]
  ↓  [text context established]
STAGE 2: Visual Processing (only after text triage is done)
  Scanner Agent (haiku) → identifies tables/figures/equations
  ├── 2a: Visual Analyzer (sonnet + vision) — tables/figures only
  └── 2b: Equation Transcriber (sonnet + vision) — equations only
  ↓
STAGE 3: Consolidation (sonnet)
  Merges text + visual + equation outputs → notes.md
  [--safe mode: uses relevance tags to trim OUT-OF-SCOPE sections]
```

## Usage

```
/cheap-scan1 path/to/paper.pdf                  (progressive triage — may eliminate early)
/cheap-scan1 path/to/paper.pdf --safe           (exhaustive read, tags irrelevant sections)
/cheap-scan1 path/to/paper.pdf --triage-only    (just score relevance, don't deep-read)
```

### Mode Summary

| Mode | Reads | Eliminates Papers? | Section Filtering | Best For |
|------|-------|-------------------|-------------------|----------|
| Default (progressive) | Abstract → intro → conclusion → selective | Yes, at any stage | Skips irrelevant sections entirely | Large lit review batches, clear scope boundaries |
| `--safe` | All sections | Never | Tags sections CORE/TANGENTIAL/OUT-OF-SCOPE; consolidator trims | Borderline papers, unfamiliar subfields, cautious exploration |
| `--triage-only` | Abstract only | Reports score, always stops | N/A | Quick relevance check before committing |

## Prerequisites

- Python 3 with pymupdf: `pip install pymupdf`
- The extraction script at `.claude/skills/cheap-scan1/extract_pdf.py`

## Full Protocol

### STAGE 0: Local Extraction (runs on user's machine — zero API tokens)

1. **Run the Python extraction script:**

```bash
python ".claude/skills/cheap-scan1/extract_pdf.py" "INPUT_PDF" "OUTPUT_DIR"
```

Where:
- `INPUT_PDF` = full path to the PDF
- `OUTPUT_DIR` = `$RB/articles/scanned_AUTHORNAME_YEAR/` (use `scanned_` prefix to coexist with old `split_` directories)

This produces:
- `extracted_text.md` — full text with `--- PAGE N ---` markers
- `metadata.json` — per-page quality metrics + section map
- `sections/sec_NN_ppXX-YY_label.md` — per-section markdown files (anti-skimming failsafe)

2. **Check for scanned PDF:**

Read `metadata.json`. If `"scanned_pdf": true` → abort cheap-scan1 and fall back to `/split-pdf`. Print:
> "This PDF appears to be a scan (most pages have no extractable text). Falling back to /split-pdf which handles scanned documents."

3. **Progressive Triage Funnel (default mode):**

The triage is staged to minimize tokens spent on irrelevant papers. Each stage reads only what's needed to make a scope decision. **Only scope-based elimination** — do not make quality judgments (subpar science, ideological slant) autonomously.

#### Stage 1a — Abstract

Read the abstract section file (`sec_*_abstract.md` or first section file if no abstract detected).

Score relevance to the current research project on a 1–5 scale (consult `domain-profile.md` for scope boundaries):
- **Score 1** (clearly out of scope — no empirical or institutional connection to the project's research question) → **ELIMINATE immediately.** Write elimination log and stop. (~200 tokens spent)
- **Score 5** (clearly relevant — directly studies the project's core topic, mechanisms, or institutional setting) → **PROCEED** to Stage 1b scanner. Skip remaining triage stages.
- **Score 2–4** (uncertain) → Continue to Stage 1b-triage.

If `--triage-only` flag was given, stop here regardless of score.

#### Stage 1b-triage — Introduction

Read the introduction section file(s). Re-evaluate relevance:
- If relevance **drops to 1** (e.g., intro reveals it's about a completely different system — a completely different subfield, institutional setting, or methodology with no overlap) → **ELIMINATE.** Log and stop. (~600-1,200 tokens spent)
- If relevance **rises to 4–5** → **PROCEED** to Stage 1b scanner.
- If relevance **stays at 2–3** → Continue to Stage 1c-triage.

#### Stage 1c-triage — Conclusion (non-linear jump)

**Jump to the conclusion** section file(s) — do NOT read linearly through the whole paper. The conclusion reveals the paper's actual contribution and scope.

Final scope decision:
- **Score 1–2** → **ELIMINATE.** Log and stop. (~800-1,600 tokens spent)
- **Score 3–5** → **PROCEED** to Stage 1b scanner.

#### Stage 1d — Selective Section Reading (partially relevant papers)

If the paper scored 3+ but the triage revealed that **some sections are clearly irrelevant** (e.g., a long review article where some chapters don't connect to the project's empirical focus, but others do):

1. Check if `metadata.json` contains a table of contents or section map.
2. From the abstract + intro + conclusion context, identify which sections are **likely relevant** to the project's research scope.
3. Flag the relevant sections. Only these will be sent to the text summarizer in Stage 2.
4. Log which sections were **skipped** and the rationale.

If no TOC exists or section relevance can't be determined, send ALL sections to the text summarizer (same as `--safe` mode for this paper).

#### Triage — Safe Mode (`--safe`)

**Skip Stages 1a–1d entirely.** Proceed directly to Stage 1b scanner with ALL sections.

After the text summarizer (Stage 2a) completes, add a **section-level relevance tagging pass**: the summarizer's output for each section gets a relevance tag:

| Tag | Meaning | What consolidator does |
|-----|---------|----------------------|
| **CORE** | Directly relevant to the project's research scope | Full treatment in notes.md |
| **TANGENTIAL** | Adjacent topic, might be useful for context | 1-2 sentence mention |
| **OUT-OF-SCOPE** | No connection to the project's research scope | Listed as skipped with 1-line reason |

The consolidator receives ALL section notes but with these tags, so it can trim bloat without losing the exhaustive search. The section list in notes.md includes a "Sections skipped" entry so the user knows what was omitted and can override.

#### Elimination Logging

When a paper is eliminated (default mode only), write this to `OUTPUT_DIR/notes.md`:

```markdown
# [Author (Year)] — [Title]

**Triage score:** N/5 — ELIMINATED AT [STAGE]
**Elimination rationale:** [1-2 sentences explaining why this paper is out of scope]
**Sections read before elimination:** [list]
**Tokens spent:** ~[estimate]

## Research Question
[Brief — what the paper studies]

## Connection to Our Study
[Why it was deemed out of scope for the current research project]
```

This ensures the user can audit every elimination decision and override if needed.

### STAGE 1: Text Processing (haiku — cheapest first)

**Important:** Process text BEFORE scanning for visual content. Tables and figures without the surrounding text context are wasted resources. The text triage determines which sections matter — only then do we invest sonnet tokens on vision.

4. **Dispatch text summarizer (haiku) — for selected text sections:**

Which sections to send depends on the mode:
- **Default mode:** Only sections flagged as relevant by Stage 1d (or all sections if no selective filtering was possible)
- **Safe mode:** ALL text sections (exhaustive read)

```
Task(subagent_type="general-purpose", model="haiku", prompt="""
You are the pdf-text-summarizer agent. Deep-read these section files
and produce structured notes for each:

SECTION FILES: [list the text-only section files — filtered by triage in default mode, all in --safe mode]
MODE: [default | safe]

Follow the instructions in .claude/agents/pdf-text-summarizer.md.
Write output to OUTPUT_DIR/text_notes.md.

CRITICAL: Read every word of each section file you receive.
These files are intentionally small to prevent skimming.

[If --safe mode]: After producing notes for each section, tag each
section's notes with a relevance marker:
  - CORE: Directly relevant to the current research project
  - TANGENTIAL: Adjacent topic, useful for context only
  - OUT-OF-SCOPE: No connection to the project's research scope
Add the tag as the first line of each section's notes block:
  **Relevance: CORE** (or TANGENTIAL or OUT-OF-SCOPE)
""")
```

5. **Read text_notes.md.** This provides the text context that makes visual analysis meaningful.

### STAGE 2: Visual Processing (sonnet — only after text context exists)

Now that we have text notes and know which sections are relevant, scan for visual content and dispatch vision agents.

6. **Spawn the pdf-scanner agent (haiku):**

```
Task(subagent_type="general-purpose", model="haiku", prompt="""
You are the pdf-scanner agent. Read these files and classify each page:

SECTION FILES: [glob sections/sec_*.md — only the sections that passed triage]
METADATA: [path to metadata.json]
PATTERNS: [path to scanner_patterns.json]

Follow the instructions in .claude/agents/pdf-scanner.md.
Produce scan_manifest.json in the output directory.

IMPORTANT: Only scan sections that were sent to the text summarizer.
If default mode filtered out certain sections, do NOT scan those pages
for visual content — they're irrelevant to the project's research scope.
""")
```

7. **Read the scan manifest.** It tells you which pages need vision.

8. **Render pages that need vision** (local, zero tokens):

```bash
python ".claude/skills/cheap-scan1/extract_pdf.py" "INPUT_PDF" "OUTPUT_DIR" --render-pages 8,12,15 --dpi 200
```

Only render pages listed in `routing_summary.table_pages`, `figure_pages`, and `equation_pages`.

9. **Dispatch visual analyzer (sonnet) — for table/figure pages:**

Only if `vision_required_count > 0` in the manifest:

```
Task(subagent_type="general-purpose", model="sonnet", prompt="""
You are the pdf-visual-analyzer agent. Analyze these rendered page images:

PAGE IMAGES: [list page_NN.png files for table/figure pages]
EXTRACTED TEXT (for context): [relevant section files]
TEXT NOTES (for context): OUTPUT_DIR/text_notes.md
SCANNER CONTEXT: [what was detected on each page]

Follow the instructions in .claude/agents/pdf-visual-analyzer.md.
Write output to OUTPUT_DIR/visual_notes.md.
""")
```

10. **Dispatch equation transcriber (sonnet) — for equation pages:**

Only if equation pages were identified:

```
Task(subagent_type="general-purpose", model="sonnet", prompt="""
You are the pdf-equation-transcriber agent. Transcribe these equations to LaTeX:

PAGE IMAGES: [list page_NN.png files for equation pages]
EXTRACTED TEXT (for context): [relevant section files]

Follow the instructions in .claude/agents/pdf-equation-transcriber.md.
Write output to OUTPUT_DIR/equation_notes.md.
""")
```

**Run steps 9 and 10 in parallel** — they're independent. Both only run if the scanner identified pages that need them. Most papers only need the visual analyzer (no separate equation transcription). Many law reviews need neither (zero vision calls).

### STAGE 3: Consolidation (sonnet agent)

11. **Wait for all parallel agents to complete.**

12. **Spawn the pdf-consolidator agent (sonnet):**

```
Task(subagent_type="general-purpose", model="sonnet", prompt="""
You are the pdf-consolidator agent. Merge these specialist outputs into
a single notes.md file:

TEXT NOTES: OUTPUT_DIR/text_notes.md
VISUAL NOTES: OUTPUT_DIR/visual_notes.md (if exists)
EQUATION NOTES: OUTPUT_DIR/equation_notes.md (if exists)
METADATA: OUTPUT_DIR/metadata.json
MODE: [default | safe]

Follow the instructions in .claude/agents/pdf-consolidator.md.
Write the final output to OUTPUT_DIR/notes.md.

[If --safe mode]: The text_notes.md contains per-section relevance tags
(CORE / TANGENTIAL / OUT-OF-SCOPE). Use these to control depth:
  - CORE sections: Full treatment in notes.md (all 8 output sections)
  - TANGENTIAL sections: 1-2 sentence mention in the relevant output section
  - OUT-OF-SCOPE sections: List under a "## Sections Omitted" heading with
    the section name and a 1-line reason. The user can audit these and
    override if any were wrongly classified.

[If default mode]: All section notes are pre-filtered (only relevant sections
were sent to the summarizer). Consolidate everything at full depth.

[Both modes]: If sections were skipped by the triage funnel (default mode)
or tagged OUT-OF-SCOPE (safe mode), add this block at the end of notes.md:

## Triage Log
- **Mode:** [default / safe]
- **Sections read:** [count] of [total]
- **Sections skipped/out-of-scope:** [list with 1-line reasons]
- **Estimated tokens saved by filtering:** ~[calculated vs reading all]
""")
```

13. **Verify output.** Read the `notes.md` and confirm all 8 sections are populated. If any section is empty that shouldn't be, report it.

14. **Clean up temporary files** (optional — keep for debugging):
- `text_notes.md`, `visual_notes.md`, `equation_notes.md` can be kept as intermediate artifacts
- PNG files in `pages/` can be deleted after consolidation (they're large)

15. **Report results:**

For papers that proceed to full processing:
```markdown
### cheap-scan1 complete: [Author (Year)]

**Mode:** [default / safe]
**Triage:** N/5 — [LABEL]
**Pages:** X total, Y text-only, Z visual, W equations
**Sections:** A read of B total [C skipped as out-of-scope]
**Vision calls:** Z+W pages (saved ~X-Z-W pages vs split-pdf)
**Output:** OUTPUT_DIR/notes.md
**Token estimate:** ~[calculated] (vs ~[split-pdf estimate] for split-pdf)
```

For papers eliminated by progressive triage:
```markdown
### cheap-scan1 eliminated: [Author (Year)]

**Eliminated at:** Stage 1[a/b/c] — [abstract/introduction/conclusion]
**Score:** N/5
**Rationale:** [1-2 sentences — scope-based only]
**Tokens spent:** ~[estimate] (vs ~[split-pdf estimate] if fully read)
**Output:** OUTPUT_DIR/notes.md (elimination log only)
```

## Output Directory Structure

```
articles/scanned_smith_2024/
├── extracted_text.md       # Full text (kept for scanner, not sent to agents)
├── metadata.json           # Per-page quality + section map + final section manifest
├── scan_manifest.json      # Scanner's routing decisions
├── notes.md               # ★ FINAL OUTPUT — feeds into lit-filter/lit-synthesizer
├── text_notes.md          # Intermediate: text summarizer output
├── visual_notes.md        # Intermediate: visual analyzer output (if applicable)
├── equation_notes.md      # Intermediate: equation transcriber output (if applicable)
├── sections/              # Per-section markdown files (anti-skimming chunks)
│   ├── sec_01_pp01-02_abstract.md
│   ├── sec_02_pp03-06_background.md
│   ├── sec_02a_pp03-04_background_pt1.md    # Only if section was too long
│   ├── sec_02b_pp05-06_background_pt2.md
│   └── ...
└── pages/                 # Rendered PNGs (only for pages needing vision)
    ├── page_08.png
    └── page_15.png
```

## Fallback Conditions

| Condition | Action |
|-----------|--------|
| `metadata.json` shows `scanned_pdf: true` | Fall back to `/split-pdf` |
| pymupdf not installed | Print install instructions, abort |
| No section headers detected | Extract script uses 4-page chunks (same as split-pdf) |
| Triage score 1 at abstract (default mode) | ELIMINATE — write elimination log, stop |
| Triage score 1–2 after intro+conclusion (default mode) | ELIMINATE — write elimination log, stop |
| Partially relevant paper with TOC (default mode) | Selective section reading — skip irrelevant chapters |
| `--safe` mode | No elimination, all sections read; relevance tags control consolidation depth |
| Scanner finds 0 visual pages | Skip visual analyzer entirely (save sonnet tokens) |
| Scanner finds 0 equation pages | Skip equation transcriber entirely |

## Cost Comparison

### 30-page economics paper

| Component | split-pdf | cheap-scan1 (default) | cheap-scan1 (--safe) |
|-----------|-----------|----------------------|---------------------|
| Reading pages | ~60,000 | 0 (local) | 0 (local) |
| Triage funnel | 0 | ~200-1,600 (1-3 sections) | 0 (skipped) |
| Scanner (haiku) | 0 | ~1,000 | ~1,000 |
| Text to haiku | 0 | ~4,000-6,000 (filtered) | ~6,000 (all sections) |
| Vision on ~5 pages | 0 | ~8,000 | ~8,000 |
| Consolidation | 0 | ~2,500 | ~3,000 (tags → trim) |
| **Total** | **~60,000** | **~16,000-19,000** | **~18,000** |

### 80-page law review (partially relevant)

| Component | split-pdf | cheap-scan1 (default) | cheap-scan1 (--safe) |
|-----------|-----------|----------------------|---------------------|
| Reading pages | ~160,000 | 0 (local) | 0 (local) |
| Triage funnel | 0 | ~1,500 (abstract+intro+conclusion) | 0 (skipped) |
| Scanner (haiku) | 0 | ~600 (relevant sections only) | ~1,000 (all) |
| Text to haiku | 0 | ~8,000-12,000 (selective) | ~25,000 (all) |
| Vision | 0 | 0 (text-only law review) | 0 |
| Consolidation | 0 | ~2,000 | ~2,500 (tags → trim) |
| **Total** | **~160,000** | **~12,000-16,000** | **~28,500** |

### Eliminated paper (clearly irrelevant at abstract)

| Component | split-pdf | cheap-scan1 (default) | cheap-scan1 (--safe) |
|-----------|-----------|----------------------|---------------------|
| **Total** | **~60,000+** | **~200** | **~18,000+** |

**Default mode savings: 73–92%** (depends on paper length and how much is filtered).
**Safe mode savings: 55–82%** (no filtering savings, but still avoids vision tokens).

## Future: Local LLM (not v1)

The architecture supports replacing Stage 2a (haiku text summarizer) with a local LLM (e.g., Ollama with a small model) for zero-token text summarization. This would push savings to 80–90%. Not implemented in v1 — requires testing local model quality first.

## Downstream Compatibility

The final `notes.md` uses the exact same 8-section format as split-pdf. Both `/lit-filter` and `/lit-synthesizer` work with `scanned_*/notes.md` via updated glob patterns.
