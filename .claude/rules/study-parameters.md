# Study Parameters — Michigan Jury Trial Paper

## Design

- **Unit:** County-year (83 Michigan counties x 7 years: 2016-2019, 2022-2024)
- **Estimator:** TWFE panel regression (`reghdfe` with county + year FE)
- **Clustering:** County-level (83 clusters) on ALL regressions — no exceptions
- **COVID:** 2020-2021 always excluded (SCAO data does not exist for these years)
- **Treatment:** Recurring/transitory election regimes, NOT staggered absorbing treatment

## Treatment Variable Codebook

### Primary Variables (used in regressions)

| Variable | Meaning | =1 When | =0 When |
|----------|---------|---------|---------|
| `treat_pros_pressure` | Incumbent running for re-election | Incumbent is on the ballot | Non-election year OR open seat |
| `open_pros` | Open-seat election | No incumbent running, seat is open | Non-election year OR incumbent running |
| `treat_pros_contested_long` | General-election contested incumbent | Incumbent faces challenger in general election | All other obs |
| `treat_pros_contested` | Any-stage contested incumbent | Incumbent faces challenger in primary OR general | All other obs |
| `treat_pros_uncontested` | Uncontested incumbent | Incumbent runs unopposed at all stages | All other obs |
| `is_election_year_pros` | Election year binary (ANY type) | Any prosecutor election occurs (incumbent OR open seat) | Non-election year |
| `elec_incumbent` | Alias for `treat_pros_pressure` | Same as `treat_pros_pressure` | Same |

### Mutual Exclusivity Rules

| Rule | Variables | Constraint |
|------|----------|-----------|
| **Election decomposition** | `treat_pros_pressure` + `open_pros` | Mutually exclusive, sum ≤ 1. Non-election years have both = 0. |
| **Contestation decomposition** | `treat_pros_contested_long` + `treat_pros_uncontested` | Mutually exclusive among incumbent elections. Sum = `treat_pros_pressure`. |
| **Election year overlap** | `is_election_year_pros` vs `open_pros` | **NOT mutually exclusive.** `is_election_year_pros = 1` for ALL election years including open seats. 26 obs have both = 1. |

### CRITICAL WARNING

**`is_election_year_pros` INCLUDES open seats.** It equals 1 for all 170 election-year observations (144 incumbent + 26 open seat). Do NOT use `is_election_year_pros` as an "incumbent election" indicator — use `treat_pros_pressure` (or its alias `elec_incumbent`) instead.

**`elec_incumbent`** is created as `clonevar elec_incumbent = treat_pros_pressure` in `14_paper_tables.do` for labeling clarity. It is NOT a separate variable in the build pipeline — it is an alias created at table-generation time.

### Variable Hierarchy

```
is_election_year_pros = 1  (any election)
├── treat_pros_pressure = 1  (incumbent running)
│   ├── treat_pros_contested_long = 1  (general election challenger)
│   ├── treat_pros_contested = 1       (any stage challenger)
│   └── treat_pros_uncontested = 1     (fully unopposed)
└── open_pros = 1  (no incumbent)
```

## Model/Tier Map

| Model | Tier | Treatment Variable(s) | Omitted Category | Sample Restriction | N (Var B) |
|-------|------|----------------------|-----------------|-------------------|-----------|
| 0 | T0 | `is_election_year_pros` | Non-election years | Open-seat cycles excluded (lame-duck years + open-seat year dropped) | ~465 |
| 1 | T1 | `treat_pros_pressure` + `open_pros` | Non-election years | Full panel | 579 |
| 2 | T2 | `treat_pros_contested_long` + `treat_pros_uncontested` | Non-election years | Open seats excluded + primary-only excluded | ~553 |
| 3 | T3 | `treat_pros_contested` + `treat_pros_uncontested` | Non-election years | Open seats excluded | ~553 |
| 4 | T4 | `treat_pros_pressure` + `open_pros` | Non-election years | Full panel, per-10k outcomes | 579 |
| 5 | T5 | `treat_pros_pressure` | Open-seat elections | Election years only | ~167 |

**T2 vs T3:** T2 = general-election challenges only (primary-only dropped). T3 = any-stage challenges (primary-only = contested). T2 is the primary specification.

## Current Framing (Post-Correction, 2026-03-20)

**The "shadow expansion" mobilization story is DEAD.**

- Corrected results show NO significant increase in raw juror counts under electoral pressure
- New story: **"shadow contraction"** — election pressure reduces voir dire utilization rates and suppresses jury verdicts
- Contestation adds a **capital-felony-specific verdict premium** in small counties
- The composition shift (other-felony share decline) is the most directionally stable result

### Open-Seat Baseline Contamination Fix (2026-03-20)

26 open-seat county-year observations (4.5% of sample) were previously pooled into the control group. Fix: T1 now includes `open_pros` as separate regressor. T2/T3 exclude open seats entirely. ALL prior positive mobilization results were artifacts of this contamination.

### TWFE Weight Diagnostics (2026-03-23)

`twowayfeweights` (de Chaisemartin & D'Haultfoeuille 2020) decomposes the TWFE estimator:

| Variant | Neg ATTs | Σ Neg Weights | Status |
|---------|----------|---------------|--------|
| T1 (pressure) | 2/144 | -0.007 | **CLEAN** — primary spec is reliable |
| T0 full (uncorrected) | 12/170 | -0.325 | BAD — open seats + off-cycle timing |
| T0 corrected (open-seat excl) | 8/133 | -0.361 | BAD — open-seat fix doesn't resolve |
| T0 no off-cycle counties | **0/77** | **0.000** | **CLEAN** — off-cycle counties were the source |
| T0 no offcycle + no open-seat | 62/119 | -0.471 | WORSE — lame-duck exclusion creates asymmetry |

**Key finding:** The 6 off-cycle election counties (Allegan, Isabella, Newaygo, Osceola, Roscommon with 2018; Delta with 2022) are the **entire source** of T0 negative weights. Dropping them produces zero negative weights. The `B_no_offcycle` variant is the clean T0 specification.

**Implication:** T1 is the primary specification (clean weights, full panel). T0 requires the `B_no_offcycle` variant to be TWFE-valid. The lame-duck cycle exclusion fixes sample contamination but not TWFE weight heterogeneity — these are separate issues.

### T2 TWFE Weights (Contestation Model)

| Treatment | Pos ATTs | Neg ATTs | Σ Neg Weights | Status |
|-----------|----------|----------|---------------|--------|
| Contested (general-election) | 39/39 | **0** | **0.000** | **CLEAN** |
| Uncontested | 103/105 | 2 | -0.0006 | **CLEAN** (0.06%) |

T2 is TWFE-valid on the full panel.

### Timing Robustness (Off-Cycle Asynchronicity)

The 6 off-cycle counties create asynchronous election timing that interacts with year FE estimation. Individual composition coefficients (% capital felony, % other felony, % other cases) are sensitive to whether off-cycle counties are included. The Δ (contested − uncontested) is robust across all specifications.

**Four timing specifications tested (2026-03-25, corrected):**

| Spec | Description | Δ Total Verdicts | Δ Capital Felony | Δ % Cap Felony |
|------|-------------|-------------------|-------------------|-----------------|
| 1. Main TWFE | County + year FE (standard) | -6.2** | -5.1** | -0.077*** |
| 2. Group × Year FE | Separate year FE for sync vs off-cycle (= 2-cohort Wooldridge) | -6.2** | -5.3** | -0.082*** |
| 3. Linear Trends | County-specific trends for 6 off-cycle counties | -6.4** | -5.2** | -0.077*** |
| 4. Drop Off-Cycle | Exclude 6 off-cycle counties entirely (77 counties, N=518) | -5.9* | -5.4* | -0.079*** |

**CORRECTION (2026-03-25):** The earlier "3-cohort Wooldridge" spec was wrong — it incorrectly split off-cycle counties into 2018 vs 2022 sub-cohorts. 2018 and 2022 are the SAME off-cycle schedule, not separate cohorts. The corrected 2-cohort Wooldridge (sync vs off-cycle) is numerically identical to spec 2 (Group × Year FE). The old 3-cohort results are discarded.

**Election-cycle interaction (appendix only, 2026-03-25):**
Allowing β_contested and β_uncontested to differ by 2016 vs 2024 cycle reveals that the verdict suppression Δ is 2024-driven (2016 Δ for total verdicts = +6.8, null; 2024 Δ = -26.4*). However, β_uncontested × 2024 is collinear (dropped), and cycle-specific estimates are very imprecise with only 2 election cycles. Presented as descriptive, not as a primary robustness check.

**Key finding:** Uncontested % capital felony moves from null (main spec) to significant (p=.008 in Group × Year FE) when timing heterogeneity is accounted for. Off-cycle counties have structurally lower composition baselines (capital felony share 5.8% vs 13.9%) that distort year FE when included without timing adjustment.

**Current architecture (2026-03-25, corrected):**
- T0: County FE only (no year FE). Descriptive benchmark. `elec_incumbent + open_pros`.
- T2: County + year FE (TWFE). Main result. `contested + uncontested + Δ`. Open seats dropped.
- Timing robustness: 4 specs (main, group×year, linear trends, drop off-cycle) + cycle interaction in appendix.

## Non-Negotiable Facts

- **FC = Felony Capital** (capital felonies). **FH = Felony non-capital** (other felonies). From SCAO case type codes.
- **`B_no_offcycle`** (formerly `B_midterm`, renamed 2026-03-21). Means "dropping 2018 and 2022 off-cycle years." Also the TWFE-valid T0 variant (zero negative weights).
- **Never use log outcomes** for jury or plea data. Too many zeros. Use levels and shares only. Permanent rule.
- **Rate outcomes (`pct_*`) are top-coded at 1.0** in `03_classify_and_aggregate.do`.
- **Prosecutors do NOT summon jurors.** Court administrators do. Prosecutors generate demand signals.
- **2018 and 2022 ARE prosecutor election years** for a handful of counties (off-cycle elections).

## Aggregation Variants

| Variant | Strategy | Counties | Obs |
|---------|----------|----------|-----|
| A | Felony-focused: standalone circuit/probate + fallback combined | 83 | 579 |
| B | All-courts expanded: combined else sum non-combined | 83 | 579 |
| C | Combined-only courts | 44 | 307 |
| Court-level | Individual courts with court FE | varies | varies |

## UNVERIFIED Claims (Pre-Correction Numbers)

**WARNING:** The Overleaf `5-results.tex` contains pre-correction coefficient values that have NOT been re-verified after the 2026-03-20 open-seat fix. All specific numbers (e.g., "+195 actually reported", "+312 told to report") should be treated as potentially outdated until the pipeline is re-run with corrected code.

Verified claims are limited to:
1. Shadow expansion story is dead (no significant mobilization increase)
2. Shadow contraction is the current framing
3. Contestation adds capital-felony verdict premium
4. All results re-estimated with corrected baseline
5. Mobilization effects null, verdict suppression strengthens
