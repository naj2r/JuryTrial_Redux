---
name: lit-review
description: Structured literature search and synthesis with citation extraction and gap identification
disable-model-invocation: true
argument-hint: "[topic, paper title, or research question]"
allowed-tools: ["Read", "Grep", "Glob", "Write", "WebSearch", "WebFetch", "Task"]
---

# Literature Review

Conduct a structured literature search and synthesis on the given topic.

**Input:** `$ARGUMENTS` — a topic, paper title, research question, or phenomenon to investigate.

## Project Context

Core references are in:
- `$RB/docs/` (existing .bib files and literature notes)
- `$PAPERS/` (source PDFs organized by topic)

## Steps

1. **Parse the topic** from `$ARGUMENTS`. If a specific paper is named, use it as the anchor.

2. **Search for related work** using available tools:
   - Check `$PAPERS/` for uploaded PDFs
   - Check existing .bib files and literature notes in `$RB/docs/`
   - Use `WebSearch` to find recent publications
   - Use the Consensus API for academic paper search

3. **Organize findings** into categories:
   - **Theoretical contributions** — models, frameworks, mechanisms
   - **Empirical findings** — key results, effect sizes, identification strategies
   - **Methodological innovations** — estimators, research designs
   - **Open debates** — unresolved disagreements

4. **Identify gaps and opportunities:**
   - What questions remain unanswered?
   - What data or methods could address them?
   - How does our study fill these gaps?

5. **Extract citations** in BibTeX format (key format: `authorYYYYdescriptor`).

6. **Save the report** to `$RB/quality_reports/lit_review_[topic].md`

## Output Format

```markdown
# Literature Review: [Topic]

**Date:** [YYYY-MM-DD]
**Query:** [Original query]

## Summary
[2-3 paragraph overview]

## Key Papers
### [Author (Year)] — [Short Title]
- **Main contribution:** [1-2 sentences]
- **Method:** [ID strategy / data]
- **Key finding:** [Result with effect size]
- **Relevance:** [Connection to our study]

## Gaps and Opportunities
1. [Gap our study fills]
2. [Gap for future work]

## BibTeX Entries
```

## Important

- **Do NOT fabricate citations.** If unsure about details, flag for verification.
- **Prioritize recent work** (last 5-10 years) unless seminal papers are older.
- **Note working papers vs published papers.**
- **BibTeX key format:** `authorYYYYdescriptor` (e.g., `bibas2004shadow`)
