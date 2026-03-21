---
name: research-ideation
description: Brainstorm research questions, extensions, and strategies based on current findings
disable-model-invocation: true
argument-hint: "[topic, finding, or direction to explore]"
allowed-tools: ["Read", "Grep", "Glob", "Write", "WebSearch", "Task"]
---

# Research Ideation

Generate research questions, extensions, and strategies building on the current study.

**Input:** `$ARGUMENTS` — a topic, specific finding, or direction to explore.

## Context

Current study: {{Brief one-line summary of your study, method, setting, and key finding.}}

## Steps

1. **Read the current findings** from `docs/results_briefing_for_lit_review.md`
2. **Identify extension opportunities:**
   - New data sources that could test mechanisms
   - Alternative estimation strategies (stacked DID, event study, RDD)
   - Cross-state comparisons
   - Case-level data possibilities
   - Policy variation to exploit
3. **Generate 5-10 research questions** ranked by:
   - Feasibility (data availability, methodology)
   - Novelty (gap in literature)
   - Impact (importance for policy or theory)
4. **For top 3 questions**, sketch:
   - Data requirements
   - Identification strategy
   - Expected findings
   - Key references
5. **Save to** `quality_reports/research_ideation_[topic].md`
