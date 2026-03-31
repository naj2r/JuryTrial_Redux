---
name: review-paper
description: Comprehensive manuscript review — argument structure, econometric specification, citations, and referee objections
disable-model-invocation: true
argument-hint: "[paper file path or section name]"
allowed-tools: ["Read", "Grep", "Glob", "Write", "Task"]
---

# Manuscript Review

Produce a thorough, constructive review — the kind a top-journal referee would write.

**Input:** `$ARGUMENTS` — path to a paper (.tex, .pdf, .qmd), or a section name (e.g., "introduction", "results").

## For This Paper

The paper is at: `$OL/`
Key sections: `$OL/Sections/1-introduction.tex` through `$OL/Sections/6-conclusion.tex`
Results reference: `$RB/output/results/regression_results.csv`

## Review Dimensions

### 1. Argument Structure
- Research question clearly stated?
- Introduction motivates effectively?
- Logical flow: question → method → results → conclusion?
- Conclusions supported by evidence?

### 2. Identification Strategy
- Causal claim credible?
- Key assumptions stated?
- Threats addressed?
- Robustness adequate?

### 3. Econometric Specification
- Correct SEs? (check clustering from study-parameters.md)
- Appropriate functional form?
- Multiple testing concerns?
- Effect sizes economically meaningful?

### 4. Literature Positioning
- Key papers cited? (check study-parameters.md for core references)
- Contribution differentiated from existing work?
- Missing citations a referee would flag?

### 5. Writing Quality & Presentation
- Tables self-contained (labels, notes, sources)?
- Notation consistent?
- Appropriate length?

## Output

Save to: `quality_reports/paper_review_[section].md`

Include:
- Summary assessment (Accept / R&R / Reject)
- 3+ strengths
- Major and minor concerns with suggestions
- 3-5 "referee objections" — tough questions a top referee would ask
- Dimension-by-dimension scores (1-5)
