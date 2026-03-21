---
paths:
  - "Documentation/**/*.do"
  - "Documentation/**/*.R"
  - "Documentation/**/*.qmd"
  - "Documentation/**/*.tex"
  - "Documentation/**/*.bib"
---

# Verification Protocol

**At the end of EVERY task, verify the output works correctly.** This is non-negotiable.

## For Stata Do-Files:
1. Check that the do-file runs without errors (read the log)
2. Verify output datasets exist and have expected dimensions
3. Spot-check coefficient estimates against `{{regression_results_csv}}`
4. Confirm table output matches expected format

## For R Scripts:
1. Run `Rscript path/to/script.R` and check for errors
2. Verify output files (PDF, RDS, CSV) were created with non-zero size
3. Spot-check estimates for reasonable magnitude
4. If translating from Stata, verify against CSV within tolerance

## For Quarto Chapters:
1. Run `quarto render` from $RB/ (or render single chapter)
2. Check for missing cross-references or broken links
3. Verify code chunks execute without errors
4. Check that figures and tables render

## For LaTeX (Overleaf):
1. Verify .tex files are well-formed (balanced braces, no syntax errors)
2. Cross-check citations against bibliographyCiteDrive.bib
3. Confirm table files exist at $OL/files/tab/{{table_subfolder}}/
4. Tables must include: coefficient, SE, N, dep var mean, FE notes, star thresholds

## For BibTeX:
1. Check for duplicate keys
2. Verify required fields (author, title, year, journal/institution)
3. Confirm entry types are natbib-compatible (@article, @book, @techreport, @unpublished, @misc)
4. Check for encoding issues in author names

## Verification Checklist:
```
[ ] Output file(s) created successfully
[ ] No errors in log/console
[ ] Estimates match expectations (direction, magnitude, significance)
[ ] Files are in the correct location
[ ] Reported results to user
```
