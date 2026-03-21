---
name: render-pdf
description: Render Quarto book to PDF — handles config toggle, LaTeX compilation, log audit, and quality checks
disable-model-invocation: true
argument-hint: "[optional: 'full' (default), 'both', chapter number, or 'audit-only']"
allowed-tools: ["Read", "Grep", "Glob", "Edit", "Write", "Bash", "Task"]
---

# Render PDF

Render the Quarto replication book to PDF with full quality assurance. Handles the workflow of enabling PDF format, compiling with lualatex, auditing the output, and optionally restoring HTML-only mode.

**Input:** `$ARGUMENTS` — `full` (PDF only, default), `both` (HTML + PDF in one pass), a chapter number, or `audit-only`.

## Render Modes

### Mode 1: `both` (RECOMMENDED when user wants to view both)

Uncomment the `pdf:` block, then run `quarto render` with NO `--to` flag. Quarto renders **all** formats defined in `_quarto.yml` into `_book/`:
```bash
cd "$RB" && quarto render 2>&1
```
This produces both `_book/index.html` (+ all HTML chapters) and `_book/*.pdf` in a single pass. No output-dir collision.

### Mode 2: `full` (PDF only, default)

When user only needs the PDF. Uses `--to pdf` flag:
```bash
cd "$RB" && quarto render --to pdf 2>&1
```
**Warning:** This wipes HTML from `_book/`. If the user needs HTML too, use `both` mode or re-render HTML afterward.

### Mode 3: Chapter number (single chapter preview)

```bash
cd "$RB" && quarto preview replication_book/[chapter].qmd --to pdf
```
Fastest iteration but won't catch cross-chapter issues.

### Mode 4: `audit-only`

Skip rendering, just audit the existing PDF and log file.

## Full Render Workflow

### Step 1: Enable PDF Format

Uncomment the `pdf:` block in `$RB/_quarto.yml`. The block contains hardcoded best practices:
- `fvextra` for code wrapping
- `longtable` + `booktabs` + `tabularx` for table overflow
- `float` with `\floatplacement{H}` for figure/table anchoring
- `xurl` for URL line-breaking
- `underscore[strings]` for filenames with `_` in tables
- `fontspec` for full Unicode support
- `\widowpenalty`/`\clubpenalty` for orphan/widow prevention
- `\tolerance`/`\emergencystretch` for reduced overfull hbox warnings
- `open=any` class option to prevent blank pages between chapters
- `margin=1in` geometry

### Step 2: Pre-Render Protocol

```bash
# Close Firefox (prevent file locks — may need manual close on this system)
taskkill /IM firefox.exe /F 2>/dev/null

# Wait for Dropbox sync (config change is critical)
sleep 10

# Clear stale state
cd "$RB" && rm -rf _freeze .quarto
```

Note: `taskkill` may not work from the Claude sandbox. If Firefox is open, ask the user to close it.

### Step 3: Render

```bash
# Both formats (recommended):
cd "$RB" && quarto render 2>&1

# PDF only:
cd "$RB" && quarto render --to pdf 2>&1
```

**Expected duration:** 2-5 minutes for 20 chapters with lualatex (3 passes).

If render fails, follow triage protocol from `quarto-workflow.md` (cache reset before content debugging).

### Step 4: Audit

After successful render:

1. **Check for the `.log` file:** `$RB/*.log` or `$RB/_book/*.log` (lualatex log, kept by `keep-tex: true`)
2. **Run pdf-auditor agent** on the log file and PDF output
3. **Check against warning ledger:** `$RB/quarto_known_warnings.md`
4. **Classify new warnings** via `quarto-warnings` skill

### Step 5: Fix (if needed)

If pdf-auditor finds actionable issues:
1. **Run pdf-fixer agent** with the auditor's issue list
2. **Re-render** (both or PDF-only depending on mode)
3. **Re-audit** — max 3 fix→audit rounds
4. After 3 rounds, report remaining issues to user

### Step 6: Restore Config (if user wants HTML-only default)

If the user prefers HTML-only as default, recomment the `pdf:` block:
```yaml
# pdf:
#   documentclass: scrreprt
#   ...
```

If the user wants to keep both formats active, leave it uncommented. The tradeoff: every `quarto render` will take longer (HTML is ~30s, PDF adds 2-5min).

### Step 7: Open Outputs

```bash
# Open PDF
start "$RB/_book/{{book-slug}}.pdf"

# Open HTML in Firefox
start firefox "file:///$RB/_book/index.html"
```

## Common LaTeX Issues and Their Fixes

| Issue | Symptom | Fix (in `_quarto.yml` preamble) |
|-------|---------|--------------------------------|
| Code overflow | `Overfull \hbox` near Highlighting | `fvextra` breaklines (already in preamble) |
| Table overflow | `Overfull \hbox` near tabular | `tbl-colwidths` per chunk, or landscape |
| Underscore in tables | `{{prefix}}_table1` → garbled subscripts | `\usepackage[strings]{underscore}` (already in preamble) |
| Missing Unicode | `Missing character: →` | `fontspec` (already in preamble) |
| Blank pages | Empty pages between chapters | `open=any` class option (already in preamble) |
| Float drift | Figures/tables far from text | `\floatplacement{H}` (already in preamble) |
| SVG images | File not found in PDF | Convert `.svg` → `.pdf` or `.png` |
| Long URLs | Overfull hbox from URLs | `xurl` (already in preamble) |

## Warning Ledger Integration

PDF-specific warnings go into `$RB/quarto_known_warnings.md` with `P` prefix IDs (P001, P002, ...) to distinguish from HTML warnings (W001, W002, ...).

## Output

```
PDF RENDER: [book title]
Mode: [both / pdf-only / chapter / audit-only]
Status: SUCCESS / PARTIAL / FAILED

Compilation: [duration, pages produced]
Log summary: [X errors, Y warnings (Z known-benign)]
Audit: [PASS/FAIL with details]
Fixes applied: [count, if any]
Config state: [pdf: uncommented / recommented]

PDF location: $RB/_book/[filename].pdf
HTML location: $RB/_book/index.html (if 'both' mode)
```
