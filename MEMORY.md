# Project Memory

Corrections and learned facts that persist across sessions.
When a mistake is corrected, append a `[LEARN:category]` entry below.

---

<!-- Append new entries below. Most recent at bottom. -->

## Workflow Patterns

[LEARN:workflow] Requirements specification phase catches ambiguity before planning → reduces rework 30-50%. Use spec-then-plan for complex/ambiguous tasks (>1 hour or >3 files).

[LEARN:workflow] Spec-then-plan protocol: AskUserQuestion (3-5 questions) → create `quality_reports/specs/YYYY-MM-DD_description.md` with MUST/SHOULD/MAY requirements → declare clarity status (CLEAR/ASSUMED/BLOCKED) → get approval → then draft plan.

[LEARN:workflow] Context survival before compression: (1) Update MEMORY.md with [LEARN] entries, (2) Ensure session log current (last 10 min), (3) Active plan saved to disk, (4) Open questions documented. The pre-compact hook displays checklist.

[LEARN:workflow] Plans, specs, and session logs must live on disk (not just in conversation) to survive compression and session boundaries. Quality reports only at merge time.

## Documentation Standards

[LEARN:documentation] When adding new features, update BOTH README and guide immediately to prevent documentation drift. Stale docs break user trust.

[LEARN:documentation] Always document new templates in README's "What's Included" section with purpose description. Template inventory must be complete and accurate.

[LEARN:documentation] Guide must be generic (framework-oriented) not prescriptive. Provide templates with examples for multiple workflows (LaTeX, R, Python, Jupyter), let users customize. No "thou shalt" rules.

[LEARN:documentation] Date fields in frontmatter and README must reflect latest significant changes. Users check dates to assess currency.

## Design Philosophy

[LEARN:design] Framework-oriented > Prescriptive rules. Constitutional governance works as a TEMPLATE with examples users customize to their domain. Same for requirements specs.

[LEARN:design] Quality standard for guide additions: useful + pedagogically strong + drives usage + leaves great impression + improves upon starting fresh + no redundancy + not slow. All 7 criteria must hold.

[LEARN:design] Generic means working for any academic workflow: pure LaTeX (no Quarto), pure R (no LaTeX), Python/Jupyter, any domain (not just econometrics). Test recommendations across use cases.

## File Organization

[LEARN:files] Specifications go in `quality_reports/specs/YYYY-MM-DD_description.md`, not scattered in root or other directories. Maintains structure.

[LEARN:files] Templates belong in `templates/` directory with descriptive names. Currently have: session-log.md, quality-report.md, exploration-readme.md, archive-readme.md, requirements-spec.md, constitutional-governance.md.

## Constitutional Governance

[LEARN:governance] Constitutional articles distinguish immutable principles (non-negotiable for quality/reproducibility) from flexible user preferences. Keep to 3-7 articles max.

[LEARN:governance] Example articles: Primary Artifact (which file is authoritative), Plan-First Threshold (when to plan), Quality Gate (minimum score), Verification Standard (what must pass), File Organization (where files live).

[LEARN:governance] Amendment process: Ask user if deviating from article is "amending Article X (permanent)" or "overriding for this task (one-time exception)". Preserves institutional memory.

## Skill Creation

[LEARN:skills] Effective skill descriptions use trigger phrases users actually say: "check citations", "format results", "validate protocol" → Claude knows when to load skill.

[LEARN:skills] Skills need 3 sections minimum: Instructions (step-by-step), Examples (concrete scenarios), Troubleshooting (common errors) → users can debug independently.

[LEARN:skills] Domain-specific examples beat generic ones: citation checker (psychology), protocol validator (biology), regression formatter (economics) → shows adaptability.

## Memory System

[LEARN:memory] Two-tier memory solves template vs working project tension: MEMORY.md (generic patterns, committed), personal-memory.md (machine-specific, gitignored) → cross-machine sync + local privacy.

[LEARN:memory] Post-merge hooks prompt reflection, don't auto-append → user maintains control while building habit.

## Meta-Governance

[LEARN:meta] Repository dual nature requires explicit governance: what's generic (commit) vs specific (gitignore) → prevents template pollution.

[LEARN:meta] Dogfooding principles must be enforced: plan-first, spec-then-plan, quality gates, session logs → we follow our own guide.

[LEARN:meta] Template development work (building infrastructure, docs) doesn't create session logs in quality_reports/ → those are for user work (slides, analysis), not meta-work. Keeps template clean for users who fork.

## Project-Specific (Jury Trial Redux)

[LEARN:project] User institution is Wabash College. Any Emory references in templates are placeholders.

[LEARN:project] "Shadow expansion" mobilization story is DEAD (2026-03-20 correction). Current framing: "shadow contraction" — election pressure reduces voir dire utilization and suppresses jury verdicts. Contestation adds capital-felony verdict premium in small counties.

[LEARN:project] Overleaf results section (5-results.tex) contains pre-correction coefficient values. All specific numbers are UNVERIFIED until pipeline re-run with corrected code.

[LEARN:project] Three locations: repo (code + config), Dropbox $RB (data + results + Quarto book), Overleaf $OL (paper .tex). See `_paths.md` for routing.

[LEARN:data] Log transform rule: log(x) is fine for CONTROLS with no zeros (e.g., log_county_pop — every county has positive population). Log(x) is BAD for outcomes or controls with concentrated zeros (jury counts, plea counts, pending caseload). pending_felony has zeros at 1st percentile — use levels, not log. Permanent rule.

[LEARN:data] FC = Felony Capital (life-eligible), FH = Felony non-capital. From SCAO case type codes. Never guess definitions.

[LEARN:data] `B_midterm` was renamed to `B_no_offcycle` (2026-03-21). It means "dropping 2018 and 2022 off-cycle years." Rename applied to all do-files + CSV outputs. Coefficients verified identical pre/post rename.

[LEARN:stata] Always use PowerShell batch mode for Stata: `& "C:\Program Files\StataNow19\StataMP-64.exe" /e do "path\to\file.do"`. Never run from bash.

[LEARN:stata] Do NOT use `///` line continuation inside `local` macro definitions with quoted strings (`local x "a b /// c d"`). Stata treats `///` as literal text. Put the full list on one line.

[LEARN:stata] Stata writes p-values without leading zeros (`.39` not `0.39`). R's `read_csv` parses these as character strings. ALWAYS add `mutate(across(c(beta, se, p_value, ci_lo, ci_hi), as.numeric))` after reading Stata-generated CSVs in R/Quarto.

[LEARN:identity] CLAUDE.md must stay under 150 lines. Verbose content goes into .claude/rules/ files.

[LEARN:identification] `is_election_year_pros` = 1 for ALL election years including open seats (N=170). It OVERLAPS with `open_pros`. Use `treat_pros_pressure` (alias `elec_incumbent`) for incumbent-only elections. These are mutually exclusive with `open_pros`.

[LEARN:identification] T0 cannot use county + year FE (TWFE) because election timing is nearly synchronized — year FE absorbs the election signal. Use county FE only for T0 (descriptive benchmark). T2 can use TWFE because contested/uncontested varies within election years.

[LEARN:identification] Off-cycle counties (Allegan, Isabella, Newaygo, Osceola, Roscommon + Delta) have structurally lower composition baselines (capital felony share 5.8% vs 13.9%). They distort year FE estimation for composition outcomes. Δ (contested - uncontested) is robust; individual coefficients are sensitive. Address with timing-group × year FE (= 2-cohort Wooldridge, they're identical).

[LEARN:identification] 2018 and 2022 off-cycle elections are the SAME off-cycle schedule, not separate cohorts. Do NOT split into 3 cohorts (sync, 2018, 2022). Use 2 cohorts only (sync vs off-cycle). The 3-cohort Wooldridge was an error — corrected 2026-03-25.

[LEARN:identification] TWFE weights for T2: contested 0/39 negative (perfect), uncontested 2/105 negative (0.06%). T2 is TWFE-valid on the full panel.

[LEARN:tables] Stata `file write` eats `$` as macro references. Use `\(` and `\)` for inline LaTeX math instead of `$...$`. Or use compound quotes `` `"..."' `` to suppress expansion.

[LEARN:tables] Portrait format (outcomes as rows) is better for 16-outcome tables. Use `file write` loop, not `esttab` (which forces outcomes as columns).

[LEARN:workflow] When user says "add placeholder" to the paper, ALWAYS use: red font (\color{red}), bold header with description + timestamp, closing timestamp. Format: {\color{red}\textbf{[PLACEHOLDER --- DESCRIPTION --- YYYY-MM-DD HH:MM]} ... text ... (YYYY-MM-DD HH:MM)}

[LEARN:data] SCAO jury utilization dashboard verdict columns (capital_felony, other_felony, other_cases) are BROKEN for 2024. Power BI uses MIN() aggregation for capital_felony. Shows 3 FC verdicts statewide vs 431 in caseload data. Use SCAO outgoing caseload dashboard (outgoing_felony_by_year.csv) for ALL verdict, plea, and dismissal variables. Pipeline variables (summoned through utilization_rate) are fine from jury dashboard.

[LEARN:data] The SCAO 73 jury statistics form does NOT collect verdict categories at all. Only pipeline counts (summoned through questioned_in_voir_dire). Verdict columns in the jury dashboard come from a different, unreliable data source.

[LEARN:identification] Δ ≈ 0 on disposition margins (FC jury trial rate, FC dismissal rate) distinguishes competence-maintenance from voter-signaling (McCannon). McCannon predicts Δ > 0 (more behavior change when challenged). Our finding: Δ = 0 — the election cycle itself is sufficient, regardless of challenger presence. This is a distinct theoretical contribution.

[LEARN:identification] FC dismissal rate (-13.6pp***) is the strongest individual result. Both contested and uncontested produce identical drops (Δ = 0.000). FH dismissal rate increases under contestation only (+2.9pp**) — contested prosecutors triage non-capital cases.

[LEARN:git] Always use SSH for git remotes, not HTTPS. SSH key exists at ~/.ssh/id_ed25519 and is authenticated with GitHub (naj2r). When setting up a new repo or encountering OAuth popups, run: `git remote set-url origin git@github.com:naj2r/REPO.git`

[LEARN:stata] NEVER use `levelsof` to extract numeric values from a dataset into locals. `levelsof` is for string/categorical values. For numeric extraction from a single-row filter, use `qui summ varname if condition` then `local val = r(mean)`. The `levelsof` approach causes `<0.01 invalid name` errors when the local is empty or when Stata tries to parse a numeric literal as a name.

[LEARN:stata] All regression panels should be built from ONE unified augmented dataset. Do NOT load different .dta files for different tables — fragile, bad for replication. Use `05b_build_augmented_panel.do` to merge all sources (pipeline, caseload, disposition, election) into `michigan_panel_B_augmented.dta`. Pipeline position: after 05 + 03d, before 06.

[LEARN:tables] AER formatting standard: booktabs only (\toprule, \midrule, \bottomrule), no vertical lines, threeparttable for notes, SEs in parentheses below coefficients, stars (*p<0.10, **p<0.05, ***p<0.01), column headers (1)/(2)/(3), notes section with sample/specification/clustering description. Use siunitx S columns for decimal alignment when needed.
