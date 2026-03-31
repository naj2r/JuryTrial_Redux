---
paths:
  - "**/*.qmd"
  - "**/*.md"
---

# Compression Triad — 3-Agent Adversarial Compression

**Purpose:** Compress lit review (or any QMD section) to target word count while preserving argumentative nuance.

## The Three Agents

### 1. Compressor (sonnet)
**Bias:** Prefers shorter. Always slightly favors hitting the word limit.
**Task:** Produce compressed draft from the input, targeting the specified word range.
**Scoring lens:** Word count compliance is paramount. Every paragraph must earn its place. Redundancy is the enemy.

### 2. Nuance Contrarian (sonnet)
**Bias:** Hates simplification. Only begrudgingly accepts calls to reduce scope and length.
**Task:** Review the Compressor's output. For each compression decision:
- **ACCEPT** — if the cut removed genuine redundancy without losing argumentative force
- **OBJECT** — if the cut lost a nuanced point central to the argument. Specify what was lost and why it matters.
- **Score** the compressed draft. Deduct points for:
  - Lost theoretical nuance (e.g., a caveat that prevents overclaiming) — **-5 per instance**
  - Lost empirical specificity (e.g., effect sizes, p-values, sample details) — **-3 per instance**
  - Lost citation context (e.g., what a paper actually showed vs. a hand-wave) — **-3 per instance**
  - Lost argumentative connective tissue (e.g., a transition that established WHY two ideas connect) — **-4 per instance**
  - Introduce vagueness where precision existed — **-5 per instance**

### 3. Mediator (sonnet)
**Bias:** 50-50 between context preservation and size compliance. Wants to placate reasonable complaints from both sides.
**Task:** Read the Compressor's draft AND the Contrarian's objections. For each objection:
- **SUSTAIN** — restore the nuance (Contrarian wins this point)
- **OVERRULE** — the compression was justified (Compressor wins this point)
- **COMPROMISE** — find a middle path (shorter than original, more nuanced than compressed)

**Mediator's Word Count Penalty:** Deduct **10 points per 200 words** over the max range. This is softer than the quality-gates rule — the mediator accepts slight overruns if the content justifies it.

**Mediator's output is final.** No further rounds.

## Protocol

```
Round 1: Compressor
  Input: Draft N (full text)
  Output: compressed_draft.md + compression_report.md
    (lists every cut with rationale)

Round 2: Nuance Contrarian
  Input: Draft N (original) + compressed_draft.md + compression_report.md
  Output: contrarian_objections.md
    (lists every objection with what was lost and a score)

Round 3: Mediator
  Input: compressed_draft.md + contrarian_objections.md
  Output: mediated_draft.md (FINAL) + mediation_report.md
    (lists each ruling: SUSTAIN/OVERRULE/COMPROMISE with rationale)
```

## Agent Model Assignments

| Agent | Model | Rationale |
|-------|-------|-----------|
| Compressor | sonnet | Structural work, pattern-matching on redundancy |
| Nuance Contrarian | **opus** | Must deeply understand the argument to detect lost nuance — economic reasoning cannot be cheapened |
| Mediator | sonnet | Balanced judgment, applying rules to the dispute |

## Word Count Targets

| Section | Max Range | Hard Ceiling |
|---------|-----------|-------------|
| Literature review (§2) | 3,000–3,500 words | 4,000 words (mediator penalty above this) |
| Other sections | TBD per section | TBD — set in study-parameters.md |

## Integration

- Runs AFTER the review pipeline (inquisitor + domain reviewer + clarifier)
- Runs BEFORE McCloskey prose edit (compress first to target word count, THEN polish prose style)
- Pipeline order: Draft → Review pipeline → **Compression triad** → **Narrative fact-check** → **McCloskey prose edit** → Final draft
- Output goes to the next draft QMD file
- Compression and mediation reports go to `$RB/quality_reports/drafts/consolidation/`
- Stenographer fires after completion

## What the Contrarian Should Especially Protect

These are the kinds of nuances that should NOT be compressed away:
- Caveats that prevent overclaiming (e.g., "consistent with" vs. "confirms")
- Mechanism ambiguity acknowledgment (multiple mechanisms can't yet be distinguished)
- Falsifiability criteria
- Asymmetric loss function framing (Niskanen/Wilson)
- Multi-task agency appeal (Holmstrom & Milgrom)
- Specific effect sizes and p-values from headline results — defined in `study-parameters.md`
- Precise language about theory extension vs. confirmation
- "Shadow expands without light" configurations or analogous theoretical nuances from your study
