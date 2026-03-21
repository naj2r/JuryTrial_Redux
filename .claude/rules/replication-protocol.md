---
paths:
  - "**/code/**"
  - "**/scripts/**"
---

# Replication Protocol

**Core principle:** The Stata do-file pipeline is the authoritative source for all empirical results. R scripts supplement but never replace.

## The Pipeline

```
01_{{data_build}}.do       → {{output_panel}}.dta
02_{{import_secondary}}.do → {{secondary_data}}.dta
...
{{NN}}_regressions.do      → regression_results.csv
{{NN}}_tables.do           → .tex tables → Overleaf
```

Customize this pipeline to match your project's do-file structure.

## Rules

1. **Never modify existing do-files without explicit permission** — these are validated
2. **New analysis** goes in new numbered do-files or R scripts
3. **Stata→R translation**: match specification exactly before extending
4. **Verify against CSV**: any R regression must match `regression_results.csv` within tolerance
5. **All paths relative** — no absolute paths in code

## Stata↔R Translation Pitfalls

| Stata | R (fixest) | Trap |
|-------|------------|------|
| `areg y x, absorb(id) vce(cluster id)` | `feols(y ~ x \| id, cluster = ~id)` | df adjustment differs |
| `reghdfe y x, absorb(id year) cluster(id)` | `feols(y ~ x \| id + year, cluster = ~id)` | Check absorb vs interact |
| `esttab` formatting | `modelsummary` formatting | Star thresholds may differ |
| `_b[x]` / `_se[x]` | `coef(m)["x"]` / `se(m)["x"]` | Naming conventions differ |
