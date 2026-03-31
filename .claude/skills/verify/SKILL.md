---
name: verify
description: Run verification checks after any code change — NEVER skip this step
disable-model-invocation: true
argument-hint: "[what was just changed — code, tables, .bib, or sections]"
allowed-tools: ["Read", "Grep", "Glob", "Bash", "Edit", "Task"]
---

# Verify

**MANDATORY** post-change verification. Run this after ANY code, table, bibliography, or section modification.

**Input:** `$ARGUMENTS` — what was just changed.

## Why This Exists

> Verification catches: unverified outputs that would deploy with wrong numbers, broken cross-references that silently fail, R scripts with missing terms that produce silently wrong estimates, BibTeX entries that don't resolve, and table files that don't match regression output.

**Rule: If you just changed something, verify it before moving on. No exceptions.**

## Verification Matrix

| What Changed | Verify |
|-------------|--------|
| Stata do-file | Re-run, check log for errors, compare output to prior |
| R script | Run script, check for warnings, compare to Stata output |
| QMD chapter | `quarto render`, check for broken cross-refs |
| LaTeX table (.tex) | Verify `\begin{table}`/`\end{table}` match, `\label{}` present |
| .bib file | Check all `\cite{}` keys resolve, no duplicate keys |
| Overleaf section | Cross-check `\ref{}` targets exist, no undefined commands |
| Presentation slide | Check `\input{}` paths, `\scalebox{}` present for tables |

## Verification Steps

### After Stata Code Change
1. Check log file for `r(...)` error codes
2. Verify output dataset row counts match expectations
3. If tables generated: diff against prior version
4. If regressions: compare key coefficients to `{{regression_results}}.csv`

### After R Code Change
1. Run script end-to-end (no interactive cherry-picking)
2. Check for warnings (especially `NaN`, `NA` coercion)
3. If cross-verifying with Stata: compare within tolerance (β ≤ 0.01, SE ≤ 0.05)

### After QMD Change
1. `quarto render` the book
2. Check render output for warnings
3. Verify cross-references resolve (`@sec-`, `@tbl-`, `@fig-`)

### After .bib Change
1. Grep all `Sections/*.tex` for `\cite{`, `\citep{`, `\citet{`
2. Extract all cited keys
3. Verify every key exists in `.bib`
4. Report any orphaned .bib entries (in .bib but never cited)

### After Overleaf Section Change
1. Check for unbalanced braces
2. Verify all `\ref{}` targets exist
3. Check `\input{}` paths resolve
4. If possible: compile locally to check for errors

## Output

```
VERIFICATION REPORT
===================
Changed: [what was modified]
Checks run: [list]
Status: PASS / FAIL

[If FAIL:]
Issues found:
  1. [Issue with location and severity]
  2. [Issue]

[If PASS:]
All checks passed. Safe to proceed.
```

## Integration with Backmatter

After verification passes, update `94_verification_evidence.qmd` if the check produced notable evidence (new cross-panel comparison, cross-language match, etc.).
