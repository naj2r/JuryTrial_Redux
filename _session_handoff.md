# Session Handoff: Michigan Jury Trial Paper

## 1. Project Overview

This paper (Jensen & Ammons, working title: "Electoral Incentives and the Jury Pipeline: Evidence from Michigan Prosecutor Elections") studies whether electoral pressure on county prosecutors affects jury system utilization. The identification strategy is a two-way fixed effects (TWFE) panel regression exploiting within-county variation across election regimes over time. The unit of observation is the county-year (83 Michigan counties × 7 years: 2016–2019, 2022–2024; COVID years 2020–2021 excluded). Treatment is defined by three mutually exclusive political states: non-election year (omitted), incumbent-running election year (`treat_pros_pressure=1`), and open-seat election year (`open_pros=1`). Key outcome variables fall into five families: jury mobilization counts (summoned, told_to_report, actually_reported, sent_to_courtroom, questioned_in_voir_dire), pipeline utilization rates (pct_told_to_report, pct_sent_to_courtroom, pct_questioned_in_voir_dire, utilization_rate), verdict counts (total_jury_verdicts, capital_felony, other_felony, other_cases), verdict composition shares (pct_capital_felony, pct_other_felony, pct_other_cases), and per-10,000-resident scaled counts. All regressions use county fixed effects, year fixed effects, and county-clustered standard errors (83 clusters).

## 2. Data Pipeline

| File | Purpose | Status |
|------|---------|--------|
| `01_elections_build.do` | Collapse candidate-level election data → district×year treatment panel (747 obs). Creates `treat_pros_pressure`, `open_pros`, `treat_pros_contested_long`, `treat_pros_uncontested`, `treat_pros_contested`, turnover flags. | **Complete.** Needs modification: add closeness variable construction. |
| `02_import_jury_data.do` | Import SCAO jury utilization CSVs → `court_utilization.dta` (1,213 court-year obs). | **Complete.** |
| `03_classify_and_aggregate.do` | Classify courts by type, aggregate to county-year. Produces 5 variant panels (A–E). Top-codes rates at 1.0. | **Complete.** |
| `03b_caseload_build.do` | Build felony caseload panel from SCAO data (83 counties × 20 years = 1,660 obs). Creates incoming_felony, pending_felony, clearance_rate, outgoing_felony. | **Complete.** |
| `03c_plea_composition_build.do` | Build plea/trial disposition data for felony (circuit), misdemeanor (district), and district-felony courts. Creates plea_share, jury_only, jury_share. | **Complete.** Log outcomes removed 2026-03-20. |
| `04_population_build.do` | Build county population panel from Census ACS data. FIPS crosswalk refactored to static reference file. | **Complete.** |
| `05_merge_panels.do` | Merge elections + jury + population → 6 regression-ready panels. | **Complete.** Needs modification: carry closeness variables through merge. |
| `06_scaling.do` | Add per-10,000-resident scaled outcomes to all panels. | **Complete.** |
| `07_regressions.do` | Run all TWFE regressions: T1 (pressure + open_pros), T2 (contested_long + uncontested, open seats excluded), T3 (contested + uncontested, open seats excluded), T4 (per-10k). Variants A/B/C/D/E + court-level + robustness (leave-one-cycle, off-cycle exclusion, population split). | **Complete.** Needs modification: add T0 tier (election-year binary). |
| `07c_tost_and_rwolf.do` | TOST equivalence tests + Romano-Wolf / Bonferroni-Holm multiple testing adjustments. | **Complete.** |
| `07d_caseload_robustness.do` | Caseload falsification (incoming_felony as DV) + congestion control (log_pending as covariate). | **Complete.** |
| `07e_plea_composition.do` | Plea composition regressions across court types (felony, misdemeanor, combined, court-level). | **Complete.** Log outcomes removed 2026-03-20. |
| `07f_plea_fc_fh.do` | FC vs FH plea decomposition with population splits (FC_LARGE, FC_SMALL, FH_LARGE, FH_SMALL). | **Complete.** |
| `07g_closeness_regressions.do` | Closeness/margin interaction regressions. | **New file needed.** |
| `07h_additional_robustness.do` | Jackknife (10 largest counties), placebo permutation (500 iterations), pre-trend diagnostic. | **New file needed.** |
| `08_conference_tables.do` | Generate 20+ LaTeX tables from regression CSVs → Overleaf. Now includes open-seat rows in T1 tables. | **Complete.** Needs label rename (B_midterm → B_no_offcycle). |
| `09_appendix_2016_diagnostic.do` | 2016 cycle-specific diagnostics. | **Complete.** |
| `09b_outlier_robustness.do` | Rate outcome sensitivity: drop/topcode/winsorize observations where pipeline rates exceed 1.0. | **Complete.** |
| `10_capacity_robustness_tables.do` | Capacity/large-county appendix tables. | **Complete.** |
| `11_caseload_tables.do` | Caseload appendix tables (A17–A19). | **Complete.** |
| `12_plea_tables.do` | Plea composition tables. | **Complete.** |
| `13_plea_fc_fh_tables.do` | FC/FH plea tables. | **Complete.** |

## 3. Corrections Applied (2026-03-20)

- **Open-seat baseline contamination fix:** 26 open-seat county-year observations (4.5% of sample) were previously pooled into the control group (pressure=0) for T1 regressions and into the baseline for T2/T3. Open-seat elections have fundamentally different jury patterns than non-election years. **Fix:** T1 now includes `open_pros` as a separate regressor (non-election years are the omitted category). T2/T3 now exclude open-seat observations entirely (`drop if open_pros == 1`). **Impact:** ALL prior positive mobilization results (actually_reported +195, told_to_report +312) were artifacts of this contamination. Verdict suppression effects doubled and gained significance.

- **Log outcome removal:** `03c_plea_composition_build.do` and `07e_plea_composition.do` previously created and regressed on `log_jury_only` and other log-transformed outcomes. Many county-years have zero jury trials, making log transformations inappropriate (ln(0) is undefined; ln(0+1)=0 compresses the distribution). **Fix:** All log outcome variables removed from 03c and 07e. Analysis uses levels and shares only.

- **PPP coding artifact fix:** Three county-years had `contested_primary = 1` incorrectly set for nonpartisan incumbents who appeared on both party ballots (Keweenaw 2024, Montmorency 2020, Montmorency 2024). **Fix:** Added explicit `replace contested_primary = 0` corrections in `01_elections_build.do` (lines 120–150). No effect on regressions (small counties).

## 4. Model/Tier Terminology Map

| Model | Tier Label | Treatment Variable(s) | Omitted Category | Sample Restriction | N (Var B) |
|-------|-----------|----------------------|-----------------|-------------------|-----------|
| Model 0 | T0 | `is_election_year_pros` | Non-election years | Full panel | 579 |
| Model 1 | T1 | `treat_pros_pressure` + `open_pros` | Non-election years | Full panel | 579 |
| Model 2 | T2 | `treat_pros_contested_long` + `treat_pros_uncontested` | Non-election years | Open seats excluded + primary-only contested excluded | ~553 |
| Model 3 | T3 | `treat_pros_contested` + `treat_pros_uncontested` | Non-election years | Open seats excluded | ~553 |
| Model 4 | T4 | `treat_pros_pressure` + `open_pros` | Non-election years | Full panel, per-10k outcomes | 579 |

**Convention:** Use "Model N" when referring to the conceptual specification family (e.g., "Model 2 tests general-election contestation"). Use "TN" when referring to the regression tier label in CSV output (e.g., `tier=="T2_mechanism"`). The mapping is 1:1 — Model 0 = T0, Model 1 = T1, etc.

**T2 vs T3 distinction:** T2 uses `treat_pros_contested_long` (general-election challenges only; primary-only contested county-years are dropped from the sample). T3 uses `treat_pros_contested` (any-stage challenges; primary-only contested are classified as contested). T2 is the primary specification; T3 is classification robustness.

## 5. Key Facts That Must Not Be Gotten Wrong

- **FC = Felony Capital (capital felonies). FH = Felony non-capital (other felonies).** Never guess on these definitions. They come from SCAO case type codes in the outgoing caseload data.

- **`B_midterm` is a misleading label.** It does NOT mean "dropping midterm election years." It means "dropping 2018 and 2022 from the sample." These years contain a handful of off-cycle prosecutor elections (~5 counties in 2018: Allegan, Isabella, Newaygo, Osceola, Roscommon; 1 county in 2022: Delta). **Pending rename to `B_no_offcycle`** to prevent confusion.

- **2018 and 2022 ARE prosecutor election years** for those specific counties. Michigan prosecutors mostly run on the 4-year presidential cycle (2016, 2020, 2024), but some counties have off-cycle elections or special elections. The raw election data contains 9 candidate rows for 2018 and 2 for 2022.

- **`treat_pros_pressure` means "incumbent prosecutor running for re-election."** It does NOT mean "generic electoral pressure." When `pressure=1`, the incumbent is on the ballot. When `pressure=0`, it is either a non-election year or an open-seat election. `open_pros=1` means the seat is open (no incumbent running). These two dummies are mutually exclusive and collectively exhaustive of election years.

- **Never use log outcomes** for jury or plea data. Too many zeros. Use levels and shares only. This is a permanent rule applied 2026-03-20.

- **County-clustered SEs (83 clusters) on ALL regressions.** No exceptions.

- **COVID years 2020–2021 always excluded.** The 2020 election year is dropped, so only 2016 and 2024 election cycles are in the analysis.

- **Rate outcomes (pct_*) are top-coded at 1.0** in `03_classify_and_aggregate.do` before computing `utilization_rate`. This handles fiscal-year timing mismatches in small counties where rates occasionally exceed 1.0.

- **Prosecutors do not summon jurors.** Court administrators do. Prosecutors generate demand signals (by preparing for trial) that administrators respond to. Never write "prosecutors summon jurors" — it is factually wrong.

- **The old mobilization story ("shadow expansion") is dead.** The corrected results show no significant increase in raw juror counts under electoral pressure. The new story is "shadow contraction" — election pressure reduces voir dire utilization rates and suppresses jury verdicts, with contestation adding a capital-felony-specific verdict premium.

## 6. Pending Work

### Phase 0: Fix Misleading Labels
- Rename `B_midterm` → `B_no_offcycle` (and `A_midterm` → `A_no_offcycle`, etc.) in `07_regressions.do`, `08_conference_tables.do`, and all supplemental do-files.
- Add `/* FC = Felony Capital, FH = Felony non-capital */` comment to every do-file that uses these terms.
- Search-and-replace in CSV outputs. Keep old CSVs as backups.
- This is the FIRST task — do it before any other code changes.

### Phase 1: Code Pipeline Modifications
- Add closeness variable construction (`general_closeness`, `primary_closeness`, `max_closeness`) to `01_elections_build.do`. Fill non-election/open/uncontested with 0. Source: logic from `Audit 3-19-26/check_margin_regressions_v2.do`.
- Add closeness vars to keep-list in `05_merge_panels.do`.
- Add T0 tier (election-year binary using `is_election_year_pros`) to `07_regressions.do` inside `run_variant` and `run_court_subsample`.
- Create `07g_closeness_regressions.do` → output `mi_closeness_results.csv`.
- Create `07h_additional_robustness.do` → outputs `mi_jackknife_results.csv`, `mi_permutation_results.csv`, `mi_pretrend_results.csv`. Jackknife: at least 10 largest counties. Permutation: 500 iterations. Pre-trend: exclude prosecutors not seeking re-election at t=0.
- Run full pipeline: master_build_all.do (01–06) → 07 → 07c → 07d → 07e → 07f → 07g → 07h → 09b.
- Verify all topcoding and winsorization is correct. Review audit notes for any remaining impossible values.

### Phase 2: Quarto Master Results Audit Book
- Create 8 new QMD chapters (100–107) in `replication_book/`.
- Add as new `part: "Master Results Audit"` in root `_quarto.yml`.
- All tables populated via R chunks reading CSVs — no hardcoded numbers.
- Chapters: 100 (model architecture), 101 (outcome taxonomy), 102 (main results), 103 (heterogeneity), 104 (supporting/falsification), 105 (sensitivity tests), 106 (multiple testing), 107 (corrections audit trail).

### Phase 3: Table Population
- R code chunks in each QMD read from `output/results/mi_*.csv` files.
- Cross-variant comparison tables, sign-consistency heatmaps, before/after comparison tables.
- Each table must show: coefficient, SE, p-value, adjusted p-value (where applicable), N, sample restriction, FE, omitted category.

### Phase 4: Render and Verify
- `quarto render` from `$RB/` — confirm all R chunks execute.
- Spot-check 10 table values against raw CSV.
- Verify T0 N = 579, closeness coverage, jackknife centering, before/after CSV references.

### Phase 5: Documentation
- Update `quality_reports/specs/2026-03-20_model-specifications-and-results.md` with T0 and closeness results.
- Update MEMORY.md with any new [LEARN] tags.
- Update backmatter chapters (91–95) with session log.
- Update permanent agenda with completed items and new items.

## 7. File Map

### Core Pipeline (code)
| File | Path | Description |
|------|------|-------------|
| `01_elections_build.do` | `$RB/code/michigan/` | Election treatment panel build |
| `02_import_jury_data.do` | `$RB/code/michigan/` | SCAO jury data import |
| `03_classify_and_aggregate.do` | `$RB/code/michigan/` | Court classification + county aggregation (5 variants) |
| `03b_caseload_build.do` | `$RB/code/michigan/` | Caseload panel build |
| `03c_plea_composition_build.do` | `$RB/code/michigan/` | Plea/trial disposition build |
| `04_population_build.do` | `$RB/code/michigan/` | Population panel build (FIPS crosswalk) |
| `05_merge_panels.do` | `$RB/code/michigan/` | Merge all panels → regression-ready datasets |
| `06_scaling.do` | `$RB/code/michigan/` | Per-10k scaling |
| `07_regressions.do` | `$RB/code/michigan/` | Main TWFE regressions (T1–T4, all variants) |
| `07c_tost_and_rwolf.do` | `$RB/code/michigan/` | TOST + multiple testing adjustments |
| `07d_caseload_robustness.do` | `$RB/code/michigan/` | Caseload falsification + congestion control |
| `07e_plea_composition.do` | `$RB/code/michigan/` | Plea composition regressions |
| `07f_plea_fc_fh.do` | `$RB/code/michigan/` | FC vs FH plea decomposition |
| `08_conference_tables.do` | `$RB/code/michigan/` | LaTeX table generation (20+ tables) |
| `09b_outlier_robustness.do` | `$RB/code/michigan/` | Rate outcome outlier sensitivity |

### New Files Needed
| File | Path | Description |
|------|------|-------------|
| `07g_closeness_regressions.do` | `$RB/code/michigan/` | Closeness/margin interaction regressions |
| `07h_additional_robustness.do` | `$RB/code/michigan/` | Jackknife, permutation, pre-trend |
| `100_model_architecture.qmd` | `$RB/replication_book/` | Model definitions chapter |
| `101_outcome_taxonomy.qmd` | `$RB/replication_book/` | Outcome variable definitions |
| `102_main_results.qmd` | `$RB/replication_book/` | Main results by model |
| `103_heterogeneity.qmd` | `$RB/replication_book/` | Population splits + closeness interactions |
| `104_supporting_falsification.qmd` | `$RB/replication_book/` | Caseload falsification + plea composition |
| `105_sensitivity_tests.qmd` | `$RB/replication_book/` | All sensitivity tests |
| `106_multiple_testing.qmd` | `$RB/replication_book/` | Romano-Wolf, BH, TOST |
| `107_corrections_audit.qmd` | `$RB/replication_book/` | Before/after correction comparison |

### Results CSVs
| File | Path | Description |
|------|------|-------------|
| `mi_regression_results.csv` | `$RB/output/results/` | Main results (current, post-correction) |
| `mi_regression_results_BEFORE_openseat_fix.csv` | `$RB/output/results/` | Backup: pre-correction main results |
| `mi_equality_tests.csv` | `$RB/output/results/` | F-tests for β_contested = β_uncontested |
| `mi_caseload_results.csv` | `$RB/output/results/` | Caseload falsification + congestion control |
| `mi_plea_composition_results.csv` | `$RB/output/results/` | Plea composition regressions |
| `mi_plea_fc_fh_results.csv` | `$RB/output/results/` | FC vs FH plea decomposition |
| `mi_tost_tests.csv` | `$RB/output/results/` | TOST equivalence tests |
| `mi_multiple_testing_adj.csv` | `$RB/output/results/` | Bonferroni-Holm adjustments |
| `mi_rwolf_t1_pressure.csv` | `$RB/output/results/` | Romano-Wolf adjusted p-values |
| `mi_reg_robustness_*.csv` | `$RB/output/results/` | Outlier robustness (3 files: drop/topcode/winsor) |
| `mi_closeness_results.csv` | `$RB/output/results/` | **NEW** — closeness interaction results |
| `mi_jackknife_results.csv` | `$RB/output/results/` | **NEW** — leave-one-county-out |
| `mi_permutation_results.csv` | `$RB/output/results/` | **NEW** — placebo permutation |
| `mi_pretrend_results.csv` | `$RB/output/results/` | **NEW** — pre-trend diagnostic |

### Key Reference Documents
| File | Path | Description |
|------|------|-------------|
| `2026-03-20_model-specifications-and-results.md` | `$RB/quality_reports/specs/` | Authoritative model specs + headline results |
| `CLAUDE.md` | `$RB/../../` (project root) | Project rules, agent list, path shortcuts |
| `MEMORY.md` | User's `.claude/` directory | Persistent project memory across sessions |
| `claim-constraints.md` | `$RB/../../.claude/rules/` | Banned phrases, safe anchors, claim classification |
| `study-parameters.md` | `$RB/../../.claude/rules/` | Treatment definitions, headline results, panel structure |

### Path Shortcuts
| Shorthand | Full Path |
|-----------|-----------|
| `$RB` | `C:\Users\jensenn\Dropbox\Research Papers\Jury Trials\master\jury_trial_documentation\Documentation\Michigan_replication_cleaned\results_rebuild` |
| `$OL` | `C:\Users\jensenn\Dropbox\Apps\Overleaf\Voir Dire 2-20-26` |
| Stata | `C:\Program Files\StataNow19\StataMP-64.exe` |

## 8. How to Orient a New Session

**Read these files first (in order):**
1. `CLAUDE.md` — project rules, agent roster, non-negotiables
2. `MEMORY.md` — persistent project memory, key results, corrections
3. This file (`_session_handoff.md`) — current state and pending work
4. `quality_reports/specs/2026-03-20_model-specifications-and-results.md` — authoritative model specs
5. `quality_reports/plans/staged-nibbling-bentley.md` — the full implementation plan

**Verify before touching any code:**
1. Confirm all backup CSVs exist: `ls $RB/output/results/*_BEFORE_openseat_fix*` — there should be ~13 backup files
2. Confirm current regression CSV has the T1 decomposition: `head -5 $RB/output/results/mi_regression_results.csv` — should show `open_pros` as a treatment variable
3. Confirm open seats are excluded from T2: grep for `drop if open_pros` in `07_regressions.do`
4. Confirm log outcomes are removed: grep for `log_jury_only` in `03c_plea_composition_build.do` — should NOT be present

**The first task is Phase 0: Fix misleading labels.** Start with renaming `B_midterm` → `B_no_offcycle` in `07_regressions.do` and propagate to all supplemental files and table generators. This is a search-and-replace operation. Run the full pipeline after to regenerate CSVs with corrected labels. Then proceed to Phase 1 code modifications.

**Stata execution rule:** ALWAYS use the PowerShell batch pattern. Never run Stata from bash directly. See `.claude/rules/stata-batch-mode.md` for the exact command.
