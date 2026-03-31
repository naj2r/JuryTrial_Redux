---
name: stata-code
description: Write native Stata do-files following project conventions and pipeline structure
disable-model-invocation: true
argument-hint: "[task description — what the do-file should accomplish]"
allowed-tools: ["Read", "Grep", "Glob", "Write", "Edit", "Bash", "Task"]
---

# Stata Code

Write production-quality Stata do-files following this project's established conventions.

**Input:** `$ARGUMENTS` — what the do-file should accomplish.

## Project Context

- Do-files live in `$RB/code/` (organized by topic or state)
- Numbered sequentially: customize to your pipeline
- Path globals defined in `code/master/paths.do` ($RB, $OL, $DATA, $OUTPUT, $TABLES)
- Analysis globals in `code/master/globals.do` (treatment variable names, panel names)

## Do-File Template

Every do-file MUST follow this structure:

```stata
/*==============================================================================
 [NN]_[description].do
 Purpose:  [What this script does]
 Input:    [What datasets/files it reads]
 Output:   [What datasets/files it creates]
 Author:   {{Author}}
 Date:     [YYYY-MM-DD]
==============================================================================*/

// --- Bootstrap (allows standalone execution) ---
capture log close
if "$RB" == "" {
    do "{{absolute/path/to}}/code/master/paths.do"
    do "{{absolute/path/to}}/code/master/globals.do"
}
log using "$OUTPUT/logs/[NN]_[description].log", replace

// --- Main code ---

// [Your code here]

// --- Cleanup ---
log close
```

## Stata Conventions (from `.claude/rules/stata-r-conventions.md`)

### Commands
- `reghdfe` for TWFE: `reghdfe depvar treatvar, absorb(unit_id year) vce(cluster unit_id)`
- `esttab` for table output → `.tex` files
- `destring` after replacing `"NA"` → `""`
- `egen` for group operations, `bysort` for within-group
- `preserve`/`restore` to protect data in memory
- `assert` for data validation (panel balance, treatment identities)

### Naming
- Variables: `snake_case` (e.g., `treatment_var`, `outcome_var`)
- Estimate stores: ≤32 characters (Stata limit)
- Labels: descriptive, used in table output
- Tempvars: `tempvar` / `tempfile` — never leave temporary objects behind

### Table Output (esttab)
```stata
esttab model1 model2 model3 using "$TABLES/$TABLE_SUB/table_name.tex", ///
    replace booktabs ///
    cells(b(star fmt(1)) se(par fmt(1))) ///
    star(* 0.10 ** 0.05 *** 0.01) ///
    stats(N r2_within ymean, fmt(0 3 1) ///
          labels("Observations" "R-squared (within)" "Dep. var. mean")) ///
    mtitles("(1)" "(2)" "(3)") ///
    label
```

### Output Paths
- Tables for paper: `$TABLES/$TABLE_SUB/` (defined in paths.do / globals.do)
- Raw data: `$DATA_RAW/`
- Final data: `$DATA/`
- Logs: `$OUTPUT/logs/`
- Figures: `$OUTPUT/figures/`

## Steps

1. **Read existing do-files** to understand patterns and conventions
2. **Read `paths.do` and `globals.do`** to get available globals
3. **Draft the do-file** following the template above
4. **Include assertions** for data validation (row counts, variable ranges, treatment identities)
5. **Write the file** to the appropriate location
6. **If the do-file produces tables**: verify `esttab` output format matches existing tables

## Quality Checklist
- [ ] Bootstrap preamble present (standalone execution works)
- [ ] `log using` / `log close` wrapping
- [ ] All paths use globals ($RB, $DATA, $TABLES, etc.)
- [ ] Treatment variable names match globals.do
- [ ] Clustering matches study-parameters.md specification
- [ ] Estimate store names ≤ 32 characters
- [ ] Assert statements for data validation
- [ ] Comments explain non-obvious logic
