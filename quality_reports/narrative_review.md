# Narrative Review: Cross-Section Coherence
**Reviewer:** narrative-reviewer agent
**Date:** 2026-03-24
**Files reviewed:**
- `$OL/Sections/1-introduction.tex`
- `$OL/Sections/2-background.tex`
- `$OL/Sections/4-methods.tex`
- `$OL/Sections/5-results.tex`

---

## Executive Summary

The paper is in a mid-transition state. The results and framing have been substantially overhauled since the original "shadow expansion / jury mobilization" story, and the revised draft correctly orients around **case disposition shifts** and **competence maintenance**. However, the revision is incomplete: several live (non-commented) paragraphs in Section 2 still argue for the old mobilization framing as if it is an established finding, and the Introduction contains both old struck-through text and new DRAFT-flagged text that have not been reconciled into a single voice. The four sections do not yet tell one consistent story.

**Overall severity:** HIGH. The paper cannot be submitted or sent for peer review in its current state. The core argument — null mobilization counts, negative utilization rates, disposition shifts toward jury trial — is correct and well-developed in the new draft passages, but it coexists with active prose that contradicts it.

---

## 1. Framing Consistency

### 1a. Active text in Section 2 still argues for "shadow expansion" / jury mobilization increase

**Severity: CRITICAL**

The following non-commented, non-struck paragraphs in `2-background.tex` assert or strongly imply that jury mobilization *increases* under electoral pressure. These contradict the corrected results, where raw mobilization counts are uniformly null.

**Line 29 (`2-background.tex`):**
> "We examine whether pressure continues on the jury pipeline margin---whether jury mobilization increases during election years"

This sentence frames "increased jury mobilization" as the hypothesis being tested. The corrected results show mobilization is null. The correct framing is that we test whether *any* margin responds, and the actual finding is disposition shifts (not mobilization increases). A reader of this sentence will expect a positive mobilization result.

**Line 58 (`2-background.tex`):**
> "Our jury pipeline results provide corroborating evidence consistent with this account: electoral pressure is associated with expanded jury mobilization."

This is a direct claim of expanded jury mobilization as a confirmed empirical result. It is factually wrong under the corrected data. This sentence must be deleted or corrected. It is active, non-commented text, not struck through.

**Line 84 (`2-background.tex`):**
> "Jury mobilization during election periods is a form of resource expansion---assembling larger panels may signal commitment to trial readiness, which is consistent with the defendant screening mechanism \citet{baker2001prosecutorial} describe. Our null verdict finding is consistent with their model's prediction: the welfare gain from better screening operates through plea bargaining, not through adjudication."

The first sentence ("assembling larger panels") treats mobilization expansion as an established fact. The second sentence correctly reports a null verdict. This combination is internally contradictory: if mobilization is null (which it is), the Baker et al. mechanism linking mobilization to screening cannot be invoked. Either the mobilization result was positive (old story) or the mechanism claim needs to be rewritten around the disposition shift story.

**Line 92 (`2-background.tex`):**
> "Under sentence-length evaluation (Propositions 2--3), prosecutors take too many cases to trial---consistent with our jury summoning increase."

"Consistent with our jury summoning increase" is a false claim. Jury summoning shows no significant increase in the corrected results. This should be updated to reference the disposition shift (more jury trials on the FC disposition margin) rather than jury summoning.

**Lines 103--107 (`2-background.tex`, Priest-Klein enumeration):**
> "1. Trial preparation as a bargaining tool: expanded jury mobilization credibly signals trial readiness..."
> "2. Selection on marginal cases: prosecutors pushing cases toward trial preparation bring weaker marginal cases into the pipeline..."

Both points assume that the finding is expanded jury mobilization. Under the corrected results, there is no evidence of expanded mobilization. The Priest-Klein discussion needs to be reframed around the disposition shift (more FC cases routed to jury trial, fewer dismissed) rather than the mobilization pipeline.

**Line 112 (`2-background.tex`):**
> "Electoral pressure may contract completed trials while expanding the mobilization infrastructure that casts the shadow."
> "we test whether pipeline mobilization increases during election years while verdict counts remain stable---consistent with the threat of trial, not trial itself, resolving cases."

This sentence sets up the old story (mobilization increases, verdicts null) as the test. The actual finding is different: verdict counts *decline*, and mobilization does not increase. The sentence needs to be updated to the new story.

**Lines 143--144 (`2-background.tex`):**
> "When more jurors are summoned, instructed to report, and empaneled for voir dire, the system is building the machinery that casts the shadow. If electoral pressure expands the shadow---if increased jury mobilization builds a more credible trial threat---without expanding the light, then the jury pipeline responds to electoral incentives even when final trial outcomes do not."

This paragraph frames the test as "does mobilization increase." The answer is no. This should be replaced with a setup for the actual finding: disposition shifts toward jury trial, even as raw mobilization is stable.

**Lines 177--188 (`2-background.tex`, testable predictions):**

Prediction 1 explicitly states:
> "Electoral pressure increases jury mobilization (the shadow expands): If prosecutors facing re-election invest more in trial readiness to signal competence, jurors told to report and jurors who actually report should increase during election years."

And line 189:
> "Our empirical results, detailed in Section~\ref{section-results}, are consistent with all four predictions."

This is a false claim. Prediction 1 (increased juror reporting) is NOT confirmed in the corrected results. The raw pipeline counts (summoned, told to report, actually reported) are uniformly null. Claiming that results are "consistent with all four predictions" when Prediction 1 fails is a verifiable factual error that a referee will catch immediately.

---

### 1b. Introduction struck text is visible, no clean replacement

**Severity: HIGH**

`1-introduction.tex` lines 13--17 contain commented-out (struck-through) paragraphs from the old results section, followed by a new `{\color{red}\textbf{[DRAFT...]}}` block at lines 19--31 with revised contributions. The paper has *two* contributions paragraphs in the same section: the old one (commented out but visually cluttering the `.tex` source), and the new draft one (in red with a timestamp). A reader of the compiled PDF will see the new draft contributions in red text. This is a production-blocking issue regardless of content.

Additionally, the Introduction's roadmap at line 33 references `section-background` (for jury mobilization theory), but the results it summarizes are the new disposition-shift results. The transition sentence — "Section 2 reviews the relevant literature and develops the theoretical framework linking electoral pressure to jury mobilization" — now describes a framework that diverges from what the results show. If the contribution has shifted from jury mobilization to case disposition, the section roadmap should say so.

---

## 2. Narrative Arc

### 2a. Introduction → Background: The puzzle is set up correctly, but Background resolves it with the wrong answer

**Severity: HIGH**

The Introduction (lines 7--11) correctly sets up the puzzle: if electoral pressure exists but doesn't appear in aggregate adjudication counts, where does it go? The Introduction's new draft contributions (lines 23--29) correctly answer: it goes to the *disposition margin* (fewer FC dismissals, more FC jury trials).

But Background Section 2 opens (line 6) with: "Using Michigan jury management data (2016--2024), we test whether electoral pressure has shifted to a different margin---the administrative infrastructure of trial readiness." The word "administrative infrastructure" foregrounds jury summoning and mobilization (the old story) rather than case disposition. A reader moving from Introduction to Background will find the contribution framing shifting under their feet.

The Background then develops a full mobilization theory (Baker et al., Priest-Klein, shadow expansion) that the corrected results do not support, before the red-flagged PLACEHOLDER block at lines 31--43 introduces the correct disposition shift framing. The logical sequence should be: puzzle → disposition mechanism theory → empirical test. Currently it is: puzzle → mobilization theory (active, wrong) → disposition mechanism theory (red DRAFT, correct) → [results that don't match the active theory].

### 2b. Methods → Results: Coherent on their own terms

**Severity: LOW**

The Methods section (4-methods.tex) and the new DRAFT passages in Results (5-results.tex) are internally consistent. T0 as benchmark (county FE only, no year FE), T2 as primary (TWFE, contested + uncontested, open seats excluded), the $\Delta$ estimand, the Wooldridge robustness — all of this is explained clearly in Methods and correctly invoked in Results. The falsification section (Table 8 / incoming filings) directly connects to the null confound concern raised in Methods. This arc works.

### 2c. Background subsection \ref{subsec-contribution} and Introduction contributions: Partial redundancy

**Severity: MEDIUM**

The Background's `\subsection{Contribution and Hypotheses}` (lines 138--189, 2-background.tex) and the Introduction's new DRAFT contributions block (lines 19--31, 1-introduction.tex) cover substantially overlapping ground. Both enumerate three contributions. Both describe the null $\Delta$. Both invoke Hessick (2023) on contestation. In a finished paper, contributions are typically stated once in the Introduction and not repeated at length in a Background subsection. If the Background subsection is retained, it should position the paper relative to prior literature (the gaps table at line 153 is appropriate for this) rather than re-enumerate the findings.

---

## 3. Claims Alignment

### 3a. Four testable predictions (Background lines 177--188) vs. actual results

**Severity: CRITICAL**

As noted in §1a above, line 189 claims "Our empirical results... are consistent with all four predictions." This is false. The predictions are:

1. Electoral pressure **increases jury mobilization** — NOT CONFIRMED (null raw counts)
2. Electoral pressure does not increase verdicts — CONFIRMED (verdicts decline)
3. Contested elections may reduce verdicts — PARTIALLY consistent
4. Effects concentrate in pipeline stages courts control — AMBIGUOUS

The claim of consistency across all four predictions must be corrected. The most defensible fix is to replace Prediction 1 with a prediction consistent with the disposition shift story (e.g., "Electoral pressure routes capital felony cases away from dismissal and toward jury trial") and adjust the claim of consistency accordingly.

### 3b. Introduction contributions vs. Results

**Severity: LOW — well-aligned in the new drafts**

The new DRAFT contributions block in the Introduction (lines 19--31) aligns well with the Results DRAFT passages. The three contributions stated there (disposition margin response, null $\Delta$ on disposition margins, severity-selective / capacity-mediated effects) all appear as named subsections in Results. This is good. The alignment will hold once the Introduction's red DRAFT block is finalized as live text.

### 3c. "Shadow expansion" residue in Background's shadow-of-trial subsection

**Severity: MEDIUM**

The shadow-of-trial subsection (lines 62--114, 2-background.tex) was written around the old framing and still uses "shadow expansion" language throughout:

- Line 84: "Our null verdict finding is consistent with their model's prediction" — but the model being referenced (Baker et al.) was linked to mobilization expansion, not disposition shifts.
- Lines 103--107: The Priest-Klein enumeration treats trial preparation expansion as the finding.
- Line 112: "Electoral pressure may contract completed trials while expanding the mobilization infrastructure."

The shadow-of-trial theory is still *relevant* to the paper (disposition shifts toward jury trial strengthen the trial threat in plea negotiations), but the specific connecting sentences need to be rewritten to connect the theory to the disposition mechanism rather than the mobilization mechanism.

---

## 4. Voice Consistency

### 4a. Red DRAFT/PLACEHOLDER blocks throughout

**Severity: PRODUCTION-BLOCKING**

The compiled PDF will display prominent red `[DRAFT --- ... --- 2026-03-26]` and `[PLACEHOLDER --- ...]` blocks throughout the paper. These appear in:

- Introduction: lines 19--31 (DRAFT revised results summary)
- Background: lines 31--43 (PLACEHOLDER contribution positioning), line 91 (PLACEHOLDER Wooldridge model in Methods)
- Methods: lines 35--68 (PLACEHOLDER revised model architecture), lines 87--88 (NOTE on corrected estimates), lines 91--109 (PLACEHOLDER Wooldridge adjustment), lines 113--114 (NOTE on Romano-Wolf)
- Results: lines 9--11, 13--17, 19--33 (domain reviewer notes / OVB caveat), lines 50--64, 76--86, 93--99, 119--127 (DRAFT sections), lines 131--143, 145--153, 176--190 (PLACEHOLDER timing / interpretation)

The red-flagged material is substantively correct and well-argued. The problem is purely production: these blocks need to be converted from draft placeholders to live prose before the paper can be circulated. The voice within the DRAFT blocks is generally strong and consistent with the Introduction's framing — the issue is not register or style but the explicit red formatting.

### 4b. Voice differences: author prose vs. Claude-drafted passages

**Severity: LOW / ADVISORY**

The Background's older subsections (electoral accountability, §2.1; shadow of trial, §2.2; bureaucratic mechanisms, §2.3) appear to be primarily author-written prose. The new DRAFT blocks (Introduction contributions, Results subsections) read as more systematic and exhibit more parallel structure (three-item enumerations, labeled findings). This creates a mild voice discontinuity — the old sections use flowing prose with embedded citations, the new sections use labeled-paragraph structure. This is not a serious problem for peer review, but the author may want to decide on a structural style and apply it consistently.

---

## 5. Redundancy

### 5a. Null $\Delta$ stated five times in active + draft text

**Severity: LOW** (once cleaned, this will be easy to cut)

The null contestation differential ($\Delta \approx 0$) is stated in:
1. Introduction DRAFT (line 25): "$\Delta = 0.001$...indistinguishable from zero"
2. Background PLACEHOLDER (lines 36--37): same finding
3. Results Contestation subsection (line 54): restated
4. Results Mechanism subsection (line 84): restated
5. Results Interpretation (line 180): restated

In a finished paper, the finding would be stated once in the Introduction, set up in Methods as the key estimand ($\Delta$), confirmed in Results, and interpreted in Discussion. The current draft states it in each location because the sections were written separately. A consolidation pass is needed.

### 5b. Description of the T2 specification: stated in Methods and restated in Results

**Severity: LOW**

Results §5.2 (line 52) re-describes the T2 specification in detail: "The specification uses county fixed effects only... open-seat elections modeled as a separate regressor..." This description already appears in Methods §4.3. In a finished paper, Results can refer readers to Methods rather than re-explaining the specification. This is a minor issue but adds length.

---

## 6. Missing Transitions

### 6a. Introduction → Section 2: roadmap describes old story

**Severity: MEDIUM**

The roadmap sentence (Introduction, line 33) reads:
> "Section 2 reviews the relevant literature and develops the theoretical framework linking electoral pressure to jury mobilization."

"Jury mobilization" should be replaced with language that matches the current contribution framing: "case disposition and trial readiness" or similar. As written, a reader follows this sentence expecting Section 2 to deliver a jury mobilization theory, which it partially does — but the actual findings are about case routing, not mobilization volume. This mismatch primes the reader for the wrong result.

### 6b. End of Background → Methods: no transition

**Severity: LOW**

Section 2 ends at line 189 with "Our empirical results... are consistent with all four predictions." Section 4 (Methods) opens directly on the regression equation with no transitional sentence. A brief sentence connecting the theoretical predictions to the empirical design would improve flow: "We test these predictions using a TWFE panel design across Michigan's 83 counties and 7 years."

### 6c. Falsification subsection → Heterogeneity: no bridge

**Severity: LOW**

Results §5.4 (Falsification) ends by establishing that incoming filings are null. §5.5 (Heterogeneity) opens directly with Michigan county cost statistics. A single sentence — e.g., "Having established that the disposition shift is not driven by case volume, we ask where within the state it is most pronounced" — would orient the reader.

---

## 7. Old Framing Remnants (Specific Text Flags)

The following are active (non-commented, non-struck) passages that use "shadow expansion," "jury mobilization increases," "expanded jury mobilization," or pre-correction logic. Each needs to be revised or deleted.

| Location | Line(s) | Quoted Text | Action Required |
|----------|---------|-------------|-----------------|
| 2-background.tex | 29 | "we examine whether...jury mobilization increases during election years" | Revise to "we examine whether case disposition responds to election years" |
| 2-background.tex | 58 | "electoral pressure is associated with expanded jury mobilization" | DELETE — factually wrong per corrected results |
| 2-background.tex | 84 | "assembling larger panels may signal commitment to trial readiness" | Revise to link Baker et al. to the disposition mechanism, not mobilization expansion |
| 2-background.tex | 92 | "consistent with our jury summoning increase" | Revise: no summoning increase found; link instead to FC jury trial rate increase |
| 2-background.tex | 103--104 | "expanded jury mobilization credibly signals trial readiness" (Priest-Klein item 1) | Revise Priest-Klein framing to disposition-shift story |
| 2-background.tex | 112 | "expanding the mobilization infrastructure that casts the shadow" | Revise to "routing more capital cases toward jury trial" |
| 2-background.tex | 112 | "we test whether pipeline mobilization increases during election years while verdict counts remain stable" | Revise: the actual test is disposition shifts, and verdicts decline (not stable/null) |
| 2-background.tex | 143--144 | "if increased jury mobilization builds a more credible trial threat...without expanding the light" | This paragraph sets up the old hypothesis. Replace with setup for the disposition shift test. |
| 2-background.tex | 178 | Prediction 1: "jurors told to report and jurors who actually report should increase" | Revise Prediction 1 to match the disposition story |
| 2-background.tex | 189 | "Our empirical results...are consistent with all four predictions" | Revise: Prediction 1 (mobilization increase) is NOT consistent with corrected results |

---

## 8. Summary Assessment

| Category | Severity | Blocking? |
|----------|----------|-----------|
| Active text asserting jury mobilization increase (Background §2.2, §2.4) | CRITICAL | Yes — contradicts all corrected results |
| Testable predictions claim all four confirmed (Background line 189) | CRITICAL | Yes — Prediction 1 fails |
| Red DRAFT/PLACEHOLDER blocks visible in compiled PDF | PRODUCTION | Yes for circulation |
| Roadmap sentence describes old mobilization story | HIGH | Should fix before circulation |
| Four null-Δ restatements across sections | LOW | No — minor prose cleanup |
| Voice discontinuity (author prose vs. DRAFT blocks) | ADVISORY | No |
| Missing transitions (Background→Methods, Falsification→Heterogeneity) | LOW | No |
| Background contribution subsection redundant with Introduction | MEDIUM | No |

### Priority Order for Revisions

1. **Immediate (pre-circulation):** Correct or delete the eight active passages in Section 2 that claim jury mobilization increases (flagged above). These will cause a referee to reject the paper as internally inconsistent on first read.

2. **Immediate (pre-circulation):** Revise the four testable predictions (Background lines 177--188) and their summary claim (line 189) to match the corrected findings.

3. **Before sending out:** Convert all red DRAFT/PLACEHOLDER blocks to live prose. The content is largely right — it needs formatting, not rewriting.

4. **Prose pass:** Update the Introduction roadmap sentence (line 33), add the two missing transition sentences, and consolidate the five restatements of the null $\Delta$ into a single canonical statement in each relevant section.

5. **Advisory:** Reconcile the voice discontinuity between older flowing-prose sections and the more structured DRAFT passages. Not blocking, but will read as a draft if left unaddressed.
