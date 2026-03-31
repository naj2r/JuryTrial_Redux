---
name: validate-bib
description: Cross-reference citations in paper against bibliography. Find missing entries, unused refs, and quality issues.
allowed-tools: ["Read", "Grep", "Glob"]
---

# Validate Bibliography

Cross-reference all citations in the paper against the bibliography file.

## Files to Scan

**Bibliography:**
`$OL/bibliographyCiteDrive.bib`

**Paper sections:**
`$OL/Sections/*.tex`

**Quarto chapters (secondary):**
`$RB/replication_book/*.qmd`

## Steps

1. **Read the bibliography file** and extract all citation keys

2. **Scan all paper files for citation commands:**
   - `.tex` files: `\cite{`, `\citet{`, `\citep{`, `\citeauthor{`, `\citeyear{`
   - `.qmd` files: `@key`, `[@key]`, `[@key1; @key2]`

3. **Cross-reference:**
   - **Missing entries:** Citations used but NOT in bibliography (CRITICAL)
   - **Unused entries:** Entries in bibliography not cited anywhere (informational)
   - **Potential typos:** Similar-but-not-matching keys (WARNING)

4. **Check entry quality** for each bib entry:
   - Required fields present (author, title, year, journal/institution)
   - Entry type is natbib-compatible (@article, @book, @techreport, @unpublished, @misc)
   - No `@report` entries (natbib doesn't support — use `@techreport`)
   - Author field properly formatted
   - DOIs included where possible

5. **Report findings** organized by severity
