---
name: translate-code
description: Translate code between Stata and R with common equivalence patterns
disable-model-invocation: true
argument-hint: "[direction: stata→r or r→stata] [code or file path]"
allowed-tools: ["Read", "Grep", "Glob", "Write", "Edit", "Task"]
---

# Translate Code (Stata ↔ R)

Translate code between Stata and R, using established equivalence patterns for this project.

**Input:** `$ARGUMENTS` — direction (stata→r or r→stata) and either inline code or a file path.

## Core Equivalence Table

### Data Operations

| Task | Stata | R (tidyverse + fixest) |
|------|-------|----------------------|
| Load .dta | `use "file.dta", clear` | `df <- haven::read_dta("file.dta")` |
| Save .dta | `save "file.dta", replace` | `haven::write_dta(df, "file.dta")` |
| Keep vars | `keep var1 var2 var3` | `df <- df |> select(var1, var2, var3)` |
| Drop vars | `drop var1` | `df <- df |> select(-var1)` |
| Rename | `rename old new` | `df <- df |> rename(new = old)` |
| Filter rows | `keep if x > 5` | `df <- df |> filter(x > 5)` |
| Drop rows | `drop if x == .` | `df <- df |> filter(!is.na(x))` |
| Sort | `sort var1 var2` | `df <- df |> arrange(var1, var2)` |
| Generate | `gen newvar = expr` | `df <- df |> mutate(newvar = expr)` |
| Replace | `replace var = x if cond` | `df <- df |> mutate(var = if_else(cond, x, var))` |
| Egen mean | `egen mean_x = mean(x), by(grp)` | `df <- df |> group_by(grp) |> mutate(mean_x = mean(x, na.rm=T))` |
| Collapse | `collapse (mean) x, by(grp)` | `df <- df |> group_by(grp) |> summarise(x = mean(x, na.rm=T))` |
| Merge 1:1 | `merge 1:1 id using "file"` | `df <- left_join(df, df2, by = "id")` |
| Merge m:1 | `merge m:1 grp using "file"` | `df <- left_join(df, df2, by = "grp")` |
| Reshape long | `reshape long stub, i(id) j(time)` | `df <- df |> pivot_longer(...)` |
| Reshape wide | `reshape wide stub, i(id) j(time)` | `df <- df |> pivot_wider(...)` |
| Destring | `destring var, replace` | `df$var <- as.numeric(df$var)` |
| Label var | `label variable x "Label"` | `attr(df$x, "label") <- "Label"` |

### Regression

| Task | Stata | R |
|------|-------|---|
| TWFE | `reghdfe y x, absorb({{unit}} year) vce(cluster {{unit}})` | `feols(y ~ x \| {{unit}} + year, data=df, vcov=~{{unit}})` |
| OLS | `reg y x1 x2, robust` | `feols(y ~ x1 + x2, data=df, vcov="HC1")` |
| Store estimates | `estimates store model1` | `model1 <- feols(...)` |
| Number of obs | `e(N)` | `nobs(model1)` |
| R-squared | `e(r2)` | `r2(model1, type="within")` |
| Predict | `predict yhat` | `df$yhat <- predict(model1)` |

### Table Output

| Task | Stata | R |
|------|-------|---|
| Publication table | `esttab m1 m2 using "file.tex"` | `modelsummary(list(m1, m2), output="file.tex")` |
| Summary stats | `summarize x, detail` | `summary(df$x)` or `skimr::skim(df$x)` |
| Tabulate | `tab var1 var2` | `table(df$var1, df$var2)` or `janitor::tabyl()` |
| Cross-tab | `tabstat y, by(group) stat(mean sd n)` | `df |> group_by(group) |> summarise(...)` |

### Missing Values (CRITICAL DIFFERENCE)

| Behavior | Stata | R |
|----------|-------|---|
| Missing representation | `.` (dot) | `NA` |
| Missing in comparison | `.` > any number (!) | `NA` propagates (returns NA) |
| Guard against | `if !missing(x)` | `if_else(!is.na(x), ...)` |
| Count missing | `count if missing(x)` | `sum(is.na(df$x))` |

**WARNING:** Stata's `if x != 5` evaluates TRUE for missing values because `.` > 5. R's `x != 5` returns NA for missing values. Always guard conditionals explicitly.

### String Operations

| Task | Stata | R |
|------|-------|---|
| Trim whitespace | `strtrim(var)` | `trimws(var)` |
| Upper/lower | `upper(var)` / `lower(var)` | `toupper(var)` / `tolower(var)` |
| Substring | `substr(var, 1, 3)` | `substr(var, 1, 3)` |
| Regex match | `regexm(var, "pattern")` | `grepl("pattern", var)` |
| Replace string | `subinstr(var, "old", "new", .)` | `gsub("old", "new", var)` |

## Translation Process

1. **Read the source code** (Stata or R)
2. **Identify each operation** and find its equivalent in the target language
3. **Handle missing value behavior** differences (this is the #1 source of bugs)
4. **Translate the code** line by line or block by block
5. **Add comments** marking the Stata↔R equivalence for non-obvious translations
6. **Verify:** run both versions on the same data and compare outputs

## Cross-Verification Protocol

After translation, produce a verification table:

```
| Statistic | Stata | R | Diff | Tolerance | Pass? |
|-----------|-------|---|------|-----------|-------|
| N         | {{N}}   | {{N}} | 0  | exact     | ✓     |
| β₁        | {{beta}} | {{beta}} | 0.02 | 0.01 | ✓  |
| SE(β₁)    | {{se}}  | {{se}} | 0.03 | 0.05  | ✓     |
```

Tolerances: point estimates ≤ 0.01, SEs ≤ 0.05, sample sizes exact.
