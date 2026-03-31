---
name: insert-tables
description: After Stata/R generates .tex tables, insert \input commands into the correct Overleaf sections
disable-model-invocation: true
argument-hint: "[table file name or 'scan' to find new unlinked tables]"
allowed-tools: ["Read", "Grep", "Glob", "Write", "Edit", "Task"]
---

# Insert Tables

After a Stata or R script generates `.tex` table files in the Overleaf project, this skill:
1. Identifies where the `\input{}` command should go
2. Inserts it in the correct section file
3. Verifies the table file exists and is well-formed

**Input:** `$ARGUMENTS` — table filename (e.g., `table5_new.tex`) or "scan" to find all unlinked tables.

## Overleaf Table Architecture

Tables live in: `$OL/files/tab/`

```
files/tab/
├── {{your_subfolder}}/     ← Main tables from your table do-file
│   ├── table1.tex
│   ├── table2.tex
│   └── ...
└── {{archive_subfolder}}/  ← Older/archived tables
```

## Insertion Points

| Table Type | Insert In | Section |
|-----------|-----------|---------|
| Main tables (1-4) | `Sections/7-figuresAndTables.tex` | After existing tables |
| Appendix tables (A.1+) | `Sections/8-appendix.tex` | After existing appendix tables |
| In-text reference | `Sections/5-results.tex` | Where results are discussed |
| Presentation tables | `presentation.tex` | In relevant `\section{}` |

## For Paper (main.tex)

Tables from `esttab` are COMPLETE — they include `\begin{table}...\end{table}` with caption and label. Do NOT wrap in another table environment.

```latex
% In 7-figuresAndTables.tex:
\input{files/tab/{{subfolder}}/table_new.tex}

% For wide tables (6+ columns):
\begin{landscape}
\input{files/tab/{{subfolder}}/table_wide.tex}
\end{landscape}
```

## For Slides (presentation.tex)

Tables need scaling for Beamer frames:
```latex
\begin{frame}[plain]\frametitle{Table Title}
\scalebox{0.8}{
  \input{files/tab/{{subfolder}}/table_new.tex}
}
\end{frame}
```

## "Scan" Mode

When called with "scan":
1. List all `.tex` files in `files/tab/` subdirectories
2. Grep `7-figuresAndTables.tex`, `8-appendix.tex`, and `presentation.tex` for `\input{files/tab/`
3. Report any `.tex` table files that exist but are NOT referenced anywhere
4. Suggest where each unlinked table should be inserted

## Steps

1. **Verify table file exists** at the expected path
2. **Read the table file** — check for `\begin{table}`, `\caption{}`, `\label{tab:...}`
3. **Determine insertion point** based on table type (main/appendix/slides)
4. **Read the target section file**
5. **Insert `\input{}` command** at the appropriate location with a comment
6. **If results section reference needed**: add `Table \ref{tab:label}` in the narrative
7. **Verify** no duplicate `\input{}` for the same file

## Quality Checks
- [ ] Table file has matching `\begin{table}` / `\end{table}`
- [ ] `\label{tab:...}` is present and unique
- [ ] `\input{}` path is correct relative to main.tex
- [ ] No duplicate insertions
- [ ] For slides: `\scalebox{}` wrapping present
