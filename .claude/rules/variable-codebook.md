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

## Michigan Court Structure and Case Type Definitions

### Court Types

| Court | SCAO Code | Jurisdiction | Prosecutor Role | Data Source |
|-------|-----------|-------------|-----------------|-------------|
| **Circuit Court** | C01-C57 | All felonies (FC, FH), civil >$25K | Felony prosecution and trial | `outgoing_felony_by_year.csv` |
| **District Court** | D01-D98 | Misdemeanors, felony preliminary exams, arraignments | Misdemeanor prosecution + felony prelim hearings | `outgoing_district_felony_by_year.csv` |
| **Probate Court** | P01-P83 | Estates, guardianship, juvenile, mental health | Limited (juvenile cases) | Not used |

### Circuit-to-County Mapping

Michigan has 57 judicial circuits serving 83 counties. Multi-county circuits exist (e.g., C12 covers Baraga + Houghton + Keweenaw; C23 covers Alcona + Arenac + Iosco + Oscoda). **The SCAO caseload dashboard reports data at the county level, not the circuit level** — each county within a multi-county circuit receives its own county-specific counts. Verified: counties within the same circuit have different verdict counts (not duplicated circuit totals). Each county maps to exactly one circuit court code. Source: SCAO Trial Court Map (December 2023), `docs/trial-court-map-w-regions.pdf`.

### District-to-County Mapping

District courts have a many-to-one relationship with counties: large counties have multiple district courts (Wayne = 24, Oakland = 11, Macomb = 8), small counties have one each. The SCAO data tags each record with county name, so aggregation to county-year is a simple sum across district courts within county.

### Case Type Definitions

**Circuit court case types (used in this paper):**

| Code | Full Name | Definition | Examples |
|------|-----------|-----------|----------|
| **FC** | Capital Felonies | Life-offense-eligible felonies | Murder, armed robbery, CSC-1, drug trafficking (large quantity) |
| **FH** | Non-capital Felonies | All other felonies not life-eligible | Assault, burglary, fraud, drug possession, felony DUI (if bound over) |

**District court case types (NOT in main analysis):**

| Code | Full Name | Notes |
|------|-----------|-------|
| **FD** | Felony Drunk Driving | Handled at district court; if bound over to circuit, reclassified as FC or FH |
| **FT** | Felony Traffic | Handled at district court; if bound over to circuit, reclassified as FC or FH |
| **FY** | Felony Criminal Cases | Non-traffic felonies at district level; includes prelim hearings before bindover |

**Key rule:** The FD/FT/FY classification exists ONLY at the district court level. Once a case is bound over to circuit court, it enters as FC or FH based on severity (life-eligible or not). Circuit court data contains only FC and FH — no traffic-specific categories.

### What This Means for the Analysis

- **Pipeline variables** (summoned through utilization_rate): from ALL court types via the jury dashboard. A juror summoned for a district court misdemeanor trial counts the same as one summoned for a circuit court capital felony trial.
- **Disposition variables** (fc_jury, fc_plea, fc_dismissed, etc.): from circuit courts ONLY. These capture felony case resolution after the case has reached circuit court.
- **District court upstream decisions** (bindover, felony plea acceptance, charge reduction to misdemeanor): available in `outgoing_district_felony_by_year.csv` but NOT included in the current analysis. These represent the upstream mechanism that determines which cases reach circuit court.
- **Limitation:** The analysis captures circuit-court-level case routing but does not observe district court decisions that filter which cases reach the circuit level. If prosecutors adjust district-level screening under electoral pressure, our estimates capture only the downstream portion of the behavioral shift.

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
