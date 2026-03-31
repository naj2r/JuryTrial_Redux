---
paths:
  - "**/*.qmd"
  - "**/_quarto.yml"
---

# Quarto Book Workflow

## Project Location

The Quarto book lives at `$RB/`.
The root `_quarto.yml` is obsolete — ignore it.

## Render Commands

```bash
# DEFAULT — HTML only (fast, for iteration)
cd "$RB" && quarto render --to html

# PDF — only for finalized drafts (slow, requires lualatex)
# First uncomment the pdf: block in _quarto.yml, then:
cd "$RB" && quarto render --to pdf

# Single chapter preview (fastest)
cd "$RB" && quarto preview replication_book/85_literature_sources.qmd
```

**Always render HTML by default.** PDF is only for finalized drafts and requires uncommenting the `pdf:` block in `_quarto.yml`.

## Dropbox Sync Delay

Dropbox syncs slower than Claude can write files. If you render immediately after editing a .qmd, Dropbox may still be syncing the change, causing stale reads or lock contention.

**Proactive wait protocol:**
1. After writing/editing .qmd files, wait before rendering:
   - `sleep 5` minimum after a single file edit
   - `sleep 10` after editing 3+ files or `_quarto.yml`
   - Scale by last known full-render time (currently ~30s for 20 chapters; use 1/3 as sync buffer = 10s)
2. This is cheap insurance — a 10-second wait beats a 5-minute debug cycle chasing phantom errors

## Firefox Cache Lock Workaround

Quarto HTML output can get locked by browser file handles. Known symptoms:
- "File is open/locked" errors during render
- Render appears to succeed but chapters are stale
- Infinite loops where render claims success but output doesn't change

**Prevention protocol:**
1. Open Quarto HTML output in **Firefox only** (not Chrome)
2. **Close Firefox before any fresh render** — `taskkill /IM firefox.exe /F 2>/dev/null` or close manually
3. If render still reports locks, delete `_book/` and `_freeze/` directories and re-render
4. As a last resort: `cd "$RB" && rm -rf _book _freeze .quarto && quarto render --to html`

## Render Failure Triage (default first response)

**When a render fails or produces unexpected warnings, the FIRST action is always cache/freeze reset — not debugging the .qmd content.**

Most "phantom" render errors on this project are stale state, not content bugs. Triage order:

```
Step 1: Close Firefox              → taskkill /IM firefox.exe /F 2>/dev/null
Step 2: Wait for Dropbox sync      → sleep 10
Step 3: Clear stale state           → cd "$RB" && rm -rf _freeze .quarto
Step 4: Re-render                   → quarto render --to html
Step 5: STILL failing?              → nuclear reset: rm -rf _book _freeze .quarto && quarto render --to html
Step 6: STILL failing after reset?  → NOW investigate .qmd content (this is a real bug)
```

**Do not skip to Step 6.** Steps 1-5 resolve the majority of render issues on Windows+Dropbox. Only after a clean-state render still fails should you start reading error messages as content bugs.

## Auto-Audit: When to Verify Render

**After ANY non-trivial .qmd change, verify the book still renders.** Specifically:

### MUST render-check after:
- Adding/removing chapters from `_quarto.yml`
- Adding cross-references (`@sec-`, `@tbl-`, `@fig-`)
- Adding code chunks with `eval: true`
- Changing YAML frontmatter in any chapter
- Structural changes (headers, callouts, parts)

### Can skip render-check for:
- Small text edits (typo fixes, rewording)
- Adding `eval: false` documentation chunks
- Editing comments or TODO markers

### Verification steps:
1. Close Firefox if open: `taskkill /IM firefox.exe /F 2>/dev/null`
2. Run `quarto render --to html` from `$RB/`
3. Check output for:
   - All chapters listed (currently 20)
   - `Output created: _book\index.html` at the end
4. **For each warning**: check `$RB/quarto_known_warnings.md` first
   - **Known BENIGN** → report but do NOT re-investigate (saves computation)
   - **Known ACTIONABLE** → must fix before proceeding
   - **Known CONDITIONAL** → check the stated condition
   - **NEW warning (not in ledger)** → investigate fully, then classify:
     - Cross-ref warnings → find the missing `{#sec-xxx}` anchor or fix the `@sec-xxx` reference
     - File lock warnings → verify output timestamps are current, clear cache if stale
     - Temp file warnings → check if Dropbox sync is contending; re-render after sync settles
     - Chunk errors (masked by `error: true`) → grep render output for `Error in` to find them
   - Add classification to `quarto_known_warnings.md` via `quarto-warnings` skill
5. If actionable or new warnings found, pass to quarto-fixer or fix directly before continuing other work

## Current Status

Last verified: 2026-02-25
Result: 20/20 chapters rendered successfully, 0 warnings
Notes: Previously had 1 unresolved crossref (`@sec-verification-checks` in ch. 94) — fixed by adding anchor to ch. 90

## Config Notes

- `freeze: auto` — chapters only re-execute when source changes
- `cache: true` — chunk-level caching for R/Python computations
- `error: true` — render completes even if a chunk errors (important for documentation chapters with illustrative code)
