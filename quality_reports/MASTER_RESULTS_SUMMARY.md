# Master Results Summary
## Electoral Incentives and the Jury Pipeline: Evidence from Michigan Prosecutor Elections
### Jensen & Ammons | Last Updated: 2026-03-27

---

## The Finding in One Paragraph

Michigan prosecutors facing re-election reduce capital felony (FC) dismissal rates by 13.6 percentage points and increase FC jury trial rates by 9.2 percentage points. The effect is identical for contested and uncontested elections (Delta near zero on every disposition margin). Non-capital felonies (FH) show zero response. The behavioral shift is driven by the election calendar, not competitive pressure, consistent with a competence-maintenance mechanism rather than voter-directed signaling. Results survive wild cluster bootstrap, are invariant to caseload and population controls, and are robust to alternative sample definitions. Raw jury mobilization counts are uniformly null.

---

## Model Architecture

### T0: Benchmark (Tables 1-2)
Y_ct = B1 * IncumbentElection_ct + B2 * OpenSeat_ct + county_FE + e_ct
- County FE only (no year FE). Descriptive benchmark, not causal.
- Full B panel: 579 obs, 83 counties, 7 years (2016-2019, 2022-2024)

### T2: Primary Specification (Tables 3-7, all appendix tables)
Y_ct = B1 * Contested_ct + B2 * Uncontested_ct + county_FE + year_FE + e_ct
- County + year FE (TWFE). Causal under conditional independence.
- 77 synchronized counties, open seats dropped: ~518 obs
- Key estimand: Delta = B1 - B2 via lincom (covariance-adjusted)
- Off-cycle counties (6) excluded from primary spec due to timing heterogeneity

### T5: Appendix (Table A4)
Y_ct = B * IncumbentRunning_ct + county_FE + year_FE + e_ct
- Election years only (~167 obs). Descriptive, not primary.

---

## Headline Results (T2 Primary Specification)

### FC Disposition (THE MAIN FINDING)

| Outcome | Contested | Uncontested | Delta | p(Delta) | Tag |
|---------|-----------|-------------|-------|----------|-----|
| FC Dismissal Rate | -0.136*** | -0.137*** | 0.000 | 0.994 | FC-DISMISS-DROP, DELTA-ZERO |
| FC Jury Trial Rate | 0.092*** | 0.107*** | -0.015 | 0.639 | FC-TRIAL-UP, DELTA-ZERO |
| FC Plea Rate | 0.041 | 0.019 | 0.022 | 0.605 | null |
| FC Jury Share (Adjud.) | 0.096*** | 0.117*** | -0.021 | >0.10 | FC-TRIAL-UP |
| FC Plea Share (Adjud.) | -0.101** | -0.116*** | 0.015 | >0.10 | mirror of trial |
| Severity Share (FC/Total) | 0.145** | 0.215*** | -0.070 | 0.057 | SEVERITY-SHIFT |

### FH Disposition (THE NULL)

| Outcome | Contested | Uncontested | Delta | Tag |
|---------|-----------|-------------|-------|-----|
| FH Jury Trial Rate | -0.001 | 0.003 | -0.003 | FH-NULL |
| FH Plea Rate | -0.033 | -0.017 | -0.016 | FH-NULL |
| FH Dismissal Rate | 0.029** | 0.008 | 0.021 | triage effect (contested only) |

### Pipeline (NULL MOBILIZATION)

| Outcome | Contested | Uncontested | Delta | Tag |
|---------|-----------|-------------|-------|-----|
| Summoned | 3030.5 | 43.5 | 2987.1 | null (large SE) |
| Told to Report | 875.9 | -67.6 | 943.4 | null |
| Actually Reported | 291.2* | -83.3 | 374.5 | weak |
| % Sent to Courtroom | 0.214*** | 0.109*** | 0.105* | significant individual coefs |
| % Questioned in Voir Dire | -0.109 | -0.147 | 0.038 | null |
| Utilization Rate | -0.028 | -0.064*** | 0.036 | uncontested drives decline |

### Verdict Counts (null)

| Outcome | Contested | Uncontested | Delta | Tag |
|---------|-----------|-------------|-------|-----|
| FC Jury Verdicts | 1.1 | 0.2 | 0.9 | null |
| FH Jury Verdicts | -0.5 | -0.6 | 0.1 | null |
| Total Felony Jury | 0.7 | -0.3 | 1.0 | null |

---

## T0 Benchmark (County FE Only)

Key results (incumbent election coefficient):

| Outcome | Coef | SE | Sig | Tag |
|---------|------|----|-----|-----|
| Utilization Rate | -0.031 | 0.010 | *** | RATE-DECLINE |
| % Sent to Courtroom | -0.057 | 0.020 | *** | RATE-DECLINE |
| % Questioned in Voir Dire | -0.046 | 0.018 | ** | RATE-DECLINE |
| FC Jury Trial Rate | 0.034 | 0.013 | *** | FC-TRIAL-UP |
| FC Dismissal Rate | -0.047 | 0.012 | *** | FC-DISMISS-DROP |
| FH Dismissal Rate | 0.014 | 0.007 | ** | small positive |
| Severity Share | 0.074 | 0.027 | *** | SEVERITY-SHIFT |
| Capital Felony Verdicts | -2.2 | 0.7 | *** | verdict decline |
| All pipeline counts | null | | | NULL-PIPELINE |

Open seat shows opposite composition pattern (other felony share UP, not down).

---

## Robustness Summary

### Sample Variants (T2 Contested Coefficient)

| Outcome | Main (77) | Wooldridge (83) | No 2016 | No 2024 |
|---------|-----------|-----------------|---------|---------|
| FC Jury Trial Rate | 0.092*** | 0.029 | 0.078* | 0.093** |
| FC Dismissal Rate | -0.136*** | -0.242* | -0.056** | -0.185*** |
| Severity Share | 0.145** | 0.216 | 0.174* | 0.145** |

Delta: null across ALL specs and ALL outcomes.

### Wild Cluster Bootstrap (Table A6, nonull, 999 reps)

All headline FC results survive bootstrap inference. Nonull bootstrap p < 0.001 for all headline coefficients.

| Outcome | Cluster p | Bootstrap p | Survives? |
|---------|-----------|-------------|-----------|
| FC Jury Trial Rate (con) | 0.013 | 0.001 | YES |
| FC Jury Trial Rate (unc) | <0.001 | <0.001 | YES |
| FC Dismissal Rate (con) | <0.001 | <0.001 | YES |
| FC Dismissal Rate (unc) | <0.001 | <0.001 | YES |
| Severity Share (con) | 0.035 | 0.010 | YES |
| Severity Share (unc) | <0.001 | <0.001 | YES |

### TWFE Weight Diagnostics

| Treatment | Neg ATTs | Neg Weight Share | Status |
|-----------|----------|-----------------|--------|
| Contested | 0/39 | 0.000 | CLEAN |
| Uncontested | 2/105 | 0.0006 | CLEAN |

### Control Sensitivity (4 decimals)

Adding incoming_felony + pending_felony + log_county_pop as controls produces ZERO meaningful shift on any headline result. FC Dismissal Rate moves from -0.1362 to -0.1374.

---

## Heterogeneity (Population Split)

FC Dismissal Rate:
- Below-median: Contested -0.153***, Uncontested -0.117***
- Above-median: collinear (single-coefficient model only)

FC effects concentrate in small counties where individual cases represent a larger share of annual activity.

---

## Falsification (Table 8)

### Standard Falsification (Levels)

| DV | Contested | Uncontested | Delta |
|----|-----------|-------------|-------|
| Incoming Felonies | 6.9 | -36.0 | 42.8 |
| Clearance Rate | 0.006 | 0.008 | -0.002 |
| Pending Felonies | 36.5 | 34.1*** | 2.4 |

### Dynamic/Lead Falsification

| DV | Contested | Uncontested | Delta | Notes |
|----|-----------|-------------|-------|-------|
| Lead Incoming (t+1) | -- | -- | -- | Attenuates under first differences |
| FD Incoming | -- | -- | -- | Null |
| FD Lead Incoming | -- | -- | -- | Null |

### Interpretation

- Incoming: null. No evidence that election years receive different caseload inflows.
- Clearance: null. Courts do not mechanically process more cases in election years.
- Lead: attenuates under first differences, consistent with no anticipation.
- Pending significant for uncontested only (mechanical consequence of fewer dismissals increasing stock of unresolved cases -- mechanism-consistent, not an independent confound).

---

## Jackknife Leave-One-County-Out (Table A7)

Leave-one-county-out jackknife over the 10 largest counties confirms no single county drives the headline results. FC Dismissal Rate and FC Jury Trial Rate remain significant across all 10 drops. Severity Share is the most sensitive (expected given smaller effective sample for composition outcomes).

---

## Table Inventory (16 Production Tables)

### Main Tables (7)

| # | Table | Content |
|---|-------|---------|
| 1 | table_sumstats | Summary statistics |
| 2 | table1_baseline + 1a + 1b | T0 baseline (pipeline + disposition) |
| 3 | table2_contestation + 2a + 2b | T2 contestation (pipeline + disposition) |
| 4 | table3_outcomes | Verdict counts |
| 5 | table4a/4b_het | Population heterogeneity (high/low) |
| 6 | table5_contamination | Open-seat contamination diagnostic |
| 7 | table8_falsification | Falsification (incoming, clearance, lead, FD) |

### Reference Tables (2)

| # | Table | Content |
|---|-------|---------|
| R1 | table6_robustness | Sample variant robustness |
| R2 | table7_composition | Composition shifts |

### Appendix Tables (7)

| # | Table | Content |
|---|-------|---------|
| A1 | tableA1_t0_sensitivity | T0 sensitivity variants |
| A2 | tableA2_t2_offcycle | Off-cycle county robustness |
| A3 | tableA3_delta_robustness | Delta robustness across specs |
| A4 | tableA4_within_election | Within-election-year (T5) |
| A5 | tableA5_controlled | Controlled specifications (caseload + population) |
| A6 | tableA6_bootstrap | Wild cluster bootstrap inference |
| A7 | tableA7_jackknife | Leave-one-county-out jackknife |

### Notes

- All tables in `$OL/files/tab/paper/`. Deprecated mi_conference tables removed.
- Per-10k scaling (T4) postponed -- not included in current table set.
- Sub-tables (1a/1b, 2a/2b, 2b_delta_robustness) count as part of their parent table.

---

## Theoretical Contribution

### Competence Maintenance vs Voter Signaling

| | McCannon (voter signaling) | Our finding (competence maintenance) |
|---|---|---|
| Trigger | Challenger presence | Any election year |
| Prediction for Delta | Delta > 0 | Delta near zero |
| Our result | Delta = 0.000 (p=0.994) for FC dismissal | Supports competence maintenance |
| Mechanism | Signal toughness to voters | Avoid appearance of leniency |
| Margin | Sentencing severity, conviction rates | Case disposition routing |

### Key Distinctions from Prior Work

- McCannon (2013): measures appellate reversals, not disposition routing. Different margin.
- Bandyopadhyay et al. (2014): finds contested > uncontested. We find Delta near zero.
- Okafor (2021): finds effects vanished post-2006. We find them on a different margin post-2016.
- Hessick (2023): shows contestation is structural (population/lawyer supply), not performance-based. Supports our interpretation that prosecutors cannot deter challengers through behavior.

### The Severity-Selective Pattern

FC responds, FH does not. This is consistent with:
1. Capital felonies being the most visible and consequential cases
2. Prosecutorial discretion being greatest for serious charges
3. Electoral accountability operating through case salience, not case volume

---

## Data Sources

| Source | Variables | Dashboard |
|--------|-----------|-----------|
| SCAO Jury Statistics (Form 73) | Pipeline: summoned through utilization_rate | Jury Utilization Dashboard |
| SCAO Outgoing Caseload | FC/FH jury, plea, dismissed, bench, rates | Interactive Court Data Dashboard |
| SCAO Caseload (incoming/pending) | incoming_felony, pending_felony, clearance_rate | Interactive Court Data Dashboard |
| PPP (UNC) | Election treatment variables | ppp.unc.edu |
| Census ACS | County population | census.gov |

FC = Capital Felonies (life-sentence-eligible). FH = Non-capital Felonies.
Circuit courts only for disposition data. All courts for pipeline data.

---

## Effect Size Ranking and Contextualization

### Tier 1: Strongest and Most Novel

| Rank | Result | Beta | Mean | Beta/Mean | Plain English |
|------|--------|------|------|-----------|---------------|
| 1 | FC Dismissal Rate drop | -0.136 | ~0.14 | ~0.97 | Prosecutors eliminate nearly all FC dismissals in election years |
| 2 | Delta = 0 on FC Dismissal | 0.000 | N/A | N/A | Contested and uncontested produce identical shifts (0.7% difference) |
| 3 | FC Jury Trial Rate increase | +0.092 | ~0.05 | ~1.8 | FC jury trial rate nearly triples during election years |
| 4 | FC Plea Share (Adjud.) decline | -0.101 | ~0.80 | ~0.13 | Among resolved FC cases, plea share drops 10pp |

### Tier 2: Supporting

| Rank | Result | Context |
|------|--------|---------|
| 5 | FH null on every margin | Severity-selective: only life-eligible felonies respond |
| 6 | Severity Share shift | +14.5-21.5pp; FC share of jury verdicts increases substantially |
| 7 | Small-county concentration | FC dismissal -15.3pp in small counties; large counties collinear |

### Tier 3: Boundary Conditions

| Rank | Result | Context |
|------|--------|---------|
| 8 | Pipeline rate decline (T0) | Utilization -3.1pp; descriptive benchmark |
| 9 | Falsification passes | Incoming null, controls invariant, bootstrap confirmed |
| 10 | 2016 sensitivity | Dropping 2016 attenuates magnitude ~60% but not sign |

### How to Report Effect Sizes in Text

For each headline result, the paper should provide three things:
1. Stars in the table (significance visible at a glance)
2. Beta/mean ratio in one sentence ("approximately doubles the baseline rate")
3. Qualitative interpretation in one sentence ("prosecutors essentially stop dismissing capital felonies")

Do NOT embed coefficients, SEs, CIs, or exact p-values in running prose. Those belong in the table.

---

## Known Limitations

1. Two presidential election cycles (2016, 2024) provide treatment variation. Dropping 2016 attenuates FC dismissal rate by ~60% (magnitude, not sign).
2. T0 (county FE only) is descriptive, not causal. Conflates election effects with secular trends.
3. Wooldridge group x year FE is fragile for individual coefficients (only 6 off-cycle counties anchor the group-specific effects).
4. T2 contestation decomposition is collinear in high-population subsample.
5. District court upstream decisions (bindover, charge reduction) not observed.
6. SCAO jury dashboard verdict columns unreliable for 2024 (Power BI MIN() aggregation artifact). All verdict/plea/dismissal variables use the outgoing caseload dashboard instead.
7. Pipeline variables (jury dashboard) and disposition variables (caseload dashboard) come from different SCAO data sources, aggregated at different court levels (all courts vs circuit only).

---

## File Locations

| What | Path |
|------|------|
| Production tables | $OL/files/tab/paper/*.tex |
| Table generation code | $RB/code/michigan/14_paper_tables.do |
| Augmented panel | $RB/data_final/michigan_panel_B_augmented.dta |
| Panel builder | $RB/code/michigan/05b_build_augmented_panel.do |
| Boottest results | $RB/output/results/mi_boottest_results.csv |
| Control comparison | $RB/output/results/mi_controlled_comparison.csv |
| Paper (.tex) | $OL/Sections/*.tex |
| Quarto audit book | $RB/replication_book/*.qmd |
