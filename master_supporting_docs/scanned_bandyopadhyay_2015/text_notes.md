# Deep Reading Notes: Bandyopadhyay & McCannon (2015)
## "Prosecutorial Retention: Signaling by Trial"

**Status:** Complete reading of all 34 pages
**Date:** 2026-03-24
**Focus Areas:** Signaling model predictions, contested vs uncontested elections, disposition margins, behavioral mechanisms

---

## 1. CORE RESEARCH QUESTION & MODEL STRUCTURE

### Main Question
How do retention elections distort prosecutorial behavior in choosing between trials and plea bargains? What evaluation metrics create what distortions? Can optimal metrics achieve first-best outcomes?

### Model Setup (Two-Period, Asymmetric Information)
- **Period 1:** Unknown-quality prosecutor (H or L type) observes case strength θ and decides: trial vs. plea bargain
- **Key asymmetry:** Voters know P(high type) = γ but cannot observe type directly
- **Period 2:** Retention decision based on observable signals; voters must infer quality from period 1 actions
- **Retention bonus:** Low-quality prosecutors receive bonus *b* if retained (creates incentive to signal quality)
- **Assumption:** Without retention bonus, prosecutor preferences aligned with welfare (u = αw, α > 0)

### Critical Parameters
| Parameter | Meaning |
|-----------|---------|
| θ ∈ [0, θM] | Evidence strength (prosecutor observes) |
| p_q(θ) | Conviction probability for type q (p_H > p_L for all θ) |
| S(θ) | Sanction if convicted at trial (exogenous; increasing in θ) |
| B(θ) | Plea bargain outcome (increasing in θ) |
| C | Trial cost (fixed, independent of θ or q) |
| θ_q | First-best threshold for type q (θ_L > θ_H: high-type has lower bar) |

---

## 2. FIRST-BEST (FULL INFORMATION) OUTCOME

### Decision Rule (Proposition 1)
Take case to trial if: p_q(θ) w(S(θ)) − C > w(B(θ))

**Result:** Threshold exists θ_q such that:
- Cases θ > θ_q → trial (expected sanction high enough to justify trial cost)
- Cases θ ≤ θ_q → plea bargain (plea is more efficient)
- **Key inequality:** θ_L > θ_H (low-quality prosecutors plea out more cases in first-best)

### Why? High-quality prosecutors win at trial with higher probability, so marginal cases that barely justify trial costs for high-types do NOT justify them for low-types.

---

## 3. SIGNALING UNDER ASYMMETRIC INFORMATION: AGGREGATE SENTENCE LENGTH

### Setup
Voters use observable metric: total sentence length X = ∫B(θ)dF + ∫p_q(θ)S(θ)dF across all cases

### Separating Equilibrium (Proposition 2)
**Equilibrium range:** X^e ∈ (X^φ_L, X^φ_H]

**Behavior:**
- **High-quality prosecutor:** Takes MORE cases to trial than first-best (θ^e_H < θ_H)
  - Distorts downward to inflate aggregate sentence length
  - Purpose: Signal "I'm good at getting convictions" (they win at trial with higher prob)
  - Result: **TOO MANY TRIALS**
- **Low-quality prosecutor:** NOT willing to mimic
  - Even with more trials, they don't win often enough to reach X^e
  - In equilibrium, chooses NOT to distort and forfeits re-election

**Key insight:** High-type bears the distortion cost; low-type selects first-best outcome

### Pooling Equilibrium (Proposition 3)
**Equilibrium range:** X^e ∈ [X_H, X^φ_L]

**Behavior:**
- **Both types:** Take more cases to trial than first-best
  - Result: **TOO MANY TRIALS** (all pooling equilibria)
- Voters cannot distinguish types, so both inflate to signal quality

### Intuition for Sentence-Length Metric
High-quality prosecutors can inflate X by taking weaker cases to trial (they still win often). Low-quality prosecutors struggle with this because they lose more. **Sentence length asymmetrically rewards trial-taking for high types → overuse of trials.**

---

## 4. SIGNALING UNDER ASYMMETRIC INFORMATION: CONVICTION RATE

### Setup
Voters use observable metric: success rate r = (# convictions) / (# trials tried)

### Separating Equilibrium (Proposition 4)
**Equilibrium range:** r^e ∈ (r^φ_L, r^φ_H]

**Behavior:**
- **High-quality prosecutor:** Takes FEWER cases to trial than first-best (θ^e_H > θ_H)
  - Drops weak-evidence cases from trial docket
  - Keeps strong cases where they win
  - Purpose: Signal "I have high conviction rate"
  - Result: **TOO FEW TRIALS, EXCESS PLEA BARGAINING**
- **Low-quality prosecutor:** NOT willing to mimic
  - Would need even fewer trials to achieve high conviction rate
  - Prefers to forgo re-election and choose first-best

### Pooling Equilibrium (Proposition 5)
**Equilibrium range:** r^e ∈ [r_H, r^φ_L]

**Behavior:**
- **Both types:** Fewer cases go to trial than first-best
  - Result: **TOO FEW TRIALS** (all pooling equilibria)

### Intuition for Conviction-Rate Metric
High-quality prosecutors can inflate r by plea-bargaining weak cases (they already win most trials). Low-quality prosecutors would need to plea out even more weak cases to match the rate. **Conviction rate asymmetrically rewards plea-bargaining for high types → underuse of trials.**

---

## 5. OPPOSITION OF DISTORTIONS: THE KEY INSIGHT

### Central Finding (Proposition 6)
**Aggregate sentence length and conviction rate cause OPPOSITE distortions:**

| Metric | Direction | Why |
|--------|-----------|-----|
| Sentence length | **Too many trials** | High-types take weak cases to trial to inflate total sanction |
| Conviction rate | **Too few trials** | High-types plea out weak cases to inflate success rate |

**Combined metric (X*, r*):** If voters require BOTH X ≥ X* AND r ≥ r*, where:
- X* is high-quality first-best level (or slightly lower)
- r* is between low- and high-quality first-best rates (specifically r* ∈ (r_L, r_H])

**Result:** Low-quality prosecutors CANNOT achieve both simultaneously
- To reach X*, they must take many weak cases to trial → drives down r
- Cannot simultaneously inflate r without sacrificing X
- Signals collapse; low-types choose first-best outcome and lose re-election

**First-best achieved:** High-types choose first-best, low-types choose first-best (by necessity)

---

## 6. CONTINUUM OF TYPES (Propositions 7-8)

### Semi-Separation Pattern
When prosecutors vary continuously in quality q ∈ [q_D, q_U]:

**With single metric (e.g., sentence length):**
- Lowest types (q < q'') → first-best (not worth distorting)
- Middle types (q ∈ [q'', q']) → pool on signal X' (distort to signal)
- Highest types (q > q') → first-best (naturally exceed X')

**With combined metrics (X_q, r_q):**
- Unique threshold q̄ such that:
  - q < q̄ → cannot achieve both targets → replaced
  - q ≥ q̄ → achieve targets → retained
  - All types at or above threshold choose first-best

**Key:** Multiple metrics achieve unique separating threshold (no pooling). Single metrics yield multiple equilibria with partial pooling.

---

## 7. RELEVANCE TO YOUR EMPIRICAL WORK: Δ(contested − uncontested) = 0

### Theoretical Prediction for YOUR SETTING

**Your finding:** Contested incumbent elections (treatment) show Δ ≈ 0 on plea/verdict counts, but null/negative effects on verdict rates and capital felony frequency.

### What Bandyopadhyay & McCannon Predict

#### Scenario A: If voters evaluate by conviction rate
- Prosecutors facing contestation should REDUCE trials (plea bargain more)
- High-quality prosecutors particularly sensitive (they can afford to drop weak cases)
- **Prediction:** Fewer jury trials, more pleas → ✓ CONSISTENT with your verdict suppression finding

#### Scenario B: If voters evaluate by sentence length
- Prosecutors facing contestation should INCREASE trials
- Take more cases to trial to inflate aggregate sentences
- **Prediction:** More jury trials → ✗ CONTRADICTS your finding

#### Scenario C: If voters evaluate by both metrics (optimal screening)
- Prosecutors face cross-pressure: can't win on both dimensions
- **Prediction:** Modest/null trial-count effects, with composition shifts (lower capital felony share)
- → ✓ CONSISTENT with your finding that trial counts ≈ flat but verdict mix shifts

### The Model Suggests Your Δ ≈ 0 Means:

1. **Voters are NOT evaluating on sentence length alone**
   - If they were, you'd see trial increases under contestation

2. **Voters evaluate on conviction rate OR both metrics**
   - Conviction-rate focus → prosecutors plea bargain more, avoid weak trials
   - Result: Trial counts may stay flat (mix shifts to stronger cases), verdict rates fall (fewer weak trials to lose)

3. **Alternative:** Your "shadow contraction" story (reduced jury usage even if trial counts stable)
   - Model predicts that conviction-rate-focused voters cause prosecutors to be **selective** about which cases go to trial
   - They keep high-conviction-probability cases but drop marginal ones
   - This produces: flat count, shifted composition, lower overall success rates in jury pool

---

## 8. BEHAVIORAL MARGINS THE MODEL ADDRESSES

### What the Model Can Explain
✓ **Selection of cases for trial vs. plea** (primary margin)
✓ **Composition shifts:** Prosecutors taking "easier" vs. "harder" cases to trial
✓ **Aggregate outcomes:** Total sanctions, total convictions, conviction rates
✓ **Why trial counts can be flat while verdict composition shifts** (Scenario C)

### What the Model CANNOT Explain
✗ Juror selection/voir dire behavior (model is about prosecutor case selection, not jury behavior)
✗ Verdict rates per se (jurors decide verdicts; model is about case selection)
✗ Jury size/number effects (assumes uniform jury pool)
✗ Mechanisms OTHER than case selection (e.g., prosecutorial effort in preparation)

### Your Evidence of Verdict Suppression (Lower % capital guilty)
The model predicts prosecutors would shift composition under conviction-rate pressure, but does NOT directly explain:
- Lower verdict rates among the cases that ARE tried
- Why contested elections would reduce juries' likelihood of conviction

**Possible extensions:**
- Prosecutors avoid weak cases → remaining trials are on moderate evidence → lower conviction rates even in filtered pool
- Selection effect: if prosecutors drop marginal cases, the jury pool has fewer "slam dunks" and more contested evidence
- Juror composition changes (fewer jurors called from "tough on crime" subsample?)

---

## 9. KEY PROPOSITIONS SUMMARY TABLE

| Proposition | Metric | Equilibrium Type | Effect on Trials | Effect on Pleas | Key Finding |
|-------------|--------|------------------|------------------|-----------------|-------------|
| 2 | Sentence length | Separating | Too many | Too few | High-types distort upward |
| 3 | Sentence length | Pooling | Too many | Too few | Both types inflate |
| 4 | Conviction rate | Separating | Too few | Too many | High-types distort downward |
| 5 | Conviction rate | Pooling | Too few | Too many | Both types compress docket |
| 6 | Both (X*, r*) | Separating | **First-best** | **First-best** | Opposite distortions cancel |
| 7 | Sentence length | Semi-separation (continuum) | Partial distortion | Partial distortion | Middle types pool |
| 8 | Both (X_q, r_q) | Separating (continuum) | **First-best** | **First-best** | Unique threshold |

---

## 10. CRITICAL ASSUMPTIONS & ROBUSTNESS

### Assumptions that Drive Results
1. **u(P) = αw(P)** → Prosecutors aligned with welfare absent retention concerns
   - Relaxing this (e.g., prosecutors prefer longer sentences regardless) would dampen signaling
2. **Large number of cases** → Expected values approximate realized distributions
3. **p_q(θ) known to voters** → Voters know high-types have higher conviction probability
   - If unknown, signal identification breaks down
4. **θ observed by prosecutor before decision** → Prosecutor has private information
5. **p_H(θ) > p_L(θ) ∀θ** → Quality translates to better performance on all cases

### Robustness Checks in Paper
- **Double-crossing plea/trial tradeoff** (Appendix A): Results hold; conviction-rate effect still causes trial reduction
- **Type-dependent plea bargains** (Appendix B): Results weaken (separating range shrinks) but hold
- **Type I & II errors in trial/plea outcomes** (Appendix C): Results robust if error rates not too high

---

## 11. POLICY IMPLICATIONS FOR YOUR PAPER

### What B&M Suggest About Contested Elections
- **Contested elections likely cause voters to focus on conviction rate** (political pressure to "solve" the contest by emphasizing success metrics)
- This focus predicts trial reduction and jury underuse
- The model suggests this is NOT inefficient per se if the baseline is sentence-length focus
- Instead, it's a shift from one distortion to another

### Why Your Δ ≈ 0 Makes Theoretical Sense
1. If prosecutors shift from sentence-length to conviction-rate optimization under contestation
2. The first distortion caused trial increases; second causes trial decreases
3. Net effect on trial counts ≈ zero (they offset)
4. But composition shifts (drop weak cases) → verdict rates fall despite flat counts

### Testable Implication for Future Work
- **Examine whether uncontested prosecutors have more diverse case dockets**
  - If sentence-length focused, should see more weak-evidence trials
  - If conviction-rate focused, should see more strong-evidence trials
  - Contested → more selection, narrower docket

---

## 12. HOW THIS PAPER FILLS THE THEORY GAP IN YOUR FINDINGS

### What Your Data Shows (Empirical)
- Contestation → null trial effects, null plea effects, verdict suppression
- Interpretation: "shadow contraction" (prosecutors use juries less, verdicts lower)

### What B&M Provides (Theory)
1. **Mechanism:** Retention elections cause case-selection distortions
2. **Direction depends on evaluation metric:**
   - Sentence-length metric → too many trials (your baseline)
   - Conviction-rate metric → too few trials (under contestation)
3. **Net effect on counts can be zero** even if behavior changes (composition shifts)
4. **Verdict rates fall** because prosecutors become more selective, avoiding weak cases → remaining trials are marginal → lower conviction rates

### The "Shadow Contraction" Narrative Now Has Foundation
Instead of "prosecutors mysteriously avoid juries," the B&M model says:
> "Contested elections activate voter focus on conviction rates, causing prosecutors to shift to a conviction-rate-optimizing strategy. This distorts case selection (fewer weak-evidence trials), leaving trial counts flat but composition shifted and verdicts lower."

---

## 13. UNSOLVED QUESTIONS (For Future Extensions)

1. **Why does contestation specifically activate conviction-rate focus?**
   - B&M doesn't explain which metric voters use; you'd need to show voters care about conviction rates when elections are close

2. **Do jurors respond to composition shift?**
   - Model predicts prosecutors select cases differently
   - But jury verdict rates could also be affected by juror composition or prosecutor effort changes
   - B&M assumes juries are fixed; your verdict data suggests they're not

3. **Can we distinguish case-selection distortion from effort distortion?**
   - Model predicts cases tried differ in strength
   - If prosecutors also reduce effort on marginal cases, verdicts fall even faster
   - Need evidence on prosecutor preparation/effort by contestation status

4. **Generalization to other metrics**
   - What if voters care about speed (case disposition time)?
   - What if conviction rate is weighted by severity (avoiding weak cases on serious charges)?
   - B&M framework extends but cases analyzed are limited

---

## 14. BOTTOM LINE FOR YOUR RESEARCH

**B&M Theoretical Takeaway:**
> Contested elections, if they cause voters to focus on conviction rates, predict exactly your empirical pattern: flat trial counts, composition shifts, lower verdict rates. This is not a mysterious "shadow contraction" but a rational response to a different signal that prosecutors must satisfy.

**How to use this in your paper:**
1. Cite B&M as the theoretical foundation for why electoral incentives distort case selection
2. Explain that Δ ≈ 0 on counts but Δ < 0 on verdicts is CONSISTENT with conviction-rate-focused voter screening
3. Suggest that the evaluation metric (conviction rate vs. sentence length) is the missing link between theory and data
4. Propose extensions: measure voter focus on different metrics, examine case composition shifts empirically

---

## REFERENCES & CITATIONS

**Full Citation:**
Bandyopadhyay, S., & McCannon, B. C. (2015). Prosecutorial retention: Signaling by trial. *Journal of Public Economic Theory*, 17(2), 219–256.

**Key propositions to cite:**
- Proposition 2 (Sentence length → too many trials)
- Proposition 4 (Conviction rate → too few trials)
- Proposition 6 (Combined metrics → first-best)
- Section 6 (Policy implications)
