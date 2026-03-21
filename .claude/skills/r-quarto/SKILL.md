---
name: r-quarto
description: Create R scripts and Quarto chapters with executable code chunks and printed output
disable-model-invocation: true
argument-hint: "[task — what the R script or QMD chapter should do]"
allowed-tools: ["Read", "Grep", "Glob", "Write", "Edit", "Bash", "Task"]
---

# R / Quarto Code

Write R scripts or Quarto chapters with code chunks that can execute as part of the Quarto render or at minimum print results and code excerpts.

**Input:** `$ARGUMENTS` — what the R code or QMD chapter should accomplish.

## Two Modes

### Mode 1: Standalone R Script
For analysis scripts that run independently and save output.

**Location:** `$RB/scripts/` or `$RB/code/R/`

**Template:**
```r
#' =============================================================================
#' [script_name].R
#' Purpose:  [What this script does]
#' Input:    [What datasets it reads]
#' Output:   [What it produces]
#' Author:   {{Author}}
#' Date:     [YYYY-MM-DD]
#' =============================================================================

# --- Setup ---
library(tidyverse)
library(fixest)       # for feols() TWFE
library(modelsummary) # for publication tables
library(haven)        # for .dta ↔ R
set.seed(42)

# --- Paths ---
root <- "$RB"
data_final <- file.path(root, "data_final")
output     <- file.path(root, "output")

# --- Load data ---
panel_b <- read_dta(file.path(data_final, "{{panel_filename}}.dta"))

# --- Analysis ---
# [Your code here]

# --- Save output ---
saveRDS(results, file.path(output, "results_name.rds"))
```

### Mode 2: Quarto Chapter (.qmd)
For replication book chapters that document analysis with embedded code and output.

**Location:** `$RB/replication_book/`

**Template:**
```qmd
# Chapter Title

Brief description of what this chapter documents.

## Setup

```{r}
#| label: setup
#| message: false
library(tidyverse)
library(fixest)
library(haven)
library(modelsummary)
library(knitr)

root <- "$RB"
panel_b <- read_dta(file.path(root, "data_final/{{panel_filename}}.dta"))
```

## Analysis Section

Narrative explaining what we're doing and why.

```{r}
#| label: regression-example
#| echo: true
#| eval: true

model <- feols({{outcome}} ~ {{treatment}} |
               {{unit_fe}} + year,
               data = panel_b,
               vcov = ~{{cluster_var}})
summary(model)
```

Interpretation of the results above.

## Key Output

```{r}
#| label: tbl-results
#| tbl-cap: "{{table caption}}"
modelsummary(model,
             stars = c('*' = .1, '**' = .05, '***' = .01),
             gof_omit = "AIC|BIC|Log")
```
```

## R Conventions (from `.claude/rules/stata-r-conventions.md`)

- `library()` never `require()`
- `set.seed(42)` at top of any script using randomness
- `fixest::feols()` for TWFE (mirrors Stata's `reghdfe`)
- `modelsummary` for publication tables (mirrors Stata's `esttab`)
- `haven::read_dta()` / `haven::write_dta()` for Stata interop
- `ggplot2` with explicit `width=` and `height=` in `ggsave()`
- Pipe: `|>` (base R) preferred over `%>%` (magrittr)
- Naming: `snake_case` for variables and functions

## Quarto Chunk Options

| Option | Use |
|--------|-----|
| `echo: true` | Show code in rendered output (default for replication book) |
| `eval: true` | Actually execute the code during render |
| `eval: false` | Print code but don't run it (for documentation/reference) |
| `message: false` | Suppress package loading messages |
| `warning: false` | Suppress warnings in output |
| `label: descriptive-name` | Every chunk gets a unique label |
| `tbl-cap: "Title"` | Caption for table output |
| `fig-cap: "Title"` | Caption for figure output |

## For Backmatter Chapters (91-95)

When writing backmatter audit trail chapters:
- Use `eval: false` for code excerpts that document what was done (not re-run)
- Use `echo: true` so reviewers can see the actual code
- Include output as plain text or screenshots rather than live computation
- Cross-reference other chapters with `@sec-label` syntax

## Steps

1. **Determine mode** — standalone R script or Quarto chapter?
2. **Read existing files** in the target directory for conventions
3. **If Quarto:** read `_quarto.yml` for book structure, check chapter numbering
4. **Draft the code** following the template
5. **For tables going to Overleaf:** use `modelsummary` with `output = "$OL/files/tab/..."` to write `.tex`
6. **Write the file**
7. **If Quarto chapter:** update `_quarto.yml` if adding a new chapter

## Quality Checklist
- [ ] All paths are absolute or use defined root variable
- [ ] `set.seed(42)` if any randomness
- [ ] Every chunk has a unique `label:`
- [ ] Tables use `modelsummary` (not `print()` of raw output)
- [ ] `haven::read_dta()` for loading Stata datasets
- [ ] Variable names match Stata conventions (snake_case)
- [ ] Comments explain non-obvious logic
