---
name: devils-advocate
description: Challenge analytical choices with tough referee-style questions before submission
disable-model-invocation: true
argument-hint: "[section, finding, or specification to challenge]"
allowed-tools: ["Read", "Grep", "Glob", "WebSearch", "Task"]
---

# Devil's Advocate

Challenge a section, finding, or specification with 5-7 tough questions a skeptical referee would ask. Purpose: identify weaknesses before submission.

**Input:** `$ARGUMENTS` — what to challenge (e.g., "identification strategy", "Table 1 results", "2-background section").

## Challenge Categories

### 1. Identification & Endogeneity
- Is the treatment truly exogenous?
- What omitted variables could drive both treatment and outcome?
- Could reverse causality explain the results?
- Is there a more credible identification strategy available?

### 2. Data & Measurement
- Are the outcome variables measuring what you claim?
- Could measurement error bias the results? In which direction?
- Is the sample representative of the population you want to generalize to?
- Are there selection effects in your sample construction?

### 3. Specification & Robustness
- Why this specification and not an alternative?
- How sensitive are results to the exact control set?
- What happens if you change the sample period, geographic scope, or clustering level?
- Is TWFE appropriate here given potential treatment effect heterogeneity?

### 4. Interpretation
- Could the null result on a secondary outcome mean something other than the proposed mechanism?
- Are you overclaiming from suggestively significant results?
- How does this generalize beyond the study setting?
- What's the policy relevance given institutional features?

### 5. Literature & Contribution
- How exactly does this advance beyond key prior papers?
- Is the contribution truly novel, or has someone observed it before?
- Are you citing the most recent work in this area?

## Output

Generate 5-7 specific, challenging questions with:
1. The question itself (as a referee would phrase it)
2. Why it matters (what it threatens)
3. Your best available response (from existing analysis)
4. Remaining vulnerability (what you can't fully address)

Format each as:
```
### Q[N]: [Question]
**Threat:** [What this challenges]
**Response:** [Best available answer]
**Vulnerability:** [What remains unaddressed]
**Action:** [NONE / ADD ROBUSTNESS / REVISE TEXT / FUTURE WORK]
```
