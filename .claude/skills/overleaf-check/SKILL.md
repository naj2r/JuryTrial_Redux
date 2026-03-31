---
name: overleaf-check
description: Verify Overleaf project compiles cleanly — check .bib, .tex cross-refs, and formatting
disable-model-invocation: true
argument-hint: "[optional: specific section or 'full']"
allowed-tools: ["Read", "Grep", "Glob", "Write", "Edit", "Task"]
---

# Overleaf Compilation Check

Verify the Overleaf project at `$OL/` compiles without errors.

**Input:** `$ARGUMENTS` — optional section name (e.g., "5-results") or "full" for everything.

## Overleaf Architecture

```
main.tex
├── preamble.tex (packages: natbib, booktabs, hyperref, graphicx, placeins, pdflscape)
├── titlepageThesis.tex
├── Sections/1-introduction.tex
├── Sections/2-background.tex
├── Sections/3-data.tex
├── Sections/4-methods.tex
├── Sections/5-results.tex
├── Sections/6-conclusion.tex
├── bibliographyCiteDrive.bib        ← natbib + apalike
├── Sections/7-figuresAndTables.tex  ← \input{files/tab/...} for main tables
└── Sections/8-appendix.tex          ← Appendix tables
```

## Checks

### 1. Bibliography Integrity
- Read `bibliographyCiteDrive.bib` and verify:
  - All entries use natbib-compatible types: `@article`, `@book`, `@techreport`, `@unpublished`, `@misc`, `@inproceedings`, `@incollection`
  - NO `@report` (use `@techreport`), NO `@online` (use `@misc`)
  - Every entry has required fields (author, title, year minimum)
  - Key format: `authorYYYYdescriptor`
  - No duplicate keys
- Grep all `Sections/*.tex` for `\cite`, `\citep`, `\citet` commands
- Cross-reference: every cited key exists in .bib, every .bib key is cited somewhere

### 2. Table File References
- Grep `7-figuresAndTables.tex` and `8-appendix.tex` for `\input{files/tab/...}`
- Verify each referenced `.tex` file exists at the path
- Check each table file for:
  - Matching `\begin{table}` / `\end{table}`
  - `\label{tab:...}` present
  - `\sym` command used (already defined in preamble and in table files)

### 3. Cross-References
- Grep all Sections/ for `\ref{...}` and `\label{...}`
- Flag any `\ref` that doesn't have a matching `\label`
- Flag any `\label` that is never `\ref`'d (warning only)

### 4. LaTeX Syntax
- Check for unbalanced braces in each Sections/ file
- Check for undefined commands (anything not in preamble.tex)
- Check for common errors: `\being` (typo), orphaned `\end`, double `$$`

### 5. Content Consistency
- Verify section numbers in main.tex match file naming (1- through 8-)
- Check that `\graphicspath{{./files/}}` matches actual figure locations
- Verify `\tablepath` macro matches actual table locations

## Output

Save report to `quality_reports/overleaf_check_[date].md` with:
- Pass/Fail for each check category
- List of all issues found with severity (Error/Warning/Info)
- Missing citations list
- Orphaned bibliography entries list
- Suggested fixes for all errors
