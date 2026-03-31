# Domain Profile

## Field

**Primary:** Political Economy / Law & Economics
**Adjacent subfields:** Public Economics, Labor Economics, Criminal Justice, Judicial Politics

---

## Target Journals (ranked by tier)

| Tier | Journals |
|------|----------|
| Top-5 | AER, JPE, QJE, REStud |
| Top field | AEJ:Applied, AEJ:Policy, JLE, Journal of Law and Economics, Journal of Law, Economics, and Organization |
| Strong field | JPubE, JHR, JELS (Journal of Empirical Legal Studies), American Law and Economics Review |
| Specialty | Journal of Criminal Justice, Criminology & Public Policy, Justice Quarterly |

---

## Common Data Sources

| Dataset | Type | Access | Notes |
|---------|------|--------|-------|
| SCAO Jury Management System | Admin (court-level) | Public (Power BI dashboard) | Michigan-specific; court-year panel of juror counts/rates |
| UNC PPP (Prosecutors & Politics) | Admin (election) | Public (web scrape) | Candidate-level prosecutor election records, all states |
| Census ACS | Survey/admin | Public | County-year population for scaling and controls |
| SCAO Caseload Data | Admin (court-level) | Public (CSV) | Incoming/outgoing/pending felony caseloads by court-year |

---

## Common Identification Strategies

| Strategy | Typical Application | Key Assumption to Defend |
|----------|-------------------|------------------------|
| TWFE with recurring treatment | Within-county election/non-election year contrasts | Conditional on county + year FE, outcomes would not differ across regimes absent electoral incentives |
| Contestation decomposition | Contested vs uncontested incumbent elections | Contestation is not driven by county-specific jury trends |
| Population heterogeneity splits | Above/below median county population | No differential trends by county size |

---

## Field Conventions

- County-clustered SEs for county-level policy variation (83 clusters)
- Report within-unit SD standardized effects alongside raw coefficients
- Multiple testing adjustments (Romano-Wolf, Bonferroni-Holm) when testing outcome families
- TOST equivalence tests for establishing meaningful nulls
- Always distinguish prosecutorial agency from judicial or administrative responses
- Never claim prosecutors "summon jurors" — court administrators do

---

## Notation Conventions

| Symbol | Meaning | Anti-pattern |
|--------|---------|-------------|
| $Y_{ct}$ | Outcome for county $c$ in year $t$ | Don't use $y$ without subscripts |
| $\alpha_c$ | County fixed effect | Don't call it "individual FE" |
| $\gamma_t$ | Year fixed effect | Don't call it "time trend" |
| $D_{ct}$ | Treatment indicator (electoral regime) | Don't use generic $T$ or $W$ |
| FC | Felony Capital (life-eligible) | Never guess — from SCAO codes |
| FH | Felony non-capital (other felonies) | Never guess — from SCAO codes |

---

## Seminal References

| Paper | Why It Matters |
|-------|---------------|
| Bibas (2004) | Plea-bargaining shadow — credible threat of trial affects plea behavior |
| Gordon & Huber (2007) | Electoral proximity increases prosecutorial severity in competitive districts |
| Gordon (2009) | Review of prosecutorial agency framework (agents of voters, principals of staff) |
| Priest & Klein (1984) | Selection model — enhanced preparation shifts litigation threshold |
| Bandyopadhyay et al. (2014) | Population density and electoral competitiveness interaction |
| Hessick & Morse (2020) | Contestation rates by district population |
| Detotto et al. (2020) | Scale economies in prosecutor offices |

---

## Field-Specific Referee Concerns

- "Is this causal or just association?" — Recurring treatment complicates standard DiD interpretation
- "External validity" — Michigan single-county prosecutor system is unusual nationally
- "Selection into contestation" — Challenged incumbents may differ from unchallenged ones
- "Reverse causality" — High-crime years could trigger both jury demand and contested elections
- "Administrative vs prosecutorial" — Can you distinguish prosecutor intent from court admin response?
- "Small N of treated cycles" — Only 2 presidential election cycles (2016, 2024) provide treatment variation
- "Why not staggered DiD?" — Because treatment is recurring/transitory, not absorbing

---

## Quality Tolerance Thresholds

| Quantity | Tolerance | Rationale |
|----------|-----------|-----------|
| Point estimates | 1e-6 | Numerical precision in Stata |
| Standard errors | 1e-4 | Clustering variance |
| p-values | 1e-3 | Reporting precision |
| Sample sizes | Exact | Must match panel structure exactly |
