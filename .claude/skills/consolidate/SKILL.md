---
name: consolidate
description: Cherry-pick additions from source documents into the current draft. Adversarial process — fixer proposes, critic evaluates, max 2 rounds.
argument-hint: "[source documents to compare against current draft]"
allowed-tools: ["Read", "Grep", "Glob", "Edit", "Write", "Task"]
---

# /consolidate — Cherry-Pick Additions from Source Documents

## Purpose
Compare the current draft against earlier drafts, co-author notes, and manuscript sections. Cherry-pick content that merits inclusion but isn't there yet. Adversarial process: fixer proposes, critic evaluates, fixer rebuts, critic decides.

## Trigger
Run when the user asks to consolidate, merge, or compare drafts.

## Inputs
- **Current draft**: The latest draft QMD file (user-specified)
- **Comparison documents** (user provides, typically):
  - Earlier manuscript `.tex` sections
  - Co-author notes/drafts
  - Co-author `.bib` files for citation discovery
  - Previous QMD drafts

## Process

### Step 1: Consolidator-Fixer (opus)
Spawn `consolidator-fixer` agent with:
- The full text of the current draft
- The full text of each comparison document
- Instruction: identify content NOT in the current draft that would improve it

Output: `quality_reports/consolidation/[date]_fixer_proposals.md`

### Step 2: Consolidator-Critic — Round 1 (sonnet)
Spawn `consolidator-critic` agent with:
- The current draft
- The fixer's proposals

Output: Verdicts (APPROVED/REJECTED/MODIFIED)

### Step 3: Consolidator-Fixer — Rebuttal (opus)
Fixer argues for rejected proposals.

### Step 4: Consolidator-Critic — Round 2 (sonnet)
Critic reconsiders rejections. Changes verdict only if rebuttal identifies something missed.

### Step 5: Apply Approved Changes
- Apply all APPROVED and MODIFIED additions to a new draft version
- Add any new bib entries
- Document the full adversarial exchange

### Step 6: Verify
- Run `bib-checker` on updated draft
- Verify render

## Rules
- Additions are ADDITIVE — don't delete or replace existing content
- Both fixer and critic document their arguments — the user is the arbiter
- Max 2 rounds of adversarial exchange
- New bib entries follow `authorYYYYdescriptor` format

## Model Assignment
- consolidator-fixer: **opus** (deep economic reasoning)
- consolidator-critic: **sonnet** (lighter gatekeeper; asymmetric by design)
- bib-checker: haiku
