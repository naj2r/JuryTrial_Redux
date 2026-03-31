---
paths:
  - "Documentation/**/code/**"
  - "Documentation/**/scripts/**"
---

# Stata & R Code Conventions

## Stata Conventions

### Script Structure
```stata
capture log close
log using "output/logs/scriptname.log", replace

* ============================================================
* Descriptive Title
* Author: {{Author}}
* Purpose: What this script does
* Inputs: data_final/{{panel_filename}}.dta
* Outputs: output/results/new_results.csv
* ============================================================

* 0. Setup
clear all
set more off
set matsize 10000

* 1. Load Data
use "data_final/{{panel_filename}}.dta", clear

* 2. Analysis
* [code]

* 3. Export
* [code]

log close
```

### Naming
- Variables: `snake_case` (e.g., `{{treatment_var}}`, `{{outcome_var}}`)
- Do-files: `NN_description.do` (e.g., `07_regressions.do`)
- Datasets: `mi_description.dta`
- Output: descriptive filenames in `output/`

### Regression Standards
- Always include: `{{unit_fe}}` and `{{time_fe}}` fixed effects
- Always cluster: `vce(cluster {{cluster_var}})`
- Store with `estimates store` for table output
- Report: coefficient, SE, N, dependent variable mean

## R Conventions

### Script Structure
```r
# ============================================================
# Descriptive Title
# Author: {{Author}}
# Purpose: What this script does
# Inputs: data_final/{{panel_filename}}.dta (via haven::read_dta)
# Outputs: output/figures/figure_name.pdf
# ============================================================

# 0. Setup
library(tidyverse)
library(fixest)
library(haven)
library(modelsummary)

set.seed(42)
dir.create("output/figures", recursive = TRUE, showWarnings = FALSE)

# 1. Load Data
df <- read_dta("data_final/{{panel_filename}}.dta")

# 2. Analysis
m1 <- feols(outcome ~ treatment | {{unit_fe}} + year,
            data = df, cluster = ~{{cluster_var}})

# 3. Output
ggsave("output/figures/figure_name.pdf", width = 8, height = 6)
saveRDS(m1, "output/rds/model_name.rds")
```

### Interoperability
- Read Stata files: `haven::read_dta()`
- Write Stata files: `haven::write_dta()`
- Variable names stay `snake_case` across both languages
- Factor variables in R = labeled values in Stata
