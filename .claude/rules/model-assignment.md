# Model Assignment Policy

When spawning subagents via the Agent/Task tool, use the appropriate model to balance cost and capability.

## Decision Matrix

| Task Type | Model | Why |
|-----------|-------|-----|
| Economic interpretation, identification critique, literature assessment | `opus` | Needs deep domain reasoning |
| Referee-style review, contribution assessment | `opus` | Nuanced judgment required |
| Research ideation, hypothesis generation | `opus` | Creative + domain knowledge |
| Paper section drafting | `opus` | Requires argumentative restructuring |
| Grammar, typos, formatting checks | `sonnet` | Pattern-matching, speed matters |
| Table verification (numbers match CSV) | `sonnet` | Mechanical comparison |
| LaTeX syntax checking, brace matching | `sonnet` | Constrained pattern work |
| Citation key cross-referencing | `haiku` | Pure lookup task |
| File scanning, glob/grep operations | `haiku` | Trivial search |
| Raw action recording (stenographer) | `haiku` | Mechanical logging |

## Agent Model Assignments

### Clo-Author Worker-Critic Pairs

| Agent | Model | Rationale |
|-------|-------|-----------|
| strategist | `inherit` | Needs deep economic reasoning for identification design |
| strategist-critic | `inherit` | Must match strategist's depth to evaluate properly |
| coder | `inherit` | Code writing + domain alignment |
| coder-critic | `inherit` | Code review + strategy alignment check |
| writer | `inherit` | Paper drafting requires argumentative skill |
| writer-critic | `sonnet` | Constrained pattern-matching (grammar, formatting, consistency) |
| librarian | `inherit` | Literature synthesis needs depth |
| librarian-critic | `sonnet` | Coverage checking is more mechanical |
| explorer | `inherit` | Data discovery needs creativity |
| explorer-critic | `sonnet` | Data quality scoring is checklist-based |
| data-engineer | `inherit` | Pipeline construction |
| storyteller | `inherit` | Talk narrative design |
| storyteller-critic | `sonnet` | Talk review is checklist-based |

### Peer Review

| Agent | Model | Rationale |
|-------|-------|-----------|
| domain-referee | `opus` | Economic interpretation cannot be cheapened |
| methods-referee | `opus` | Identification validity requires deep reasoning |

### Infrastructure Agents

| Agent | Model | Rationale |
|-------|-------|-----------|
| orchestrator | `inherit` | Phase transitions, dispatch logic |
| verifier | `sonnet` | Mechanical compilation/output checks |
| stenographer | `haiku` | Pure action recording — cheapest possible |

### cheap-scan1 Pipeline Agents

| Agent | Model | Rationale |
|-------|-------|-----------|
| pdf-scanner | `haiku` | Pure pattern matching against regex dictionary |
| pdf-text-summarizer | `haiku` | Structured extraction from pre-split text |
| pdf-visual-analyzer | `sonnet` | Requires vision for rendered table/figure PNGs |
| pdf-equation-transcriber | `sonnet` | Requires vision + LaTeX output |
| pdf-consolidator | `sonnet` | Merges specialist outputs with judgment |

## Orchestrator Agent Selection

When selecting review agents based on modified files:

| Files Modified | Agents to Run |
|---------------|---------------|
| `Paper/*.tex` sections | writer-critic → then strategist-critic if empirical content |
| `Paper/*.tex` (tables/figures section) | writer-critic (lightweight) |
| `scripts/R/*.R` | coder-critic |
| `ProjectBook/*.qmd` | writer-critic (advisory, non-blocking) |
| `Bibliography_base.bib` | writer-critic (citation check only) |
| Multiple formats | verifier for cross-format parity |

## Rule of Thumb

> If the task requires understanding *why* something is correct (economic logic, identification, interpretation) → **opus**.
> If the task requires checking *whether* something is correct (matching numbers, valid syntax, resolved references) → **sonnet**.
> If the task is pure lookup or simple formatting → **haiku**.

## Cost Optimization

> Run sonnet-level reviewers **in parallel** (cheap). Run opus-level agents **sequentially** (expensive).
> Typical review: writer-critic + coder-critic on sonnet in parallel, then domain-referee on opus sequentially. Saves ~40-60% compared to running everything on opus.

**Parallel task cap:** Never dispatch more than 3 Task/Agent calls in a single message. If more than 3 independent tasks are needed, batch them in groups of 3. See `information-overload-failsafe.md`.
