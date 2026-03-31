---
name: mccloskey-prose-edit
description: Run McCloskey prose quality audit on manuscript section(s). Critic scores, fixer suggests, critic re-grades. Output to QMD.
disable-model-invocation: true
argument-hint: "[section number or 'all'] — e.g., '2' for section 2, 'all' for full paper"
allowed-tools: ["Read", "Grep", "Glob", "Write", "Task", "Edit"]
---

# McCloskey Prose Editor

Run a McCloskey *Economical Writing* compliance audit on manuscript sections. Uses the adversarial critic→fixer→critic pattern: the critic scores, the fixer suggests, the critic re-grades. All output goes to the Quarto book — **never to Overleaf files**.

## Arguments

- `[section number]` — e.g., `2` for section 2
- `all` — audit all sections

## Workflow

### Step 1: Load Inputs
- Read the manuscript section from `$OL/Sections/`
- Read the McCloskey rules summary (`docs/mccloskey_rules_summary.md`; create one if it doesn't exist yet)

### Step 2: Spawn McCloskey Critic (Round 1)
Spawn `mccloskey-critic` agent (sonnet) with section text and rules.
Produces scored audit with violation list.

**Early exit:** If score >= 90, write a brief "passing" note and skip the fixer.

### Step 3: Spawn McCloskey Fixer (Round 1)
Spawn `mccloskey-fixer` agent (sonnet) with critic output + original text.
Generates suggested revisions for every violation.

### Step 4: Re-Spawn Critic (Round 2 — Re-Grade)
Critic evaluates each suggestion AS IF applied. Produces revised score.
For each suggestion: APPROVED or REJECTED.

**If score >= 90:** All approved suggestions are final. Go to Step 6.
**If score < 90:** Proceed to Step 5 (Round 2 fixer).

### Step 5: Fixer Round 2 (if needed)
Fixer refines ONLY the REJECTED suggestions. Cap at 2 rounds.

### Step 6: Write Results to QMD
Write the final bipartite problem/solution commentary to `replication_book/prose_revisions.qmd`.

### Step 7: Log
Append to session log with `[writing]` subclassification.

## Key Constraints
- **Manuscript protection applies.** This skill READS Overleaf files but NEVER writes to them.
- **Cost cap:** Maximum 2 critic→fixer rounds per section. ~4-5 sonnet calls per section.
- **The user applies revisions.** This skill produces suggestions. The user decides what to adopt.
