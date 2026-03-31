# McCloskey Economical Writing Audit — 5-results.tex
**Auditor:** mccloskey-critic
**Date:** 2026-03-24
**Target:** Active (non-commented, non-struck) red placeholder/draft blocks only
**Score:** 100 → deductions below

---

## Scoring Summary

| Category | Violations | Deduction |
|----------|-----------|-----------|
| Cardinal (-5 each) | 4 | -20 |
| Major (-3 each) | 9 | -27 |
| Minor (-1 each) | 10 | -10 |
| AI writing patterns | 3 | -6 (counted as major) |
| **Total deductions** | | **-60** |
| **Final score** | | **40 / 100** |

---

## Cardinal Violations (-5 each)

### C1. "It is" construction + abstract noun replacing verb
**Location:** OVB Caveat block (line ~15)
> "Without year fixed effects, the Table~\ref{tab:table1} coefficients **conflate** election-year effects with these trends."

Wait — this one is actually fine. Let me flag the real one:

**Location:** Interpretation block (line ~165)
> "The corrected results---using SCAO outgoing caseload data for verdict and plea variables, replacing the unreliable jury utilization dashboard verdict columns---**reveal a pattern that distinguishes between competing theoretical mechanisms** for electoral influence on prosecutorial behavior."

The sentence opens with a long participial throat-clearing clause ("using SCAO outgoing caseload data...replacing the unreliable jury utilization dashboard verdict columns") before reaching the actual claim. The reader must wade through 20 words of provenance before learning what the results say.

**Suggested fix:** Move the data-correction note to a footnote or the "Data correction note" subsection (which already exists). Open with the finding: "The corrected results reveal a pattern that distinguishes competing mechanisms: the election cycle drives prosecutorial behavior, not the presence of a challenger."

---

### C2. Throat-clearing opener
**Location:** Disposition Mechanism block (line ~78)
> "The corrected results, using SCAO outgoing caseload data that decomposes dispositions by case type and resolution method, **reveal a coherent mechanism** operating through case routing rather than mobilization volume."

Two problems in one sentence: (1) another participial throat-clearing provenance clause; (2) "reveal a coherent mechanism" is abstract noun ("mechanism") replacing what a verb could carry directly.

**Suggested fix:** "Capital felony cases, not non-capital ones, respond to election years on every disposition margin: prosecutors dismiss fewer, plea fewer, and try more." That's the finding. Lead with it.

---

### C3. Passive voice obscuring the actor
**Location:** Disposition Mechanism block (line ~82)
> "This is not an increase in total case volume---incoming felony filings **do not respond** to electoral pressure (Table~\ref{tab:table8})---but **a reallocation** of how existing cases are processed."

"A reallocation of how existing cases are processed" uses passive ("are processed") and nominalizes the action. Who processes them? Prosecutors. This should be active.

**Suggested fix:** "...but a reallocation by prosecutors of how they route existing cases."

---

### C4. "It is" + abstract noun construction
**Location:** Contestation Mechanism block (line ~60)
> "**It suggests** that the behavioral shift is not a strategic response to a specific challenger but rather a baseline standard that activates during any election cycle."

"It suggests" is a classic throat-clearing hedge that delays the actual claim. "It" refers to the null Δ, but the sentence structure buries the finding.

**Suggested fix:** "The null Δ rules out strategic challenger-response; what activates is a baseline standard tied to the election calendar, not to a specific opponent."

---

## Major Violations (-3 each)

### M1. Redundant qualifier
**Location:** Contestation Mechanism block (line ~52)
> "The benchmark specification establishes that election years differ from non-election years **on case disposition margins**."

"On case disposition margins" is required context, not redundant — keep. BUT:

> "The **natural question** is whether the **type** of election matters---**specifically**, whether the presence of a challenger amplifies the behavioral shift."

"The natural question is" is filler. And "specifically" restates what the sentence already says.

**Suggested fix:** "Whether the type of election matters — whether a challenger's presence amplifies the shift — is answered in Table~\ref{tab:table2}."

---

### M2. Wordy throat-clear introducing the finding
**Location:** Contestation Mechanism block (line ~54)
> "**The headline finding is a null.**"

This is actually McCloskey-good. Do not flag.

Moving on — same paragraph:

> "A prosecutor facing re-election reduces capital felony dismissals by an equivalent magnitude regardless of whether anyone challenges the seat."

This is clean. Good.

---

### M3. Unnecessary hedging with "plausible"
**Location:** OVB/Baseline block (line ~25)
> "Two **plausible** mechanisms could produce this pattern, and the data cannot distinguish between them."

"Plausible" is weak hedging when the sentence already qualifies with "could produce." One qualifier is enough.

**Suggested fix:** "Two mechanisms could produce this pattern; the data cannot distinguish between them."

---

### M4. Wordy idiom
**Location:** OVB/Baseline block (line ~25)
> "The observed decline may reflect **six of one and half a dozen of the other**---some combination of prosecutorial case selection and defendant plea behavior operating simultaneously."

The idiom "six of one and half a dozen of the other" is colloquial and imprecise in academic prose. The em-dash gloss immediately explains what it means, making the idiom redundant.

**Suggested fix:** Delete the idiom; keep only: "The observed decline likely reflects some combination of prosecutorial case selection and defendant plea behavior."

---

### M5. Redundant opening with "What the X does establish"
**Location:** OVB/Baseline block (line ~25)
> "**What the pipeline decomposition does establish is that** the election-year effect is not merely administrative..."

"What X does establish is that" is a wordy emphasis construction that adds no information. "Does" is an intensifier filling space.

**Suggested fix:** "The pipeline decomposition establishes one thing clearly: the election-year effect is not merely administrative."

Or more economically: "The election-year effect is not merely administrative: the final stages..."

---

### M6. Nominalizations piled up
**Location:** Contestation Mechanism block (line ~60)
> "The competence-maintenance interpretation is consistent with this institutional environment: prosecutors in election years avoid the appearance of leniency on serious cases regardless of whether a challenger has materialized, because the election itself creates accountability pressure that is independent of the competitive environment."

Three nominalizations in one sentence: "appearance of leniency," "accountability pressure," "competitive environment." All three replace active constructions.

**Suggested fix:** "Prosecutors in election years avoid appearing lenient on serious cases whether or not a challenger has appeared, because the election itself holds them accountable regardless of competition."

---

### M7. "Warrants particular attention because"
**Location:** OVB/Baseline block (line ~25)
> "The decline in voir dire rates **warrants particular attention because** it implicates the discretionary behavior of courtroom actors rather than bureaucratic procedure."

"Warrants particular attention because" is a classic throat-clearing signal flag. The reason already carries the weight — cut the preamble.

**Suggested fix:** "The decline in voir dire rates implicates courtroom discretion, not bureaucratic procedure."

---

### M8. "Notably" as filler
**Location:** OVB Caveat block (line ~15)
> "**Notably**, the capital felony verdict share exhibits a significant secular decline of 0.56 percentage points per year ($p = 0.042$) over the panel..."

"Notably" is a meta-commentary word that tells the reader how to feel rather than letting the number speak. McCloskey: let the evidence do the noting.

**Suggested fix:** Delete "Notably," and let the sentence stand on its own.

---

### M9. AI writing pattern: triplet list with "First/Second/Third"
**Location:** Disposition Mechanism block (lines ~80–84)
> "**First**, the behavioral shift is \emph{severity-selective}... **Second**, the disposition margins move in \emph{offsetting} directions... **Third**, the reallocation is \emph{election-driven, not competition-driven}."

Enumerated triplets with emphasized labels ("severity-selective," "offsetting," "election-driven, not competition-driven") is a hallmark AI writing pattern. The structure is also used in the Baseline block ("Three patterns emerge. First... Second... Third..."). Two triplet structures in one section.

This is not a McCloskey violation per se when the content justifies the structure, but the formulaic "First/Second/Third + italicized label" applied twice is a pattern flag. The labels also do some of the work the sentences themselves should do — they are telegraphed rather than demonstrated.

**Suggested fix:** Use transitional sentences rather than enumerated labels. Let the logic flow from finding to finding without signposting every step.

---

## Minor Violations (-1 each)

### m1. "Tells a different story" — cliché
**Location:** Contestation Mechanism block (line ~58)
> "Non-capital felonies **tell a different story**."

"Tell a different story" is a clichéd transition that substitutes for a direct statement of the contrast.

**Suggested fix:** "Non-capital felonies show no significant response on any margin."

---

### m2. "Three patterns emerge" — formulaic opener
**Location:** Baseline block (line ~21)
> "**Three patterns emerge.** First..."

"Emerge" is a weak intransitive that makes the data sound passive. Patterns don't emerge; the data shows them.

**Suggested fix:** "The data reveal three patterns." Or better, drop the sentence and integrate the enumeration into a transitional sentence.

---

### m3. "Warrant emphasis" — meta-commentary
**Location:** Disposition Mechanism block (line ~79)
> "Three features of the disposition pattern **warrant emphasis**."

Same issue as M7 — "warrant emphasis" instructs the reader to pay attention rather than earning their attention.

**Suggested fix:** Delete. The three-part structure that follows is already emphatic.

---

### m4. Weak "reveal" + abstract object
**Location:** Disposition Mechanism block (line ~78)
> "reveal a coherent mechanism operating through case routing"

"Reveal a coherent mechanism" delays the actual content. Already flagged in C2, but note also that "coherent" is a weak adjective that adds no information (a mechanism is either coherent or not demonstrable).

**Suggested fix:** As in C2 — lead with the specific finding, not the abstraction.

---

### m5. Redundant "nearly identical"
**Location:** Interpretation block (line ~167)
> "Both contested and uncontested election years produce **nearly identical** behavioral shifts"

"Nearly identical" is immediately followed by specific numbers showing they are identical to one decimal place. The qualifier "nearly" does no work that the numbers don't already show.

**Suggested fix:** "Both contested and uncontested election years produce the same behavioral shifts: FC jury trial rates increase by 9.2–10.7 pp..."

---

### m6. "Critically" as filler
**Location:** Composition Sign Sensitivity block (line ~136)
> "**Critically**, the within-election-year difference $\Delta = \beta_1 - \beta_2$ is invariant..."

"Critically" is a meta-commentary word. Let the invariance speak for itself.

**Suggested fix:** Delete "Critically," — the math already makes the point.

---

### m7. "A distinct pattern" — vague
**Location:** Baseline block (line ~27)
> "The open-seat column reveals **a distinct pattern**."

"A distinct pattern" is a placeholder noun phrase that the rest of the sentence fills in. Cut it and start with the substance.

**Suggested fix:** "Both incumbent and open-seat elections suppress capital felony verdicts, but what replaces them differs."

---

### m8. "Reconciliation is temporal" — awkward nominalization
**Location:** Baseline block (line ~29)
> "The **reconciliation** is temporal: \citet{okafor2021prosecutorial} documented..."

"The reconciliation is temporal" is a noun-heavy construction. "Reconcile" is a transitive verb; use it.

**Suggested fix:** "These results diverge from \citet{bandyopadhyay2014effect}, but the divergence is temporal: \citet{okafor2021prosecutorial} documented..."

Or: "The divergence is temporal: sentencing effects of electoral pressure dissipated after 2006..."

---

### m9. "Motivates" as jargon-filler
**Location:** Baseline block (line ~31)
> "This **motivates** the contestation decomposition in the following section..."

"Motivates" is a standard academic filler verb meaning "this is why we do the next thing." It's acceptable but weak. The sentence also throat-clears about the next section rather than ending on the current finding.

**Suggested fix:** Either delete the sentence (the next subsection announces itself) or make the transition substantive: "The contestation decomposition in Section~\ref{subsec-contestation} exploits the within-year variation that year FE cannot provide."

---

### m10. "Approaches significance" — hedging p-value language
**Location:** Contestation Mechanism block (line ~62) and Interpretation block (line ~171)
> "The one margin where $\Delta$ **approaches significance** is the severity share of jury verdicts ($\Delta = -0.070$, $p = 0.057$)."

"Approaches significance" is hedge language that papers over a non-result. Either it is significant at your chosen threshold or it is not. Report the p-value and let the reader judge.

**Suggested fix:** "The one margin where Δ is marginally significant is the severity share of jury verdicts ($\Delta = -0.070$, $p = 0.057$)." Or simply: "The severity share of jury verdicts shows the largest differential ($\Delta = -0.070$, $p = 0.057$), falling just short of conventional significance."

---

## AI Writing Pattern Flags

These are counted as major violations above.

### AI-1. Triplet structure (First/Second/Third + italicized label) — used twice
See M9 above. The pattern appears in the Baseline block ("Three patterns emerge. First... Second... Third...") and the Disposition Mechanism block ("First, the behavioral shift is *severity-selective*... Second... Third..."). Two instances of identical structure in one section is a fingerprint.

### AI-2. "This distinction complements..."
**Location:** Interpretation block (line ~173)
> "**This distinction complements** \citet{gordon2007competitiveness}, who found..."

"This distinction complements" is a formulaic literature-positioning phrase ("our finding adds to X by showing Y"). It is accurate but mechanical. The sentence that follows is substantively stronger — it could carry the positioning without the preamble.

**Suggested fix:** "We extend \citet{gordon2007competitiveness}'s finding that electoral proximity increases severity: even the structure of case disposition — which cases are dismissed, which proceed to trial — responds to the electoral calendar independently of competitive pressure."

### AI-3. "This pattern is difficult to reconcile with"
**Location:** Contestation Mechanism block (line ~60) and Disposition Mechanism block (line ~84)
> "**This pattern is difficult to reconcile with** models in which prosecutors strategically respond to competitive electoral threats."

"Difficult to reconcile with" is a softened negation — academic hedging that avoids saying "the data contradict." McCloskey: if the data rule something out, say so.

**Suggested fix:** "The null Δ contradicts models of strategic challenger-response." (Disposition Mechanism block uses the same pattern: "difficult to reconcile with models in which prosecutors strategically respond" — identical phrasing, possible copy-paste.)

---

## Summary of Highest-Priority Fixes

The draft is analytically strong but structurally repetitive and over-hedged. The three most impactful changes:

1. **Eliminate the double-triplet structure.** "First/Second/Third + italicized label" appears twice in succession. This alone marks the draft as AI-generated. Integrate the findings into transitional prose.

2. **Strip the provenance throat-clears.** Both the Disposition Mechanism opener and the Interpretation opener lead with "The corrected results, using SCAO outgoing caseload data..." The data-correction issue has its own subsection — stop repeating it in every paragraph opener.

3. **Replace "difficult to reconcile with" / "is consistent with" / "approaches significance."** These hedges appear 4+ times. Pick a stance on each claim and state it directly.

---

## What's Actually Good

Not everything needs fixing. These constructions are McCloskey-clean and should be left alone:

- "The headline finding is a null." (Contestation block, line ~54) — direct, punchy, correct.
- "Capital felony jury trial rates follow the same pattern: contested elections increase the FC jury trial share by 9.6 percentage points... uncontested elections by a comparable margin, with Δ again null." — active, specific, no hedging.
- The Composition Sign Sensitivity technical explanation (lines ~134–138) is precise and well-structured; the "Critically" opener (m6) is the only blemish.
- The TWFE weight diagnostic paragraph (lines ~126–127) is clean econometric reporting.

---

*Score: 40/100. The draft is analytically coherent but below the McCloskey threshold (80) for manuscript-ready prose. Primary issues: two AI-pattern triplet structures, systematic throat-clearing openers in section leads, and 4+ instances of "difficult to reconcile with / consistent with / approaches significance" hedging. No submission-ready prose until the triplet structures and provenance openers are eliminated.*
