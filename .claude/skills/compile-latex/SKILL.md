---
name: compile-latex
description: Verify LaTeX compilation of the Overleaf paper and presentation locally
disable-model-invocation: true
argument-hint: "[main or presentation or both]"
allowed-tools: ["Read", "Grep", "Glob", "Bash", "Task"]
---

# Compile LaTeX

Verify that the Overleaf paper (`main.tex`) and/or presentation (`presentation.tex`) compile without errors.

**Input:** `$ARGUMENTS` — "main", "presentation", or "both".

## Overleaf Project
Path: `$OL/` (defined in CLAUDE.md → Shorthand Paths)

## Paper (main.tex)
Uses natbib + apalike. Compilation sequence:
```bash
cd "$OL"
pdflatex main.tex
bibtex main
pdflatex main.tex
pdflatex main.tex
```
Three passes needed: (1) generate .aux with citation keys, (2) bibtex resolves references, (3+4) resolve cross-references.

## Presentation (presentation.tex)
Beamer document. No bibliography currently active (commented out). Single pass usually sufficient:
```bash
cd "$OL"
pdflatex presentation.tex
```

## After Compilation
1. Check `.log` file for errors (lines containing `!`)
2. Check for warnings: undefined references, missing citations, overfull hboxes
3. Report findings with severity:
   - **Error**: stops compilation (missing files, syntax errors)
   - **Warning**: compiles but output wrong (undefined refs, missing citations)
   - **Info**: cosmetic (overfull hbox, underfull vbox)

## Note
Primary compilation happens on Overleaf's servers via Dropbox sync. This skill is for local verification when needed — e.g., before pushing changes or debugging compilation failures.
