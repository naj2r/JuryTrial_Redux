# Remaining Work Agenda — 2026-03-26

## Status: Tables 1, 2, 2b, A1, A2 rebuilt with corrected caseload DVs (v4)

---

## PRIORITY 1: Tables Still Needing Rebuild

### Heterogeneity (Population Split)
- [ ] Table 4a/4b: T2 on high-pop vs low-pop subsamples
- [ ] Use corrected caseload DVs (fc_jury_share, severity_share, fc_dismiss_rate)
- [ ] 77 sync counties, open seats dropped, split at median population
- [ ] Need: Contested + Uncontested + Δ for each subsample
- [ ] Key question: does the competence-maintenance mechanism differ by county size?

### Within-Election-Year Model (T5)
- [ ] T5: Y = β * Pressure + county FE + year FE, election years only
- [ ] Rebuild with corrected DVs
- [ ] This is appendix/descriptive — compares incumbent-running to open-seat within election years
- [ ] N ≈ 167 (fragile)

### Robustness Tests Not Yet Updated
- [ ] Leave-one-cycle-out (drop 2016, drop 2024) with corrected DVs
- [ ] Contamination sensitivity (open-seat only vs open-seat + t-1)
- [ ] Jackknife (leave-one-county-out) — from 07h, needs corrected DVs
- [ ] Permutation inference — from 07h, needs corrected DVs
- [ ] Wild cluster bootstrap for T2 headline results (domain reviewer flagged this)

### Falsification
- [ ] Caseload DV (incoming_felony as placebo) — already done in 07d, verify still correct
- [ ] Pre-trend leads/lags — from 07h, verify with corrected panel

---

## PRIORITY 2: Models Needing Review

### T0 (Baseline)
- [x] T0c: county FE, elec_incumbent + open_pros — DONE (v4)
- [x] T0 sensitivity (5 specs) — DONE (v4)
- [ ] Review: does T0 narrative need updating given corrected DVs?

### T2 (Contestation — Main Result)
- [x] Primary: 77 sync counties, TWFE — DONE (v4)
- [x] Δ robustness (3 specs) — DONE (v4)
- [x] Exhaustive full vs no-offcycle — DONE (v4)
- [ ] Add: Wooldridge spec individual coefficients (not just Δ)
- [ ] Add: fc_dismiss_rate headline to main paper Table 2

### T5 (Within-Election)
- [ ] Rebuild entirely with corrected DVs
- [ ] Review whether open_pros collinearity is resolved with augmented panel

---

## PRIORITY 3: Interpretation & Writing

### Competence-Maintenance Mechanism
- [x] Placeholder in Overleaf interpretation section — DONE
- [ ] Expand: formal comparison with McCannon (2013, 2014)
- [ ] Expand: connection to Gordon & Huber (2007) proximity finding
- [ ] Draft: "why Δ ≈ 0 is a finding" paragraph (standalone)
- [ ] Draft: joint significance test results paragraph

### Data Quality Documentation
- [x] 2024 jury dashboard artifact documented in interpretation — DONE
- [ ] Add formal data appendix describing: two SCAO data sources, the MIN() bug, why caseload is authoritative
- [ ] Update data section (3-data.tex) with corrected variable descriptions

### Placeholder Text Cleanup
- [ ] Review all red placeholder paragraphs — which are ready for final prose?
- [ ] Update timestamps on any placeholders with stale numbers

---

## PRIORITY 4: Figures

### Pipeline Funnel Figure
- [ ] Update fig_pipeline_funnel.R with corrected composition numbers
- [ ] Or create new figure: disposition composition (jury vs plea vs dismissed) by election type

### Coefficient Plot
- [ ] Standardized effect sizes (β/σ_w) across all outcomes for T2
- [ ] Side-by-side: contested vs uncontested
- [ ] Visual evidence of Δ ≈ 0 pattern

### Trend Figure
- [ ] Secular trends in FC jury trial rate, dismissal rate, severity share over 2016-2024
- [ ] Motivates the year FE discussion

---

## PRIORITY 5: Quarto Audit Book

- [ ] Update ch 102 (main results) with corrected numbers and new DVs
- [ ] Update ch 103 (heterogeneity) — pending heterogeneity table rebuild
- [ ] Update ch 105 (sensitivity) with timing robustness corrections
- [ ] Add new chapter: data source comparison (jury dashboard vs caseload dashboard)
- [ ] Update ch 107 (corrections audit) with the 2024 data quality finding

---

## PRIORITY 6: Infrastructure & Documentation

- [ ] Update _session_handoff.md with current state
- [ ] Update study-parameters.md with corrected architecture
- [ ] Update MEMORY.md with caseload data learnings
- [ ] Commit all to git, push to remote
- [ ] Export updated xlsx results file with corrected numbers

---

## Key Decisions Still Pending

1. **Main paper table content:** Which outcomes go in main body vs appendix? Current plan: fc_jury_share, severity_share, fc_dismiss_rate + pipeline rates in main; all counts in appendix.

2. **Plea variables:** Include fc_plea_share and fh_plea_share in main tables? They're null but theoretically important (shadow-of-trial predicts they should move).

3. **Wild cluster bootstrap:** Run for all headline results or just T2 Δ? Domain reviewer flagged as Major issue.

4. **Multiple testing:** Run Romano-Wolf on corrected DVs? Previous results didn't survive; unclear if corrected ones will.

5. **T5 model:** Keep in paper or relegate entirely to appendix? It's fragile (N≈167) and descriptive.
