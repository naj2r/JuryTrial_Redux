---
name: write
description: Draft academic economics paper sections with notation protocol, anti-hedging, and humanizer pass. Replaces /draft-paper and /humanizer.
disable-model-invocation: true
argument-hint: "[section or mode: intro | strategy | results | conclusion | abstract | full | humanize] [file path (optional)]"
allowed-tools: ["Read", "Grep", "Glob", "Write", "Edit", "Task"]
---

# Write

Draft paper sections or apply humanizer pass by dispatching the **Writer** agent.

**Input:** `$ARGUMENTS` — section name or mode, optionally followed by file path.

---

## Modes

### `/write [section]` — Draft Paper Section
Draft a specific section: `intro`, `strategy`, `results`, `conclusion`, `abstract`, or `full`.

**Agent:** Writer
**Output:** LaTeX section file in Paper/sections/

Workflow:
1. Read existing paper, research spec, literature review, results summary
2. Read domain-profile.md for field conventions
3. Check Bibliography_base.bib for available citations
4. Dispatch Writer with section standards:
   - Introduction: contribution in first 2 pages, effect sizes with units
   - Strategy: estimating equation displayed and numbered, assumptions explicit
   - Results: every estimate with units and magnitudes
   - Conclusion: restate with effect size, limitations, implications
5. Writer applies notation protocol and anti-hedging rules
6. Humanizer pass runs automatically before finalizing
7. Save to Paper/sections/[section].tex

### `/write humanize [file]` — Humanizer Pass Only
Strip AI writing patterns from existing text without rewriting content.

**Agent:** Writer (humanizer mode)
**Output:** Edited file with AI patterns removed

Strips patterns across 5 categories (40+, expanded per Feyzollahi & Rafizadeh 2025; Walther et al.):
- **Structural:** forced narrative arcs, artificial progression, hourglass paragraphs, symmetric paragraph length, "not X but Y" reframes (more than once)
- **Lexical (general):** delve, leverage (non-technical), nuanced, robust (non-statistical), garner, foster, tapestry, landscape (figurative), realm, illuminate (figurative), navigate (figurative), embody, grapple, swiftly
- **Lexical (econ-specific, empirically flagged):** underscore/underscores/underscored, nuance/nuanced, intriguing, intertwined, interplay, certainly (filler), leverage (filler)
- **Copula substitution:** "serves as" → "is"; "marks the/a" → "is"; "stands as" → "is"; "features" (= has) → "has"; "offers" (= has) → "has/provides"
- **Rhetorical:** rule-of-three everywhere, em dash overuse (>2/paragraph), trailing significance clauses ("...highlighting/underscoring/emphasizing the importance of...")
- **Framing:** filler importance preambles ("It is worth noting that..."), unearned escalation to broad significance, over-explaining obvious concepts to expert readers, promotional language ("fills a critical gap", "groundbreaking"), excessive bullet points

---

## Section Standards

| Section | Length | Key Requirements |
|---------|--------|-----------------|
| Introduction | 1000-1500 words | Hook → question → method → finding → contribution → roadmap |
| Strategy | 800-1200 words | Formal assumption, numbered equation, threats addressed |
| Results | 800-1500 words | Main spec, effect sizes in economic terms, heterogeneity |
| Conclusion | 500-700 words | Restate with effect size, policy, limitations, future |
| Abstract | 100-150 words | Question, method, finding with magnitude, implication |

---

## Principles
- **This is the user's paper, not Claude's.** Match their voice and style.
- **Never fabricate results.** Use TBD placeholders.
- **Citations must be verifiable.** Only cite confirmed papers.
- **Humanizer is automatic.** Every draft gets de-AI-ified.
