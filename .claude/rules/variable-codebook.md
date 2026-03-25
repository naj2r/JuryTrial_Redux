# Variable Codebook — Michigan Jury Trial Paper

**This file is the authoritative reference for all outcome variables in the augmented panel.**
**Source:** `michigan_panel_B_augmented.dta` (built by `05b_build_augmented_panel.do`)

---

## Data Sources

| Source | Dashboard | Variables | Reliable? |
|--------|-----------|-----------|-----------|
| SCAO Jury Statistics (Form 73) | Jury Utilization Dashboard | Pipeline: summoned → utilization_rate | ✅ Yes |
| SCAO Outgoing Caseload | Interactive Court Data Dashboard | Verdicts, pleas, dismissals by FC/FH | ✅ Yes |
| SCAO Jury Dashboard (verdict cols) | Jury Utilization Dashboard | capital_felony, other_felony, other_cases | ❌ BROKEN for 2024 — DROPPED |

**Rule:** Pipeline variables (Group 1-2) come from the jury dashboard. ALL verdict/plea/dismissal variables (Groups 3-5) come from the caseload dashboard. Never mix.

---

## Group 1: Pipeline Counts (5 variables) — Jury Dashboard

| Variable | Label | Source | N (typical) | Notes |
|----------|-------|--------|-------------|-------|
| `summoned` | Jurors summoned for service | SCAO 73 | 579 | Annual pool assembled by court admin |
| `told_to_report` | Jurors told to report | SCAO 73 | 579 | Subset of summoned who receive report date |
| `actually_reported` | Jurors who actually reported | SCAO 73 | 579 | Subset who showed up |
| `sent_to_courtroom` | Jurors sent to a courtroom | SCAO 73 | 579 | Assigned to a specific trial |
| `questioned_in_voir_dire` | Jurors questioned in voir dire | SCAO 73 | 579 | Entered jury selection process |

**Pipeline flow:** summoned ⊇ told_to_report ⊇ actually_reported ⊇ sent_to_courtroom ⊇ questioned_in_voir_dire

---

## Group 2: Pipeline Rates (4 variables) — Jury Dashboard

| Variable | Label | Formula | Notes |
|----------|-------|---------|-------|
| `pct_told_to_report` | % Told to Report | told_to_report / summoned | Top-coded at 1.0 |
| `pct_sent_to_courtroom` | % Sent to Courtroom | sent_to_courtroom / actually_reported | Note: denominator is actually_reported, NOT told_to_report. Top-coded at 1.0. |
| `pct_questioned_in_voir_dire` | % Questioned in Voir Dire | questioned_in_voir_dire / sent_to_courtroom | Top-coded at 1.0 |
| `utilization_rate` | Utilization Rate | pct_told_to_report × pct_sent_to_courtroom × pct_questioned_in_voir_dire | Multiplicative composite. NOT end-to-end (questioned/summoned). The product telescopes as: (told/summoned) × (sent/actually_reported) × (questioned/sent) — note the gap between told_to_report and actually_reported in the chain. |

---

## Group 3: Verdict/Trial Counts (5 variables) — Caseload Dashboard

| Variable | Label | Case Types | Notes |
|----------|-------|------------|-------|
| `fc_jury` | FC Jury Verdicts | FC - Capital Felonies | Life-offense-eligible, circuit court |
| `fh_jury` | FH Jury Verdicts | FH - Non-capital Felonies | Other felonies, circuit court |
| `fc_bench` | FC Bench Verdicts | FC | Judge trial, no jury |
| `fh_bench` | FH Bench Verdicts | FH | Judge trial, no jury |
| `felony_jury_total` | Total Felony Jury Verdicts | fc_jury + fh_jury | Replaces deprecated `total_jury_verdicts` |

**FC = Felony Capital (life-sentence-eligible). FH = Felony non-capital. From SCAO case type codes.**

---

## Group 4: Plea/Dismissal Counts (4 variables) — Caseload Dashboard

| Variable | Label | Disposition Method | Notes |
|----------|-------|--------------------|-------|
| `fc_plea` | FC Guilty Pleas | Guilty Plea + Guilty Plea/Admission | Combined both plea categories |
| `fh_plea` | FH Guilty Pleas | Same | Combined |
| `fc_dismissed` | FC Dismissed (Prosecutorial) | Dismissed by Party | NOT Dismissed by Court (judicial) |
| `fh_dismissed` | FH Dismissed (Prosecutorial) | Same | NOT Dismissed by Court |

---

## Group 5: Disposition Rates & Composition (11 variables) — Derived

### Total-disposition denominator (includes dismissals)

| Variable | Formula | Interpretation |
|----------|---------|----------------|
| `fc_jury_share` | fc_jury / fc_total_disp | FC jury trial rate among ALL resolved FC cases |
| `fh_jury_share` | fh_jury / fh_total_disp | FH jury trial rate |
| `fc_plea_share` | fc_plea / fc_total_disp | FC plea rate |
| `fh_plea_share` | fh_plea / fh_total_disp | FH plea rate |
| `fc_dismiss_rate` | fc_dismissed / fc_total_disp | FC prosecutorial dismissal rate |
| `fh_dismiss_rate` | fh_dismissed / fh_total_disp | FH prosecutorial dismissal rate |
| `severity_share` | fc_jury / felony_jury_total | Capital share of ALL felony jury verdicts |

### Adjudicated-only denominator (excludes dismissals)

| Variable | Formula | Interpretation |
|----------|---------|----------------|
| `fc_jury_adj_share` | fc_jury / (fc_jury + fc_bench + fc_plea) | FC jury trial rate among RESOLVED (non-dismissed) cases |
| `fc_plea_adj_share` | fc_plea / (fc_jury + fc_bench + fc_plea) | FC plea rate among resolved cases |
| `fh_jury_adj_share` | fh_jury / (fh_jury + fh_bench + fh_plea) | FH jury trial rate among resolved cases |
| `fh_plea_adj_share` | fh_plea / (fh_jury + fh_bench + fh_plea) | FH plea rate among resolved cases |

**Why two denominators:** The total-disposition rates answer "what share of ALL FC cases go to jury?" The adjudicated rates answer "given a case proceeds (isn't dismissed), what share goes to jury vs plea?" The distinction matters because if dismissal rates drop in election years, total-disposition jury/plea rates mechanically increase even if the jury/plea split among non-dismissed cases stays flat.

---

## Treatment Variables

| Variable | =1 When | =0 When | Source |
|----------|---------|---------|--------|
| `elec_incumbent` | Incumbent running for re-election | Non-election year OR open seat | alias of `treat_pros_pressure` |
| `open_pros` | Open-seat election | Non-election year OR incumbent running | 01_elections_build.do |
| `treat_pros_contested_long` | Incumbent faces general-election challenger | All other obs | 01_elections_build.do |
| `treat_pros_uncontested` | Incumbent runs fully unopposed | All other obs | 01_elections_build.do |
| `is_election_year_pros` | ANY prosecutor election (incl. open seats) | Non-election year | 01_elections_build.do |

**Mutual exclusivity:** `elec_incumbent + open_pros ≤ 1` always. `treat_pros_contested_long + treat_pros_uncontested = elec_incumbent` among incumbent elections.

---

## Caseload Controls

| Variable | Label | Source | Notes |
|----------|-------|--------|-------|
| `incoming_felony` | New circuit court felony filings | 03b_caseload_build.do | Flow variable |
| `pending_felony` | Unresolved felony cases (stock) | 03b_caseload_build.do | Stock variable |
| `outgoing_felony` | Resolved felony cases | 03b_caseload_build.do | Flow variable |
| `clearance_rate` | outgoing / incoming | 03b_caseload_build.do | Near 1.0 = steady state |
| `county_pop` | County population | 04_population_build.do | Census ACS |

---

## Deprecated Variables (DROPPED from augmented panel)

| Variable | Why Dropped | Replacement |
|----------|-------------|-------------|
| `total_jury_verdicts` | Jury dashboard broken for 2024 (MIN() aggregation) | `felony_jury_total` |
| `capital_felony` | Shows 3 statewide vs 431 in caseload | `fc_jury` |
| `other_felony` | Ambiguous categorization | `fh_jury` |
| `other_cases` | No equivalent in caseload dashboard | Dropped entirely |
| `pct_capital_felony` | Derived from broken counts | `severity_share` |
| `pct_other_felony` | Derived from broken counts | `fh_jury_share` (different denominator) |
| `pct_other_cases` | Derived from broken counts | N/A — dropped |

---

## Total: 29 Outcome Variables

| Group | Count | Source |
|-------|-------|--------|
| Pipeline Counts | 5 | Jury Dashboard |
| Pipeline Rates | 4 | Jury Dashboard |
| Verdict/Trial Counts | 5 | Caseload Dashboard |
| Plea/Dismissal Counts | 4 | Caseload Dashboard |
| Disposition Rates | 11 | Derived from Groups 3-4 |
| **Total** | **29** | |
