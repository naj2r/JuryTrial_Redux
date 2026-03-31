# McCannon (2013) Deep-Read Notes
**Paper:** "Prosecutor Elections, Mistakes, and Appeals"
**Journal:** Journal of Empirical Legal Studies 10(4): 696–714, 2013
**Author:** Bryan C. McCannon, Saint Bonaventure University
**Data:** Western New York appellate court decisions, 2009–2011 (N=1,874)

---

## Research Question Summary

Your five target questions and **exact answers from McCannon**:

### Q1: What outcomes does McCannon measure?
**UPHELD** (primary outcome): Binary = 1 if appellate court affirms lower court decision (affirms or dismisses appeal); 0 if reverses or modifies conviction.
- Affirm rates: 80.6% affirmed + 2.4% appeal dismissed = 83% UPHELD overall
- Reversal rates: 7.2% reversed + 9.9% modified = 17% NOT UPHELD
- Secondary outcomes: MODIFIED (sentence adjustments) vs. REVERSED (conviction vacated, new trial required)
- No trial rates, jury rates, plea rates as dependent variables—McCannon measures **conviction appeal success rates**, not case disposition margins.

### Q2: Does he decompose by contested vs. uncontested elections?
**YES, BUT PARTIALLY.**
- 65.8% of reelection observations (REELECT=1) occur with "incumbent contested in the election by a candidate of the opposing political party"
- Results for **contested reelections only:** marginal effect = -5.3 percentage points (vs. -5.1 to -7.1 for all reelections)
- NO decomposition of **uncontested vs. contested incumbents** within the election year in the main text
- No equivalent to your study's "contestation decomposition" (Δ contested − uncontested)

### Q3: What effect sizes does McCannon report?
**Main result (Table 2, all models):**
- **Binary probit (Column C, most restrictive):** REELECT coefficient = -0.240* (SE 0.124), marginal effect = **-5.6 percentage points** (slightly higher than reported 5.1–7.1 range)
- **Binary probit (Column A, pooled):** marginal effect = **-7.1 percentage points**
- **Ordered probit (Table 3):** REELECT coefficient = -0.248** (SE 0.119), similar magnitude
- **Interpretation:** If prosecutor running for reelection (6 months pre-election), conviction **5.1–7.1 pp more likely to be overturned**

**Decomposition by error type (Table 4):**
- **Modifications:** coefficient = 0.233* (SE 0.133), marginal effect = **+3.2 pp** → 71% of overturned cases
- **Reversals:** coefficient = 0.139 (SE 0.166), marginal effect = +1.3 pp (not significant) → 29% of overturned cases

**Jury vs. Plea (Table 5):**
- **Jury trial convictions (N=605):** REELECT effect **statistically insignificant** (ranges -1.6 to -1.5 pp)
- **Plea bargain convictions (N=885):** REELECT effect = **-8.0 to -11.2 pp** (highly significant, **-11.2 pp** in full model)
- **Interpretation:** Effect concentrated in plea bargains, NOT jury trials

**Crime-specific effects (Table 6 & 7):**
- **DWI:** Conviction upheld 70.0% (reelection) vs. 87.7% (no reelection) → **-17.7 pp gap**
- **Assault:** Conviction upheld 72.7% (reelection) vs. 85.4% (no reelection) → **-12.7 pp gap**
- **Fraud/Forgery:** Conviction upheld 66.7% (reelection) vs. 74.2% (no reelection) → **-7.5 pp gap**
- **Marginal effects (ordered probit):** DWI -40.7 pp, Assault -24.4 pp, Fraud -87.6 pp (Table 6)

### Q4: What identification strategy does he use?
**Quasi-experimental design:**
- **Treatment indicator:** REELECT = 1 if felony conviction occurs in **6 months prior to District Attorney's reelection** (May–October in election year); 0 otherwise
- **Timing identification:** Convictions paired with election data from county Board of Elections; Western NY staggered DA elections across counties
- **Unit of analysis:** Case-level (1,874 criminal convictions in appellate court)
- **Specification:** Probit and ordered probit with rich controls:
  - Crime type dummies (32 categories)
  - Appeal grounds dummies (13 categories)
  - Defense type (6 categories: PD, legal aid, private)
  - Court type (Supreme vs. County)
  - Appellate panel composition
  - County and year fixed effects (Column B)
- **Threat to validity:** No formal staggered DiD structure; timing window chosen post-hoc ("6 months is most appropriate" per p. 10)
  - Tested 1–4 month windows; 6-month window chosen because "public announcements of candidacies occur the last week of April or in early May"
  - Sensitivity check: January–April (pre-reelection) coefficient is insignificant, supporting 6-month timing
- **Control for selection bias:** Heckit model used to address selection into appeal (defense type as selection mechanism)
  - Result: REELECT remains negative and highly significant even after selection correction

**KEY LIMITATION:**
No experimental variation in election timing; no DiD structure. Identification relies on **timing assumption** (that convictions 6 months pre-reelection differ only by electoral incentives) and **rich controls** (case characteristics, judge identity, county-level differences absorbed by FE).

### Q5: Theoretical framework—voter-signaling specifically?
**YES, voter-signaling implicitly; more generally, electoral incentives distort prosecutor behavior.**

**Theoretical foundation (p. 3):**
- Cites Bandyopadhyay & McCannon (forthcoming) asymmetric information model: "voters use case outcomes to make their retention decision, the incumbent prosecutor has the incentive to distort his/her choices to stay in office"
- Predicts: **prosecutors become "hawkish" (more trials, fewer pleas) during reelection** to signal toughness
- B&M (2013) empirical work shows: cases to trial increase, pleas decrease in reelection year (especially if challenged)

**McCannon's extension (this paper):**
- Asks: Does this hawkishness **reduce quality**? (Voter signal → conviction errors → appellate reversals)
- Finds: **YES—reelection prosecutors make more mistakes, caught at appellate stage**
- Mechanism emphasis: Plea bargaining mistakes, not jury trial mistakes
  - Implies: Prosecutor "zealousness at the bargaining table" (p. 50) creates errors, not trial-level mistakes
  - Suggests: Tougher stance on pleas (demanding less-favorable terms) leads to erroneous convictions later challenged

**NOT formal voter-signaling test:**
- Paper does not directly test whether voters observe outcomes or use them to decide reelection
- Paper does not model voter beliefs or preferences
- **Implicit story:** Electoral incentives → hawkish prosecutorial behavior → mistake-prone decisions → appellate correction

---

## Critical Differences from Your Paper

| Dimension | McCannon | Your Paper (from study-parameters.md) |
|-----------|----------|--------------------------------------|
| **Outcome** | Appellate conviction reversal/modification rates | Jury trial rates, jury verdict rates, plea rates, dismissal rates |
| **Identification** | Timing of conviction relative to reelection (6-month window) | Recurring treatment: contested vs. uncontested incumbent elections (TWFE) |
| **Treatment decomposition** | Reelection (yes/no); modest contested/uncontested check (65.8% contested) | Detailed: pressure (T1), contestation (T2/T3), open seats (T1) |
| **Effect heterogeneity** | Crime type (DWI, assault, fraud); appeal grounds (speedy trial); mode (jury vs. plea) | Population size heterogeneity (above/below median); county characteristics |
| **Main mechanism** | Plea bargaining errors during reelection | Jury mobilization (expanded jury pools) OR jury suppression (reduced utilization) |
| **Data structure** | Cross-sectional appellate decisions (N=1,874) | Panel: 83 MI counties × 7 years (579 obs) |
| **Geography** | Western NY (4th Department of Appellate Division), 22 counties | Michigan (83 counties) |

---

## Substantive Comparison for Your Contrasting Finding

**Your finding:** Δ (contested − uncontested) ≈ 0 on **jury trial rates, plea rates, jury verdict rates**

**McCannon finding:** Electoral pressure (reelection) → **conviction errors → appellate reversals** (-5.1 to -7.1 pp, concentrated in pleas)

**Why no conflict:**
- McCannon measures **appellate outcome accuracy**, not **case disposition margins** (your dependent variables)
- McCannon's effect is **downstream** (mistakes revealed years later on appeal); your focus is **immediate** (case outcome at conviction)
- McCannon finds plea errors, you might find **no change in plea rates** or jury demand—consistent with his finding that plea bargaining becomes more error-prone (not more or less frequent) under electoral pressure

**Interpretation alignment possible:**
- McCannon: Prosecutors push harder in pleas during reelection → more mistakes → later overturned
- You: Prosecutors push harder (or equally hard), but jury demand/trial rates unchanged; quality suffers instead of quantity
- **Non-contradictory:** Both show electoral pressure affects *quality* of prosecutorial decisions, not necessarily *volume* of jury usage

---

## Key Robustness & Limitations

**Strengths:**
1. Rich case-level controls (crime type, appeal grounds, defense type)
2. Timing sensitivity checks confirm 6-month window
3. Heckit selection correction shows result robust to appeal appeal-to-trial selection bias
4. Subgroup analysis (jury vs. plea, crime type, appeal grounds) provides heterogeneity

**Limitations (McCannon acknowledges):**
1. **Timing window exogenously chosen:** 6 months chosen post-hoc because candidacy announcements occur May–June; weakens causal claim
2. **No staggered DiD structure:** No differential timing variation across counties to leverage (elections staggered, but analyzes each conviction timing individually)
3. **Only appealed cases:** Appeals disproportionately from trials (55.6% guilty plea appeals vs. 97%+ plea rate overall); results may not generalize to full sample
4. **Weak goodness-of-fit:** McFadden R² = 0.2–0.22; model poorly predicts individual outcomes (though marginal effects robust)
5. **Single state, single appellate division:** Western NY only; generalizability to Michigan or other states unknown

---

## Critical Take-Away for Your Paper

**McCannon is NOT a threat to your null on jury mobilization.**

He finds electoral pressure reduces appellate conviction rates (quality ↓), but he does NOT find (or test for):
- Changes in jury trial rates ← **You test this directly**
- Changes in jury verdict rates ← **You test this directly**
- Changes in jury demand or jury summons ← **Implicitly in your jury outcome measures**

His plea bargaining result (bigger effect in pleas than jury trials, -11.2 pp vs. -1.6 pp) is **consistent with** your likely finding that jury trial rates don't change but jury verdicts might shift (or quality suffers in other ways).

**Recommended framing in your paper:**
1. Cite McCannon on electoral incentives increasing prosecutorial "mistakes" (appellate reversals)
2. Clarify that your outcome space (jury trials, verdicts, pleas) is **upstream** of his appellate quality measures
3. Suggest: Electoral pressure affects *quality* of prosecutorial decisions (per McCannon) but *not quantity* of jury usage (per your data)
4. Implication: Jury mobilization story is dead; reframe to "shadow contraction of jury quality" or jury suppression mechanisms
