---
name: learn
description: Extract reusable knowledge from this session and save to persistent memory or new skills
disable-model-invocation: true
argument-hint: "[optional: specific topic to extract learnings about]"
allowed-tools: ["Read", "Grep", "Glob", "Write", "Edit"]
---

# Learn

Extract reusable knowledge from the current session and persist it for future sessions.

**Input:** `$ARGUMENTS` — optional topic focus. If blank, review the full session.

## What to Extract

### Corrections ([LEARN] tags)
Look for any `[LEARN:category]` tags in the conversation where the user corrected Claude. Save as:
```
[LEARN:category] wrong assumption → correct behavior
```

### Patterns
- Coding patterns that worked well or failed
- Data quirks that will recur (e.g., {{data source}} missing value format)
- Stata/R translation gotchas encountered
- File path conventions that are easy to get wrong

### Preferences
- User workflow preferences discovered during the session
- Communication style preferences
- Tool usage patterns

## Where to Save

| Type | Location |
|------|----------|
| General learnings | `MEMORY.md` (update, don't duplicate) |
| Stata-specific | `.claude/rules/stata-r-conventions.md` |
| Data-specific | Relevant backmatter chapter (93 for problems) |
| New skill pattern | Create new skill in `.claude/skills/` |

## Process

1. **Review the session** for corrections, discoveries, and patterns
2. **Check existing memory** — don't duplicate what's already stored
3. **Categorize** each learning (correction, pattern, preference, skill)
4. **Write to appropriate location**
5. **Report** what was saved and where

## Quality Gates
- Don't save speculative conclusions from a single interaction
- Don't save session-specific context (current task, temp state)
- Do save stable patterns confirmed across multiple observations
- Do save explicit user requests ("always do X", "never do Y")
