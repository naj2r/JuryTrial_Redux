# Tables: No Embedded Titles, No Manual Values

## Hard Rule: Every Table Is Code-Generated

**Every `.tex` file in `Tables/` or `$OL/files/tab/` MUST be produced by a script. No exceptions.**

- If a table exists, there must be a script (R, Stata, Python) that generates it
- The script must write the file directly — never copy-paste values from console output into a `.tex` file
- **Claude NEVER edits table `.tex` files directly.** To change a table, modify the generating script and re-run it. This applies to `08_conference_tables.do` and all supplemental table scripts (10-13).
- To fix a table label, number, or layout: edit the do-file, re-run, verify output
- If `modelsummary` or another package produces incompatible format (e.g., `tabularray`), fix the package settings or write a code-based formatter — do NOT fall back to manually typing values
- Hand-entered coefficient values are a **replication failure** waiting to happen: re-running the script would overwrite them with different formatting, or worse, they silently diverge from updated estimates

### Acceptable Approaches for Table Generation

```r
# Option 1: modelsummary with booktabs output (preferred)
modelsummary(models, output = "Tables/tab_name.tex",
             booktabs = TRUE, escape = FALSE)

# Option 2: etable (fixest built-in)
etable(models, tex.file = "Tables/tab_name.tex",
       style.tex = style.tex("aer"))

# Option 3: Code-based formatter when packages fail
# Write a function that extracts coef/se/stats from model objects
# and formats them into booktabs tabular — still code, not manual
writeLines(format_table(models), "Tables/tab_name.tex")
```

### What Is NOT Acceptable

```r
# ❌ NEVER: Manually type values into a .tex file
# writeLines("0.40*** & 0.32*** & ...", "Tables/tab.tex")

# ❌ NEVER: Copy regression output and hand-format it
# "I'll just type the exact values since I know them"

# ❌ NEVER: Use Write tool to create a .tex table with literal numbers
```

## Applied Micro Table Standard (AER/NBER Convention)

This is the de facto standard in applied economics. All tables MUST follow this unless a target journal's style guide explicitly requires otherwise.

### Overall Structure

- **Coefficients on top, standard errors in parentheses directly below** — never t-stats in parentheses
- **Stars for significance** (`*` p<0.10, `**` p<0.05, `***` p<0.01) — but check target journal style guide; some (AER, QJE) are moving away from stars
- **Panel structure:** columns = models/specifications, rows = variables
- **Variable ordering:**
  1. Main treatment/variable of interest first
  2. Interactions next
  3. Controls after (or omitted with a note)
  4. Constant usually suppressed in FE models

### Bottom-of-Table Rows (Required)

| Row | Content | Format |
|-----|---------|--------|
| Fixed effects | Which FE included | Yes/No or checkmarks |
| Clustering | Level of SE clustering | Text (e.g., "County") |
| Observations | N | Integer |
| R-squared | Within-R² for FE models | 3 decimals |
| Controls | If not shown as rows | "Yes" with note explaining what |
| Sample restrictions | If applicable | Text row (e.g., "Open seats excluded") |

### Formatting Aesthetics (Strict)

- **Three horizontal rules ONLY:** top of table (`\toprule`), below column headers (`\midrule`), bottom (`\bottomrule`)
- **NO vertical lines** — this is the `booktabs` standard, universally adopted in econ
- **Column headers:** `(1)`, `(2)`, `(3)`... with optional second header row for column groups (using `\cmidrule`)
- **Decimal alignment:** use `siunitx` `S` columns or `D{.}{.}{-1}` from `dcolumn` for coefficient alignment
- **Notes section:** below `\bottomrule`, smaller font (`\footnotesize`), explaining sample, specification, and abbreviations

### Table Notes Convention

Notes MUST follow this pattern:

```
Notes: [Sample description]. [Specification description].
Standard errors clustered at [level] in parentheses.
*p<0.10, **p<0.05, ***p<0.01.
```

### LaTeX Implementation

- **`booktabs` + `threeparttable`** is the workhorse combo
- **`siunitx`** for decimal-point alignment when columns contain mixed-precision numbers
- **`esttab`** (Stata) or **`modelsummary`** (R) for programmatic export
- For manual `file write` tables: use `\sym{*}`, `\sym{**}`, `\sym{***}` with the `\def\sym` preamble

### When Outcomes Are Rows (Portrait Tables)

When a table has many outcomes from the same model (e.g., Table 1 with 16 DVs):
- **Outcomes as rows**, coefficient/SE/p/N as columns
- **Panel headers** to group outcome families (e.g., "Panel A: Pipeline Counts")
- **Count outcomes:** 1 decimal place for coefficients and SEs
- **Rate outcomes:** 3 decimal places for coefficients and SEs
- **p-values:** 4 decimal places always

### Caption and Label Placement

Two valid approaches (choose one per project, be consistent):

1. **Caption in the `.tex` file** (current project convention for `14_paper_tables.do`):
   - Generated `.tex` includes `\begin{table}`, `\caption{}`, `\label{}`, `\end{table}`
   - Paper uses `\input{path/to/table.tex}` with no wrapper
   - Advantage: self-contained files, easier to reorder

2. **Caption in the paper** (template default):
   - Generated `.tex` contains only `\begin{tabular}...\end{tabular}`
   - Paper wraps with `\begin{table}`, `\caption{}`, `\label{}`, `\input{}`, `\end{table}`
   - Advantage: captions editable without re-running code

**This project uses approach 1** (self-contained `.tex` files from `14_paper_tables.do`).
