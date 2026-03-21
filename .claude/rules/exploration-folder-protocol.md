---
paths:
  - "Documentation/**/explorations/**"
---

# Exploration Folder Protocol

**All experimental work goes into `explorations/` first.** Never directly into production folders.

## Location

`$RB/explorations/`

## Folder Structure

```
explorations/
├── ACTIVE_PROJECTS.md           # Index of current explorations
├── [project_name]/
│   ├── README.md                # Goal, status, findings
│   ├── code/                    # .do and .R files
│   ├── output/                  # Results, figures
│   └── notes.md                 # Progress notes
└── ARCHIVE/
    ├── completed_[project]/
    └── abandoned_[project]/
```

## Lifecycle

1. **Create** — `mkdir explorations/[name]/{code,output}` + README
2. **Develop** — work entirely within the exploration folder
3. **Decide:**
   - **Graduate** — copy to `$RB/code/` or `$RB/scripts/`; requires quality >= 80
   - **Keep exploring** — document next steps in README
   - **Abandon** — move to `ARCHIVE/abandoned_[project]/` with explanation

## Quality Threshold

Explorations use a **60/100** threshold (vs 80/100 for production). This allows faster iteration. When graduating to production, the 80/100 gate applies.

## Examples of Good Explorations

- Event study / stacked DID as alternative estimator
- Pre-trend testing for parallel trends
- Heterogeneity analysis by {{unit}} characteristics
- Visualization experiments for conference presentation
