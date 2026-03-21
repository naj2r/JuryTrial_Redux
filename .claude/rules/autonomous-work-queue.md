# Autonomous Work Queue

**When the user says "keep going" / "run until done" / "work until midnight" — Claude works through the priority queue autonomously.**

## Activation

Triggered when the user grants open-ended execution time:
- "Keep going until I say stop"
- "Run parallel tasks until midnight"
- "Handle P1-P7"
- "Just do it" (see also workflow.md Section 2)

## The Queue

Maintain an internal priority queue of pending tasks. After each task completes:

1. **Log** — append to session log what was done
2. **Score** — run the appropriate critic if the task produced an artifact
3. **Check** — is the score >= 80? If not, fix before proceeding
4. **Pick next** — select the highest-priority unblocked task
5. **Announce** — tell the user what you're starting (1 line)
6. **Execute** — implement, verify, log

## Priority Rules

| Priority | Task Type |
|----------|-----------|
| CRITICAL | Tasks the user flagged as high priority (P1, P2) |
| HIGH | Tasks with high upside or blocking downstream work (P3, P7) |
| MEDIUM | Robustness and positioning tasks (P4, P5, P6) |
| LOW | Documentation updates, cleanup |

Within a priority tier, prefer tasks that:
- Unblock other tasks (dependency resolution)
- Touch fewer files (lower risk)
- Have clearer requirements (less ambiguity)

## Constraints

- **Max 3 parallel agent dispatches** per message (see information-overload-failsafe.md)
- **Plan before implementing** non-trivial changes (see workflow.md)
- **Archive before overwriting** any artifact (see instruction doc: non-destructive rules)
- **Route code changes through econometrics check** (see instruction doc: hard constraint)
- **Save state before context overflow** — write TODO list, session log, MEMORY.md updates to disk

## Stall Recovery

If stuck on a task for > 2 rounds:
1. Log what you've tried
2. Move to next unblocked task
3. Come back to stuck task after completing others
4. If still stuck after 3 attempts, escalate to user with specific blocker description

## Session Boundary

Before wrapping up (context limit approaching or user says stop):
1. Write session log with completed/remaining tasks
2. Update MEMORY.md with any [LEARN] entries
3. Update SESSION_REPORT.md
4. Announce: "Completed X of Y tasks. Remaining: [list]. Next session should start with [specific task]."
