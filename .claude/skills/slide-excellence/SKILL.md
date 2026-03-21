---
name: slide-excellence
description: Comprehensive multi-pass slide review for conference readiness — visual, content, and flow
disable-model-invocation: true
argument-hint: "[presentation.tex or 'full']"
allowed-tools: ["Read", "Grep", "Glob", "Bash", "Write", "Task"]
---

# Slide Excellence

Multi-pass comprehensive review for conference-ready slides. Runs several review passes in parallel and synthesizes a combined quality score.

**Input:** `$ARGUMENTS` — path to presentation or "full" for complete review.

## Review Passes

### Pass 1: Visual Audit
Run `/visual-audit` — check overflow, fonts, layout, technical compilation.

### Pass 2: Content Review
- Does each slide have ONE clear takeaway?
- Are results slides focused on key findings (not all 412 specifications)?
- Is the "so what" clear for each empirical result?
- Do tables match the narrative (correct magnitudes, significance)?

### Pass 3: Audience Calibration
- **For economics seminar**: Is the identification strategy prominently featured?
- **For law conference**: Is the policy implication front and center?
- **For general audience**: Are acronyms (TWFE, {{project acronyms}}) defined?
- Adjust emphasis based on `$ARGUMENTS` audience specification.

### Pass 4: Flow & Timing
For a ~20 minute talk:
- Title: 1 slide (30 sec)
- Motivation: 2-3 slides (3 min)
- This paper: 1 slide (1 min)
- Institutional background: 1-2 slides (2 min)
- Data: 1-2 slides (2 min)
- Methods: 1 slide (1.5 min)
- Results: 3-5 slides (6-7 min)
- Robustness: 1 slide (1 min)
- Conclusions: 1-2 slides (2 min)
- **Total**: 12-18 slides for 20 min (≈ 1.5 min per slide)

### Pass 5: Proofreading
Run `/proofread` on the `.tex` source — grammar, typos, LaTeX syntax.

## Synthesis

Combine all passes into a single report with:
1. **Quality Score** (0-100) across dimensions:
   - Visual quality (20 pts)
   - Content accuracy (25 pts)
   - Flow & structure (20 pts)
   - Audience calibration (15 pts)
   - Technical correctness (20 pts)
2. **Top 5 Issues** (highest impact, ranked)
3. **Quick Wins** (easy fixes with high return)
4. **Conference Readiness**: READY / NEEDS WORK / NOT READY

## Conference Prep Checklist
- [ ] All tables use latest regression results
- [ ] Appendix slides ready for tough questions
- [ ] Backup slides for: endogeneity, alternative specs, mechanism, data construction
- [ ] Author contact info on final slide
- [ ] Timer test: practice talk fits in allotted time
