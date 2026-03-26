# Model Specifications and Table Architecture
## Authoritative Reference — Do Not Edit Tables Without Checking This File
### Last Updated: 2026-03-27

---

## Main Paper Tables

### Table 1 (1a + 1b): Baseline Election Effect

$$Y_{ct} = \beta_1 \cdot \text{elec\_incumbent}_{ct} + \beta_2 \cdot \text{open\_pros}_{ct} + \alpha_c + \varepsilon_{ct}$$

- **FE:** County only (NO year FE)
- **Clustering:** County (83 clusters)
- **Sample:** Full Panel B (N=579, 83 counties, 7 years: 2016-2019, 2022-2024)
- **No observations dropped**
- **Treatment vars:**
  - `elec_incumbent` = 1 when incumbent running for re-election
  - `open_pros` = 1 when open seat (no incumbent)
  - Mutually exclusive: `elec_incumbent + open_pros <= 1`
- **Omitted category:** Non-election years
- **Reports:** BOTH coefficients (incumbent column + open seat column) + N
- **Split:** 1a = pipeline counts + verdicts; 1b = disposition rates + composition

### Table 2 (2a + 2b): Electoral Contestation — PRIMARY SPECIFICATION

$$Y_{ct} = \beta_1 \cdot \text{treat\_pros\_contested\_long}_{ct} + \beta_2 \cdot \text{treat\_pros\_uncontested}_{ct} + \alpha_c + \gamma_t + \varepsilon_{ct}$$

$$\Delta = \beta_1 - \beta_2 \text{ via lincom (covariance-adjusted)}$$

- **FE:** County + Year (TWFE)
- **Clustering:** County
- **Sample:** 77 synchronized counties, open-seat county-years dropped
  - 6 off-cycle counties excluded: Allegan (3), Isabella (37), Newaygo (62), Osceola (66), Roscommon (74), Delta (21)
  - N varies by outcome (~505-518)
- **Treatment vars:**
  - `treat_pros_contested_long` = 1 when incumbent faces general-election challenger
  - `treat_pros_uncontested` = 1 when incumbent runs fully unopposed
- **Omitted category:** Non-election years
- **Reports:** Contested coef/SE, Uncontested coef/SE, Delta/SE, N
- **Split:** 2a = pipeline counts + verdicts; 2b = disposition rates + composition

### Table 5 (file: table4b): Heterogeneity — Below-Median Population

Same model as Table 2, restricted to below-median population counties.

- **Sample:** 77 sync counties, open dropped, below-median county population only (~236 obs)
- **Median:** Computed as median of county-level mean population across panel years (~37,650)
- **Reports:** Same as Table 2 (Contested, Uncontested, Delta)
- **Note:** Above-median version is collinear (uncontested absorbed by county x year FE). Not reported.

### Table 6: Robustness Across Sample Variants

Same T2 model, four sample/FE variants:

$$Y_{ct} = \beta_1 \cdot \text{contested} + \beta_2 \cdot \text{uncontested} + \alpha_c + [\text{year effects}] + \varepsilon_{ct}$$

| Column | Label | Counties | Off-Cycle | Year Effects | Open Seats |
|--------|-------|----------|-----------|-------------|------------|
| (1) | 77 Sync Counties | 77 | Excluded | Standard year FE | Dropped |
| (2) | 83 Counties, Group x Year FE | 83 | Included (adjusted) | Group x Year (2 groups x 7 years = 14 cells) | Dropped |
| (3) | Drop 2016 Cycle | 77 | Excluded | Standard year FE | Dropped |
| (4) | Drop 2024 Cycle | 77 | Excluded | Standard year FE | Dropped |

- **Panel A:** Contested coefficient ($\beta_1$)
- **Panel B:** Delta ($\beta_1 - \beta_2$)

### Table 7 (file: table8): Falsification — Caseload as DV

Same T2 model, different DVs:

$$Y_{ct} = \beta_1 \cdot \text{contested} + \beta_2 \cdot \text{uncontested} + \alpha_c + \gamma_t + \varepsilon_{ct}$$

- **Sample:** Same as Table 2 (77 sync, open dropped)
- **DVs:** Incoming felony filings, pending felony stock, clearance rate
- **Reports:** Contested, Uncontested, Delta for each DV

---

## Appendix Tables

### Table A1: Baseline Sample Restriction Sensitivity

Five specifications of T0, varying sample and FE:

| Col | Label | Model | FE | Sample |
|-----|-------|-------|----|--------|
| (1) | Open Seats Dropped | $Y = \beta \cdot \text{is\_elec\_year} + \alpha_c + \varepsilon$ | County | 83 counties, open obs dropped |
| (2) | Open + Off-Cycle Dropped | Same | County | 77 sync, open dropped |
| (3) | Open Seat as Regressor | $Y = \beta_1 \cdot \text{is\_elec\_year} + \beta_2 \cdot \text{open\_pros} + \alpha_c + \varepsilon$ | County | Full B (579) |
| (4) | Open Regressor, No Off-Cycle | Same as (3) | County | 77 sync (537) |
| (5) | TWFE (+ Year FE) | $Y = \beta \cdot \text{is\_elec\_year} + \alpha_c + \gamma_t + \varepsilon$ | County + Year | 83 counties, open dropped |

**Columns (3) and (4) report BOTH $\beta_1$ and $\beta_2$.**
Columns (1), (2), (5) report single coefficient only.

### Table A2: Contestation Full Panel vs Off-Cycle Excluded (Exhaustive)

Same T2 model, two sample variants, ALL 29 outcomes:

| Columns 1-3 | Columns 4-6 |
|-------------|-------------|
| Full panel (83 counties, open dropped) | 77 sync (open + off-cycle dropped) |
| Contested, Uncontested, Delta | Contested, Uncontested, Delta |

### Table A3: Delta Robustness

Reports ONLY $\Delta = \beta_1 - \beta_2$ across three specs:

| Col | Label | FE | Counties |
|-----|-------|----|----------|
| (1) | 77 Sync, TWFE | County + Year | 77 |
| (2) | 83 All, Group x Year FE | County + Group x Year | 83 |
| (3) | Pooled (County FE only) | County | 83 (open dropped) |

### Table A4: Within-Election (T5, Descriptive)

$$Y_{ct} = \beta \cdot \text{treat\_pros\_pressure}_{ct} + \alpha_c + \gamma_t + \varepsilon_{ct}$$

- **Sample:** Election years only (~167 obs)
- **Omitted:** Open-seat elections
- **Single coefficient:** incumbent vs open seat

### Table A5: Control Sensitivity (Exhaustive, 4 Decimals)

Same T2 model with controls added:

$$Y_{ct} = \beta_1 \cdot \text{contested} + \beta_2 \cdot \text{uncontested} + \mathbf{X}_{ct}'\delta + \alpha_c + \gamma_t + \varepsilon_{ct}$$

| Col | Controls |
|-----|----------|
| (1) Base | None |
| (2) + Caseload | incoming_felony, pending_felony |
| (3) + Population | log_county_pop |
| (4) + Both | incoming_felony, pending_felony, log_county_pop |

- **Sample:** 77 sync, open dropped
- **ALL 29 outcomes reported** (exhaustive)
- **4 decimal places** for rates, 1 decimal for counts
- **Panel A:** Contested coefficient ($\beta_1$)
- **Panel B:** Delta ($\beta_1 - \beta_2$)

---

## File-Label Mapping

| File | Label | LaTeX # |
|------|-------|---------|
| table1a_baseline_pipeline.tex | tab:t0-pipeline | 1 |
| table1b_baseline_disposition.tex | tab:t0-disposition | 2 |
| table2a_contestation_pipeline.tex | tab:t2-pipeline | 3 |
| table2b_contestation_disposition.tex | tab:t2-disposition | 4 |
| table4b_het_lowpop.tex | tab:het-lowpop | 5 |
| table6_robustness.tex | tab:robustness | 6 |
| table8_falsification.tex | tab:falsification | 7 |
| tableA1_t0_sensitivity.tex | tab:t0-sensitivity | A1 |
| tableA2_t2_offcycle.tex | tab:t2-offcycle | A2 |
| tableA3_delta_robustness.tex | tab:delta-robust | A3 |
| tableA4_within_election.tex | tab:within-election | A4 |
| tableA5_controlled.tex | tab:controls | A5 |
