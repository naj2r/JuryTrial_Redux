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

## Formatting Rules

- **Never embed titles in generated `.tex` table files** — no `\caption{}` inside the output from R/Stata
- **Table information goes in two places:**
  1. **File name** — descriptive, e.g., `table2_enrollment_ascm.tex`
  2. **LaTeX `\caption{}`** — added in the paper where the table is `\input{}`'d, not in the generated file
- **Generated `.tex` files contain only the tabular content** — the wrapping `\begin{table}`, `\caption`, and `\label` live in the paper
- **Use `threeparttable`** — wrap tables with `\begin{threeparttable}` for proper alignment of notes via `\begin{tablenotes}`
- **Use `booktabs`** — `\toprule`, `\midrule`, `\bottomrule` only. No vertical lines.
- **Notes live in the paper, not in R output** — `\begin{tablenotes}` content (sample descriptions, variable definitions, significance stars) is written in the paper alongside `\caption` and `\label`
