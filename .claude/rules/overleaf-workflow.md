# Overleaf Writing Workflow

Applies when working on any file in the Overleaf directory or writing paper content.

## Two-Layer Architecture

| Layer | Purpose | Location |
|-------|---------|----------|
| **Quarto book** | Internal: full methodology, code, documentation | `$RB/replication_book/*.qmd` |
| **Overleaf paper** | External: paper draft for distribution | `$OL/main.tex` + `Sections/` |
| **Overleaf slides** | External: Beamer presentation | `$OL/presentation.tex` |
| **Quarto slides** | Alternative: multi-format slides (RevealJS + Beamer) | `Quarto/conference/*.qmd` |

## Slide Workflows (Choose One)

| Approach | Source | Outputs | When to Use |
|----------|--------|---------|-------------|
| **Option A: Pure Beamer** | `$OL/presentation.tex` | PDF only | Full LaTeX control, Overleaf-only |
| **Option B: Quarto multi-format** | `Quarto/conference/*.qmd` | RevealJS HTML + Beamer PDF | Web + PDF from one source |

Option B details: see `.claude/rules/quarto-presentation-pipeline.md`
Template: `templates/quarto-presentation/`

## Content Flow
```
Quarto book (detailed internals) → proofread & condense → Overleaf Sections/ (paper)
                                                        → presentation.tex (slides, Option A)
                                                        → Quarto/conference/*.qmd (slides, Option B)
Stata esttab → files/tab/{{subfolder}}/*.tex → \input{} in paper + slides
bibliography.bib ← single source for paper + Quarto book + slides
```

## Table Pipeline (Stata → Overleaf)
1. Table do-file runs `esttab` → complete `.tex` table files
2. Output lands in `$OL/files/tab/{{subfolder}}/` via Dropbox sync
3. Paper: `\input{files/tab/{{subfolder}}/table1.tex}`
4. Slides: `\scalebox{0.8}{\input{files/tab/{{subfolder}}/table1.tex}}`
5. R equivalent: `modelsummary` or `stargazer` can produce identical `.tex`

## Section Writing Status
| Section | Status | Next Action |
|---------|--------|-------------|
| 1-introduction | {{status}} | {{next action}} |
| 2-background | {{status}} | {{next action}} |
| 3-data | {{status}} | {{next action}} |
| 4-methods | {{status}} | {{next action}} |
| 5-results | {{status}} | {{next action}} |
| 6-conclusion | {{status}} | {{next action}} |
| 7-figuresAndTables | {{status}} | {{next action}} |
| 8-appendix | {{status}} | {{next action}} |

## Overleaf Compilation

Overleaf compiles via cloud. Tables sync via Dropbox. No local compilation needed unless testing offline.

## natbib Compatibility

Entry types must be natbib-compatible: `@article`, `@book`, `@techreport`, `@unpublished`, `@misc`, `@incollection`. Change any `@report` to `@techreport`.
