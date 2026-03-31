---
name: data-analysis
description: End-to-end data analysis in R or Stata — exploration through regression to publication-ready output
disable-model-invocation: true
argument-hint: "[dataset path, analysis goal, or 'stata' / 'R' preference]"
allowed-tools: ["Read", "Grep", "Glob", "Write", "Edit", "Bash", "Task"]
---

# Data Analysis Workflow

Run an end-to-end data analysis: load, explore, analyze, and produce publication-ready output.

**Input:** `$ARGUMENTS` — a dataset path, analysis goal, or language preference.

## Language Selection

- If user says "stata" or "do-file" → write a .do file
- If user says "R" or "Rscript" → write an .R file
- If ambiguous → ask. Default to **Stata for regressions**, **R for visualization**.

## Project Data

| Dataset | Path | Contents |
|---------|------|----------|
| Panel A | `data_final/{{panel_A}}.dta` | {{description}} |
| Panel B | `data_final/{{panel_B}}.dta` | {{description}} |
| Panel C | `data_final/{{panel_C}}.dta` | {{description}} |
| Results CSV | `output/results/{{regression_results}}.csv` | {{description}} |
| Elections | `data_final/{{elections_panel}}.dta` | {{description}} |

## Workflow Phases

### Phase 1: Setup
- Follow conventions in `.claude/rules/stata-r-conventions.md`
- Create script with proper header
- Load data and inspect

### Phase 2: Exploratory Analysis
- Summary statistics, distributions, missingness
- Treatment/control comparisons
- Time trends

### Phase 3: Main Analysis
- **Stata:** `areg` or `reghdfe` with county+year FE, `vce(cluster {{cluster_var}})`
- **R:** `fixest::feols()` with `cluster = ~{{cluster_var}}`
- Start simple, progressively add controls
- Report standardized effects (β/ȳ and β/σ_w)

### Phase 4: Publication-Ready Output
- **Stata:** `esttab` → `.tex` tables
- **R:** `modelsummary` → `.tex` and `.html` tables
- Figures: `ggplot2` with explicit dimensions, export PDF+PNG

### Phase 5: Verify
- Run the code and check for errors
- Cross-check against `{{regression_results}}.csv` if applicable
- Save all outputs to `output/`

## Important

- **New analysis → new numbered do-file (09+)** or script in `scripts/`
- **Never modify 01–08 do-files** without explicit permission
- **All paths relative** to `$RB/`
- **Match existing specifications** before extending
