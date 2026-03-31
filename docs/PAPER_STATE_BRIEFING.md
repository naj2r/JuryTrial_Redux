# Paper State Briefing: Electoral Incentives and the Jury Pipeline
## For Coauthors Joining Mid-Project
**Date:** 2026-03-27
**Paper:** Jensen & Ammons, "Electoral Incentives and the Jury Pipeline: Evidence from Michigan Prosecutor Elections"

---

## The 60-Second Version

We study whether prosecutor elections affect how capital felony cases are handled in Michigan's 83 counties (2016-2024, excluding COVID years 2020-2021). The answer is yes: during election years, prosecutors dismiss fewer capital felony cases and send more to jury trial. This happens identically whether or not the incumbent faces a challenger. The election calendar itself triggers the behavioral shift, not competitive pressure. Non-capital felonies show zero response.

---

## What Changed Recently (Critical Context)

### Data Source Switch
The SCAO jury utilization dashboard's verdict columns are **broken for 2024** (Power BI uses MIN() instead of SUM() for capital felony counts, reporting 3 statewide vs the correct 431). ALL verdict, plea, and dismissal variables now come from the SCAO **outgoing caseload dashboard**, which reports by case type (FC = Capital Felonies, FH = Non-capital Felonies) at the county-court-year level. Pipeline variables (summoned through utilization rate) are still from the jury dashboard and are correct.

### Framing Shift
- **Old story (DEAD):** "Shadow expansion" -- electoral pressure increases jury mobilization (+195 jurors). This was an artifact of open-seat contamination in the control group.
- **New story:** "Competence maintenance" -- electoral pressure reroutes capital felony dispositions (fewer dismissals, more jury trials). The effect is identical for contested and uncontested elections (Delta near zero on every margin).

### Model Architecture
- **T0 (Benchmark):** County FE only, no year FE. Descriptive. Full panel (83 counties, N=579).
- **T2 (Primary):** County + year FE. 77 synchronized counties, open seats excluded. Two coefficients (contested + uncontested) plus Delta = contested minus uncontested. THIS IS THE MAIN TABLE.
- **T5 (Appendix):** Within-election comparison (incumbent vs open seat). Exploratory only (~26 open-seat obs).

### Why 77 Counties Not 83
Six counties (Allegan, Isabella, Newaygo, Osceola, Roscommon, Delta) hold off-cycle elections (2018 or 2022 instead of the standard presidential cycle). Their asynchronous timing distorts year FE estimation for composition outcomes. The primary specification excludes them. A Wooldridge (2021) timing-group x year FE specification that includes all 83 counties produces identical Delta values, confirming the restriction doesn't drive results.

---

## Headline Results

### From Table 2b (Primary Specification, T2):

| Outcome | Contested | Uncontested | Delta | Interpretation |
|---------|-----------|-------------|-------|----------------|
| FC Dismissal Rate | -0.136*** | -0.137*** | 0.000 (p=.99) | Both election types reduce FC dismissals equally |
| FC Jury Trial Rate | 0.092*** | 0.107*** | -0.015 (null) | Both increase FC jury trials equally |
| FC Plea Share (Adjud.) | -0.101** | -0.116*** | 0.015 (null) | Both reduce FC plea rates equally |
| Severity Share | 0.145** | 0.215*** | -0.070 (null) | Both shift toward FC jury trials |
| FH anything | null | null | null | Non-capital felonies do not respond |

**The key finding: Delta near zero everywhere.** The election cycle drives the behavioral shift, not the presence of a challenger. This distinguishes "competence maintenance" from "voter-directed signaling" (McCannon 2013, 2014).

---

## Current Paper Structure

### Sections with current prose:
| Section | Status | Notes |
|---------|--------|-------|
| 1-introduction | Draft with red placeholders | Rewritten for competence-maintenance framing |
| 2-background | Draft with 16 struck/replaced passages | Old mobilization claims struck, disposition framing inserted |
| 3-data | Partially updated | Caseload dashboard described; summary stats flagged as stale |
| 4-methods | Draft with red placeholders | T0/T2/T5 architecture, Wooldridge timing adjustment |
| 5-results | Draft with red placeholders | Baseline, contestation, falsification, heterogeneity, robustness |
| 6-conclusion | **NOT STARTED** | Needs writing |
| 7-figuresAndTables | Updated | Old tables removed, new tables input'd |
| 8-appendix | Updated | Tables A1-A7 input'd, bootstrap prose, deprecated sections deleted |

### Tables (16 production tables):

**Main paper:**
1. Table 1a: T0 Baseline -- Pipeline + Verdicts
2. Table 1b: T0 Baseline -- Case Disposition
3. Table 2a: T2 Contestation -- Pipeline + Verdicts (PRIMARY)
4. Table 2b: T2 Contestation -- Case Disposition (PRIMARY)
5. Table 4b: Heterogeneity -- Below-Median Population
6. Table 6: Robustness -- 4 sample variants
7. Table 8: Falsification -- Caseload DVs + lead tests

**Reference:**
8. Sample Definitions
9. Summary Statistics

**Appendix:**
- A1: T0 Sensitivity (5 specification variants)
- A2: T2 Off-Cycle Comparison (full vs 77 counties)
- A3: Delta Robustness (3 specifications)
- A4: T5 Within-Election (descriptive)
- A5: Control Sensitivity (4 control sets, 29 outcomes)
- A6: Wild Cluster Bootstrap (null-imposed vs nonull)
- A7: Jackknife Leave-One-County-Out

---

## Key Variables

### Treatment Variables
| Variable | = 1 when | = 0 when |
|----------|----------|----------|
| elec_incumbent | Incumbent running for re-election | Non-election year OR open seat |
| open_pros | Open seat (no incumbent) | Non-election year OR incumbent running |
| treat_pros_contested_long | Incumbent faces general-election challenger | All other obs |
| treat_pros_uncontested | Incumbent runs unopposed | All other obs |

### Outcome Variables (29 total, 5 groups)
- **Pipeline (jury dashboard):** summoned, told_to_report, actually_reported, sent_to_courtroom, questioned_in_voir_dire + their rates + utilization_rate
- **Verdicts (caseload dashboard):** fc_jury, fh_jury, fc_bench, fh_bench, felony_jury_total
- **Pleas/Dismissals (caseload):** fc_plea, fh_plea, fc_dismissed, fh_dismissed
- **Rates (derived):** fc_jury_share, fc_dismiss_rate, fc_plea_share, severity_share, adjudicated shares, FH equivalents

### Non-Negotiable Facts
- FC = Felony Capital (life-sentence-eligible). FH = Felony non-capital.
- 83 counties x 7 years (2016-2019, 2022-2024). COVID 2020-2021 always excluded.
- County-clustered SEs on ALL regressions. No exceptions.
- Never use log outcomes (too many zeros). Levels and shares only.
- Prosecutors do NOT summon jurors. Court administrators do.

---

## What Needs Doing (Your Tasks)

### Task 1: Fix Stale Numbers in Results (HIGH PRIORITY)
`Sections/5-results.tex` lines 21-31 have wrong numbers from old data. Replace with Table 1a/1b values. The domain reviewer report at `quality_reports/domain_review_tables.md` lists every mismatch with line numbers.

### Task 2: Remove Em-Dashes (MEDIUM)
Search for `---` in all `.tex` files under `Sections/`. Replace with commas, semicolons, or periods. Zero em-dashes allowed in the final paper.

### Task 3: Compile Check (MEDIUM)
Open Overleaf, compile, look for `??` (broken refs), red errors, overfull hboxes. Screenshot issues.

### Task 4: Number Cross-Check (MEDIUM)
Every number in the prose must match a table. The domain reviewer found 5+ mismatches. See `quality_reports/domain_review_tables.md` for the full list.

### Task 5: Conclusion Draft (HIGH PRIORITY)
Section 6 is empty. Key points:
1. Election years produce uniform FC disposition shifts (Fewer dismissals, more trials). Delta near zero.
2. Competence maintenance, not voter signaling. Consistent with Hessick (2023) on structural contestation.
3. First paper decomposing disposition pipeline by severity under electoral pressure.
4. Limitations: 2 election cycles, T0 descriptive only, can't distinguish prosecutor strategy from defendant behavior, Michigan single-county system.

### DO NOT TOUCH:
- Any file in `files/tab/paper/` (code-generated tables)
- `.claude/` directory (infrastructure)
- `2-background.tex` (16 replacements already done, pending humanizer)
- Any `\draftnote{}` or `{\color{red}` block (marked for later cleanup)

---

## Reference Documents (in the repo)

| Document | Path | What it contains |
|----------|------|-----------------|
| Study Parameters | `.claude/rules/study-parameters.md` | Treatment definitions, model specs, non-negotiables |
| Variable Codebook | `.claude/rules/variable-codebook.md` | All 29 outcome variables with definitions |
| Domain Review | `quality_reports/domain_review_tables.md` | 21 issues found, 7 critical (number mismatches) |
| Writer-Critic | `quality_reports/writer_critic_intro_results.md` | Prose quality scores (intro 88, results 72) |
| Narrative Review | `quality_reports/narrative_review.md` | Structural issues in paper flow |
| Table Inventory | `quality_reports/table_inventory.md` | All 16 tables with labels and file paths |
| Master Results | `quality_reports/MASTER_RESULTS_SUMMARY.md` | Comprehensive results summary |
| Literature Notes | `master_supporting_docs/scanned_*/text_notes.md` | 12 papers, structured reading notes |
| Session Handoff | Dropbox `results_rebuild/_session_handoff.md` | Full project history and pipeline documentation |
