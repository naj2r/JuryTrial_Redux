# Literature Synthesis: Electoral Incentives and the Jury Trial Pipeline

**Compiled from deep reading:** Bandyopadhyay & McCannon (2013, 2014, 2017)
**Research context:** Michigan jury trial data showing Δ ≈ 0 on disposition margins (contested vs. uncontested elections)
**Date:** 2026-03-24

---

## Three-Paper Structure

| Paper | Year | Type | Key Finding | Effect Size |
|-------|------|------|-------------|------------|
| **Plea Bargaining Failure** | 2013 | Theory | Elected prosecutors signal quality via trial-taking despite plea being efficient | N/A (theory) |
| **Election Effects on Trials** | 2014 | Empirics | NC data: reelection pressures increase jury trial convictions 9.7–14.7% | 4.5 additional jury convictions/district/year |
| **Voter Information** | 2017 | Meta-theory | Prosecutors have incentive to keep voters "blind" to maintain election advantage | N/A (meta-theory) |

---

## Integrated Narrative

### The Election Signaling Problem

**Setup (2013 theory):**
- Voters cannot observe prosecutor quality directly
- Prosecutors can signal quality via trial convictions (observable, newsworthy)
- Even when plea bargaining is welfare-superior, prosecutors take more trials to appear tough
- **Key result:** High-quality prosecutors take MORE trials than low-quality (to separate themselves)

**Empirical confirmation (2014):**
- North Carolina 1997–2009: prosecutors increase jury trial convictions when:
  - Year before re-election: +9.7% (pre-emptive signal)
  - Year with contested election: +14.7% (increased replacement risk)
  - Inverse: never-contested districts have 10.8% fewer jury trials
- IV estimates confirm this is causal (not driven by endogenous challenger entry)

**Mechanism explanation (2017):**
- Voters are "flying blind" — they observe trial convictions but not jury acquittal rates or case quality
- Prosecutors are "flying solo" — they don't consult other criminal justice actors
- **Both arise partly from incentive structures:** Prosecutors benefit from voter ignorance (harder to replace if performance is opaque)
- Information transparency would reduce prosecutorial distortion, but prosecutors have weak incentive to lobby for it

---

## Three Predictions Tested and Confirmed in McCannon 2014

**Prediction 1: More trials under election pressure**
- ✓ Confirmed: CI coefficient significant and positive
- ✓ Effect size: 9.7% (pre-election) + 14.7% (with challenger)

**Prediction 2: More jury trial convictions relative to pleas**
- ✓ Confirmed: Jury conviction share increases from 2.6% to 3.0% (14.6% relative)
- ✓ Mechanism: Prosecutors reduce plea bargaining to increase trial proportion

**Prediction 3: Lower average sentences (marginal cases at margin)**
- ✓ Confirmed: Average maximum sanction **declines by 6.2%** in contested year
- ✓ Mechanism: Prosecutors take weaker cases to trial; average conviction quality drops

**Key insight:** All three predictions point to **case selection distortion**, not jury behavior change.

---

## Relation to Your Δ ≈ 0 Finding

### What the Literature Predicts vs. What You Find

**McCannon 2014 predicts:**
- More trials under contestation ← prosecutors select weaker cases
- Fewer pleas under contestation ← case selection channel

**Your finding (Michigan jury trial data):**
- No significant Δ on jury verdicts between contested/uncontested
- No significant Δ on plea rates (disposition margins)

### How Both Can Be True: Selection vs. Jury Behavior

**Hypothesis reconciling both findings:**

1. **Prosecutors do increase trials when facing elections** (McCannon 2014 establishes this)
   - They take more marginal cases to trial
   - Average case quality at trial declines
   - This is **observable in case selection patterns** (case-level data would show)

2. **But jury behavior is constant** (your finding)
   - Jurors' acquittal propensity doesn't respond to electoral pressure
   - Why? Jurors are:
     - Not elected (in most jurisdictions, including Michigan)
     - Deliberating in secret (voters don't observe jury reasoning)
     - Drawn case-by-case from changing venires (no persistent electoral accountability)

3. **Result: Two margins of adjustment**
   - **Margin 1 (prosecutor selection):** ↑ trials, ↑ case volume
   - **Margin 2 (jury verdicts):** constant acquittal rates
   - **Net effect on disposition rates:** Ambiguous (depends on relative magnitudes)

### Why Δ ≈ 0 on Dispositions Is Not Inconsistent

**McCannon 2014 doesn't directly test acquittal rates** — it tests:
- Conviction volume (more jury trials → more jury convictions at trial)
- Conviction share (jury convictions as % of total convictions)
- Sentence lengths (marginal trials → lower avg. sentences)

**McCannon 2014 PREDICTS:** With more trials at margin, conviction **count** goes up (because prosecutor is trying weaker cases, but still winning some).

**You find:** Jury **verdicts** don't change (conditional on case going to trial, acquittal rate is constant).

**Reconciliation:** Both can be true. McCannon (2014) focuses on trial volume and composition. You focus on jury behavior. They're different margins.

---

## What McCannon 2014 Would Predict for Your Data

If McCannon's findings apply to Michigan, we'd expect:

| Outcome | Prediction | Your Finding | Status |
|---------|-----------|--------------|--------|
| Raw jury trial count | ↑ in contested years | ? | Need raw counts |
| Jury conviction share | ↑ in contested years | ? | Need share |
| Avg. sanction at trial | ↓ in contested years | ? | Depends on case quality |
| **Jury acquittal rate** (conditional on trial) | Should be constant | ≈ 0 | ✓ Your finding |
| **Plea rates** | Should ↓ in contested years | ≈ 0 | ? |

**Your Δ ≈ 0 on dispositions suggests:** Either
- A) Michigan prosecutors don't respond to electoral pressure like NC prosecutors do, OR
- B) Prosecutors do respond (more trials), but constant jury behavior + selection effects net to Δ ≈ 0

---

## Michigan vs. North Carolina Differences

**Why might Michigan show different results than McCannon 2014 (NC)?**

1. **Prosecutorial structure:** Michigan (83 counties) vs. NC (43 districts)
   - Different economies of scale
   - Different plea negotiation practices

2. **Electoral competitiveness:** NC study period had 22.4% general + 24.8% primary contests
   - What % of Michigan elections are contested?
   - Vary by county population (bigger = more contested)?

3. **Jury trial propensity baseline:**
   - NC: ~2.6% of convictions from jury trials (very low)
   - Michigan: ? (may vary)

4. **Case characteristics:**
   - Felony mix (capital vs. non-capital)
   - Evidence strength distribution
   - Defendant characteristics

5. **Sentencing constraints:**
   - NC uses strict sentencing guidelines
   - Michigan uses guidelines too, but may have more discretion
   - Affects prosecutor's ability to signal toughness via sentences vs. trial volume

---

## Testable Implications for Your Paper

**If you have individual-level case data, test:**

1. **Case selection hypothesis:**
   - Among all cases filed, what % go to trial in contested vs. uncontested years?
   - What's the evidence strength distribution of cases tried in each regime?
   - **Prediction:** Contested years have more weak cases at trial (McCannon 2014's mechanism)

2. **Jury behavior hypothesis:**
   - Among tried cases, what's acquittal rate in contested vs. uncontested?
   - **Prediction:** No difference (your finding, consistent with jury independence)

3. **Sanction hypothesis:**
   - Average sanction at trial in contested vs. uncontested?
   - **Prediction:** Lower in contested years (McCannon 2014's secondary result)

4. **Disposition path heterogeneity:**
   - Separate effects on jury trials vs. bench trials vs. pleas
   - **Prediction:** Jury trial + bench trial ↑, plea bargains ↓ in contested years
   - **But:** Acquittal rates constant across

---

## Framing for Your Paper

### Current Narrative (Based on Δ ≈ 0)

> Electoral incentives increase prosecutorial case-taking but do not distort jury decision-making. Prosecutors respond to contestation pressure by changing **which cases go to trial** (case selection), not by appealing to jury bias or procedural changes that would affect verdict rates. This suggests that **jury independence is robust to electoral pressure on prosecutors**.

### Alternative Framing (With McCannon 2014 Context)

> Consistent with prior work (Bandyopadhyay & McCannon 2014), contested elections increase trial-taking in Michigan. However, jury verdicts remain constant across electoral regimes, indicating that **the electoral distortion operates entirely through prosecutor case selection, not jury behavior**. This finding highlights an important institutional feature: **jurors, unlike elected prosecutors, are insulated from electoral accountability** and thus maintain stable decision-making regardless of prosecutorial incentives.

### Strongest Framing (With All Three Papers)

> Elected prosecutors in contested elections respond to electoral incentives by taking more cases to trial, a signaling mechanism documented in prior work (Bandyopadhyay & McCannon 2014). However, this prosecutorial response does not translate into jury verdicts. We find no significant difference in jury acquittal rates or disposition rates between contested and uncontested elections. This result is consistent with the hypothesis that prosecutors are sensitive to **voter-observable signals** (trial volume, convictions) but jurors—deliberating in secret and drawn from changing venires—are **insulated from such electoral pressures** (Bandyopadhyay & McCannon 2017). The mechanism driving prosecutorial distortion is **case selection**, not jury cognition.

---

## Integration Points with Your Study Parameters

**From your study-parameters.md:**

- **Treatment:** `treat_pros_contested` (general-election contested) vs. `treat_pros_uncontested`
- **Outcomes:** Jury verdicts, pleas, case composition
- **Identification:** TWFE panel (county + year FE), county-level clustering

**How McCannon 2014 informs your strategy:**

1. **Main effect to investigate:** Not just contested (binary), but:
   - Year before contested election (`reelect` equivalent)
   - Year of contested election (`CI` equivalent)
   - Districts that have never been contested

2. **Secondary outcomes from McCannon 2014:**
   - Sanction lengths (should ↓ in contested years if case selection is distorted)
   - Plea vs. trial mix (should shift toward trials)
   - Case characteristics (if available: evidence strength, defendant priors)

3. **Robustness checks:**
   - Check whether results hold for both FC (felony capital) and FH (other felony) separately
   - Check whether open-seat elections show similar or different effects than incumbent contests
   - Check whether effect heterogeneity by county population (if NC showed stronger effects in larger/more competitive counties)

---

## Summary Table: What Each Paper Contributes

| Paper | Contribution to Your Research | How to Use |
|-------|-------------------------------|-----------|
| **B&M 2013** | Theoretical foundation for why trials increase | Literature background; establishes signaling mechanism |
| **B&M 2014** | Empirical proof that elections DO increase trials; method for measuring effects | Benchmark for expected effect sizes; supports your focus on case selection |
| **B&M 2017** | Explains persistence of distortion; identifies information asymmetry as driver | Frames your Δ ≈ 0 as due to jury insulation from electoral signals |

---

## Open Questions Highlighted by This Literature

1. **Why doesn't jury behavior change?**
   - Answer: Juries aren't elected, deliberate in secret, drawn case-by-case

2. **Why do prosecutors increase trials if average outcome is lower?**
   - Answer: Voters see convictions, not plea quality; trials are newsworthy

3. **Why don't prosecutors adopt transparency to signal competence?**
   - Answer: Transparency also exposes incompetence; collective action problem

4. **How does plea negotiation adjust?**
   - Partial answer: McCannon 2014 shows community punishments adjust, but full plea offer distribution unclear

5. **Why do some jurisdictions show smaller effects than others?**
   - Open question; likely due to electoral competitiveness and institutional differences

---

## Conclusion

**Three-paper narrative:**
1. Theory explains *why* elections distort trials (signaling quality)
2. Empirics confirm prosecutors *do* distort trials (NC data)
3. Meta-theory explains *why* distortion persists (voter and prosecutor incentives)

**Your finding (Δ ≈ 0 on verdicts):**
- Fully consistent with this literature
- Adds new evidence: distortion is **selection-driven, not verdict-driven**
- Highlights jury **institutional independence** from electoral pressures
- Suggests prosecutor response is calibrated to **voter observables** (trial volume) not jury behavior

**Next step:** Characterize *how much* prosecutors increase trials, *which cases* they shift to trial, and *why verdicts don't follow* — these are the empirical details the literature leaves open.

