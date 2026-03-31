---
name: stenographer
description: Autonomous raw-action logger — fires after every completed TODO item. Records exactly what was done and which files were touched. Not user-invoked; triggered by the orchestrator protocol. Can also be called manually with /stenographer.
allowed-tools: Read, Write, Edit, Glob, Task
---

# /stenographer — Autonomous Action Recorder

## When This Fires

**Automatically** after every TODO item is marked `completed`. The orchestrator (you, the main Claude session) must run this before starting the next task. This is not optional — it is part of the task completion protocol.

**Exception:** The user says "skip the changelog," "skip documentation," or "no logging" for a specific task or set of tasks.

**No recursion:** The stenographer NEVER triggers on its own completion. When a "Stenographer: ..." TODO is marked completed, do NOT add another stenographer TODO. The cycle is: real task → stenographer → next real task. Never: stenographer → stenographer.

## Protocol

1. **Identify the session log.** Check `quality_reports/session_logs/` for today's log. If none exists, create one: `quality_reports/session_logs/YYYY-MM-DD_description.md`

2. **Spawn the stenographer agent** (haiku — fast and cheap):
   ```
   Task(subagent_type="general-purpose", model="haiku", prompt="""
   You are the stenographer agent. Record the raw actions for the task just completed.

   COMPLETED TASK: [description from the TODO item]
   FILES MODIFIED: [list of files and what changed in each]
   COMMANDS RUN: [any commands and their output status]
   SESSION LOG PATH: [path to today's session log]

   Append under the ## Stenographer Record section. Follow the format in .claude/agents/stenographer.md.
   3-5 lines. Facts only. No interpretation.
   """)
   ```

3. **Resume the next task** only after the stenographer returns.

## Why Haiku?

The stenographer is purely mechanical: list what files changed, what commands ran. Haiku keeps cost at ~$0.001 per entry so you can run it 30+ times per session without budget concern.

## Division of Labor

| Layer | Who Writes It | What It Contains |
|-------|--------------|-----------------|
| **Stenographer record** | This skill (haiku agent) | Raw chronological action log — files, edits, commands, pass/fail |
| **Session log narrative** | Orchestrator (main session) | Analytical reasoning — why decisions were made, what problems surfaced |
| **Backmatter chapters** | Orchestrator (main session) | Reviewer-facing audit trail — decisions, problems, verification evidence |

The stenographer produces the raw material. The orchestrator decides what's analytically significant enough for the session log narrative and backmatter.

## Integration with incremental-documentation Rule

This skill implements `.claude/rules/incremental-documentation.md`. The rule says "add a documentation TODO after every task." This skill says "here's how — spawn a haiku agent to record the facts."

The documentation TODO in the task list should look like:
```
Content: "Stenographer: [what was just done]"
ActiveForm: "Recording [short description]"
Status: in_progress
```

Mark it `completed` after the stenographer returns.

## Manual Invocation

Users can also run `/stenographer` manually to force a log entry at any point — useful for:
- Catching up after forgetting to log
- Recording a decision that didn't come from a TODO
- Forcing a checkpoint before ending a session
