---
name: proofread
description: Grammar, typos, LaTeX/QMD formatting, and academic writing review
disable-model-invocation: true
argument-hint: "[file path or section name]"
allowed-tools: ["Read", "Grep", "Glob", "Write", "Task"]
---

# Proofread

Review a file for grammar, typos, formatting issues, and academic writing quality.

**Input:** `$ARGUMENTS` — path to a .tex, .qmd, or .md file, or a section name.

## Steps

1. **Read the file** end-to-end
2. **Check for:**
   - Spelling and grammar errors
   - Awkward phrasing or unclear sentences
   - Passive voice overuse
   - Inconsistent terminology (e.g., "{{term variant A}}" vs "{{term variant B}}")
   - LaTeX issues: undefined commands, unbalanced braces, overfull hbox triggers
   - QMD issues: broken YAML, malformed code chunks, missing cross-refs
   - Citation formatting: `\cite{}` vs `\citep{}` vs `\citet{}` consistency
   - Number formatting: consistent use of commas, decimal places
   - Table/figure references match actual labels
3. **Report findings** by severity:
   - **Errors** (must fix): typos, grammar mistakes, broken formatting
   - **Style** (should fix): passive voice, wordiness, inconsistency
   - **Suggestions** (optional): alternative phrasing, better organization
4. **Provide corrected text** for all errors found

## Academic Writing Standards

- Active voice preferred ("We find..." not "It was found that...")
- Present tense for established facts, past tense for specific study results
- Numbers < 10 spelled out unless in a data context
- "Significant" only for statistical significance, not "important"
- Effect sizes always accompanied by significance levels
- Table notes explain ALL abbreviations and symbols
