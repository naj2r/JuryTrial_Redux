# Deep Reading Notes: "Re-election Concerns and the Failure of Plea Bargaining"

**Authors:** Siddhartha Bandyopadhyay, Bryan C. McCannon
**Journal:** Theoretical Economics Letters, 2013
**Pages:** 5 pages (theory paper)
**Citation:** Bandyopadhyay & McCannon (2013)

---

## Paper Summary

Short theoretical model establishing that elected prosecutors facing re-election may take cases to trial even when both prosecutor and defendant know plea bargaining is efficient. The central mechanism: voters cannot observe prosecutor quality directly, so prosecutors signal quality via trial convictions.

---

## Core Theory

### Setup (Two-Period Model)

- **Incumbent prosecutor:** Unknown quality $q \in \{H, L\}$, prob of high-quality = $\gamma \in (0,1)$
- **Evidence strength:** $\theta \in [0, \theta_M]$ for each case; known to both prosecutor and defendant
- **Conviction probability:** High-quality wins at trial with prob $p_H(\theta)$; low-quality with prob $p_L(\theta)$ where $p_H > p_L$ and both increasing in $\theta$
- **Trial cost:** $c > 0$ borne by both parties
- **Plea bargain:** Fixed agreement $b$ where $0 < b < c$ and $0 < b < qp_\theta s$ for all $q$
- **Sanction:** $s$ (expected outcome of trial conviction, exogenously set)

### Key Assumption: Plea Bargaining Is Always Efficient

**Stark assumption (Eq. 1):** For ALL cases, welfare from plea $w(b) > E[\text{trial}] = qp_\theta w(s) - w(c)$ for both prosecutor types.

This makes the model stark: both parties would prefer to plea. Yet trials still occur.

### Prosecutor Preferences

- **Without retention motivation:** Utility proportional to welfare ($u(z) = \alpha w(z)$)
- **With retention motivation:** Prosecutor also receives bonus $R > 0$ if re-elected
- **Voters' metric:** Cannot observe quality; use aggregate sentence length obtained to infer type

---

## Main Results

### Proposition 1: Separating Equilibrium

**There exist separating equilibria where:**
- High-quality prosecutor achieves conviction threshold to signal type and is retained
- Low-quality prosecutor plea-bargains all cases and is not retained
- **Crucially:** High-quality prosecutor takes MORE cases to trial than low-quality (counter-intuitive!)
- Low-quality prosecutor selects first-best (welfare-maximizing) number of trials

**Mechanism:** High-quality prosecutors are MORE successful at trial (higher $p_H$), so they must take substantially more cases to trial to separate themselves. This over-litigation signals their superior ability.

### Proposition 2: Welfare Loss

**Separating equilibria generate lower total welfare than universal plea bargaining IF:**
$$1 - \frac{V_H - V_L}{[w(b) - c] - [p_H w(s) - w(c)]} > \frac{F(\theta_H)}{F(\theta_M)}$$

Intuitively: welfare loss occurs when trial costs are high, replacement quality is poor, or the benefit of retaining a high-quality prosecutor is small.

---

## Effect Sizes and Predictions

**No explicit effect sizes given** (theoretical paper). Key prediction:

**Contested elections → More trials** because $z$ (probability of replacement) increases when facing challenger.

---

## Identification Strategy

**None** (theory paper). But the model makes falsifiable predictions:
- Incumbent prosecutors take more cases to trial in election years
- Contested elections amplify this effect
- Aggregate sentences decline (because marginal cases tried have lower evidence)

---

## Relation to Our Findings (Δ ≈ 0 on Dispositions)

**Critical gap:** This model predicts **changes in trial volume** (more trials taken), not changes in **jury verdicts or disposition rates**.

Our finding: Δ ≈ 0 on verdicts **is consistent** with this theory IF:
- Electoral pressure increases trial-taking (which it does per McCannon 2014 below)
- But **jury conviction rates DO NOT CHANGE** between contested and uncontested
- The model says trials increase to signal quality, but doesn't predict that jury acquittal rates change

**Implication for our paper:** Electoral pressure may increase trial mix without changing jury acquittal propensity. This is actually a clean separation: prosecutors change **what cases go to trial** (selection effect) but jurors don't change **how they decide those cases** (jury behavior invariant to elections).

---

## Contested vs. Uncontested

**Not explicitly tested** in the theory, but implied: contested elections create stronger reelection pressures (higher $z$), so we expect larger distortions in contested years.

---

## Strengths of Paper

1. **Clean mechanism:** Asymmetric information + signaling framework
2. **Stark assumption:** By assuming plea is always efficient, isolates the election distortion
3. **Welfare analysis:** Explicitly considers whether signaling destroys social welfare

## Weaknesses

1. **Pure theory:** No empirical test; relies entirely on cited evidence (Rasmusen et al. 2009, Gordon & Huber 2002)
2. **Binary quality assumption:** Real prosecutor quality is likely continuous
3. **No heterogeneity:** All voters have same metric for evaluation; real elections have ideology/preference heterogeneity
4. **Plea bargain simplification:** Assumes plea is fixed; real plea offers vary by prosecutor and evidence

---

## What It Adds to Our Understanding

**Theoretical foundation:** Establishes that electoral incentives distort trial selection through signaling. The mechanism is **case selection** (which cases go to trial), not jury performance.

**For our paper:** If we find Δ ≈ 0 on jury verdicts but trials increase under contestation, it suggests voters are observing trial-taking behavior (newsworthy) but jurors are not responding to electoral pressure signals.

