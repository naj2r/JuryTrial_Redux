# Session TODO — 2026-03-26

## Status: END OF SESSION

---

## Completed Today

- [x] Infrastructure setup (36 agents, 36 skills, 10 rules ported)
- [x] Phase 0 label rename (B_midterm → B_no_offcycle)
- [x] Phase 1 code additions (07g closeness, 07h jackknife/permutation/pretrend)
- [x] Data source switch: jury dashboard verdicts → SCAO outgoing caseload dashboard
- [x] Built augmented panel with FC/FH jury/plea/bench/dismissed/case_change variables
- [x] Added adjudicated-share variables (fc_jury_adj_share, fc_plea_adj_share)
- [x] Production tables 1a/1b (T0 baseline, split) — county FE only
- [x] Production tables 2a/2b (T2 contestation, split) — 77 sync counties, TWFE
- [x] Production table A1 (T0 sensitivity, 5 variants T0a-T0e)
- [x] Production table A2 (T2 off-cycle comparison, exhaustive)
- [x] Production table A3 (Δ robustness, moved to appendix — all nulls)
- [x] Timing robustness: Wooldridge (group×year FE), linear trends, pooled
- [x] TWFE weight diagnostics: T2 contested 0/39 negative, uncontested 0.06%
- [x] Introduction rewritten with competence-maintenance framing
- [x] Methods section updated to T0/T2 architecture + Wooldridge
- [x] Results: 5 subsections drafted (baseline, contestation, disposition, falsification, heterogeneity)
- [x] Background: contribution positioning placeholder added
- [x] Data section: disposition data source description added
- [x] 12 papers scanned via cheap-scan1 (text notes in master_supporting_docs/)
- [x] QMD lit review chapter written (97_literature_deep_review.qmd)
- [x] Adversarial reviews run (writer-critic 80/100, narrative-reviewer, McCloskey)
- [x] Fixed framing remnants: 4 "expanded mobilization" claims corrected in background
- [x] Removed AI triplet pattern from disposition section
- [x] Old broken tables commented out in results section

---

## TODO — Next Session

### Priority 1: Fix Remaining Compilation Errors
- [ ] Strike remaining mobilization claims in 2-background.tex (narrative reviewer flagged 4 more)
- [ ] Update testable predictions section — Prediction 1 is wrong (line ~178 of 2-background.tex)
- [ ] Verify Overleaf compiles with 0 errors in main text sections (appendix errors ok for now)

### Priority 2: Regenerate Remaining Tables
- [ ] table4a_het_highpop.tex — heterogeneity with corrected DVs (FC/FH jury/plea/dismiss)
- [ ] table4b_het_lowpop.tex — same
- [ ] table5_contamination.tex — open-seat contamination sensitivity
- [ ] table6_robustness.tex — sample robustness (B vs B_no2016 vs B_no2024)
- [ ] table8_falsification.tex — caseload falsification with corrected DVs
- [ ] All tables need to use augmented panel (michigan_panel_B_augmented.dta)

### Priority 3: Write Conclusion
- [ ] Competence-maintenance framing (not voter-signaling)
- [ ] Severity-selective finding (FC responds, FH does not)
- [ ] Δ ≈ 0 as mechanism discriminator
- [ ] Limitations: 2 election cycles, T0 descriptive only, can't decompose mechanism
- [ ] Policy implications: election structure → case routing → welfare

### Priority 4: Background Section Cleanup
- [ ] Line 55: "Our jury mobilization result fits this pattern" → fix
- [ ] Line 77: "jury mobilization, before jury composition is set" → fix
- [ ] Line 94: "building visible mobilization capacity" → fix
- [ ] Line 103: "expanded jury mobilization" in Priest-Klein → fix
- [ ] Line 112: "shadow expansion" in Munir comparison → fix
- [ ] Lines 141-145: "mobilization effect" and "jury mobilization" → fix
- [ ] Line 178: Prediction 1 says mobilization increases — WRONG, needs rewrite
- [ ] Line 189: "All four predictions find support" — Prediction 1 is NOT supported

### Priority 5: Humanizer Pass
- [ ] Run humanizer on introduction draft blocks
- [ ] Run humanizer on results draft blocks
- [ ] Run humanizer on background contribution placeholder
- [ ] Check for remaining AI patterns (triplets already fixed)

### Priority 6: Quarto Audit Book
- [ ] Update chapters 100-107 to use corrected caseload-sourced variables
- [ ] Add adjudicated-share results to ch 102
- [ ] Re-render full book
- [ ] Verify all R chunks execute

### Priority 7: If Time Permits
- [ ] Wild cluster bootstrap (boottest) for T2 headline results
- [ ] Excel summary workbook update with new variables
- [ ] Abstract rewrite with competence-maintenance framing
- [ ] Update _session_handoff.md in Dropbox with current state

---

## Key Numbers to Remember

| Result | Value | Source |
|--------|-------|--------|
| FC Dismissal Rate (contested) | -0.136*** | Table 2b |
| FC Dismissal Rate (uncontested) | -0.137*** | Table 2b |
| FC Dismissal Rate Δ | 0.000 (p=0.994) | Table 2b |
| FC Jury Trial Rate (contested) | 0.092*** | Table 2b |
| FC Jury Trial Rate (uncontested) | 0.107*** | Table 2b |
| FC Plea Share Adjud. (contested) | -0.101** | Table 2b |
| FC Plea Share Adjud. (uncontested) | -0.116*** | Table 2b |
| FH: all null | — | Table 2b |
| Severity Share Δ | -0.070 (p>0.10) | Table 2b |
| T2 TWFE weights | 0/39 negative (contested) | Diagnostic |
| T0 county FE only | Descriptive benchmark | Table 1a/1b |

---

## Architecture

| Table | Model | FE | Sample | Location |
|-------|-------|----|--------|----------|
| 1a/1b | T0 (elec_incumbent + open_pros) | County only | Full B (579) | Main paper |
| 2a/2b | T2 (contested + uncontested + Δ) | County + Year | 77 sync, open dropped | Main paper |
| A1 | T0 sensitivity (5 variants) | Various | Various | Appendix |
| A2 | T2 off-cycle comparison | County + Year | Full vs no-OC | Appendix |
| A3 | Δ robustness (3 specs) | Various | Various | Appendix |

---

## Files Modified (Overleaf — via Dropbox sync)

- `Sections/1-introduction.tex` — rewritten results/contributions paragraphs
- `Sections/2-background.tex` — contribution positioning + partial mobilization fixes
- `Sections/3-data.tex` — disposition data source description
- `Sections/4-methods.tex` — T0/T2 architecture + Wooldridge
- `Sections/5-results.tex` — 5 subsections drafted, old tables cleaned up
- `files/tab/paper/table1a_baseline_pipeline.tex` — NEW
- `files/tab/paper/table1b_baseline_disposition.tex` — NEW
- `files/tab/paper/table2a_contestation_pipeline.tex` — NEW
- `files/tab/paper/table2b_contestation_disposition.tex` — NEW
- `files/tab/paper/tableA1_t0_sensitivity.tex` — updated
- `files/tab/paper/tableA2_t2_offcycle.tex` — updated
- `files/tab/paper/tableA3_delta_robustness.tex` — NEW (moved from table2b)
