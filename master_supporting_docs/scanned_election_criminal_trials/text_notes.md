# Deep Reading Notes: "The effect of the election of prosecutors on criminal trials"

**Authors:** Siddhartha Bandyopadhyay, Bryan C. McCannon
**Journal:** Public Choice, 2014
**Pages:** 16 pages (empirical paper)
**Citation:** Bandyopadhyay & McCannon (2014)

---

## Paper Summary

Empirical test of the signaling theory from Bandyopadhyay & McCannon (2013) using North Carolina prosecutor election data (1997–2009, 43 districts, 476 obs). Tests whether prosecutors distort case selection (more trials vs. pleas) when facing re-election pressures.

**Key finding:** Elections do increase trial-taking; prosecutors facing re-election and challengers increase jury trial convictions by 9.7% (pre-election) + 14.7% (with challenger).

---

## Theoretical Model (Brief Recap)

Same asymmetric information setup as the theory paper. Key adaptation:

**Voters evaluate prosecutor using two metrics:**
1. **Aggregate sentence length obtained** (primary metric in model)
2. **Proportion of convictions from trials vs. pleas** (in empirical test)

**Election variables as proxies for reelection pressure $z$:**
- `reelect` = year before incumbent runs (prob. of voter attention high)
- `CI` (contested incumbent) = challenger present in primary or general (prob. of replacement increases)
- `never` = district never had contested election 1997–2009 (proxy for low $z$)

---

## Data

### Sample
- **Units:** 43 prosecutorial districts in North Carolina
- **Time period:** Fiscal years 1997–1998 through 2008–2009 (13 years, but district count changes)
- **Panel size:** 476 observations
- **Outcome variable:** `jury` = proportion of convictions from jury trials (not total volume; controls for scale differences across districts)

### District-Level Controls
- Population density
- Unemployment rate
- Demographic composition (% male, % white, % age 16–24)
- Sentencing guideline indicators:
  - Avg. maximum sanction (years incarcerated)
  - % convictions with aggravated, mitigated, intermediate, community sanctions

### Election Data
Three dummy variables capturing reelection pressures:
1. **`reelect`:** Year before incumbent runs for re-election (t–1)
2. **`CI` (contested incumbent):** Challenger enters primary or general election (t)
3. **`never`:** District has never had a contested election, 1997–2009 (time-invariant)

**Competitive environment:** 22.4% general election contests, 24.8% primary contests

---

## Empirical Strategy

### Model 1: Main specification with CI and reelect
$$\text{jury}_{dt} = \alpha_0 + \alpha_1 \text{CI}_{dt} + \alpha_2 \text{reelect}_{dt} + \alpha_3 \mathbf{S}_{dt} + \alpha_4 \mathbf{X}_{dt} + \alpha_5 \mathbf{D}_d + \epsilon_{dt}$$

Where:
- $\mathbf{S}$ = sanction controls
- $\mathbf{X}$ = socioeconomic controls
- $\mathbf{D}_d$ = district fixed effects

**Why district FE instead of year FE?** CI and reelect are highly correlated with election-year calendar effects. Using district FE avoids collinearity but loses year-level trends.

### Model 2: Alternative specification with never
$$\text{jury}_{dt} = \beta_0 + \beta_1 \text{never}_d + \beta_2 \mathbf{S}_{dt} + \beta_3 \mathbf{X}_{dt} + \beta_4 \mathbf{Y}_t + \epsilon_{dt}$$

Where $\mathbf{Y}_t$ = year fixed effects.

**Note:** Cannot use both `never` and district FE (never is time-invariant).

### Robustness: IV Specification
**Instrument for CI:** Proportion of Superior Court judicial seats contested in the judicial division containing the district.

**Rationale:** Judicial elections may correlate with prosecutor elections due to political climate, but judicial contests should not directly affect prosecutor case selection.

**IV results (Table 2):** CI coefficient remains significant, confirming results are not driven by endogenous challenger entry.

---

## Results

### Table 1: Main Results (DV = proportion jury convictions)

**Model I (District FE):**
- `CI` = **0.0038** (0.0018)** → 0.38 pp increase; 9.7% relative effect
  - At mean jury = 0.026 (2.6% of convictions from jury trials)
  - Interpretation: 0.38 pp → [(0.0038/0.026) = 14.6% relative increase]
  - Paper states this as **14.7% increase with challenger**

- `reelect` = **0.0025** (0.0011)** → 0.25 pp increase; 9.7% relative effect
  - Interpretation: Year before re-election, prosecutor pre-emptively increases trials

- Sanction variables significant and correct sign
  - Higher avg. max sanction → more jury trials (selection: harder cases → trials)
  - Aggravated sentences → more jury trials

**Model II (Year FE):**
- `never` = **–0.0028** (0.0012)** → 0.28 pp decrease
  - Districts with no contested elections have **10.8% fewer jury trial convictions**
  - Supports theory: low $z$ (replacement prob) → less distortion → fewer trials

### Summary Effect Sizes
- **Pre-election incentive:** +1.80 jury convictions per district-year
- **Contested election:** +2.73 jury convictions per district-year (additional)
- **Total amplification:** 4.53 additional jury trials per district per year when facing challenger

### Table 2: IV Results
- **CI (2SLS):** 0.0121* (0.0069) — larger than OLS, suggests measurement error or that challengers are less likely to enter when prosecutors are already high-volume trial takers
- `reelect` remains ~0.0028

### Table 3: Effect on Sentencing (Secondary predictions)

**Does prosecutor take weaker cases to trial?**

Dependent variables:
1. % convictions with community punishment
2. Avg. maximum sanction

**Results:**
- **CI:** –0.0213** (community punishment) → prosecutors taking CI cases to trial have 2.1 pp fewer community punishments (i.e., they're pursuing harsher sentences at trial)
  - Sanction effect: –2.64* years → avg. max sanction **drops by 6.2%** in contested year
  - **Interpretation:** Prosecutors try harder cases (lower marginal evidence), leading to lower average sentences despite apparent toughness increase

- **reelect:** +0.0338*** (community punishment) → **more community punishments pre-election**
  - Sanction effect: +1.43* years → avg. sanction **increases** pre-election
  - **Interpretation:** Forward-looking behavior: clear weak cases via plea pre-election, then concentrate resources on trial wins in election year

- **never:** +0.0248*** (community punishment) → districts with no contestation have **higher** community punishment prevalence
  - No electoral pressure → less case selection distortion

---

## Identification and Causal Assumptions

### Main Threats

1. **Endogenous challenger entry:** Maybe challengers enter when prosecutors are already aggressive
   - **Response:** IV specification using judicial contests; results hold

2. **Reverse causality:** Maybe high trial rates provoke challengers
   - **Partial defense:** Specification uses pre-election (`reelect` t–1) and calendar effects; can't explain all variation

3. **Confounding elections:** Judicial elections correlate with prosecutor elections
   - **Response:** Authors test; judge variable uncorrelated with jury proportion, so unlikely to drive results

4. **Unobserved district heterogeneity:** Some districts structurally more trial-heavy
   - **Partial defense:** District FE in Model I

### Validity of Election Timing

- **Critical detail:** Prosecution data is fiscal year (June 1 – July 30)
- **General elections:** November, appear in t+1 data
- **Primary elections:** Spring of election year, appear in t

This timing allows researchers to separate pre-election (`reelect`) from election-year (`CI`) effects.

---

## Effect Sizes in Context

### Absolute Numbers
- Mean jury convictions per district per year: **17.66**
- Mean guilty pleas: **700.92**
- Election effects: **4.53 additional jury trials** (25.6% increase relative to baseline jury convictions)

### Relative to Baseline
- Baseline jury conviction share: **2.6%** (17.66 / 700.92 + 17.66)
- CI effect: +0.38 pp → 2.6% → 3.0% (14.6% relative increase) ✓ matches "14.7%"
- reelect effect: +0.25 pp → 2.6% → 2.85% (9.6% relative increase) ✓ matches "9.7%"

---

## Does Paper Test Contested vs. Uncontested?

**Yes, partially.** `CI` variable = contested incumbent; controls are uncontested. But the paper doesn't create a clean "contested" vs. "uncontested" binary as we do. Instead:

1. **Pre-election year** (reelect = 1)
2. **Election year with challenger** (CI = 1)
3. **Election year without challenger** (CI = 0, reelect = 0 in year t, but reelect = 1 in year t–1)
4. **Never contested district** (`never` = 1)

Our research context asks about **contested vs. uncontested within election cycles**. This paper measures **pre-election, incumbent-with-challenger, and never-contested** — similar but structured differently.

---

## Relation to Our Findings (Δ ≈ 0 on Dispositions)

**Critical disconnect:**

This paper finds **prosecutors increase jury trial convictions when facing elections** (election pressure → more trials).

Our paper finds **Δ ≈ 0 on jury verdicts and plea rates between contested and uncontested**.

**How can both be true?**

1. **Prosecutors selection response (McCannon 2014):** More cases are taken to trial (this paper's finding)
2. **Jury acquittal rates constant:** But juries don't change their acquittal propensity (our finding)

**Implication:** Electoral pressure affects prosecutor **discretion over case selection** but not jury **decision-making on tried cases**.

---

## What It Adds to Our Understanding

1. **Strong empirical support for signaling theory:** Prosecutors do respond to elections by increasing trials
2. **Causal identification:** IV strategy reduces concerns about endogenous challenger entry
3. **Disposition margin evidence:** Prosecutors expand case selection (weaker evidence at margin), leading to lower average sentences
4. **Heterogeneity by competitiveness:** Never-contested districts show opposite pattern

**For our jury trial paper:**
- Establishes the baseline: elections → more trials (✓ confirmed)
- Raises the question: why don't verdicts respond?
- Suggests the mechanism operates through **selection**, not **jury behavior**

---

## Strengths

1. **Clean research design:** Pre-post-election timing with multiple specifications
2. **Robustness:** IV specification addresses endogenous entry
3. **Comprehensive outcome set:** Trial volume, conviction type, sentence length all tested
4. **Theory-grounded predictions:** All three key predictions confirmed (more trials, lower avg. sentences, pattern reversed for never-contested)

## Weaknesses

1. **No individual case data:** Uses district-level aggregates; cannot see which specific cases are pushed to trial
2. **Sanction interpretation:** Lower average sanctions could reflect worse case quality OR judicial leniency; paper doesn't separate
3. **External validity:** North Carolina only; prosecutorial institutions vary nationally
4. **No acquittal rate analysis:** Only looks at conviction patterns, not jury verdicts

---

## Key Table Reference

**Table 1, Model I:** `CI` = 0.0038, `reelect` = 0.0025 are the core estimates.

**Table 3:** Shows sentencing effects; confirms prosecutors are taking marginal cases to trial (lower avg. sentences).

