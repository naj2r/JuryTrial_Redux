# Information Overload Failsafe

**Prevents context overload freezes from parallel agent dispatching.**

## Parallel Task Cap

**Max 3 Agent/Task dispatches per message.** No exceptions.

If more than 3 independent tasks are needed, batch them in groups of 3. Wait for the first batch to complete before dispatching the next.

Empirical basis: 4+ parallel agents → stall/freeze. 2-3 → works reliably.

## Anti-Stall Protocol

| Trigger | Action |
|---------|--------|
| Stuck >1 message with no output | Force a status update to the user — say what you're doing |
| Near context overflow | Write in-progress work to disk BEFORE continuing |
| >5 queued tasks | Table non-disruptive ones; focus on pipeline-critical work |
| Session ending (compression imminent) | Save all state: TODO list, session log, MEMORY.md, active plan |

**Don't stop until usage runs out or all items completed.** If stalled, the fix is to communicate, not to go silent.

## Chunking Strategy

When an agent receives content that's too large (>3,000 words of prose), split it:

1. Break the content into logical sections (headers, subsections)
2. Dispatch per-section agents (max 3 at a time)
3. Reassemble the outputs

This applies to compression, review, and any agent that processes large text blocks.

## Stuck Recovery

If truly stuck (agent won't return, context is full):
1. Force pause — stop trying the same approach
2. Write what you have to disk
3. Tell the user what happened and what's left
4. Resume after user prompt or context refresh

## Integration

- This rule overrides any implicit "do everything at once" instinct
- The 3-task cap applies to ALL Agent/Task tool dispatches, including background agents
- Model-assignment.md's "Cost Optimization" section reinforces this rule
