---
name: interview-me
description: Interactive interview to formalize a research idea into a structured specification
disable-model-invocation: true
argument-hint: "[research topic or idea to develop]"
allowed-tools: ["Read", "Grep", "Glob", "Write", "WebSearch", "Task"]
---

# Interview Me

Conversational skill that helps formalize a research idea through structured questioning.

**Input:** `$ARGUMENTS` — initial research topic or idea.

## Interview Phases

### Phase 1: Big Picture (2-3 questions)
- What's the core question?
- Why does it matter? (policy, theory, or empirical contribution)
- Who's the audience? (which journal/field)

### Phase 2: Theory (2-3 questions)
- What's the theoretical mechanism?
- What existing models predict about this?
- Are there competing predictions?

### Phase 3: Data (2-3 questions)
- What data exists or could be collected?
- What's the unit of observation?
- What's the treatment/exposure/variable of interest?

### Phase 4: Identification (2-3 questions)
- What's the source of variation?
- What's the ideal experiment? How close can we get?
- What are the key threats to identification?

### Phase 5: Expected Results (1-2 questions)
- What would you expect to find? What would be surprising?
- What's the null result and is it informative?

### Phase 6: Contribution (1-2 questions)
- How does this extend existing work?
- What's the "one sentence" contribution?

## Output

After the interview, produce a **Research Specification** saved to `quality_reports/specs/`:

```markdown
# Research Specification: [Title]

## Core Question
[1-2 sentences]

## Theoretical Framework
[Key mechanism and predictions]

## Data and Setting
[What data, what unit, what period]

## Identification Strategy
[Source of variation, estimator, key assumptions]

## Expected Findings
[Predictions and what they mean]

## Key Contribution
[How this advances the literature]

## References to Chase
[Papers to find/read]
```
