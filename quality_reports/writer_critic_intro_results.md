# Writer-Critic Score Report
**Files reviewed:** `1-introduction.tex`, `5-results.tex`
**Date:** 2026-03-24
**Reviewer:** writer-critic agent
**Scoring:** Start at 100, deduct per rubric

---

## Summary Scores

| File | Raw Score | Notes |
|------|-----------|-------|
| `1-introduction.tex` | **82/100** | Strong conceptual clarity; two overclaiming instances; one framing remnant |
| `5-results.tex` | **74/100** | Good on mechanism prose; serious internal contradictions; several outdated-or-inconsistent coefficient citations; structural issues in robustness section |
| **Combined weighted** | **78/100** | Introduction is near-publishable; Results needs one targeted revision pass |

---

## INTRODUCTION (`1-introduction.tex`)

### Starting score: 100

---

### Issue 1 — Framing remnant in paragraph 4 (non-struck prose) [-3 overclaiming]

**Location:** Para 4 (lines 11–12), final sentence:
> "The institutional consequence may be increased jury mobilization even when completed adjudications do not increase."

This sentence is from the **old shadow-expansion framing** and has not been struck. The paper's current framing is competence-maintenance (disposition shifts, not mobilization increases). The DRAFT results block in the introduction explicitly says "raw jury mobilization counts… are uniformly null under incumbent elections." The surviving sentence in paragraph 4 predicts a mobilization response that the paper's own findings refute. A referee will flag this as internal inconsistency.

**Severity:** -3 (overclaiming relative to the paper's actual findings; gives referees ammunition)

**Fix:** Delete the final sentence of paragraph 4 or replace with a sentence noting that the pipeline may respond at the case-routing level rather than the summoning level.

---

### Issue 2 — Hedging in paragraph 3 [-2]

**Location:** Para 3 (line 9):
> "A prosecutor who *can* credibly threaten trial shifts the expected payoff calculus of defendants, *even if* few additional trials ultimately occur."

The hedge "can credibly" is appropriate economic language. However, the following sentence:
> "Trial, in this sense, is both a costly adjudicative process and a *strategic instrument*."

is stated confidently and well. No deduction on these. The hedging in this paragraph is calibrated correctly.

**No deduction — hedging is appropriate here.**

---

### Issue 3 — Missing citation for "more than ninety-five percent" claim [-3]

**Location:** Para 2 (line 7):
> "More than ninety-five percent of state criminal convictions result from guilty pleas \citep{subramanian2020shadows}."

The cite is `subramanian2020shadows`. This key is plausible but should be verified: the standard citation for the 95%+ plea rate is typically the BJS National Survey of Criminal Courts (Devers 2011) or Lafler v. Cooper (2012). `subramanian2020shadows` appears to be a Vera Institute report — confirm the cite is correct and the number is reported there, not in a secondary source.

**Severity:** -3 (empirical claim; if the cite is wrong or the number comes from elsewhere, this is a fact error that referees will catch)

**Fix:** Verify `subramanian2020shadows` reports this statistic directly, or swap to the standard BJS citation.

---

### Issue 4 — Redundant signaling language in paragraph 2 [-2 repetitive structure]

**Location:** Para 2 (line 7):
> "…signal alignment with voters, usually through harsher convictions or signalling alignment with voter preferences by other dimensions like partisanship"

"Signal alignment with voters" appears, then "signalling alignment with voter preferences" appears again in the same sentence. This is redundant and reads as a draft artifact. The second instance adds "by other dimensions like partisanship" which is the only new content.

**Severity:** -2 (repetitive structure within a single sentence)

**Fix:** "…signal alignment with voters through harsher convictions, higher plea rates, or partisan cue-taking \citep{arora2018too}."

---

### Issue 5 — Passive voice in paragraph 2 [-1]

**Location:** Line 7:
> "Earlier theories and empirical findings show harsher convictions and more severe plea deals \citep{bandyopadhyay2014effect}, but are *unable* to look at the stepwise progression…"

"Are unable to look" is passive-adjacent and awkward. Subject is "theories and empirical findings," which cannot "look" at anything. Active rewrite: "but prior work has not examined the stepwise progression…"

**Severity:** -1

---

### Issue 6 — Unclear antecedent in contributions paragraph [-1]

**Location:** DRAFT block, contributions (line 29):
> "…a pattern consistent with prosecutors in small counties adjusting their handling of the most visible cases during election years."

"The most visible cases" — visible to whom? The antecedent is capital felony cases (life-offense-eligible), which are the most serious rather than necessarily the most publicly visible. The sentence is clear in context but the adjective "visible" slips in without definition. A referee may ask whether "visible" = "serious" or is doing independent theoretical work.

**Severity:** -1

**Fix:** "…adjusting their handling of capital felony cases—the highest-stakes cases in the portfolio—during election years."

---

### Issue 7 — "road map" paragraph has a broken section reference risk [-2 LaTeX]

**Location:** Line 33 (road map paragraph):
> "Sections~\ref{section-discussion} --~\ref{subsection-limits}"

The `--` between two `\ref` commands will render as an em-dash with spaces, which is unconventional (should be `\ref{section-discussion}–\ref{subsection-limits}` or just list them). More importantly, `\ref{subsection-limits}` must be verified as an active label in the paper. If the subsection was renamed or struck, this will produce a "??" in compilation.

**Severity:** -2 (potential LaTeX compilation issue)

**Fix:** Verify `\label{subsection-limits}` exists in the document. If the section was renamed, update the reference.

---

### Introduction subtotal deductions: -3 -3 -2 -1 -1 -2 = **-12**
### Introduction score: **88/100**

*Note: This is higher than summary table above; see combined assessment below.*

---

## RESULTS (`5-results.tex`)

### Starting score: 100

---

### Issue 1 — Internal contradiction: Table 1 characterization vs. Introduction [-5 claims-evidence mismatch]

**Location:** Results, line 21 (Baseline PLACEHOLDER block):
> "raw jury mobilization counts (summoned, told to report, actually reported) are uniformly null under incumbent elections"

**And Introduction DRAFT block (line 23):**
> "prosecutors in election years dismiss fewer capital felony cases ($-13.6$ percentage points…) and route more to jury trial ($+9.6$ pp…)"

These are consistent with each other. However, the Baseline section (Table 1 description, line 15) states:
> "the capital felony verdict share exhibits a significant secular decline of 0.56 percentage points per year ($p = 0.042$) over the panel, and pipeline utilization rates trend upward ($+0.55$ pp/year, $p = 0.003$)"

These specific numbers ($0.56$ pp/year, $+0.55$ pp/year) are cited in prose without any reference to the table they come from. If these are from Table 1 (T0 baseline), that should be stated. If they are from a separate trend regression, that needs a table reference. As written, these appear to be unanchored empirical claims.

**Severity:** -5 (empirical claims with specific numbers but no table anchor)

**Fix:** Add `(Table~\ref{tab:table1}, col.~X)` or similar after each secular trend claim.

---

### Issue 2 — Outdated coefficient reference: "9.2--10.7" vs. "$+9.6$" [-5 claims-evidence mismatch]

**Location:** Interpretation subsection (line 180):
> "FC jury trial rates increase by 9.2--10.7 percentage points ($p < 0.01$ for both)"

**And:** Contestation subsection (line 54) and Introduction DRAFT (line 23):
> "Capital felony jury trial rates… by 9.6 percentage points"
> "route more to jury trial ($+9.6$ pp)"

The Introduction and Contestation section both cite 9.6 pp. The Interpretation subsection cites 9.2–10.7 pp as a range. These could reflect different specifications or table columns, but as written a reader cannot tell. The Interpretation subsection appears to be quoting the same T2 main result — if so, the range should be narrowed to match the headline number, or the source of the range should be explained.

**Severity:** -5 (number inconsistency across sections for the same headline finding)

**Fix:** Either (a) reconcile to a single number with the table reference, or (b) explain what the range represents (e.g., "across the four timing specifications").

---

### Issue 3 — Outdated/inconsistent coefficient: FC dismissal rate [-3]

**Location:** Interpretation subsection (line 180):
> "FC prosecutorial dismissal rates decline by 13.6--13.7 percentage points ($p < 0.001$ for both)"

**And:** Contestation section (line 54):
> "Capital felony dismissal rates decline by 13.6 percentage points under contested elections ($p < 0.001$) and by 13.7 percentage points under uncontested elections ($p < 0.001$)"

These are consistent, which is good. However, the Falsification section (line 97) says:
> "The capital felony dismissal rate coefficient moves from $-13.6$ to $-13.5$ percentage points."

$-13.5$ is cited as the caseload-controlled estimate. If $-13.6$ is the baseline estimate (Table 2) and $-13.5$ is the controlled estimate (Table 8), that should be stated explicitly — "from Table~\ref{tab:table2}… to $-13.5$ (Table~\ref{tab:table8})."

**Severity:** -3 (minor inconsistency, but the two numbers appear in different subsections without sufficient anchoring)

---

### Issue 4 — Unanchored $\Delta$ claim in Contestation section [-3]

**Location:** Contestation section (line 54):
> "The contestation differential $\Delta = \beta_1 - \beta_2 = 0.001$ ($p = 0.994$)"

The $\Delta = 0.001$ value is cited inline. But the Introduction DRAFT (line 25) says "indistinguishable from zero" without citing the number, and the Interpretation section (line 181) says "$\Delta \approx 0$." The numerical value ($0.001$, $p = 0.994$) appears only once in the Results section. This value should be anchored to a table column — readers need to know where $\Delta = 0.001$ comes from.

**Severity:** -3 (missing table anchor for a key empirical claim)

**Fix:** Add "(Table~\ref{tab:table2}, col.~X)" after the first citation of $\Delta = 0.001$.

---

### Issue 5 — Hedging in the Falsification section [-2]

**Location:** Line 97:
> "What remains is *consistent with* a behavioral response to the electoral environment rather than a mechanical response to case flows."

"Consistent with" is technically appropriate here (you cannot rule out all alternatives), but this is the closing sentence of the Falsification section, which should be a relatively confident claim. The prior sentences have already established the null on incoming filings and the stability through caseload controls. The hedging weakens the landing.

**Severity:** -2

**Fix:** "The pattern is consistent with a behavioral response to the electoral cycle — not a mechanical response to case flows."
(Marginal improvement, but removes the passive "what remains" construction.)

---

### Issue 6 — "six of one and half a dozen of the other" idiom [-1 register]

**Location:** Baseline PLACEHOLDER block (line 25):
> "The observed decline may reflect six of one and half a dozen of the other—some combination of prosecutorial case selection and defendant plea behavior operating simultaneously."

This idiom is colloquial for an economics paper. The subsequent clause ("some combination of…") makes the idiom redundant — it just says the same thing twice. In a paper targeting AEJ:Applied or JPubE, this phrasing will stick out.

**Severity:** -1

**Fix:** Delete "six of one and half a dozen of the other—" and keep only "The observed decline may reflect some combination of prosecutorial case selection and defendant plea behavior operating simultaneously."

---

### Issue 7 — Passive voice in Composition subsection [-1]

**Location:** Disposition mechanism (line 84):
> "The reallocation is *election-driven, not competition-driven*."

This is fine as a declarative label. However, the following sentence:
> "The $\Delta \approx 0$ finding across all disposition margins *means* the reallocation is identical whether or not a challenger is present. This pattern *is difficult to reconcile with* models in which prosecutors strategically respond to competitive electoral threats."

"Is difficult to reconcile with" is passive-adjacent and weaker than needed for a conclusion sentence. After establishing the null, a cleaner closing: "No model of competitive signaling can accommodate a null $\Delta$ across all three disposition margins."

**Severity:** -1

---

### Issue 8 — Robustness section cites numbers not yet verified against current tables [-3]

**Location:** Timing Robustness PLACEHOLDER (lines 137–141):
> "$\Delta$ for total jury verdicts ranges from $-5.9$ to $-6.4$ ($p < 0.05$ in all cases), $\Delta$ for capital felony verdicts from $-5.1$ to $-5.4$ ($p < 0.05$), and $\Delta$ for the capital felony verdict share from $-0.077$ to $-0.082$ ($p < 0.01$)"

These specific numbers are in the PLACEHOLDER block (which is still red/draft), but they also appear in `study-parameters.md` (the non-negotiables file) from 2026-03-25 diagnostics. Per the UNVERIFIED CLAIMS warning in `study-parameters.md`, all specific coefficient values should be flagged as potentially outdated. These values appear plausible given the context, but the robustness table (table2b_delta_robustness.tex) is what should anchor these numbers. If table2b has been regenerated since 2026-03-25, these ranges need re-verification.

**Severity:** -3 (empirical claims in draft blocks that need explicit table-to-prose verification before finalizing)

**Flag for author:** Run the current `table2b_delta_robustness.tex` and confirm these ranges match. Do not finalize this section until table and prose agree.

---

### Issue 9 — Inconsistency between Interpretation and Introduction on "FC jury trial rates" [-3 claims-evidence mismatch]

**Location:** Interpretation section (line 184):
> "Uncontested prosecutors shift *more* aggressively toward capital felony jury trials ($+0.215$, $p < 0.001$) than contested prosecutors ($+0.145$, $p = 0.021$)."

These values ($+0.215$, $+0.145$) are in shares (proportions), not percentage points. But the Introduction DRAFT and Contestation section consistently report $+9.6$ pp (percentage points). If $+0.215$ represents a 21.5 pp increase, that is inconsistent with $+9.6$ pp. If $+0.215$ represents something else (shares of verdicts, not share of cases), the units must be clarified.

**Severity:** -3 (potential unit inconsistency for the same outcome; could be two different DVs but that must be explicit)

**Fix:** Clarify what variable $+0.215$ measures. If this is the share of jury verdicts that are capital felonies (the verdict composition DV), that is a different outcome than the FC jury trial rate. Label clearly: "the share of jury verdicts classified as capital felonies increases by 21.5 percentage points…"

---

### Issue 10 — Redundant structure across subsections (Baseline → Contestation → Composition) [-2]

The three core results subsections (Baseline, Contestation, Composition) each open with a sentence restating what the section will show, then present the finding, then provide mechanism interpretation. This parallel structure is appropriate for a results section. However, all three contain the clause "The behavioral shift is severity-selective" or equivalent:

- Baseline (line 23, Introduction DRAFT): "The behavioral shift is severity-selective"
- Contestation (line 58): "The behavioral shift is severity-specific"
- Composition (line 80): "The prosecutorial behavioral change during election years is concentrated on cases where the stakes are highest"

Three near-identical articulations of the same claim across three subsections feels repetitive. One full statement belongs in the Introduction; briefer callbacks in Results.

**Severity:** -2

---

### Results subtotal deductions: -5 -5 -3 -3 -2 -1 -1 -3 -3 -2 = **-28**
### Results score: **72/100**

*(Rounded to 74 in summary table to reflect that ~half the text remains in PLACEHOLDER/DRAFT blocks that are developmental rather than final prose.)*

---

## Cross-File Issues

### Outdated numbers — explicit flag list

The following specific coefficient values appear in active (non-struck) prose and must be verified against the current table outputs before submission:

| Value | Location | Risk |
|-------|----------|------|
| $-13.6$ pp (FC dismissal, contested) | Intro DRAFT, Results Contestation, Results Interpretation | Consistent across files — LOW risk if table2 is current |
| $-13.7$ pp (FC dismissal, uncontested) | Results Contestation | Consistent — LOW risk |
| $+9.6$ pp (FC jury trial, contested) | Intro DRAFT, Results Contestation | Consistent — LOW risk |
| $\Delta = 0.001$, $p = 0.994$ | Results Contestation | No table anchor — MEDIUM risk |
| $-10.1$ pp (FC plea rate) | Intro DRAFT, Results Contestation | Appears once each — LOW risk |
| $+0.215$ (uncontested FC jury share) | Results Interpretation | Unit unclear — HIGH risk |
| $+0.145$ (contested FC jury share) | Results Interpretation | Unit unclear — HIGH risk |
| $-5.9$ to $-6.4$ (Δ total verdicts, robustness) | Results Robustness | Draft block, needs table anchor — MEDIUM risk |
| $0.56$ pp/year trend | Results Baseline OVB caveat | No table anchor — HIGH risk |
| $+0.55$ pp/year trend | Results Baseline OVB caveat | No table anchor — HIGH risk |
| $-15.3$ pp (below-median FC dismissal) | Results Heterogeneity | No table anchor — MEDIUM risk |
| $+14.2$ pp (below-median FC trial rate) | Results Heterogeneity | No table anchor — MEDIUM risk |

---

## Positive Observations

- The mechanism prose in the Contestation and Composition subsections is well-constructed. The three-bullet structure (severity-selective / offsetting / election-driven not competition-driven) is clear and publication-ready with minor edits.
- The open-seat contrast paragraph (Results, line 27) is analytically sharp and demonstrates genuine value-added from the T1 decomposition.
- The theoretical framing in Introduction paragraphs 1–3 is strong. The shadow-of-trial setup (Landes, Grossman, Reinganum) is correctly cited and the motivation for examining upstream rather than downstream margins is clearly articulated.
- The "data correction note" in the Interpretation subsection is appropriately transparent. Methodological transparency about the Power BI aggregation artifact will be well-received by referees.
- The robustness section's off-cycle timing discussion is technically precise and correctly handles the distinction between sample contamination and TWFE weight heterogeneity.

---

## Priority Fixes Before Next Review

**Must fix (blocking for publishable quality):**
1. Strike the mobilization-framing sentence in Introduction para 4 (line 12) — internal inconsistency with paper's own findings
2. Reconcile the $+9.6$ pp vs. $+9.2$–$10.7$ pp inconsistency across Results subsections
3. Clarify units for $+0.215$ and $+0.145$ in Interpretation (are these verdict composition shares or trial rate shares?)
4. Anchor all secular trend values ($0.56$ pp/year, $+0.55$ pp/year) to a table reference

**Should fix:**
5. Verify `subramanian2020shadows` is the correct cite for the 95% plea rate statistic
6. Add table anchors for $\Delta = 0.001$ and the heterogeneity numbers ($-15.3$ pp, $+14.2$ pp)
7. Eliminate "six of one and half a dozen of the other" idiom
8. Reduce the redundant "severity-selective" language to one primary statement + brief callbacks

**May fix (advisory):**
9. Replace "most visible cases" with "highest-stakes cases" in contributions paragraph
10. Verify `\label{subsection-limits}` exists in the document
11. Strengthen closing sentence of Falsification section (remove "What remains")

---

## Final Scores

| File | Score |
|------|-------|
| `1-introduction.tex` | **88/100** |
| `5-results.tex` | **72/100** |
| **Combined (equal weight)** | **80/100** |

The Introduction is close to publishable with two targeted fixes (framing remnant, citation verification). The Results section needs a focused revision pass to resolve the number inconsistencies and add table anchors for the inline coefficient claims before it can advance.
