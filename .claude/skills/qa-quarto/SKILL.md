---
name: qa-quarto
description: Quality-assure Quarto book output — check rendering, tables, cross-refs, and content
disable-model-invocation: true
argument-hint: "[chapter number or 'full' for entire book]"
allowed-tools: ["Read", "Grep", "Glob", "Bash", "Task"]
---

# QA Quarto

Run adversarial quality assurance on the Quarto replication book.

**Input:** `$ARGUMENTS` — chapter number (e.g., "85") or "full" for entire book.

## Checks

### 1. Render Test
```bash
cd "$RB" && quarto render
```
- Does it compile without errors?
- Any warnings about missing cross-references?
- Any R chunks that fail to evaluate?

### 2. Content Parity (for chapters with Stata equivalents)
- Does the Quarto chapter produce the same numbers as the Stata output?
- Are table values consistent with `{{regression_results}}.csv`?
- Do summary statistics match between Quarto and do-file logs?

### 3. Cross-Reference Integrity
- All `@sec-`, `@tbl-`, `@fig-` references resolve
- No broken links to other chapters
- Table/figure numbering is sequential

### 4. Code Chunk Quality
- Every chunk has a unique label
- `eval:` is set correctly (true for live code, false for documentation)
- No chunks that silently produce wrong output
- Package loading is in setup chunk, not scattered

### 5. Backmatter Currency (chapters 91-95)
- Change log has entries for recent changes
- Decisions chapter covers all non-obvious choices
- Verification evidence is current
- Session history includes recent sessions

### 6. Reviewer Readability
- Could a reviewer unfamiliar with the project follow the logic?
- Are code chunks commented enough to understand without deep context?
- Are output tables clearly labeled and captioned?
- Is the narrative connecting code→output→interpretation clear?

## Critic/Fixer Loop (max 3 rounds)

1. **Critic pass**: Identify all issues by category
2. **Fix**: Address errors and warnings
3. **Re-check**: Verify fixes resolved issues
4. Repeat if needed (max 3 rounds)

## Output

Report with:
- PASS/FAIL for each check category
- Issues by severity (Error > Warning > Style > Note)
- Specific line numbers and file paths
- Suggested fixes for each issue
