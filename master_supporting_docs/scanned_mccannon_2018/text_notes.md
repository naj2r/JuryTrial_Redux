# Deep-Read Notes: McCannon & Pruitt (2018) "Taking on the Boss: Informative Contests in Prosecutor Elections"

## Paper Summary
McCannon & Pruitt develop a signaling model of prosecutor elections where **the decision to challenge an incumbent prosecutor is informative to voters**. Because challenging is costly (the incumbent typically fires the challenger) and subordinates have inside information about the incumbent's quality, a subordinate's decision to challenge reveals that the incumbent is likely low-quality. The model predicts: (1) low-quality incumbents are more likely to be challenged, (2) low-quality incumbents are more likely to exit before elections, and (3) contested elections are rare but this reflects an effective signaling mechanism, not institutional failure.

---

## Key Research Question
**Is the election mechanism effective for prosecutor accountability, or does it fail because contested elections are rare and voters are poorly informed?**

Critics (Wright 2009, 2014) argue prosecutor elections fail because:
- Only ~15% of prosecutor elections are contested
- Vacant seats are 2.2x more common than contested reelections
- Voters lack information on prosecutor quality

McCannon & Pruitt challenge this: rare contests may indicate an **effective signaling equilibrium**, not failure.

---

## Main Theoretical Insights

### The Signaling Model

#### Setup
- **Players:** Incumbent prosecutor (I), Subordinate challenger (C), Median voter (V)
- **Information:** Nature assigns I's quality: t ∈ {H, L} (high or low)
- **Knowledge asymmetry:** I and C know t; V has prior belief θ = Pr(t = H)
- **Assumption:** θ > ψ (incumbent more likely high-quality than outsider subordinate due to selection)

#### Challenger's Decision
- **Payoffs to C if running:** κ (cost) + β × P(win) (benefit)
  - Cost κ includes campaigning + opportunity cost of losing job if incumbent retaliates
  - Benefit β is salary/prestige of holding office
  - **Assumption:** C prefers working for high-quality incumbent (uC(H) > uC(L)) but prefers winning (b - x > uC(t))
- **If not running:** C earns uC(t) (quality-dependent utility of current job)

#### Voter's Decision
If challenged, V chooses between:
- **Keep incumbent:** Expected payoff = θ' × uV(H) + (1-θ') × uV(L)
- **Install challenger:** Expected payoff = ψ × uV(H) + (1-ψ) × uV(L)

Where θ' is V's updated belief about incumbent's quality after observing C's entry decision.

### Equilibrium Results

#### **Proposition 1: Pooling Equilibrium (Non-Informative)**
There exists a pure strategy equilibrium where ρL = ρH = 0 (no one ever challenges). If no one challenges, V has no reason to doubt the incumbent, so V retains I. Anticipating retention, C doesn't run.

**This is the "accountability deficit" Wright criticizes.**

#### **Proposition 2: Separating Equilibrium (Informative)** ⭐
There exists a mixed-strategy equilibrium where:
- **ρL = 1** (low-quality incumbents are ALWAYS challenged)
- **ρH ∈ (0,1)** (high-quality incumbents are challenged with probability ρ*H = (1-θ)ψ / (1-ψ)θ)
- **κ* = κ̂H** (voter indifferent between keeping and replacing when seeing a challenge)

**Key insight:** The challenger's entry decision is informative because it's costly and only becomes worthwhile when the incumbent is likely low-quality.

### Extension: Incumbent Exit Decision (Section 4)

The baseline model assumes incumbents always run. Extending to allow incumbents to exit:
- Incumbents have an outside option ω (wage in private sector)
- **Stage 0:** I decides to run or exit
- **Stage 1:** C decides to challenge (given I runs)
- **Stage 2:** V votes

**Result:** Low-quality incumbents exit more readily because:
- ω̂L < ω̂H (low-quality incumbents have lower reelection probability, so exit threshold is lower)
- When ω ∈ (ω̂L, ω̂H], only low-quality incumbents exit (self-selection)

**Implication for contested elections:**
- Vacancies and uncontested reelections are the norm (low-quality exit, high-quality run unchallenged)
- When a race is contested, the incumbent is more likely to be high-quality initially
- This improves the probability of electing a high-quality prosecutor

### Mechanism Efficiency (Section 4.2)

**The paper argues the election mechanism is EFFECTIVE:**

Without information transmission (benchmark):
- Pr(high-quality wins) = θ̃ (ex-ante probability)

With signaling by insider challenge:
- Pr(high-quality wins) = θ > θ̃ (updated probability after exit sorting + challenge decision)

The mechanism sorts out low-quality types through:
1. **Exit sorting:** Low-quality are more likely to exit (vacancies)
2. **Challenge signaling:** Challenges reveal low quality (if challenged, less likely to be high-quality but still possible)
3. **Voter updating:** Voters rationally interpret exits and challenges

---

## Key Empirical Observations Explained by the Model

| Empirical Pattern | Model Prediction |
|------------------|------------------|
| Contested elections rare (15-20%) | Separating equilibrium with low ρ*H |
| Vacancies common (1.4-3x as frequent as contests) | Low-quality incumbents exit pre-election |
| Incumbents rarely lose contested elections | Challenging mostly occurs against low-quality, but voter uncertainty and noise mean high-quality sometimes lose |
| Most DAs unchallenged for multiple terms | High-quality incumbents deter challenges by staying in; voters learn their quality over time |

---

## Critical Assumptions and Limitations

### Assumption: Θ > ψ
**The model requires the incumbent is MORE likely to be high-quality than the challenger.**

This is justified by:
- Selection: previous elections have already screened some low-quality types
- Reputation: sitting incumbents have demonstrated competence
- Experience: chief prosecutors have more experience than subordinates

**But:** If private labor markets also select for quality (Section 4.3), this breaks down. If both the incumbent and subordinate are credentialed, the assumption becomes weaker.

### Assumption: Challenging is Costly
The model critically depends on **firing retaliation** being credible and standard. The paper notes:
- Legal precedent from *Elrod v. Burns* and *Branti v. Finkel* is ambiguous
- In *Fazio v. City and County of San Francisco*, courts upheld firing of assistant prosecutors for challenging
- But protection isn't universal; some states may have stricter civil service laws

**For your Michigan work:** Are Michigan assistant prosecutors protected from retaliation? If yes, the cost κ is lower, weakening the signaling mechanism.

### No Empirical Testing
**This paper is entirely theoretical.** McCannon & Pruitt do NOT test their model against data. They:
- Document empirical patterns (rare contests, vacancies, incumbent win rates)
- Show their model predictions align qualitatively with these patterns
- Do NOT measure entry probabilities, exit probabilities, or voter belief updating

---

## Connection to Your Michigan Research

### Direct Relevance
**Your finding that Δ (contested - uncontested) ≈ 0 on case disposition may support McCannon & Pruitt's mechanism:**

If challenges are informative and signal low quality:
- Voters who observe a challenge update downward about the incumbent
- Voters shift their support away from the incumbent
- **Incumbent behavior should NOT change** (because voters are already informed by the challenge)
- Uncontested elections also don't require behavior change if voters have learned the incumbent's quality through reputation/experience

**Under this logic:** Whether you're contested or uncontested shouldn't matter for case disposition, because voter information comes from the challenge (if it happens) or from accumulated reputation (if it doesn't).

### Questions for Your Work
1. **Is the challenger cost high in Michigan?** If assistant prosecutors CAN'T easily challenge (strong retaliation or civil service protection), the signaling value diminishes.
2. **Does contestation correlate with incumbent quality in Michigan?** If lower-quality prosecutors are more likely to be challenged (per the model), you should see compositional differences between contested and uncontested races.
3. **Do voters update beliefs?** McCannon & Pruitt assume sophisticated voter belief updating. If Michigan voters don't update, the model fails and you'd expect behavior changes in contested races.

### Alternative to the Signaling Mechanism
If your Δ ≈ 0 persists, **perhaps the signaling mechanism isn't driving behavior in Michigan.** Instead:
- Prosecutors may be constrained by caseload/legal/institutional factors (not election pressure)
- Or the jury mobilization mechanism dominates (prosecutors adjust jury selection/voir dire, not dispositions)
- Or contestation is endogenous to prosecutor quality (not exogenous shock to equilibrium)

---

## Model Details & Key Equations

### Voter's Best Response
If V observes a challenge:
- Retains incumbent if θ' > ψ (updated belief > belief about challenger)
- Indifferent if θ' = ψ
- Replaces incumbent if θ' < ψ

### Challenger's Best Response
Enters if κ > κ̂t where κ̂t = (x + uC(t)) / b

- For t = L (low-quality incumbent): easier to enter because uC(L) is lower (bad job)
- For t = H (high-quality incumbent): harder to enter because uC(H) is higher (good job)

### Equilibrium Conditions
For mixed-strategy equilibrium (ρ*L = 1, ρ*H ∈ (0,1)):
- V's updated beliefs: θ' = ψ (indifferent between candidates)
- C's mixing probability: ρ*H = (1-θ)ψ / (1-ψ)θ
- Voter's mixing probability: κ* = κ̂H (V indifferent between keeping and replacing)

---

## Why This Model Matters for Prosecutor Elections

### Standard Critique (Wright et al.)
"Rare contests + uninformed voters = institution fails"

### McCannon & Pruitt's Counterargument
"Costly signaling + asymmetric information = rare contests is OPTIMAL equilibrium"

The low frequency of contests isn't evidence of failure; it's evidence that:
- Bad incumbents self-select out (vacancies)
- Good incumbents deter challenges (voters learn)
- Challenges, when they occur, are highly informative

**This flips the normative conclusion:** Instead of replacing elections with appointment, improve voter information (Bibas 2009 theme).

---

## Summary Assessment

### Strengths
- Clever signaling model that rationalizes empirical patterns
- Addresses a major critique in prosecutor election literature
- Shows how insider information + costly entry can align electoral mechanism with voter interests

### Weaknesses
- No empirical testing of model predictions
- Strong assumption θ > ψ may not hold everywhere
- Relies on threat of retaliation (assumption about institutional enforcement)
- Doesn't address voter competence (still assumes voters correctly interpret signals)

### For Your Project
This model suggests **contestation may not matter** for prosecutor behavior if voters are sophisticated. Your null Δ would be consistent with the signaling mechanism. But further investigation is needed on:
1. Whether Michigan prosecutors face retaliation costs
2. Whether voters actually update beliefs on challenges
3. Whether any other institutional factors (jury mobilization, caseload) explain behavior instead
