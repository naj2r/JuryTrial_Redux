---
name: own-writing-check
description: Audit manuscript .tex changes — flag any edit the user didn't explicitly request. Run after any session that touched Overleaf files.
disable-model-invocation: true
argument-hint: "[optional: specific file to audit, or 'all' for full scan]"
allowed-tools: ["Read", "Grep", "Glob", "Task"]
---

# Own-Writing Check

Enforces the manuscript-protection rule: **the user writes the paper, Claude does not.**

**Input:** `$ARGUMENTS` — file to audit, or blank for all protected files.

## When to Run

- After any session that modified files in `$OL/Sections/*.tex`
- After `/condense-to-overleaf` (which should output to drafts, not directly to .tex)
- Proactively when Claude is about to edit a protected file (pre-flight check)

## Procedure

### Step 1: Identify Modified Protected Files

Scan `$OL/Sections/*.tex` and `$OL/presentation.tex`. If `$ARGUMENTS` specifies a file, audit only that file.

### Step 2: Launch Manuscript Critic Agent

Spawn the `manuscript-critic` agent (sonnet) with:
- The list of modified protected files
- The full conversation context (the agent has access to it)

The agent classifies each change as PERMITTED or VIOLATION per the manuscript-protection rule.

### Step 3: Report

Present the audit report to the user. If violations are found:
1. List each violation with the specific unauthorized change
2. Suggest where the content should have gone instead (drafts folder, session log, chat)
3. Ask the user whether to revert the violations or keep them

### Step 4: If Pre-Flight (Before Editing)

If this skill is invoked BEFORE an edit (as a gate), the check is simpler:
1. Is the target file protected?
2. Did the user explicitly request this specific edit?
3. Is the edit mechanical (key fix, syntax) or substantive (prose)?

If substantive and not explicitly requested → BLOCK the edit and suggest alternatives.

## Integration

This skill uses the `manuscript-critic` agent (READ-ONLY, sonnet model).
The rule is defined in `.claude/rules/manuscript-protection.md`.
