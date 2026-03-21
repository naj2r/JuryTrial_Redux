---
name: split-pdf
description: Download, split, and deeply read academic PDFs. Use when asked to read, review, or summarize an academic paper. Splits PDFs into 4-page chunks, reads them in small batches, and produces structured reading notes — avoiding context window crashes and shallow comprehension.
allowed-tools: Bash(python*), Bash(pip*), Bash(curl*), Bash(wget*), Bash(mkdir*), Bash(ls*), Read, Write, Edit, WebSearch, WebFetch
argument-hint: [pdf-path-or-search-query]
---

# Split-PDF: Download, Split, and Deep-Read Academic Papers

**CRITICAL RULE: Never read a full PDF. Never.** Only read the 4-page split files, and only 3 splits at a time (~12 pages). Reading a full PDF will either crash the session with an unrecoverable "prompt too long" error — destroying all context — or produce shallow, hallucinated output. There are no exceptions.

## When This Skill Is Invoked

The user wants you to read, review, or summarize an academic paper. The input is either:
- A file path to a local PDF (e.g., `./articles/smith_2024.pdf`)
- A search query or paper title (e.g., `"Gentzkow Shapiro Sinkinson 2014 competition newspapers"`)

**Important:** You cannot search for a paper you don't know exists. The user MUST provide either a file path or a specific search query — an author name, a title, keywords, a year, or some combination that identifies the paper. If the user invokes this skill without specifying what paper to read, ask them. Do not guess.

## Step 1: Acquire the PDF

**If a local file path is provided:**
- Verify the file exists
- If the file is NOT already inside `./articles/`, copy it there (do not move — preserve the original location)
- Proceed to Step 2

**If a search query or paper title is provided:**
1. Use WebSearch to find the paper
2. Use WebFetch or Bash (curl/wget) to download the PDF
3. Save it to `./articles/` in the project directory (create the directory if needed)
4. Proceed to Step 2

**CRITICAL: Always preserve the original PDF.** The downloaded or provided PDF in `./articles/` must NEVER be deleted, moved, or overwritten at any point in this workflow. The split files are derivatives — the original is the permanent artifact.

## Step 2: Split the PDF

Create a subdirectory for the splits and run the splitting script:

```python
from PyPDF2 import PdfReader, PdfWriter
import os, sys

def split_pdf(input_path, output_dir, pages_per_chunk=4):
    os.makedirs(output_dir, exist_ok=True)
    reader = PdfReader(input_path)
    total = len(reader.pages)
    prefix = os.path.splitext(os.path.basename(input_path))[0]

    for start in range(0, total, pages_per_chunk):
        end = min(start + pages_per_chunk, total)
        writer = PdfWriter()
        for i in range(start, end):
            writer.add_page(reader.pages[i])

        out_name = f"{prefix}_pp{start+1}-{end}.pdf"
        out_path = os.path.join(output_dir, out_name)
        with open(out_path, "wb") as f:
            writer.write(f)

    print(f"Split {total} pages into {-(-total // pages_per_chunk)} chunks in {output_dir}")
```

**Directory convention:**
```
articles/
├── smith_2024.pdf                    # original PDF — NEVER DELETE THIS
└── split_smith_2024/                 # split subdirectory
    ├── smith_2024_pp1-4.pdf
    ├── smith_2024_pp5-8.pdf
    └── ...
```

If PyPDF2 is not installed, install it: `pip install PyPDF2`

## Step 2.5: Triage Gate (First Split Only)

**Before committing to a full read, triage the paper from its first split (pages 1-4).**

Read only the first split file (abstract + introduction). Then make a relevance judgment:

| Score | Decision | Action |
|-------|----------|--------|
| **4-5** | HIGH relevance | Proceed to full continuous read (Step 3) |
| **3** | MEDIUM relevance | Proceed to full read, but flag as "background cite only" |
| **1-2** | LOW relevance | Write a SHORT triage note to `notes.md` and STOP. |

**Triage criteria** — score relative to your study [defined in study-parameters.md]:
- **5 = ESSENTIAL:** Directly studies your core research question
- **4 = HIGH:** Studies closely related mechanisms or institutional context
- **3 = MEDIUM:** Important background context
- **2 = LOW:** Tangentially related
- **1 = SKIP:** Not relevant enough to cite

## Step 3: Read Continuously in Batches of 3 Splits

Read **exactly 3 split files at a time** (~12 pages). After each batch:

1. **Read** the 3 split PDFs using the Read tool
2. **Update** the running notes file (`notes.md` in the split subdirectory)
3. **Continue immediately** to the next batch — do NOT pause or ask for permission

**CONTINUOUS MODE:** Read all batches without stopping. The only pause point is AFTER all splits are read, when the notes file is finalized.

## Step 4: Structured Extraction

As you read, collect information along these dimensions and write them into `notes.md`:

1. **Research question** — What is the paper asking and why does it matter?
2. **Audience** — Which sub-community of researchers cares about this?
3. **Data** — What data do they use? Unit of observation? Sample size? Time period?
4. **Findings** — What are the main results? Key coefficient estimates and standard errors?
5. **Contributions** — What is learned from this exercise that we didn't know before?
6. **Replication feasibility** — Is the data publicly available? Replication archive?

### Methodology — CONDITIONAL extraction:
7. **Method/ID strategy** — ONLY extract if the paper uses a method relevant to your study (see study-parameters.md for your method)
8. **Connection to your study** — How does this paper's question, data, or findings relate to your research?

## The Notes File

Output is `notes.md` in the split subdirectory:
```
articles/split_smith_2024/notes.md
```

Updated incrementally after each batch. By the time all splits are read, notes should contain specific data sources, variable names, sample sizes, coefficient estimates, and standard errors.

## When NOT to Split

- Papers shorter than ~15 pages: read directly (still use the Read tool, not Bash)
- Policy briefs or non-technical documents: a rough summary is fine
- Triage only: read just the first split (pages 1-4)
