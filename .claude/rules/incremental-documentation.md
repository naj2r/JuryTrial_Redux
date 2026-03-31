# Incremental Documentation Rule

**After every completed TODO item, add a documentation TODO before starting the next task.**

This produces a research-journal-style log — readable narrative entries that explain *why* things happened, not just what files changed. Think lab notebook, not commit messages.

## The Protocol

When you finish a task (mark a TODO as `completed`), immediately add a new TODO:

```
Content: "Document: [short description of what was just done]"
ActiveForm: "Documenting [short description]"
Status: pending (then mark in_progress and do it before the next real task)
```

Complete the documentation TODO **before** starting the next user-requested task. This is the default behavior — it is implied on every task list unless the user explicitly says "skip the changelog" or "skip documentation" for specific steps.

## What to Document

For each completed task, append to the active session log (`quality_reports/session_logs/`):

| Field | What to Write |
|-------|--------------|
| **What** | 1-2 sentence summary of the change |
| **Why** | The user instruction or rationale that motivated it |
| **Files modified** | List of files touched, with brief description of each change |
| **Decisions made** | Any choices between alternatives, with reasoning |
| **Problems encountered** | Anything unexpected, even if resolved |
| **Verification** | How you confirmed the change worked (rendered, compiled, tests passed, etc.) |

Keep entries concise but complete. More information is safer than less — you can always compress later, but you can't recover what you didn't write down.

## Why This Exists

Context compression is lossy. When Claude hits a context limit and compresses, it loses detail about intermediate steps. If documentation happens only at session end, the intermediate work is gone. By documenting after every task:

1. The session log is always current — even if context compresses mid-session
2. The next session can reconstruct exactly what happened
3. Backmatter chapters stay in sync with actual work
4. The user has a complete audit trail without relying on Claude's memory

## When to Skip

Only skip if the user explicitly says one of:
- "skip the changelog"
- "skip documentation for this"
- "just do it, no logging"
- Or any clear equivalent

A general "just do it" about the task itself does **not** mean skip documentation — it means proceed without asking for approval. Document anyway.

## Integration with Session Logging

This rule extends `session-logging.md` trigger #2 (Incremental Logging) by making it a **blocking TODO item** rather than a best-effort practice. The session log format from `session-logging.md` still applies — this rule just enforces that it happens after every task, not in batches.

## Integration with Backmatter

When the documented change affects any of these, update the corresponding backmatter chapter as part of the documentation TODO:

| Change Type | Update This Chapter |
|------------|-------------------|
| Analytical or data decision | `replication_book/92_decisions_and_assumptions.qmd` |
| Problem encountered and solved | `replication_book/93_problems_and_solutions.qmd` |
| Data, code, spec, or table change | `replication_book/91_change_log.qmd` |
| Verification or confirmation | `replication_book/94_verification_evidence.qmd` |
| Overleaf manuscript files modified | `replication_book/91_change_log.qmd` (Overleaf changelog) |
