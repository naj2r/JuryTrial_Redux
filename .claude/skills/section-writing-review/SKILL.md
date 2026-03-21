---
name: section-writing-review
description: Run pedagogical compliance audit on any paper section (intro, data, methods, results, conclusion). Generic inquisitor scores against section-specific rubric, clarifier proposes structural revisions, inquisitor re-grades. Output to QMD.
disable-model-invocation: true
argument-hint: "<section> [file path] — e.g., 'data 3-data.tex' or 'results results_draft1.qmd'"
allowed-tools: ["Read", "Grep", "Glob", "Write", "Task", "Edit"]
---

# Section Writing Review

Run a pedagogical compliance audit on any paper section. Uses the adversarial inquisitor→clarifier→inquisitor pattern with the generic `section-inquisitor` and `section-clarifier` agents, loading the appropriate section-specific rubric.

For the **literature review / background** section, use `/lit-writing-review` instead if you have dedicated lit-review agents.

## Arguments

- `<section>` — one of: `intro`, `data`, `methods`, `results`, `conclusion`
- `[file path]` — path to the file containing the section
  - QMD files: `results_draft1.qmd`, etc.
  - Overleaf files: `3-data.tex` (READ-ONLY — output goes to QMD)
- If no file path given, search for the most recent QMD or .tex file for that section

## Rubric Mapping

| Section Argument | Rubric File | Adjacent Sections for Cross-Check |
|-----------------|-------------|-----------------------------------|
| `intro` | `rubric_introduction_section.md` | methods (RQ→spec), results (preview→findings) |
| `data` | `rubric_data_section.md` | methods (variables→equation), results (units consistency) |
| `methods` | `rubric_methods_section.md` | data (variables defined), results (spec matches) |
| `results` | `rubric_results_section.md` | methods (spec promised), conclusion (summary accuracy), intro (preview) |
| `conclusion` | `rubric_conclusion_section.md` | results (no inflation), intro (contributions match) |

**Rubric location:** `$RB/quality_reports/writing_rubrics/` (or wherever your project stores rubric files)

## Workflow

### Step 1: Load Inputs

```
Read [target file]                                                      # Section text
Read [rubric directory]/rubric_[section]_section.md                     # Section rubric
Read .claude/agents/section-inquisitor.md                               # Agent instructions
Read .claude/agents/section-clarifier.md                                # Agent instructions
```

### Step 2: Spawn Inquisitor (Round 1 — haiku)

**Early exit:** If score >= 95, write a brief "passing" note and skip the clarifier.

### Step 3: Spawn Clarifier (Round 1 — sonnet)

Generates suggested revisions for every violation.

### Step 4: Re-Spawn Inquisitor (Round 2 — sonnet)

Evaluates each suggestion AS IF applied.

**If score >= 95:** Go to Step 6.
**If score < 95:** Proceed to Step 5.

### Step 5: Clarifier Round 2 (if needed — opus)

Refines ONLY the REJECTED suggestions. Cap at 2 rounds.

### Step 6: Write Results

Write to: `$RB/quality_reports/drafts/section_revisions/[section]_writing_review.md`

### Step 7: Log

Append to session log.

## Cost Profile

| Scenario | Calls | Models |
|----------|-------|--------|
| Best case (passes Round 1) | 1 | haiku |
| Typical (Round 1 fails, Round 2 passes) | 3 | haiku + sonnet + sonnet |
| Worst case (both rounds fail) | 5 | haiku + sonnet + sonnet + opus + sonnet |

## Key Constraints

- **Manuscript protection applies.** Reads Overleaf files, never writes to them.
- **Cost cap:** Maximum 2 rounds. ~3-5 calls per audit.
- **Separate from McCloskey.** This handles structural compliance; prose quality is a separate pass.
- **Source verification required.** Inquisitor auto-rejects unsourced clarifier suggestions.

## Example Invocations

```
/section-writing-review data 3-data.tex
/section-writing-review methods methods_draft1.qmd
/section-writing-review results 5-results.tex
/section-writing-review conclusion 6-conclusion.tex
/section-writing-review intro 1-introduction.tex
```
