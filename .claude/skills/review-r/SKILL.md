---
name: review-r
description: Code review for R scripts checking reproducibility, correctness, and conventions
disable-model-invocation: true
argument-hint: "[file path to R script or QMD chapter]"
allowed-tools: ["Read", "Grep", "Glob", "Task"]
---

# Review R Code

Run a code review protocol on an R script or QMD chapter.

**Input:** `$ARGUMENTS` — path to `.R` or `.qmd` file.

## Review Dimensions

### 1. Reproducibility
- [ ] `set.seed()` present if any randomness used
- [ ] All paths are absolute or use defined root variable
- [ ] `library()` calls at top (not scattered)
- [ ] No hardcoded values that should be variables
- [ ] Data loading is deterministic (no web scraping without caching)

### 2. Correctness
- [ ] Regression specification matches paper ({{unit_fe}}+{{time_fe}} FE, clustered SEs)
- [ ] Missing value handling is explicit (`na.rm=TRUE` where needed)
- [ ] Joins preserve expected row counts (check for accidental duplication)
- [ ] Factor/character conversions are intentional
- [ ] Variable names match Stata equivalents for cross-verification

### 3. Conventions (from `.claude/rules/stata-r-conventions.md`)
- [ ] `library()` not `require()`
- [ ] `|>` preferred over `%>%`
- [ ] `fixest::feols()` for TWFE
- [ ] `modelsummary` for tables
- [ ] `haven::read_dta()` for Stata files
- [ ] `snake_case` naming
- [ ] Comments explain non-obvious logic

### 4. Quarto-Specific (if .qmd)
- [ ] Every code chunk has a unique `label:`
- [ ] `echo:` and `eval:` set appropriately
- [ ] Table/figure chunks have captions (`tbl-cap:`, `fig-cap:`)
- [ ] Cross-references use `@sec-`, `@tbl-`, `@fig-` syntax
- [ ] No orphaned code chunks (every chunk has surrounding narrative)

## Output

Report by severity (do NOT edit files, report only):
- **Error**: Will produce wrong results or fail to run
- **Warning**: May produce unexpected behavior
- **Style**: Convention violation, should fix for consistency
- **Note**: Suggestion for improvement

Format:
```
[SEVERITY] Line [N]: [Description]
  Found:    [what's there]
  Expected: [what should be there]
```
