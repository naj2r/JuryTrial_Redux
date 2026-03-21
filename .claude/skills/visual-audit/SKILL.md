---
name: visual-audit
description: Audit slides for overflow, layout, font consistency, and visual quality — supports Beamer .tex and Quarto .qmd
disable-model-invocation: true
argument-hint: "[presentation.tex, presentation.qmd, or 'all']"
allowed-tools: ["Read", "Grep", "Glob", "Bash", "Task"]
---

# Visual Audit

Perform an adversarial visual audit of presentation slides.

**Input:** `$ARGUMENTS` — path to presentation file, or "all" to audit all presentation files.

## Format Detection

1. If `.tex` → Beamer-only audit
2. If `.qmd` → Quarto multi-format audit (check BOTH RevealJS and Beamer concerns)
3. If "all" → find all `.tex` and `.qmd` presentation files and audit each

## Audit Checklist

### 1. Content Overflow
- [ ] No text overflowing frame boundaries
- [ ] Table `\scalebox{}` factor appropriate (0.6-0.9 for Beamer)
- [ ] No equation overflow from narrow frame width
- [ ] Bullet point lists ≤ 6 items per slide
- [ ] **Mermaid `fig-width` ≤ 8 inches** (Beamer textwidth ~8.85in at 16:9)
- [ ] **No `graph TD` with 8+ nodes** (produces enormous height; use `graph LR`)
- [ ] **`fig-height` set for any `graph TD` diagrams** (cap at 5 inches)

### 2. Font & Readability
- [ ] Consistent font sizes across similar slide types
- [ ] Math mode uses serif
- [ ] No tiny text that would be illegible in a lecture hall
- [ ] Title slide has correct author, institution, date
- [ ] **Beamer footline matches QMD metadata** (dynamic `\insertshortauthor`)

### 3. Table Presentation
- [ ] Tables scaled appropriately with `\scalebox{}`
- [ ] Column headers visible and readable
- [ ] Significance stars (`\sym`) render correctly
- [ ] Table notes visible at bottom
- [ ] **Tables inside TikZ box nodes** may cause width overflow — check

### 4. Figure Quality
- [ ] PDF/PNG figures included with appropriate dimensions
- [ ] No pixelation from over-scaling
- [ ] Axis labels readable at presentation size
- [ ] Consistent color scheme across figures
- [ ] **PDF images use format-conditional blocks** (PNG for RevealJS, PDF for Beamer)
- [ ] **No bare `.pdf` references in QMD** without `.content-visible when-format="beamer"` wrapper

### 5. Box Environment Quality (Quarto)
- [ ] Max 2 consecutive box environments per slide ("box fatigue")
- [ ] Box colors match intended purpose (key=primary, result=gray, method=med-gray)
- [ ] No deeply nested boxes
- [ ] Boxes don't overflow frame (check `text width` in TikZ nodes)
- [ ] `::: incremental` inside box environments renders correctly in Beamer

### 6. Slide Flow
- [ ] Logical section progression (Motivation → Data → Methods → Results → Conclusions)
- [ ] `\pause` / `::: incremental` appropriate
- [ ] Transition between sections makes sense
- [ ] Appendix/backup slides clearly separated
- [ ] Back-reference links (`[← Back](#target)`) resolve correctly

### 7. Cross-Format Consistency (Quarto only)
- [ ] All figure references work in BOTH RevealJS and Beamer
- [ ] Speaker notes (`::: {.notes}`) render correctly
- [ ] Custom span classes are defined in both CSS and LaTeX
- [ ] Section headers (`# Section`) create section title slides in both formats

### 8. Technical
- [ ] All `\input{}` paths resolve to existing files
- [ ] `\includegraphics{}` paths resolve
- [ ] No undefined `\ref{}` or `\cite{}` commands
- [ ] Compiles without errors
- [ ] **`natbiboptions` uses string syntax** (not YAML array)
- [ ] **`filters:` declared in QMD front matter** (not relying on `_quarto.yml`)

### 9. Number Consistency
- [ ] Coefficients match across slide title, body text, and backup slides
- [ ] p-values consistent with significance stars
- [ ] Sample sizes (N) consistent throughout
- [ ] Percentage calculations correct (coefficient / mean × 100)

## Output

Severity-categorized report:
- **CRITICAL**: Overflow, broken rendering, invisible content (e.g., PDF in RevealJS)
- **MAJOR**: Wrong numbers, missing format-conditional blocks, box fatigue
- **MINOR**: Style suggestions, reordering, additional content

```
[SEVERITY] Slide [N] "[title]": [Issue]
  Details: [what's wrong]
  Fix: [how to fix it]
```
