---
name: codevolution
description: Autonomous infrastructure sync — fires after any agent, skill, or rule is created or updated. Evaluates generalizability and propagates to the econ-paper-template repo. Background action like stenographer.
allowed-tools: Read, Write, Edit, Glob, Grep, Task, Bash
---

# CODEvolution — Autonomous Infrastructure Sync

## When This Fires

**Automatically** after any `.claude/` infrastructure file is created or updated — agents, skills, or rules. The orchestrator (you, the main Claude session) should run this as a background action, similar to stenographer.

**Trigger conditions:**
- A new file is created in `.claude/agents/`, `.claude/skills/`, or `.claude/rules/`
- An existing file in those directories is substantively modified (not just a typo fix)

**Exception:** The user says "skip codevolution," "don't propagate," or "local only" for a specific change.

**No recursion:** CODEvolution NEVER triggers on its own propagation. Writing files to the template repo does NOT trigger another CODEvolution evaluation. The cycle is: infrastructure change in project → CODEvolution evaluates → propagate/skip/ask → done.

**Not triggered by stenographer, and stenographer is not triggered by CODEvolution.** These are independent background actions.

## Protocol

1. **Identify the changed file.** What was just created or modified in `.claude/`?

2. **Evaluate generalizability** using the decision rule in `.claude/agents/codevolution.md`:
   - **≥95% confident it generalizes → PROPAGATE automatically.** Do not ask.
   - **<95% confident → ASK the user** in chat before proceeding.
   - **Clearly project-specific → SKIP.** Report the skip but take no action.

3. **If PROPAGATE or user approves:**

   a. **Spawn the CODEvolution agent** (sonnet):
   ```
   Task(subagent_type="general-purpose", model="sonnet", prompt="""
   You are the CODEvolution agent. Universalize and propagate this infrastructure file.

   SOURCE FILE: [path to the changed file in current project]
   SOURCE CONTENT: [full content of the file]
   FILE TYPE: [agent / skill / rule]
   DESTINATION REPO: [path to econ-paper-template — defined in CLAUDE.md]

   Instructions:
   1. Read the source content
   2. Apply the universalization protocol from .claude/agents/codevolution.md
   3. Write the universalized version to the template repo at the matching path
   4. Read the template README.md and update agent/skill/rule counts if needed
   5. Report what you did

   Universalization rules:
   - Replace specific file paths with generic references or variables
   - Replace study parameters with [defined in study-parameters.md]
   - Replace journal names with [target journal — defined in study-parameters.md]
   - Replace co-author names with generic "co-author"
   - Keep $OL / $RB as variables (users define in their CLAUDE.md)
   - Remove study-specific context (place names, policy details)
   - Keep scoring rubrics, process flows, model assignments, format templates intact
   """)
   ```

   b. **Report the result** to the user (brief — like stenographer):
   ```markdown
   ### CODEvolution: [filename]
   **Verdict:** PROPAGATE / SKIP / ASK USER
   **Reasoning:** [1-2 sentences]
   **Changes made:**
   - [action] `template/path` — [what was written/updated]
   - Updated README.md: [old count] → [new count]
   ```

4. **If SKIP:** Report the skip in 1 line. No further action.

5. **Resume the next task.**

## Decision Threshold

The user's preference: **default yes unless uncertain.**

- ≥95% confidence → propagate silently (report after the fact)
- <95% confidence → ask in chat: "CODEvolution: I created [file]. Should I propagate this to the template? [reason for uncertainty]."
- Clearly project-specific → skip silently (report after the fact)

The user finds it easier to say "actually no, skip that" than to manually request every propagation.

## What Gets Universalized

| Project-Specific | Template Version |
|-----------------|-----------------|
| Specific file paths (e.g., `86b_litreview_draft2.qmd`) | Generic reference (`replication_book/` or variable) |
| Study parameters (treatment names, sample sizes, cluster counts) | `[defined in study-parameters.md]` |
| Journal name | `[target journal — defined in study-parameters.md]` |
| Specific `.bib` filename | `[your .bib file]` |
| Co-author names | Generic "co-author" |
| `$OL` / `$RB` as literal paths | Keep as variables (users define in their CLAUDE.md) |
| Study-specific context (place names, policy details) | Remove or replace with `[your study context]` |

**Keep intact:** Scoring rubrics, adversarial patterns, process flows, model assignments, format templates.

## Integration with Other Background Actions

| Background Action | Trigger | Model | Purpose |
|------------------|---------|-------|---------|
| **Stenographer** | After every TODO completion | haiku | Raw action log |
| **CODEvolution** | After `.claude/` file change | sonnet | Infrastructure sync to template |

These run independently. Neither triggers the other. Neither triggers itself.

## What CODEvolution Does NOT Do

- Modify the current project's files (reads from here, writes to template only)
- Commit or push to the template repo (the orchestrator handles git)
- Trigger on its own output (no recursion)
- Propagate without universalizing first
- Make analytical decisions about the paper
- Override the user if they say "skip" or "local only"
