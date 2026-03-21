# Plan: JuryTrial_Redux Repo Setup & Consolidation

**Status:** DRAFT
**Date:** 2026-03-21
**Goal:** Set up the JuryTrial_Redux repo as the working project hub by filling in CLAUDE.md, creating path mappings, porting infrastructure from the template repo, copying code files from Dropbox, and creating study-parameters.md.

---

## Context

The JuryTrial_Redux repo currently contains the **clo-author template** infrastructure (agents, skills, rules, hooks) but with unfilled placeholders in CLAUDE.md and no project-specific content. The actual research work lives in a Dropbox directory (`$RB`). The paper is on Overleaf (`$OL`). We need to:

1. Customize the template for this specific project
2. Port additional infrastructure from the upstream template repo
3. Copy code files (Stata .do files, R scripts) into the repo
4. Create path mapping documentation
5. Create study-parameters.md with verified claims
6. Ensure the repo and Dropbox can function as complementary sources of truth

**Key constraints:**
- Large files (data, logs, rendered books) stay in Dropbox. Only code, markdown, and config files go in the repo.
- CLAUDE.md must stay under 150 lines (it's loaded every session — keep it lean).
- Any template identity info (Emory, specific domains) is placeholder — user's institution is Wabash College.

---

## Phase A: Fill in CLAUDE.md (project-specific customization)

**File:** `CLAUDE.md` (root)

Replace all `[BRACKETED PLACEHOLDERS]`:
- **Project:** Electoral Incentives and the Jury Pipeline: Evidence from Michigan Prosecutor Elections
- **Institution:** Wabash College
- **Branch:** main
- **Folder structure:** Update to reflect actual layout (scripts/stata/ instead of scripts/R/, add Overleaf path reference)
- **Commands:** Add Stata batch execution command (PowerShell pattern from `.claude/rules/stata-batch-mode.md` if it exists, or from handoff doc)
- **Beamer environments:** TBD (check Overleaf presentation.tex)
- **Current Project State:** Paper=draft (on Overleaf), Data=complete (in Dropbox), Replication=in-progress, Talks=not started
- **Domain Profile:** Fill in `domain-profile.md` — Primary field: Political Economy / Law & Economics; Adjacent: Public, Labor, Criminal Justice
- **CLAUDE.md length:** Must stay under 150 lines. Move verbose content to rules files instead of CLAUDE.md.

---

## Phase B: Create Path Configuration Files

### B1: `_paths.md` (root) — Path mapping reference

Documents the relationship between three locations:
- **Repo:** `C:\Users\jensenn\Research\repos\JuryTrial_Redux\`
- **Dropbox ($RB):** `C:\Users\jensenn\Dropbox\Research Papers\Jury Trials\master\jury_trial_documentation\Documentation\Michigan_replication_cleaned\results_rebuild\`
- **Overleaf ($OL):** `C:\Users\jensenn\Dropbox\Apps\Overleaf\Voir Dire 2-20-26\`

Include a mapping table showing which content lives where and the authoritative source for each.

### B2: `.claude/rules/path-config.md` — Rule for Claude to follow

A rule file that tells Claude where to look for different file types:
- Code files (.do, .R): `scripts/stata/michigan/` in repo (primary), `$RB/code/michigan/` in Dropbox (mirror)
- Data files (.dta, .csv raw): Dropbox only, never in repo
- Result CSVs: `$RB/output/results/` in Dropbox
- Paper .tex: `$OL/Sections/` on Overleaf
- Quarto book: `$RB/replication_book/` in Dropbox
- Tables (.tex generated): `$OL/files/tab/` on Overleaf
- Quality reports: `quality_reports/` in repo

---

## Phase C: Copy Code Files into Repo

### C1: Stata do-files → `scripts/stata/michigan/`

Copy from `$RB/code/michigan/`:
- 01_elections_build.do through 13_plea_fc_fh_tables.do (all production pipeline files)
- master_build_all.do, globals.do, paths.do from `$RB/code/master/`

Copy from `$RB/Audit 3-19-26/`:
- Key audit .do files (selective — only the ones referenced in handoff doc)

### C2: R scripts → `scripts/R/`

Copy from `$RB/scripts/`:
- fig_pipeline_funnel.R
- heterogeneity_plots.R

### C3: Key QMD files → reference only (stay in Dropbox)

QMD files and the Quarto book stay in Dropbox per user instruction. The path-config.md rule points Claude to them.

---

## Phase D: Create study-parameters.md

**File:** `.claude/rules/study-parameters.md`

Source from `_session_handoff.md` sections 4-7, verified against Overleaf `4-methods.tex`. Contains:

### Verified claims (21-27 from our analysis):
- "Shadow expansion" story is dead — corrected results show no significant mobilization increase
- New story: "shadow contraction" — election pressure reduces voir dire utilization, suppresses verdicts
- Contestation adds capital-felony-specific verdict premium
- All results re-estimated with corrected baseline (open seats modeled separately)
- Prior contaminated baselines replaced
- Mobilization effects null, verdict suppression strengthens

### Non-negotiable facts (from handoff Section 5):
- FC = Felony Capital, FH = Felony non-capital
- `B_midterm` label is misleading (pending rename to `B_no_offcycle`)
- `treat_pros_pressure` = incumbent running for re-election (not "generic pressure")
- Never use log outcomes for jury/plea data
- County-clustered SEs (83 clusters) on ALL regressions
- COVID years 2020-2021 always excluded
- Rate outcomes top-coded at 1.0
- Prosecutors do NOT summon jurors

### Treatment/Model definitions (from handoff Section 4):
- Model 0 (T0): election-year binary
- Model 1 (T1): pressure + open_pros vs non-election
- Model 2 (T2): contested_long + uncontested (open excluded, primary-only excluded)
- Model 3 (T3): contested + uncontested (open excluded)
- Model 4 (T4): per-10k scaling

### Pre-correction claims (1-20) flagged as UNVERIFIED:
- All specific coefficient values from Overleaf results section need re-running
- Will be verified after Phase 0 (label rename) and full pipeline re-run

---

## Phase E: Port Infrastructure from Template Repo

Source: `https://github.com/naj2r/claude-econ-paper-template/tree/master/.claude/`

### E1: Agents to port (up to 20 new — already have 18 locally)

**Prose quality:**
- mccloskey-critic.md, mccloskey-fixer.md — McCloskey rhetoric review
- narrative-factcheck.md, narrative-factcheck-fixer.md — Claims vs evidence
- narrative-reviewer.md — Narrative quality
- manuscript-critic.md — Full manuscript review
- proofreader.md — Grammar/typo check

**Literature:**
- lit-review-clarifier.md, lit-review-inquisitor.md — Lit review depth
- literature-organizer.md — Reference organization
- section-clarifier.md, section-inquisitor.md — Section-level Q&A

**Compression/consolidation triad:**
- compressor-critic.md, compressor-fixer.md — Context compression
- consolidator-critic.md, consolidator-fixer.md — Output consolidation

**Code review:**
- stata-reviewer.md — Stata-specific code review
- r-reviewer.md — R-specific code review
- table-auditor.md — Table verification

**PDF pipeline (cheap-scan1 sub-agents):**
- pdf-auditor.md, pdf-consolidator.md, pdf-equation-transcriber.md
- pdf-fixer.md, pdf-scanner.md, pdf-text-summarizer.md, pdf-visual-analyzer.md

**Quarto/slides:**
- quarto-auditor.md, quarto-fixer.md — Quarto QA
- slide-auditor.md, tikz-reviewer.md — Presentation review
- domain-reviewer.md — Domain-specific slide review

**Other:**
- bib-checker.md, bib-fixer.md — Bibliography management
- codevolution.md — Code evolution tracking
- organizer.md — General organization
- session-logger.md — Session logging

### E2: Skills to port (up to 26 new — already have 11 locally)

**High priority (directly useful for this project):**
- stata-code — Stata code generation/review
- compile-latex — LaTeX compilation
- validate-bib — Bibliography validation
- insert-tables — Insert generated tables into Overleaf
- overleaf-check — Verify Overleaf sync
- proofread — Manuscript proofreading
- verify — Compilation/output verification
- session-log — Session logging
- context-status — Context window status
- learn — Save [LEARN] entries

**Medium priority (useful but not immediate):**
- commit — Git commit workflow
- consolidate — Output consolidation
- condense-to-overleaf — Compress content for Overleaf
- review-paper — Paper review
- review-r — R code review
- own-writing-check — Self-review of writing
- draft-slop-fixer — Clean up AI-sounding prose
- mccloskey-prose-edit — Rhetoric editing
- section-writing-review — Section-level review
- devils-advocate — Adversarial review
- lit-review — Literature review
- lit-organizer — Bibliography organization
- research-ideation — Research idea generation
- interview-me — Requirements elicitation

**Lower priority (presentation/advanced):**
- build-slides — Beamer slide generation
- slide-excellence — Slide quality audit
- visual-audit — Visual review
- qa-quarto — Quarto QA
- quarto-warnings — Quarto warning resolution
- r-quarto — R+Quarto integration
- render-pdf — PDF rendering
- split-pdf — PDF splitting
- translate-code — Cross-language code translation
- data-analysis — Data analysis workflow
- codevolution — Code evolution tracking
- stenographer — Action recording

### E3: Rules to port (12 new — already have 16 locally)

- compression-triad.md — Context compression protocols
- exploration-folder-protocol.md — Sandbox folder rules
- incremental-documentation.md — Doc update triggers
- overleaf-workflow.md — **CRITICAL** Overleaf integration rules
- path-config.md — **CRITICAL** Path configuration (will customize for this project)
- quarto-presentation-pipeline.md — Quarto slide pipeline
- quarto-workflow.md — Quarto book conventions
- replication-protocol.md — Replication package standards
- single-source-of-truth.md — Authoritative source rules
- stata-r-conventions.md — **CRITICAL** Stata/R coding standards
- study-parameters.md — **CRITICAL** Study-specific parameters (will customize)
- verification-protocol.md — Verification checklist

### E4: Hooks to port (2 new)

- context_recovery.py — SessionStart hook for context recovery
- manuscript_protection.py — PreToolUse hook for manuscript protection

**Porting strategy:** Fetch each file from GitHub raw URL, write to local `.claude/` directory. For path-config.md and study-parameters.md, customize with project-specific content rather than using the template verbatim.

---

## Phase F: Create _session_handoff.md in Repo

Copy `$RB/_session_handoff.md` into repo root, updating paths to reference repo-local scripts where applicable. This becomes the authoritative handoff document.

---

## Phase G: Update MEMORY.md

Add project-specific `[LEARN]` entries:
- `[LEARN:project] Shadow expansion story dead → shadow contraction is current framing`
- `[LEARN:project] Overleaf results section contains pre-correction numbers (claims 1-20) — need re-verification`
- `[LEARN:project] Three locations: repo (code+config), Dropbox (data+results+book), Overleaf (paper)`
- `[LEARN:data] Never use log outcomes for jury/plea data — too many zeros`

---

## Execution Order

### Batch 1 (parallel — no dependencies)
1. **Phase A** — Fill in CLAUDE.md with project info
2. **Phase B** — Create `_paths.md` + `.claude/rules/path-config.md`
3. **Phase D** — Create `.claude/rules/study-parameters.md` (present claims to user for verification)

### Batch 2 (after Batch 1)
4. **Phase C** — Copy code files (Stata .do files → `scripts/stata/michigan/`, R → `scripts/R/`)
5. **Phase E** — Port template infrastructure (fetch from GitHub, write locally)
   - E3 rules first (especially path-config, overleaf-workflow, stata-r-conventions)
   - E1 agents next (batch by category — prose, code review, PDF, quarto)
   - E2 skills next (high-priority first)
   - E4 hooks last

### Batch 3 (after Batch 2)
6. **Phase F** — Copy `_session_handoff.md` into repo root
7. **Phase G** — Update MEMORY.md with project-specific entries
8. **Phase H** — Fill in `domain-profile.md` with political economy / law & economics profile
9. **Update .gitignore** — Ensure data files, logs, and large outputs are excluded

### Batch 4 (verification)
10. Verify all files present, no placeholders remain
11. `git status` to confirm clean staging
12. Present summary of what was done + what's next (Phase 0: label rename)

---

## Key Decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Code file location in repo | `scripts/stata/michigan/` + `scripts/stata/master/` | Template convention; clear language separation |
| Data stays in Dropbox | Yes | Too large for git; .gitignore enforces |
| Quarto book stays in Dropbox | Yes per user instruction | Path-config.md points Claude there |
| Paper lives on Overleaf | Yes | Syncs via Dropbox; path-config.md has `$OL` |
| study-parameters.md claims | 21-27 verified; 1-20 flagged UNVERIFIED | User confirmed |

---

## Verification

- [ ] CLAUDE.md has no remaining `[BRACKETED PLACEHOLDERS]`
- [ ] `_paths.md` correctly maps all three locations (repo, Dropbox, Overleaf)
- [ ] `.claude/rules/path-config.md` exists with correct paths
- [ ] `.claude/rules/study-parameters.md` exists with verified + flagged claims
- [ ] `.claude/rules/domain-profile.md` filled in for political economy
- [ ] All .do files from `$RB/code/michigan/` copied to `scripts/stata/michigan/`
- [ ] Master .do files from `$RB/code/master/` copied to `scripts/stata/master/`
- [ ] R scripts copied to `scripts/R/`
- [ ] Template repo agents ported to `.claude/agents/`
- [ ] Template repo skills ported to `.claude/skills/`
- [ ] Template repo rules ported to `.claude/rules/`
- [ ] Template repo hooks ported to `.claude/hooks/`
- [ ] `_session_handoff.md` in repo root
- [ ] MEMORY.md updated with project-specific entries
- [ ] `.gitignore` excludes data, logs, .dta, large CSVs
- [ ] `git status` shows all new files ready to commit
