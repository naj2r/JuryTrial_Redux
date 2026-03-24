# Deep-Read Notes: Dyke (2007) "Electoral Cycles in the Administration of Criminal Justice"

## Paper Summary
Andrew Dyke analyzes electoral cycles in criminal justice outcomes using over 1.3 million felony cases disposed in North Carolina Superior Courts during the 1990s. He finds that prosecutors increase conviction rates and reduce dismissals in election years, suggesting prosecutors manipulate case outcomes for electoral advantage.

---

## Key Research Question
**Does the electoral cycle faced by district attorneys (DAs) generate observable cycles in case outcomes?**

The paper applies political business cycle theory to local prosecutors: just as politicians manipulate macroeconomic policy near elections, do DAs manipulate case disposition to appear "tough on crime" when facing reelection?

---

## Main Findings

### Primary Result
- **Conviction probability increases by 1–2 percentage points in the 12 months prior to a DA election.**
- This represents 5–10% of the baseline non-conviction rate.
- The effect is **most pronounced for property and drug crimes** (1.8pp for drug crimes).
- **No significant effect for violent crimes in the full sample**, but effects appear in competitive districts.

### Heterogeneous Effects

#### By Crime Type
- **Property crimes:** 1.9pp increase in conviction probability (p<.001)
- **Drug crimes:** 1.8pp increase (p<.05)
- **Violent crimes:** No significant effect in full sample (0.012pp, not significant)
  - **Exception:** In districts with electoral competition, violent crime convictions also increase (2.6pp in close races)

#### By Electoral Competition
- **All districts (20 DAs with challengers):** 2.3pp increase in conviction probability
- **Close elections (margin < median):** 2.6pp increase
- Implies electoral pressure is **much stronger in competitive districts**

### Plea Bargaining and Dismissals
- Dismissals decrease: **probability of all charges dismissed falls by 1.3pp** in election years
- The increase in convictions comes primarily from fewer dismissals of weak cases
- **Charge bargaining:** No significant effect (prosecutors don't reduce charge counts more in election years)
- **Seriousness bargaining:** Only significant for property crimes (1.1pp, p<.01)

### Adjudication Timing
- Cases disposed in election years have **fewer charges** (statistically significant only for property crimes)
- **Adjudication time decreases by ~7% in election years** overall
- Suggests prosecutors focus on "quick wins" (simpler cases) near elections

---

## Methodology

### Identification Strategy
**Time-based comparison:** DAs in North Carolina face elections on staggered 4-year cycles (some in presidential/gubernatorial years, some in off-year congressional elections). This variation allows district-level comparisons controlling for year effects.

### Data Structure
- **Unit:** Case disposition (county-year)
- **Sample:** 342,587 defendant-episodes; 1.34 million felony charges, 1990–2001
- **Treatment variable:** Binary indicator = 1 if case disposed within 12 months of DA's election
- **Fixed effects:** County FE + two-year period dummies + calendar month dummies

### Controls
- Crime seriousness classification (UCR hierarchy + Sentencing Act classes)
- District demographics: per capita income, population density, racial composition, voter registration, Republican affiliation
- Prosecutorial resources (population/ADA ratio)
- Time trends (pre/post-1994 Structured Sentencing Act)

### Key Robustness
- Results hold with/without prosecutorial resource controls
- Includes additional controls for police hiring and arrest rates (may be endogenous)
- Pre-SSA and post-SSA trends estimated separately (sentencing reform occurred 1994)

---

## Criticisms and Limitations

### Contested vs. Uncontested Elections
**CRITICAL LIMITATION FOR YOUR WORK:** Dyke does **NOT decompose by whether the DA faces a challenger.** All election years are pooled. This means:
- He identifies an overall "election year effect" (average across contested + uncontested cycles)
- He cannot answer: "Is the effect driven by contested elections specifically?"
- His competitive district subsamples are based on **whether any challenger appeared during the full decade**, not per-election contestation

### Mechanism Ambiguity
The paper shows DAs "get tougher" near elections but doesn't directly test whether this is due to:
1. **Electoral pressure (reelection concerns)**
2. **Voter demand for tough prosecutions** (voters pressure DAs independent of elections)
3. **Caseload cycles** (police hiring cycles correlate with DA elections)

Controls for police hiring/arrests are added but are imperfect.

### Violent Crime Null Result
Why are effects weaker for violent crimes?
- Dyke hypothesizes complexity/cost: violent crime trials are more expensive to prepare
- Alternative: Violent crimes carry high salience; DAs already maximize convictions for these regardless of electoral cycle

---

## Theoretical Framework

### Political Business Cycle Model Applied to Prosecutors
Prosecutors, like other elected officials, face a principal-agent problem with voters. If voters prefer "tough on crime" outcomes:
- **Optimal strategy for DA:** Allocate resources to maximize convictions near elections
- **Mechanism:** Dismiss weaker cases (don't expend resources) and prosecute marginal cases more aggressively
- **Trade-off:** Offer fewer plea concessions to cases worth prosecuting, but may offer MORE concessions in marginal cases to secure wins

Dyke formalizes this through a resource-constrained model: DAs have limited prosecution capacity and allocate effort based on electoral incentives.

---

## Do Results Support or Refute Electoral Contestation Mechanisms?

### What Dyke's Results DON'T Show
- Whether contested elections produce **stronger** effects than uncontested ones
- Whether challengers who run affect case outcomes differently than years with no challengers
- Whether **the threat of competition** (without an actual challenger) is sufficient to generate effects

### Implications for Your Δ ≈ 0 Finding (Contested = Uncontested)
If Dyke's overall effect is driven by:
1. **Uncontested elections** (DAs preemptively get tough to deter challenges) → Your null Δ is consistent
2. **Contested elections** (challengers spur toughness) → Your null Δ would be surprising
3. **Both equally** → Hard to know what to make of your null

Dyke's competitive district results (stronger effects where challengers have appeared) suggest mechanism involves **actual competition**, not mere incumbency. But this doesn't directly address **contested in a given cycle vs. uncontested in that cycle**.

---

## Specific Numbers/Key Coefficients

| Outcome | Full Sample | Property Crimes | Drug Crimes | Violent Crimes |
|---------|-------------|-----------------|-------------|----------------|
| **Conviction (any)** | 0.015*** (0.002) | 0.019*** (0.005) | 0.018*** (0.005) | 0.012 (0.007) |
| **All charges dismissed** | -0.013*** (0.003) | -0.014*** (0.004) | -0.016*** (0.005) | -0.010 (0.007) |
| **Conviction on most serious charge** | 0.015*** (0.003) | 0.019*** (0.005) | 0.010 (0.006) | 0.012 (0.008) |
| **Charge bargaining** | -0.002 (0.002) | 0.007 (0.004) | 0.006 (0.005) | 0.004 (0.007) |

(Standard errors in parentheses; ***p<.01)

---

## Connections to Your Jury Trial Project

### Alignment
- Electoral cycles DO affect case disposition margins (Dyke shows this)
- Effects are larger where **actual electoral competition exists** (competitive district subsamples)

### Tension with Your Findings
- You find Δ (contested - uncontested) ≈ 0 on conviction/dismissal rates
- Dyke finds election effects on these same margins
- **Possible reconciliation:** Your treatment is **contestation in a single election cycle** (2016/2024); Dyke's treatment is **year before election** (within a 4-year cycle). Different granularity.

### Why Your Δ May Be Zero
1. **Jury mobilization story is weaker than expected:** Prosecutors don't change plea/conviction strategy based on electoral pressure
2. **Effects operate elsewhere:** On voir dire utilization (your actual finding), not on case disposition
3. **Institutional differences:** Michigan system (jury-reliant) vs. North Carolina (plea-dominated) may process electoral incentives differently
4. **Timing:** Your treatment (election year) may miss important sub-cycle timing effects

---

## Recommended Follow-Up
If using Dyke to contextualize your work:
- Cite his overall finding that **electoral cycles affect disposition margins**
- Note his limitation: **no decomposition by contestation within cycles**
- Argue that your contribution is to examine whether **contestation itself** (not just election timing) drives disposition changes
- Your null Δ suggests **something other than contestation** is the key mechanism (possibly jury mobilization instead)
