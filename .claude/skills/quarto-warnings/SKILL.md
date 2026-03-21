---
name: quarto-warnings
description: Classify Quarto render warnings as benign or actionable, maintain a persistent ledger to avoid re-investigating known noise
disable-model-invocation: true
argument-hint: "[render output to classify, or 'review' to show current ledger]"
allowed-tools: ["Read", "Grep", "Glob", "Edit", "Write", "Bash"]
---

# Quarto Warning Classifier

Maintain a persistent record of Quarto render warnings so known-benign warnings are not re-investigated on every render. This saves computation by distinguishing RStudio/Quarto noise from real issues.

**Input:** `$ARGUMENTS` — either paste of render output to classify, or `review` to display the current ledger.

## Tracking File

The warning ledger lives at:
```
$RB/quarto_known_warnings.md
```
(`$RB/quarto_known_warnings.md`)

This file persists across sessions and is the single source of truth for warning classification.

## Workflow

### When called after a render:

1. **Parse render output** — extract every line containing `WARN`, `WARNING`, `ERROR`, `Error in`, or `Unable to resolve`
2. **Fingerprint each warning** — create a pattern from:
   - Warning type (crossref / file-lock / temp-cleanup / chunk-error / other)
   - Source identifier (chapter file or system component)
   - Core message (stripped of line numbers and timestamps, which shift between renders)
3. **Check the ledger** — does a matching fingerprint already exist in `quarto_known_warnings.md`?
   - **YES, classified BENIGN**: Skip. Report as "known benign, not re-investigated"
   - **YES, classified ACTIONABLE**: Flag. Report as "known actionable — needs fix"
   - **YES, classified CONDITIONAL**: Check the stated condition. Report accordingly.
   - **NO match**: This is a **NEW warning**. Investigate per quarto-auditor protocol, then classify and add to ledger.
4. **Update the ledger** with any new entries (date, fingerprint, classification, evidence)

### When called with `review`:

Display the current ledger contents organized by classification status.

## Warning Categories

### BENIGN — safe to skip on future renders
- **Temp file cleanup race**: `Error removing file ... directory is not empty` when the directory is empty and output timestamps are fresh. Caused by Dropbox sync contention on Windows.
- **Package startup messages**: R package loading messages that leak through despite `message: false`
- **Pandoc info messages**: Informational notes from Pandoc that don't affect output
- **Empty freeze directories**: Warnings about freeze dirs that exist but contain no stale state

### ACTIONABLE — must fix before proceeding
- **Unresolved crossref**: `Unable to resolve crossref @sec-xxx` — broken reference
- **Chunk execution error**: `Error in ...` in render output — code failed (may be masked by `error: true`)
- **Missing file**: Chapter listed in `_quarto.yml` but file doesn't exist
- **YAML parse error**: Malformed frontmatter

### CONDITIONAL — benign under specific circumstances, actionable otherwise
- **File lock warnings**: Benign if output timestamps are current (browser had a stale handle). Actionable if output is actually stale.
- **Freeze/cache warnings**: Benign after a fresh `rm -rf _freeze .quarto` + successful re-render. Actionable if they persist after cache clear.

## Ledger Entry Format

Each entry in `quarto_known_warnings.md` follows this format:

```markdown
### [fingerprint-id]

- **Classification:** BENIGN | ACTIONABLE | CONDITIONAL
- **Warning pattern:** `[regex or key phrase that matches this warning]`
- **Source:** [chapter file or system component]
- **First seen:** [date]
- **Last seen:** [date]
- **Investigation:** [what was checked and concluded]
- **Condition** (if CONDITIONAL): [when this flips from benign to actionable]
```

## Integration with quarto-auditor

The quarto-auditor agent should:
1. After every render, collect all warnings
2. Check each against `quarto_known_warnings.md`
3. Only investigate warnings that are NEW or ACTIONABLE
4. Pass new warnings through this skill for classification
5. Report known-benign warnings as a single summary line, not individual investigations

Example auditor output with the ledger:
```
Render: 20/20 chapters, 2 warnings
  - [KNOWN BENIGN] Temp cleanup race (entry #W003, last verified 2026-02-25)
  - [NEW] Unable to resolve crossref @fig-pipeline → INVESTIGATING...
```

## Rules

1. **Never auto-classify a warning as BENIGN without investigation.** Every new warning gets investigated once, then classified.
2. **Re-verify CONDITIONAL entries periodically.** If a CONDITIONAL entry hasn't been re-verified in 30 days, treat it as NEW.
3. **Date-stamp everything.** The "last seen" field updates every time a known warning reappears.
4. **Keep the ledger lean.** Remove entries for warnings that haven't appeared in 90+ days (the underlying issue was likely fixed).
5. **ACTIONABLE entries are never ignored.** If an ACTIONABLE warning keeps appearing, it must be escalated — either fix the root cause or reclassify after deeper investigation.
