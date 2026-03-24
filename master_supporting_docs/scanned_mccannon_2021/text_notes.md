# Deep-Read Notes: McCannon (2021) "Informational Value of Challenging an Incumbent Prosecutor"

## Paper Summary
McCannon uses a quasi-natural experiment in New York State to test whether voters are strategically updating beliefs based on challenger entry in prosecutor elections. In 2012, New York raised judicial salaries by 53%. Because prosecutor salaries are legally tied to judicial compensation (95% of county court judge salary), this created an exogenous shock to prosecutor compensation. Theory predicts: (1) if voters are updating beliefs, challenger entry should become less informative (higher salary = more entry incentive, but voters discount this), so incumbency advantage should INCREASE; (2) entry rates should NOT change (the benefit increase is fully offset by reduced informational value). Empirical results confirm both predictions.

---

## Key Research Question
**Are voters strategically updating their beliefs based on challenger entry, or do they vote based on naïve incumbency preference?**

The paper tests a **testable implication of sophisticated vs. naïve voter behavior:**

| Voter Type | Prediction if Salary Increases |
|-----------|--------|
| **Naïve voters** | Higher salary → higher entry incentive → MORE challenges, NO change in incumbent win rate |
| **Sophisticated voters** | Higher salary → reduces informational value of entry → SAME challenge rate, HIGHER incumbent win rate |
| **McCannon's finding** | Entry unchanged; incumbent margin increases by 6pp; incumbent win prob increases by 33% |

---

## Main Findings

### Hypothesis 1: Entry Rates Unchanged
**Supported.** When prosecutor salaries increase in 2012:
- **Challenge rate (all re-elections):** No significant change (coefficient = 0.0293, p = .71, Table 3 Col 1)
- **Challenge rate (conditional on incumbent re-election):** Still not significant
- **Probability incumbent seeks re-election:** No change (p = .58)
- **Falsification test:** Lead and lagged years (2010, 2012) are individually insignificant when Post-2011 is included

**Interpretation:** The increase in the prize for winning (β ↑) does NOT increase entry because voters rationally respond to this change in incentives. Entry becomes less informative, so voters shift support to the incumbent, which offsets the entry incentive.

### Hypothesis 2: Incumbent Margin Increases
**Strongly supported.** After the 2012 salary increase:

#### Incumbency Advantage (Table 2)
| Sample | Outcome | Effect | Significance |
|--------|---------|--------|--------------|
| **Full sample** | Winner's margin | +1.1pp | Not sig. |
| **Incumbent re-elections** | Incumbent's margin | +3.0pp | **p<.01** |
| **Contested re-elections** | Incumbent's margin | **+6.5pp** | **p<.05** |
| **Incumbent re-elections** | Probability incumbent loses | -74.2pp | **p<.01** |
| **Contested re-elections** | Probability incumbent loses | **-24.75pp** | **p<.05** |

#### Win Rate
- **Pre-2011 contested re-elections:** Incumbents win 65.6% of the time
- **Post-2011 contested re-elections:** Incumbents win 87.5% of the time
- **Difference:** 21.9pp improvement in incumbent win probability
- **Interpretation:** 33% increase in the probability of incumbent re-election when challenged (75% → 87.5% baseline ≈ 13% improvement; estimated effect is 24.75pp loss probability = ~33% reduction in loss rate)

### Decomposition: Where Does the Effect Come From?

**The margin increase is NOT driven by:**
1. **Falsification test (vacant races):** Post-2011 coefficient on margin in races where incumbent didn't run = 0.007 (p = .923)
   - Rules out secular time trends in closeness of races
2. **Selection effects:** Probability incumbent seeks re-election unchanged
   - Rules out composition shift (higher-quality incumbents more likely to seek re-election post-2011)
3. **Entry changes:** Contestation rate flat
   - Rules out argument that higher salary attracts fewer challengers (if anything, salary makes entry more attractive, but voters offset this)

**The effect IS driven by:** Voters increasing support for incumbent conditional on challenge occurring.

---

## Theoretical Framework

### Signaling Model (Simplified Version of McCannon & Pruitt 2018)

#### Setup
- **Three players:** Incumbent I, Challenger C (insider with private signal about I), Voter V
- **Nature:** Assigns I's type t ∈ {H, L} (high/low quality)
- **Information:** I and C know t; V has prior τ = Pr(t = H)
- **Timing:**
  1. Nature chooses t
  2. C gets signal s of t with accuracy σ ≥ 1/2
  3. C decides to enter (e) or not (n̄e)
  4. V observes C's decision, updates beliefs to τ', votes between I and C

#### Payoffs
- **C entering:** Cost κ, benefit β if wins, utility ut if not
  - Assumption: uH > uL (prefer working for high-quality boss)
  - Assumption: β > κ > 0 (net incentive to run if likely to win)
- **V:** Cares only about I's quality; prefers high-quality in office (vH > vL)
- **I:** Doesn't have action choice in baseline (but extension adds exit decision)

#### Equilibrium
Mixed strategy equilibrium where:
- C challenges if signal = L (with probability 1) or signal = H (with probability ε*H)
- ε*H = θ(1-τ)σ(1-θ) / [(1-θ)τσ + θ(1-τ)(1-σ)]
- V updates beliefs to τ' = θ
- V retains I with probability ρ* = [σuH + (1-σ)uL + κ] / β

#### Key Corollary (THE MAIN THEORETICAL PREDICTION)
**Increase in β (prosecutor salary) does NOT change ε*(s), but INCREASES ρ*(τ').**

- **Why entry doesn't change:** Higher β makes entry more attractive, but voters recognize this. They update that a challenge is less informative (challenger has lower cost of entry relative to prize). Voters shift support to incumbent, offsetting the entry incentive.
- **Why incumbent win rate increases:** Higher β means voters need to be more confident the incumbent is high-quality to prefer him over the challenger. Since voters interpret higher salary as less informative signal, they give more weight to prior beliefs (which favor incumbent). Result: higher support for incumbent.

### Intuition
If salary goes from $100K to $153K and challenger entry doesn't change, voters realize: "Entry is just as costly relative to the new prize, so this challenge is neither more nor less likely if the incumbent is bad. I'll stick with the incumbent (whom I already trust more)."

---

## Empirical Strategy: The Quasi-Natural Experiment

### Why New York's Salary Increase is Exogenous to Prosecutors

**Judges' Salary Commission (2011–2015):**
- Explicitly focused on attracting talent to judicial positions
- Made no reference to prosecutors in testimony or written submissions
- Motivated by: judicial retention, federal judge salary parity
- Exogenous to prosecutor performance or election outcomes

**Institutional Link:**
- NY State Code: Prosecutor salary = 95% of County Court justice salary
- County Court justice salary = 95% of State Supreme Court justice salary
- State Supreme Court salaries set by legislature (not prosecutors' input)
- This chain was pre-existing (not created for prosecutors)

**Result:**
- 2012: Judicial salaries increase
- Automatically triggers prosecutor salary increase (no separate legislative action needed on prosecutors)
- Prosecutor elections occurred in staggered years (not tied to salary decision date)
- Challenge rates among states without salary shocks did NOT increase (falsification test)

### Data
- **Population:** All prosecutor elections in NY State, 1999–2016 (264 elections, 62 counties)
- **Pre-period:** 1999–2011 (12-year salary freeze)
- **Post-period:** 2012 onwards (53% cumulative increase through 2018)
- **Controls:** Republican partisanship, crime rates, median income, labor force participation, poverty rate change, population
- **Standard errors:** Clustered at county level (62 clusters)

---

## Robustness Checks

### 1. Timing Validation (Figure 1)
Rolling 4-year windows replacing Post-2011:
- 2000–2003 window: negative/small effect
- 2004–2007 window: effect approaching zero
- 2008–2011 window (final pre-salary window): effect marginally different from zero
- **2009–2012 window onwards: effect stabilizes and diverges from zero**
- **Sharp discontinuity at 2011**, coinciding with salary law

**Conclusion:** Not a gradual time trend; sharp break in 2011 as predicted.

### 2. Falsification Tests

#### A. Comparison States (Table 5)
Three states without prosecutor salary increases: Florida, Ohio, North Carolina
- **NY post-2011 effect on incumbent win rate:** -24.75pp loss probability (large effect on contestation)
- **FL post-2011 effect:** +68.5pp loss probability (trend opposite to NY; marginally sig.)
- **OH post-2011 effect:** +80.0pp loss probability (opposite trend)
- **NC post-2011 effect:** +41.9pp loss probability (not sig., but direction opposite)

**Interpretation:** Only NY shows increased incumbency advantage. Other states trend toward MORE incumbent losses after 2011, supporting causal interpretation of NY effect.

#### B. Vacancy Elections (Table 3 footnote)
Races where incumbent chose not to run for re-election:
- Post-2011 effect on margin = 0.007 (p = .923)
- Conclusion: No secular time trend in election closeness

#### C. Hurdle Model (Table 6, Cragg Model)
Uses partisan divide as selection variable for whether election is contested:
- Selection model: Post-2011 has no effect on contestation (coefficient = 0.088, not sig.)
- Extensive margin: Post-2011 increases incumbent margin by 7.4pp (p<.01)
- Conclusion: Results robust to different econometric specification

### 3. Alternative Hypotheses

#### Efficiency Wage Argument
"Higher salary incentivizes prosecutor effort; voters reward effort with support"

**McCannon's response:**
- If effort improves, voters should believe incumbent is higher quality
- This should REDUCE incentive to challenge (less informative)
- Entry should decline, but data shows entry unchanged
- Consistent with signaling mechanism, not effort/efficiency wage

---

## Key Empirical Patterns

### Pre- vs. Post-2011 Comparison (Table 1)

| Metric | Pre-2011 | Post-2011 | Change |
|--------|----------|-----------|--------|
| Contested elections | 31.5% | 37.2% | +5.7pp |
| Incumbents seek re-election | 81.9% | 80.4% | -1.5pp |
| Incumbent margin (all races) | 87.0% | 85.5% | -1.5pp |
| **Incumbent margin (contested)** | **55.8%** | **60.8%** | **+5.0pp** |
| **Incumbents win (contested)** | **65.6%** | **87.5%** | **+21.9pp** |

**Note:** Slight uptick in contestation post-2011 (likely due to more open seat elections, which are contested 61–70% of the time). But conditional on contested race, incumbents do much better.

---

## Connection to Your Michigan Research

### Direct Relevance to Δ ≈ 0 Finding

McCannon (2021) provides strong evidence that **voters ARE rationally updating beliefs based on entry.** Specifically:
- Voters observe challenge entry
- Voters adjust upward or downward on incumbent quality based on entry signal
- When entry becomes less informative (higher salary → lower relative cost), voters shift support to incumbent

**If Michigan voters are similarly sophisticated:**
- Whether a challenger runs (contestation) is informative
- But if contestation doesn't change prosecutor behavior on dispositions, it's because:
  - Voters already know incumbent quality (from prior experience)
  - Voters update on the challenge signal itself (not on what prosecutor does afterward)
  - Prosecutor behavior is constrained by institutional factors (not electoral incentives)

### Why Your Δ ≈ 0 Is Consistent with McCannon (2021)

**Your finding:** Contested = Uncontested on jury mobilization and verdicts

**McCannon's theory predicts:**
- Voters update WHEN CHALLENGED (shifting support to incumbent if challenge occurs)
- BUT voters DON'T require prosecutors to CHANGE BEHAVIOR to confirm expectations
- Prosecutors may signal quality through entering the race, not through case disposition

**Implication:** McCannon's framework supports your null Δ because:
1. Prosecutors don't need to change dispositions to signal quality
2. Entry signal itself (challenge happening) is sufficient for voter updating
3. Voters rely on challenge signal, not on observing disposition changes

### Questions for Your Work

1. **Do Michigan voters update on entry?** (McCannon (2021) shows NY voters do)
   - Can you test: Are voters more likely to vote for challenger when challenger enters?
   - Are incumbents PERCEIVED as lower quality when challenged?

2. **Do prosecutors anticipate voter updating?** (McCannon (2021) implies they do)
   - If prosecutors know voters update on entry, they may NOT change behavior (voters already informed)
   - This explains your null Δ

3. **Is jury mobilization endogenous to contestation?** (Your finding)
   - You find contestation DOES affect jury verdicts but NOT case dispositions
   - McCannon (2021) suggests voter updating on entry, which is orthogonal to case disposition
   - Your jury verdict effect may be a DIFFERENT mechanism than voter belief updating

---

## Specific Results to Cite

### Main Effect (Table 2, Column 3: Contested Re-Elections)
- **Post-2011 effect on incumbent margin:** 6.5 percentage points (SE 0.0381, p<.05)
- **Post-2011 effect on incumbent loss probability (Col 5):** -24.75pp (SE 0.1304, p<.05)

### Entry (Table 3)
- **Post-2011 effect on challenge rate:** 0.0293 (SE 0.0721, not significant)

### Timing Robustness (Figure 1)
- Effect appears sharp at 2011, not gradual
- Leads and lags insignificant, supporting causal interpretation

---

## Broader Significance

### Challenge to Wright Critique
Wright (2009, 2014) argues prosecutor elections fail because:
1. Rare contests (15–20% of races)
2. Voters poorly informed
3. Incumbents rarely lose

McCannon (2021) **doesn't challenge the facts** but reinterprets them:
- Voters ARE using available information (entry signal)
- Voters ARE updating beliefs rationally
- Rare contests and high incumbent success reflect effective signaling, not failure

**Normative implication:** Improve voter INFORMATION rather than replace elections with appointments.

### Alignment with McCannon & Pruitt (2018) Theory
McCannon (2021) is the **first empirical test** of the signaling model from McCannon & Pruitt (2018):
- Tests the corollary: β ↑ does not change entry, but increases incumbent support
- Confirms with quasi-experimental variation in β (prosecutor salary)
- Provides causal evidence for voter belief updating

---

## Summary Assessment

### Strengths
- **Excellent identification:** Exogenous salary shock unrelated to prosecutor performance
- **Falsification tests:** Timing validation, comparison states, vacant races
- **Theoretical clarity:** Model makes precise, testable predictions
- **Empirical confirmation:** Both Hypotheses 1 and 2 strongly supported

### Weaknesses
- **Generalizability:** NY system may differ from other states (salary links, election timing, political culture)
- **Direct evidence of belief updating:** Infers voter belief updating from behavior change; doesn't survey voters
- **Mechanism specificity:** Can't rule out alternative mechanisms (e.g., voters interpret salary increases as signal of prosecutor quality, not as change in entry cost)

### For Your Project
McCannon (2021) provides strong evidence that **voters are rationally evaluating contested elections.** Your null Δ on dispositions is consistent with this: voter updating occurs on entry signal, not on observed prosecutor behavior changes. Consider whether:
1. Voters in Michigan update similarly on entry
2. Your jury verdict effect is the operative mechanism (not disposition-level changes)
3. Contestation is endogenous to underlying prosecutor quality (not exogenous shock)
