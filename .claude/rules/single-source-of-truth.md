# Single Source of Truth

## Authoritative Sources

| Domain | Authoritative File | Derived From It |
|--------|-------------------|-----------------|
| Regression estimates | `code/{{regressions}}.do` → `regression_results.csv` | All tables, paper text |
| LaTeX tables | `code/{{tables}}.do` → `.tex` files | Overleaf paper |
| Treatment definitions | `code/{{data_build}}.do` | Everything downstream |
| Data pipeline | Do-files (sequential) | All analysis |
| Paper text | `$OL/Sections/*.tex` | N/A (final output) |
| Bibliography | `$OL/bibliography.bib` | Paper citations |
| Replication docs | `replication_book/*.qmd` | Rendered Quarto book |

## Conflict Resolution

If a table in the paper doesn't match the CSV, the **CSV is correct** (it comes from the do-file).
If a QMD chapter contradicts a do-file, the **do-file is correct**.
If the paper narrative contradicts regression output, **fix the narrative**.

## Bibliography Source Chain

```
Source .bib files / PDF extractions / web searches
    ↓
$OL/bibliography.bib              (SINGLE SOURCE for the paper)
```

The Overleaf .bib is the only file the paper reads. All other .bib files are source material.
