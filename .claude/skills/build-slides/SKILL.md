---
name: build-slides
description: Create or update presentation slides — supports both pure Beamer (Overleaf) and Quarto multi-format (RevealJS + Beamer)
disable-model-invocation: true
argument-hint: "[section to add/update, or 'full' for complete rebuild, or 'init-quarto' for Quarto setup]"
allowed-tools: ["Read", "Grep", "Glob", "Write", "Edit", "Bash", "Task"]
---

# Build Slides

Create or update presentation slides. Supports two workflows:

## Workflow Detection

1. If `Quarto/conference/*.qmd` exists → **Quarto multi-format** (Option B)
2. If `$OL/presentation.tex` exists but no QMD → **Pure Beamer** (Option A)
3. If `$ARGUMENTS` = "init-quarto" → **Initialize Quarto presentation from template**

## Option A: Pure Beamer (Overleaf)

**File:** `$OL/presentation.tex` (standalone Beamer document)

### Architecture
- **Tables:** Same `files/tab/` directory as the paper; use `\input{files/tab/...}` with `\scalebox{}`
- **Figures:** Same `files/fig/` directory; use `\includegraphics{}`
- **Style:** Default Beamer theme, custom footer (author/title/page)

### Steps
1. Read current `presentation.tex`
2. Read relevant paper Sections/ for content to adapt
3. Read relevant Quarto chapters for detailed content
4. Update/add slides for requested section
5. Verify all `\input{}` paths exist
6. Run `/compile-latex` to verify

## Option B: Quarto Multi-Format (RevealJS + Beamer)

**Files:** `Quarto/conference/presentation.qmd` (or `presentation-conference.qmd` + `presentation-jobtalk.qmd`)

### Architecture
```
Quarto/conference/
├── presentation*.qmd           # Slide source (one or two decks)
├── _quarto.yml                 # Shared settings ONLY
├── styles/beamer-preamble.tex  # Beamer theme with TikZ boxes
├── styles/revealjs-theme.scss  # RevealJS theme with CSS boxes
├── filters/custom-boxes.lua    # Div → LaTeX environment conversion
├── figures/                    # PDF + PNG versions
└── references.bib              # Bibliography
```

### Key Rules (see `.claude/rules/quarto-presentation-pipeline.md`)
- **All format settings in QMD front matter** (not `_quarto.yml`)
- **Mermaid `fig-width` ≤ 8 inches** (Beamer textwidth ~8.85in at 16:9)
- **Use `graph LR` not `graph TD`** for Mermaid diagrams
- **Format-conditional images:** `.content-visible when-format="revealjs"` for PNG, `when-format="beamer"` for PDF
- **`natbiboptions: "round,authoryear"`** (string, not YAML array)
- **`pdf-engine: lualatex`** for Unicode support

### Steps
1. Read current QMD file(s)
2. Read relevant paper Sections/ for content to adapt
3. Update/add slides for requested section
4. Use box classes: `.keybox`, `.resultbox`, `.methodbox`, `.highlightbox`, `.assumptionbox`, `.eqbox`, `.softbox`
5. Add `::: {.notes}` for speaker notes
6. Add format-conditional blocks for any PDF figures
7. Render: `quarto render presentation.qmd --to revealjs` and `--to beamer`
8. Run `/visual-audit` on the rendered output

## Option: Initialize Quarto Presentation

When `$ARGUMENTS` = "init-quarto":
1. Copy `templates/quarto-presentation/` to `Quarto/conference/`
2. Fill in `{{placeholders}}` from CLAUDE.md (title, author, institution, colors)
3. Create initial `references.bib` from `$OL/bibliography*.bib` if available
4. Test render both formats
5. Update root `.gitignore` with figure exceptions

## Slide Design Rules (Both Workflows)

- Max 5-6 bullet points per slide
- One key message per slide
- Tables via `\scalebox{0.7-0.9}{\input{}}` (Beamer) or embedded markdown (Quarto)
- Keep text large — readable from back of room
- Use `\pause` (Beamer) or `::: incremental` (Quarto) for sequential reveals
- Appendix/backup slides for robustness, mechanism details, data construction
- Max 2 consecutive box environments per slide (avoid "box fatigue")

## Suggested Structure (conference talk ~20 min)

1. **Title** (1 slide)
2. **Motivation** (2-3 slides) — research gap, why this matters
3. **This Paper** (1 slide) — research question, data, preview of findings
4. **Institutional Background** (1-2 slides) — setting, data sources
5. **Data** (1-2 slides) — panel structure, treatment definitions
6. **Empirical Approach** (1 slide) — model equation, identification
7. **Main Results** (2-3 slides) — key tables with interpretation
8. **Robustness** (1 slide) — summary or key robustness table
9. **Conclusions** (1-2 slides)
10. **Appendix** (backup slides as needed)

## Two-Deck Architecture (optional)

For job market / longer talks, create a second QMD:
- `presentation-conference.qmd` — 10-15 min, ~25 slides
- `presentation-jobtalk.qmd` — 30 min, ~40 slides + expanded sections

Additional sections for longer talks:
- Contribution slide with `::: incremental`
- Roadmap slide
- Identification Strategy section (treatment variation, TWFE justification, "Why no event study?")
- Robustness overview with hyperlinked backup slides
- Cost implications
