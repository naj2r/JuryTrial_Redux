---
name: context-status
description: Check current session health — context usage, active plans, session log state
disable-model-invocation: true
argument-hint: ""
allowed-tools: ["Read", "Glob", "Bash"]
---

# Context Status

Report current session health and preservation state.

## Checks

1. **Active plan**: Is there a plan file in `.claude/plans/`? Read and summarize.
2. **Session log**: Does a session log exist for today in `quality_reports/session_logs/`?
3. **MEMORY.md**: Read and report what's stored.
4. **Backmatter currency**: Are the backmatter chapters (91-95) up to date with this session's work?
5. **Todo state**: What's pending vs completed?

## Output

Report format:
```
Session Health Report
=====================
Plan:       [active/none] — [summary if active]
Session Log: [current/stale/missing]
Memory:     [N items stored]
Backmatter: [current/needs update]
Todos:      [N pending, M completed]

Recommendation: [action if anything needs attention]
```

## When to Use
- Before starting a complex task (verify context is clean)
- After long idle periods (verify nothing was lost to compaction)
- Before session end (verify everything is preserved)
