# Project Paths

## Three Locations

### 1. Repo (Code + Config)
```
C:\Users\jensenn\Research\repos\JuryTrial_Redux
```
Contains: CLAUDE.md, `.claude/` (agents, skills, rules, hooks), `scripts/stata/`, `scripts/R/`, quality reports, templates. This is the git-tracked source of truth for code and infrastructure.

### 2. Dropbox — Working Directory ($RB)
```
C:\Users\jensenn\Dropbox\Research Papers\Jury Trials\master\jury_trial_documentation\Documentation\Michigan_replication_cleaned\results_rebuild
```
Contains: all data files (raw, intermediate, final), result CSVs (`output/results/`), Stata logs, Quarto replication book (`replication_book/`), and the `_session_handoff.md` mirror.

### 3. Overleaf ($OL)
```
C:\Users\jensenn\Dropbox\Apps\Overleaf\Voir Dire 2-20-26
```
Contains: paper `main.tex` + `Sections/*.tex`, generated LaTeX tables (`files/tab/mi_conference/`), bibliography (`main.bib`), preamble, presentation. Syncs via Dropbox.

---

## File Routing Map

| File Type | Authoritative Location | Path |
|-----------|----------------------|------|
| **Stata do-files** | Repo (primary) | `scripts/stata/michigan/*.do` |
| **Stata do-files** | Dropbox (mirror/execution) | `$RB/code/michigan/*.do` |
| **Master scripts** | Repo (primary) | `scripts/stata/master/*.do` |
| **Master scripts** | Dropbox (mirror/execution) | `$RB/code/master/*.do` |
| **R scripts** | Repo | `scripts/R/*.R` |
| **Raw data (.csv, .dta)** | Dropbox ONLY | `$RB/data_raw/michigan/` |
| **Intermediate data** | Dropbox ONLY | `$RB/data_intermediate/michigan/` |
| **Final panels (.dta)** | Dropbox ONLY | `$RB/data_final/` |
| **Result CSVs** | Dropbox | `$RB/output/results/mi_*.csv` |
| **Stata logs** | Dropbox ONLY | `$RB/*.log` |
| **Paper .tex** | Overleaf | `$OL/Sections/*.tex` |
| **Generated tables** | Overleaf | `$OL/files/tab/mi_conference/*.tex` |
| **Bibliography** | Overleaf | `$OL/main.bib` |
| **Quarto book** | Dropbox | `$RB/replication_book/*.qmd` |
| **Quality reports** | Repo | `quality_reports/` |
| **Plans** | Repo | `quality_reports/plans/` |
| **Session logs** | Repo | `quality_reports/session_logs/` |
| **Census data** | Dropbox (external) | `C:\Users\jensenn\Dropbox\Data_research` |

---

## Stata Path Globals (defined in `paths.do`)

| Global | Points To |
|--------|-----------|
| `$ROOT` | `$RB` (project root = results_rebuild) |
| `$DATA_RAW` | `$RB/data_raw/michigan/` |
| `$DATA_INT` | `$RB/data_intermediate/michigan/` |
| `$DATA_FINAL` | `$RB/data_final/` |
| `$OUTPUT` | `$RB/output/` |
| `$CENSUS` | `C:\Users\jensenn\Dropbox\Data_research` |

---

## Sync Rules

1. **Code edits** happen in the repo first, then are synced to Dropbox for execution
2. **Data files** NEVER enter the repo — they are gitignored
3. **Results CSVs** are read from Dropbox — Claude reads them but doesn't copy to repo
4. **Generated tables** go directly to Overleaf (Stata writes to `$OL/files/tab/`)
5. **Quarto book** stays in Dropbox — Claude reads QMDs there for context
6. **Paper prose** lives on Overleaf — manuscript-protection rules apply

---

## Stata Execution

Always use PowerShell batch mode:
```powershell
& "C:\Program Files\StataNow19\StataMP-64.exe" /e do "C:\path\to\file.do"
```
Never run Stata from bash directly. See `.claude/rules/stata-batch-mode.md` for details.
