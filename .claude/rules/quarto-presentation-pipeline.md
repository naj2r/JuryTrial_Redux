# Quarto Multi-Format Presentation Pipeline

Applies when building presentations with Quarto (single QMD → RevealJS HTML + Beamer PDF).

## When to Use This vs. Pure Beamer

| Approach | Use When | Source | Outputs |
|----------|----------|--------|---------|
| **Pure Beamer** (Option A) | You only need PDF slides and want full LaTeX control | `$OL/presentation.tex` | PDF only |
| **Quarto multi-format** (Option B) | You want HTML slides for web + PDF for print from one source | `Quarto/conference/*.qmd` | RevealJS HTML + Beamer PDF |

Option B is recommended for conference presentations where you want both a web-accessible version and a PDF handout.

## Architecture

```
Quarto/conference/
├── presentation.qmd          # Single-deck (or presentation-conference.qmd + presentation-jobtalk.qmd for two-deck)
├── _quarto.yml                # Shared settings ONLY (bibliography, CSL, mermaid, execute)
├── references.bib             # Bibliography
├── styles/
│   ├── beamer-preamble.tex    # Beamer theme (TikZ boxes, colors, footline)
│   └── revealjs-theme.scss    # RevealJS theme (CSS boxes, colors)
├── filters/
│   └── custom-boxes.lua       # Lua filter: div classes → LaTeX environments
├── figures/                   # PDF (Beamer) + PNG (RevealJS) versions of all figures
├── analysis/                  # R/Python scripts that generate figures
└── .gitignore                 # Ignore rendered outputs
```

## Critical: Quarto Config Inheritance

**In `type: default` projects, QMD `format:` blocks REPLACE (not merge with) `_quarto.yml` format config.**

This means:
- **`_quarto.yml`** should contain ONLY shared settings: `bibliography`, `csl`, `mermaid`, `execute`, `knitr`
- **Each QMD front matter** must contain ALL format-specific settings (revealjs theme, beamer preamble, etc.)
- **Filters** must be declared in QMD front matter, not `_quarto.yml`

```yaml
# WRONG: _quarto.yml format block gets silently overridden by QMD
# _quarto.yml
format:
  beamer:
    include-in-header: styles/beamer-preamble.tex  # SILENTLY DROPPED if QMD has format: beamer:

# RIGHT: All format settings in QMD front matter
# presentation.qmd
format:
  revealjs:
    theme: [default, styles/revealjs-theme.scss]
    # ... all RevealJS settings
  beamer:
    include-in-header: styles/beamer-preamble.tex
    # ... all Beamer settings
```

## Mermaid Diagram Constraints

| Constraint | Limit | Why |
|-----------|-------|-----|
| `fig-width` | ≤ 8 inches | Beamer textwidth ~8.85in at 16:9; leave margin |
| `graph TD` | AVOID | Top-down chains produce enormous height (37+ inches for 10+ nodes) |
| `graph LR` | PREFER | Horizontal layouts produce wider, shorter images that fit slides |
| `fig-height` | Set explicitly for TD graphs | Constrain height when TD is unavoidable |

```
# WRONG: Will overflow Beamer frame
%%| fig-width: 11
graph TD
    A --> B --> C --> D --> E --> F --> G

# RIGHT: Horizontal layout fits 16:9
%%| fig-width: 8
graph LR
    A --> B --> C --> D
```

## Format-Conditional Content

Browsers cannot render PDF images inline. Use format-conditional blocks:

```markdown
::: {.content-visible when-format="revealjs"}
![Caption](figures/my_figure.png){fig-align="center" width="85%"}
:::
::: {.content-visible when-format="beamer"}
![Caption](figures/my_figure.pdf){fig-align="center" width="85%"}
:::
```

**Workflow:** Generate figures as PDF (for Beamer quality), then convert to PNG for RevealJS:
```python
# Python (pymupdf)
import fitz
doc = fitz.open("figure.pdf")
pix = doc[0].get_pixmap(matrix=fitz.Matrix(300/72, 300/72))
pix.save("figure.png")
```

## Custom Box Environments

The Lua filter (`filters/custom-boxes.lua`) converts Quarto div classes to LaTeX environments:

| Div Class | LaTeX Environment | Purpose |
|-----------|------------------|---------|
| `.keybox` | `\begin{keybox}` | Key findings, takeaways |
| `.resultbox` | `\begin{resultbox}` | Empirical results |
| `.methodbox` | `\begin{methodbox}` | Methodology |
| `.highlightbox` | `\begin{highlightbox}` | Callouts |
| `.assumptionbox` | `\begin{assumptionbox}` | Assumptions, predictions |
| `.eqbox` | `\begin{eqbox}` | Equation display |
| `.softbox` | `\begin{softbox}` | Soft callouts |
| `.quotebox` | `\begin{quotebox}` | Block quotes |

Usage in QMD:
```markdown
::: {.resultbox}
**Key finding:** Treatment effect = +195 (*p*=0.020)
:::
```

## Dynamic Beamer Footline

Use `\insertshortauthor` and `\insertshortinstitute` in the preamble instead of hardcoded text. This lets one preamble serve multiple decks with different authors:

```latex
\setbeamertemplate{footline}{%
  \usebeamerfont{footline}%
  \usebeamercolor[fg]{footline}%
  \hspace{8pt}%
  \insertshortauthor~|~\insertshortinstitute~|~\insertframenumber/\inserttotalframenumber%
  \hspace{8pt}\vskip6pt%
}
```

## Two-Deck Architecture

For projects needing both a short conference talk and a longer job talk:

```
presentation-conference.qmd   # 10-15 min, ~25 slides
presentation-jobtalk.qmd      # 30 min, ~40 slides + expanded backup
```

Both share the same `styles/`, `filters/`, `figures/`, and `references.bib`. Each has its own `format:` block in front matter (can differ in author, footer, etc.).

**Do NOT use `{{< include >}}` partials** — manual sync is simpler than maintaining shared partial files with different conditional logic.

## natbiboptions YAML Syntax

```yaml
# WRONG: Array concatenates as "roundauthoryear"
natbiboptions: [round, authoryear]

# RIGHT: Comma-separated string
natbiboptions: "round,authoryear"
```

## Rendering Commands

```bash
# Single deck
quarto render presentation.qmd --to revealjs
quarto render presentation.qmd --to beamer

# Two-deck architecture
quarto render presentation-conference.qmd --to revealjs
quarto render presentation-conference.qmd --to beamer
quarto render presentation-jobtalk.qmd --to revealjs
quarto render presentation-jobtalk.qmd --to beamer
```

## .gitignore for Presentations

```gitignore
# Rendered outputs (rebuild from QMD)
presentation-*.html
presentation-*.pdf
presentation-*.pptx
presentation-*.tex
presentation*_files/
_output/

# BUT track source figures
!figures/**
```

Also add to root `.gitignore` if it blanket-ignores `*.pdf`/`*.png`:
```gitignore
# Exception: presentation figures
!Quarto/conference/figures/**
!Quarto/conference/styles/**
```
