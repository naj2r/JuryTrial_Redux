# Follow-Up Paper: Upstream Prosecutorial Screening Under Electoral Pressure

## One-Sentence Pitch

Does electoral pressure change how prosecutors screen felony cases at the district court level — before cases ever reach circuit court for trial?

---

## Motivation (From Paper 1)

Paper 1 ("Electoral Incentives and the Jury Pipeline") finds that Michigan prosecutors under electoral pressure reroute capital felony cases at circuit court: fewer dismissals (-13.6pp***), higher jury trial rates (+9.2pp***), lower plea rates (-10.1pp**). The effect is identical for contested and uncontested elections (Δ ≈ 0 on every margin), consistent with competence maintenance rather than voter signaling. Non-capital felonies show zero response.

**The unanswered question:** Does this behavioral shift originate at circuit court, or does it begin upstream at district court? Before a felony case reaches circuit court, it must survive three district-court gates: (1) the prosecutor must maintain the felony charge (not reduce to misdemeanor), (2) the judge must find probable cause at the preliminary hearing, and (3) the prosecutor must decline to accept a felony plea at the district level. If prosecutors tighten screening at these upstream gates during election years, the circuit court effects in Paper 1 are downstream consequences of an earlier decision.

---

## Research Questions

1. **Bindover rates:** Do prosecutors bind over more felony cases from district to circuit court during election years?
2. **Charge reduction:** Do prosecutors reduce fewer felonies to misdemeanors during election years?
3. **District-level felony pleas:** Do prosecutors accept fewer felony plea deals at the district level during election years?
4. **District-level dismissals:** Do prosecutors dismiss fewer felony charges at the district level?
5. **Severity selection:** Does the upstream tightening operate specifically on FY (criminal felonies) rather than FD (drunk driving) or FT (traffic)?
6. **Δ ≈ 0 replication:** Is the upstream effect also identical for contested and uncontested elections (competence maintenance at every stage)?

---

## Theoretical Framework

### Priest & Klein (1984) — Selection at the Screening Stage

The standard litigation selection model says cases that go to trial are those where parties disagree about expected outcomes. But the prosecutor controls the first filter — which cases enter the circuit court system at all. Under electoral pressure, a prosecutor optimizing for visible competence should:
- Bind over more serious cases (visible circuit court activity)
- Accept fewer district-level pleas (don't let cases disappear quietly)
- Reduce fewer felonies to misdemeanors (maintain severity signal)

### Bandyopadhyay & McCannon (2015) — The Screening Margin

Their two-metric signaling model (sentence-length vs conviction-rate optimization) has prosecutors choosing trial strategy. But there's a prior margin: the screening decision. Before deciding how aggressively to try a case, prosecutors decide whether the case reaches trial at all. The district court is where this screening happens. The model's offsetting distortions (Δ ≈ 0 on trial counts) could originate at the screening stage if prosecutors simultaneously tighten screening (more bindovers) and loosen trial selectivity (more cases reaching jury, but fewer convictions per case).

### Gordon & Huber (2007) — Decomposing "Effort"

Gordon & Huber find electoral proximity increases prosecutorial severity. "Effort" is vague — this paper decomposes it into screening effort (bindover, charge reduction) vs trial effort (Paper 1's circuit court finding). If both margins shift, the full pipeline responds to elections. If only circuit court shifts, the upstream is constant and the behavioral change is purely about case routing among cases that already reached circuit.

### McCannon & Pruitt (2018) — Earliest Observable Margin

If challenger entry is informative about incumbent quality and voters update on signals, prosecutors should adjust behavior at the earliest observable margin — district court, where cases first become public (arraignment, preliminary hearing). Activity at this stage is the first signal of prosecutorial vigor.

### Bibas (2004) / Stuntz (2006) — Hydraulic Discretion

Prosecutorial discretion is hydraulic: squeeze one margin and it pops elsewhere. Paper 1 shows the circuit court margin pops. This paper tests whether the squeeze originates at district court. If bindover rates increase AND charge reduction rates decrease, that's the squeeze. The circuit court FC trial rate increase is the pop.

---

## Data

### Available (Already Scraped)

| File | Location | Content | Structure |
|------|----------|---------|-----------|
| `outgoing_district_felony_by_year.csv` | `$RB/data_raw/michigan/scao_caseload/` | District court felony dispositions | county × court_code × case_type × action × year |
| `outgoing_felony_by_year.csv` | Same | Circuit court felony dispositions (Paper 1) | Same structure |
| `michigan_panel_B_augmented.dta` | `$RB/data_final/` | County-year panel with elections + pipeline + circuit dispositions | Paper 1's regression panel |

### District Court Case Types

| Code | Name | Relevant? |
|------|------|-----------|
| **FY** | Felony Criminal Cases | **YES — primary DV** |
| **FD** | Felony Drunk Driving | Maybe — separate analysis |
| **FT** | Felony Traffic | Exclude from main — different discretion calculus |

### District Court Disposition Methods (Key DVs)

| Action | What It Measures | Theoretical Prediction |
|--------|-----------------|----------------------|
| **Bindover/Transfer** | Cases sent from district to circuit court | ↑ under electoral pressure (more cases pushed to visible trial stage) |
| **Felony Plea Accepted in District Court** | Felonies resolved at district level via plea | ↓ under electoral pressure (fewer quiet resolutions) |
| **Dismissed by Party** | Prosecutorial dismissals at district level | ↓ under electoral pressure (fewer dropped cases) |
| **Dismissed by Court** | Judicial dismissals | Control — not prosecutorial discretion |
| **Disposed and reduced to misdemeanor** | Felony charge downgraded | ↓ under electoral pressure (maintain severity) |
| **Guilty Plea** | Standard plea | Part of plea composite |
| **Guilty Plea/Admission** | Alternative plea | Part of plea composite |
| **Jury Verdict** | Rare at district level | Mostly zero — may not be usable |
| **Bench Verdict** | Also rare | Same |
| **Case Type Change** | Reclassification | Possible severity manipulation measure |

### District-to-County Mapping

Unlike circuit courts (1:1 with counties in the data), large counties have MULTIPLE district courts:
- Wayne: 24 district courts
- Oakland: 11
- Macomb: 8
- Kent: 5
- Most counties: 1

**Aggregation:** Sum across all district courts within county to get county-year totals. The `county` column in the CSV handles this — just `collapse (sum) quantity, by(county year case_type action_name)`.

### Traffic Case Exclusion

FD (Felony Drunk Driving) and FT (Felony Traffic) should be analyzed separately from FY (Felony Criminal Cases) because:
- Traffic cases involve different prosecutorial discretion (less politically salient)
- Sentencing structure is different (mandatory minimums for repeat DUI)
- Voter attention to traffic vs violent crime cases differs
- Include FD/FT in appendix for completeness but not in main results

---

## Proposed Outcome Variables

### Primary (from FY — Felony Criminal Cases)

| Variable | Construction | What It Tests |
|----------|-------------|---------------|
| `fy_bindover_rate` | Bindover / (Bindover + Plea + Dismissed + Reduced) | Screening tightness |
| `fy_plea_rate` | (Guilty Plea + Guilty Plea/Admission + Felony Plea Accepted) / total | District-level plea resolution |
| `fy_dismiss_rate` | Dismissed by Party / total | Prosecutorial dismissal at district level |
| `fy_reduction_rate` | Reduced to Misdemeanor / total | Severity downgrading |
| `fy_bindover_count` | Raw bindover count | Level effect |
| `fy_incoming` | New Filings | Demand-side falsification |

### Secondary (from FD — Felony Drunk Driving)

Same variables but for FD cases. Expected: weaker effects (less discretion, mandatory minimums).

---

## Identification Strategy

Same as Paper 1:

### T2 (Primary): Contestation Mechanism
$$Y_{ct} = \beta_1 \cdot \text{Contested}_{ct} + \beta_2 \cdot \text{Uncontested}_{ct} + \alpha_c + \gamma_t + \varepsilon_{ct}$$

- 77 synchronized counties, open seats dropped
- County + year FE
- Δ = β₁ - β₂ via lincom
- Prediction: Δ ≈ 0 (competence maintenance at screening stage too)

### T0 (Benchmark): Election-Year Baseline
$$Y_{ct} = \beta_1 \cdot \text{IncumbentElection}_{ct} + \beta_2 \cdot \text{OpenSeat}_{ct} + \alpha_c + \varepsilon_{ct}$$

- County FE only
- Descriptive benchmark

---

## Expected Results and Interpretation

### If bindover ↑ AND reduction ↓ AND district plea ↓ AND Δ ≈ 0:
**Full upstream-downstream story.** Prosecutors tighten screening at every stage during election years — more cases bound over, fewer reduced, fewer resolved quietly at district level. The circuit court effects in Paper 1 are downstream consequences. Competence maintenance operates at the earliest observable margin.

### If bindover is null BUT district dismissal ↓:
**Selective tightening.** Prosecutors don't push more cases to circuit court, but they stop dropping cases at district level. The pipeline volume is constant but the leak rate decreases. Consistent with "don't look soft" without active case-pushing.

### If everything is null:
**Circuit-court-only effect.** The behavioral shift documented in Paper 1 is purely about how prosecutors handle cases that already reached circuit court. No upstream screening change. Still publishable — it means the institutional response is localized to the trial-level decision, not the charging/screening decision. This would be inconsistent with the hydraulic theory and more consistent with prosecutors being constrained at the screening stage but having discretion at the trial stage.

### If Δ ≠ 0 (contested ≠ uncontested):
**Different mechanism at screening vs trial.** If district-level screening responds to contestation (Δ > 0) but circuit-level routing doesn't (Paper 1's Δ ≈ 0), that suggests competitive pressure affects the early-stage decision but the election calendar drives the trial-stage decision. This would be a nuanced finding — two different mechanisms operating at two different pipeline stages.

---

## Pipeline Position (Do-File Structure)

```
01_elections_build.do          — REUSE from Paper 1 (same treatment variables)
02_import_jury_data.do         — NOT NEEDED (this paper doesn't use jury pipeline)
03e_district_court_build.do    — NEW: build district court disposition panel
   Input: outgoing_district_felony_by_year.csv
   Process: filter to FY (main) + FD (secondary), aggregate to county-year
   Output: district_court_panel.dta
04_population_build.do         — REUSE from Paper 1
05c_merge_district_panel.do    — NEW: merge elections + district court + population
   Output: district_panel_augmented.dta
07_district_regressions.do     — NEW: T0 + T2 on district court outcomes
14_district_tables.do          — NEW: production LaTeX tables
```

---

## Connections to Paper 1

| Paper 1 Finding | Follow-Up Test | Variable |
|----------------|---------------|----------|
| FC dismissal rate ↓ 13.6pp at circuit | Does FC screening tighten at district? | `fy_bindover_rate`, `fy_dismiss_rate` |
| FC jury trial rate ↑ 9.2pp | Are more cases being pushed up from district? | `fy_bindover_count` |
| FH is null at circuit | Is FH also null at district? | Same vars for FD subset |
| Δ ≈ 0 at circuit | Is Δ ≈ 0 at district? | All district DVs |
| Small-county concentration | Does screening effect also concentrate in small counties? | Population split |
| Caseload falsification null | Is district incoming also null? | `fy_incoming` |

---

## Preliminary Feasibility Check (Do Before Full Build)

Before committing to the full pipeline, run a quick diagnostic:

```stata
* Load district court data
import delimited "data_raw/michigan/scao_caseload/outgoing_district_felony_by_year.csv", clear

* Filter to FY criminal felonies
keep if case_type == `"FY - Felony Criminal Cases"'

* Check coverage: how many counties x years?
tab year
distinct county

* Check key disposition counts
tab action_name if year >= 2016 & year <= 2024

* Aggregate to county-year
collapse (sum) quantity, by(county year action_name)
reshape wide quantity, i(county year) j(action_name) string

* Quick look: does bindover vary by year?
summ quantity* if year >= 2016 & year <= 2024
```

If bindover counts are non-trivial and have variation across counties and years, proceed with the full build. If they're sparse (many zeros), the paper may not be feasible.

---

## Key References

- Bandyopadhyay, S. & McCannon, B. (2015). Prosecutorial retention: Signaling by trial. *Journal of Public Economic Theory*.
- Bibas, S. (2004). Plea bargaining outside the shadow of trial. *Harvard Law Review*.
- Gordon, S. & Huber, G. (2007). The effect of electoral competitiveness on incumbent behavior. *QJPS*.
- Hessick, C., Treul, S. & Love, A. (2023). Understanding uncontested prosecutor elections. *North Carolina Law Review*.
- McCannon, B. & Pruitt, J. (2018). Informative contests and the efficient entry of political challengers. *Journal of Theoretical Politics*.
- Stuntz, W. (2006). The political constitution of criminal justice. *Harvard Law Review*.
- **Jensen & Ammons (2026). Electoral incentives and the jury pipeline.** [Paper 1 — this project]

---

## Timeline Estimate

| Phase | Task | Time |
|-------|------|------|
| 0 | Feasibility check (quick Stata diagnostic) | 1 hour |
| 1 | Build 03e + 05c (district panel) | 1 day |
| 2 | Run T0 + T2 regressions | 0.5 day |
| 3 | Tables + initial results | 1 day |
| 4 | Interpretation + write-up | 2-3 days |
| 5 | Robustness (timing, controls, pop split) | 1 day |
| **Total** | | **~1 week** |

---

## Repo Setup

If creating a separate repo:
```
DistrictCourt_Electoral/
├── CLAUDE.md                    # Copy + adapt from JuryTrial_Redux
├── .claude/                     # Copy rules, agents, skills from JuryTrial_Redux
├── scripts/stata/michigan/      # New do-files (03e, 05c, 07, 14)
├── Paper/                       # New manuscript
├── quality_reports/             # Plans, session logs
└── this file (CONTEXT.md)       # Starting context
```

If keeping in JuryTrial_Redux as an exploration:
```
explorations/followup_district_court/
├── CONTEXT.md                   # This file
├── 03e_district_court_build.do  # Build script
├── results/                     # Preliminary output
└── notes/                       # Analysis notes
```
