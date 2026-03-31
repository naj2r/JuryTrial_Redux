---
name: condense-to-overleaf
description: Proofread Quarto content and condense into Overleaf paper sections
disable-model-invocation: true
argument-hint: "[qmd chapter name or number] → [overleaf section number]"
allowed-tools: ["Read", "Grep", "Glob", "Write", "Edit", "Task"]
---

# Condense to Overleaf

Take detailed Quarto replication book content and produce concise, paper-ready LaTeX for Overleaf sections.

**Input:** `$ARGUMENTS` — e.g., "85_literature_sources → 2-background" or "chapter 70 → 3-data"

## Paths

- **Quarto source:** `$RB/replication_book/`
- **Overleaf target:** `$OL/Sections/`
- **Bibliography:** `$OL/bibliographyCiteDrive.bib`

## Process

### 1. Read the Quarto Source
- Read the full `.qmd` chapter
- Identify all substantive content (skip YAML headers, code chunks, R/Stata output blocks)
- Note any citations used (format: `@key` in QMD → `\cite{key}` or `\citet{key}` in LaTeX)

### 2. Proofread (same standards as /proofread)
- Grammar, spelling, clarity
- Academic writing standards (active voice, precise language)
- Terminology consistency with existing Overleaf sections
- Citation format correctness

### 3. Condense for Paper
- A replication book chapter may be 500-1000 lines; a paper section is 100-200 lines
- Keep: key arguments, empirical claims, theoretical motivation, essential citations
- Remove: exploratory notes, code commentary, debugging sections, verbose data descriptions
- Restructure: replication book is pedagogical; paper is argumentative

### 4. Convert to LaTeX
- QMD markdown → LaTeX formatting
- `**bold**` → `\textbf{}`
- `@cite` → `\cite{}`, `\citet{}`, or `\citep{}` as appropriate
- Tables: reference existing `\input{files/tab/...}` rather than inline
- Equations: preserve or improve LaTeX math formatting
- Cross-refs: use `\ref{tab:...}`, `\ref{fig:...}`, `\ref{section-...}`

### 5. Write to Overleaf Section
- Read the existing Overleaf section first (preserve anything that should stay)
- Write the condensed content
- Ensure it has proper `\section{}`/`\subsection{}` hierarchy
- Add `\label{section-...}` if not present

### 6. Verify
- Check all `\cite{}` keys exist in `bibliographyCiteDrive.bib`
- Check all `\ref{}` labels exist somewhere in the project
- Check no orphaned `\end{}` or unbalanced braces

## Output
- Modified Overleaf section file
- Summary of changes made
- List of any citations that need adding to .bib
