#!/usr/bin/env python3
"""
extract_pdf.py — Local PDF text extraction, section splitting, and page rendering.

Part of the cheap-scan1 pipeline. Runs locally on your machine (zero API tokens).
Extracts text from each page of a PDF, splits it into per-section markdown files
(to prevent downstream agents from skimming), and optionally renders specific
pages to PNG for visual analysis of tables, figures, and equations.

Usage:
    # Extract text + split into sections (default):
    python extract_pdf.py input.pdf output_dir/

    # Also render specific pages as PNG images (for visual analysis):
    python extract_pdf.py input.pdf output_dir/ --render-pages 5,8,12

    # Render at higher quality (default is 200 DPI):
    python extract_pdf.py input.pdf output_dir/ --render-pages 5,8 --dpi 300

    # Adjust max pages per section chunk (default 4):
    python extract_pdf.py input.pdf output_dir/ --max-section-pages 3

Output files:
    output_dir/extracted_text.md        — Full text with --- PAGE N --- markers
    output_dir/metadata.json            — Per-page extraction quality + section map
    output_dir/pages/page_NN.png        — Rendered PNGs (only for --render-pages)
    output_dir/sections/sec_NN_ppXX-YY_label.md  — Per-section markdown files
        (These are what downstream agents read — each small enough to force
         deep reading instead of skimming.)

Dependencies:
    pip install pymupdf
"""

import sys
import os
import json
import re
import argparse
from datetime import datetime

# ─────────────────────────────────────────────────────────────────
# Try to import pymupdf. If it's not installed, print a helpful
# error message instead of a confusing traceback.
# ─────────────────────────────────────────────────────────────────
try:
    import fitz  # pymupdf's import name is "fitz"
except ImportError:
    print("ERROR: pymupdf is not installed.")
    print("Fix:   pip install pymupdf")
    print("Then re-run this script.")
    sys.exit(1)


def extract_text(pdf_path: str, output_dir: str) -> dict:
    """
    Extract text from every page of a PDF.

    Produces two files:
      - extracted_text.md: Full text with page markers
      - metadata.json: Per-page quality metrics

    Returns the metadata dict so the caller can inspect it.
    """
    # Open the PDF
    doc = fitz.open(pdf_path)
    total_pages = len(doc)
    pdf_filename = os.path.basename(pdf_path)

    # ─────────────────────────────────────────────────────────────
    # Build the extracted text and per-page metadata
    # ─────────────────────────────────────────────────────────────
    text_lines = []
    page_metadata = []
    low_quality_count = 0

    for page_num in range(total_pages):
        page = doc[page_num]

        # Extract text from this page
        # "text" mode gives plain text; "blocks" mode gives layout info
        page_text = page.get_text("text")
        char_count = len(page_text.strip())

        # Check if this page contains embedded images
        # (tables rendered as images, figures, charts, etc.)
        image_list = page.get_images(full=True)
        has_images = len(image_list) > 0

        # ─────────────────────────────────────────────────────────
        # Determine extraction quality for this page.
        #
        # "good"       = text extracted normally
        # "poor"       = very little text but has images (likely a
        #                figure page or image-based table)
        # "ocr_needed" = almost no text and has images (scanned page)
        # "empty"      = no text at all and no images (blank page)
        # ─────────────────────────────────────────────────────────
        if char_count < 50 and has_images:
            quality = "ocr_needed"
            low_quality_count += 1
        elif char_count < 100 and has_images:
            quality = "poor"
        elif char_count < 50 and not has_images:
            quality = "empty"
        else:
            quality = "good"

        # Store metadata for this page
        page_metadata.append({
            "page": page_num + 1,  # 1-indexed (PDF page number)
            "char_count": char_count,
            "has_images": has_images,
            "image_count": len(image_list),
            "extraction_quality": quality
        })

        # Build the text block with page markers
        # These markers are how downstream agents find specific pages
        text_lines.append(f"--- PAGE {page_num + 1} (PDF page {page_num + 1}) ---")
        text_lines.append(page_text.strip() if page_text.strip() else "[No extractable text on this page]")
        text_lines.append(f"--- END PAGE {page_num + 1} ---")
        text_lines.append("")  # blank line between pages

    doc.close()

    # ─────────────────────────────────────────────────────────────
    # Determine if the entire PDF is likely a scan
    # (most pages have no extractable text)
    # ─────────────────────────────────────────────────────────────
    scanned_pdf = low_quality_count > (total_pages * 0.5)

    # ─────────────────────────────────────────────────────────────
    # Write the extracted text file
    # ─────────────────────────────────────────────────────────────
    text_path = os.path.join(output_dir, "extracted_text.md")
    with open(text_path, "w", encoding="utf-8") as f:
        f.write(f"# Extracted Text: {pdf_filename}\n\n")
        f.write(f"**Pages:** {total_pages}\n")
        f.write(f"**Extracted:** {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n\n")
        f.write("\n".join(text_lines))

    # ─────────────────────────────────────────────────────────────
    # Write the metadata file
    # ─────────────────────────────────────────────────────────────
    metadata = {
        "source_pdf": pdf_filename,
        "source_path": os.path.abspath(pdf_path),
        "total_pages": total_pages,
        "extraction_timestamp": datetime.now().isoformat(),
        "scanned_pdf": scanned_pdf,
        "pages": page_metadata
    }

    meta_path = os.path.join(output_dir, "metadata.json")
    with open(meta_path, "w", encoding="utf-8") as f:
        json.dump(metadata, f, indent=2)

    # Print summary to stdout (the skill reads this)
    print(f"Extracted {total_pages} pages from {pdf_filename}")
    print(f"  Good pages: {sum(1 for p in page_metadata if p['extraction_quality'] == 'good')}")
    print(f"  Poor pages: {sum(1 for p in page_metadata if p['extraction_quality'] == 'poor')}")
    print(f"  OCR needed: {sum(1 for p in page_metadata if p['extraction_quality'] == 'ocr_needed')}")
    print(f"  Empty pages: {sum(1 for p in page_metadata if p['extraction_quality'] == 'empty')}")
    if scanned_pdf:
        print("  WARNING: This PDF appears to be a scan. OCR or split-pdf fallback recommended.")
    print(f"  Output: {text_path}")
    print(f"  Metadata: {meta_path}")

    return metadata, text_path, page_metadata


# ─────────────────────────────────────────────────────────────────────
# SECTION HEADER PATTERNS
#
# These regex patterns detect section boundaries in economics papers.
# They're ordered from most-specific to least-specific so the first
# match wins. The patterns look for things like:
#   "1. Introduction"   "II. Background"   "3 Data and Methods"
#   "APPENDIX A"        "References"
#
# If a paper uses unusual headers, the fallback is 4-page chunks.
# ─────────────────────────────────────────────────────────────────────
SECTION_HEADER_PATTERNS = [
    # "1. Introduction" or "1 Introduction" (Arabic numeral + title, same line)
    re.compile(
        r"^\s*(\d{1,2})\s*[.\s]\s*"
        r"(Introduction|Background|Literature|Institutional|Data|"
        r"Method|Model|Empirical|Identification|Results|"
        r"Discussion|Conclusion|Robustness|Extensions?|Theory|"
        r"Theoretical|Framework|Setting|Sample|Variables?|"
        r"Estimation|Findings|Implications|Policy|Summary|"
        r"Related\s+Work|Prior\s+Research|Related\s+Literature|"
        r"Quasi[\s\-]?Natural|Experimental\s+Design|Mechanisms?|"
        r"Heterogeneity|Placebo|Falsification|Welfare|Efficiency)",
        re.IGNORECASE | re.MULTILINE
    ),
    # "II. Background" or "IV. Results" (Roman numeral + title, same line)
    # PERMISSIVE: Roman numerals at start-of-line are structurally distinctive.
    # Unlike Arabic numerals (which could be list items), "III." is almost
    # always a section header. So we match any capitalized title ≥3 chars.
    # This catches law review sections like "I. NONENFORCEMENT: DEFINITIONS"
    # and economics sections like "II. Background" equally.
    re.compile(
        r"^\s*(I{1,3}|IV|V|VI{0,3}|IX|X)\s*\.\s+"
        r"([A-Z][A-Za-z].{3,})",
        re.MULTILINE
    ),
    # Wiley/multi-line format: "2\n|\nRELATED LITERATURE"
    # Common in journals where number, pipe char, and title are on
    # separate lines. The number+pipe structure is strong enough evidence
    # of a section header on its own, so we match ANY ALL-CAPS title
    # (not just keywords). This catches domain-specific section names
    # like "INCUMBENCY ADVANTAGE", "QUASI-NATURAL EXPERIMENT", "ENTRY".
    # Note: [A-Z\- ] (with literal space, not \s) prevents matching across
    # line breaks into the next paragraph's first capital letter.
    re.compile(
        r"(\d{1,2})\s*\n\s*\|\s*\n\s*"
        r"([A-Z][A-Z \-]{2,}[A-Z]|[A-Z]{3,})",
        re.MULTILINE
    ),
    # ALL CAPS standalone section names (common in many journal formats)
    re.compile(
        r"^\s*(INTRODUCTION|BACKGROUND|LITERATURE\s+REVIEW|"
        r"DATA(?:\s+AND\s+METHODS?)?|METHODOLOGY|EMPIRICAL\s+STRATEGY|"
        r"RESULTS|DISCUSSION|CONCLUSION|REFERENCES|BIBLIOGRAPHY|"
        r"ACKNOWLEDGM?ENTS?|APPENDIX(?:\s+[A-Z])?|THEORY|"
        r"RELATED\s+LITERATURE|ESTIMATION\s+STRATEGY)\s*$",
        re.MULTILINE
    ),
    # Standalone section names in title case (no number prefix)
    re.compile(
        r"^\s*(Abstract|Introduction|Background|Literature\s+Review|"
        r"Data(?:\s+and\s+Methods?)?|Methodology|Empirical\s+Strategy|"
        r"Results|Discussion|Conclusion|References|Bibliography|Theory|"
        r"Acknowledgm?ents?|Appendix(?:\s+[A-Z])?|Related\s+Literature|"
        r"Online\s+Appendix|Supplementary|Tables?\s+and\s+Figures?)\s*$",
        re.IGNORECASE | re.MULTILINE
    ),
    # Law review letter subsections: "A. Defining Nonenforcement"
    # Only matches when preceded by a blank line (to avoid inline "A. Smith"
    # references or list items). The \n\n anchor + uppercase title keeps
    # false positive rate low. Only used when publisher is detected as
    # law review, or as a fallback when Roman sections are found.
    re.compile(
        r"(?:^|\n)\s*([A-D])\.\s+([A-Z][a-z].{5,})",
        re.MULTILINE
    ),
]


def detect_journal_format(full_text: str, patterns_path: str = None) -> dict:
    """
    Detect the publisher and journal from PDF text fingerprints.

    Checks the first ~2 pages of extracted text against known publisher
    fingerprints (JSTOR footer, Wiley DOI prefix, Springer boilerplate,
    etc.). When a publisher is recognized, returns which header pattern
    indices to try first — saving compute by prioritizing the most likely
    format.

    If a journal-specific override exists (e.g., Southern Economic Journal
    uses Wiley pipe format even though it's on JSTOR), that takes priority.

    Args:
        full_text:      The full extracted_text.md content
        patterns_path:  Path to scanner_patterns.json (auto-detected if None)

    Returns:
        dict with keys:
          "publisher":              str or None
          "journal":                str or None (if a journal override matched)
          "predicted_format":       str description of expected header format
          "preferred_indices":      list of int or None (which SECTION_HEADER_PATTERNS to try first)
          "confidence":             "high" | "medium" | "low"
          "fingerprints_matched":   list of matched fingerprint strings
    """
    result = {
        "publisher": None,
        "journal": None,
        "predicted_format": None,
        "preferred_indices": None,
        "confidence": "low",
        "fingerprints_matched": []
    }

    # Load scanner_patterns.json
    if patterns_path is None:
        # Look for it next to this script
        script_dir = os.path.dirname(os.path.abspath(__file__))
        patterns_path = os.path.join(script_dir, "scanner_patterns.json")

    if not os.path.exists(patterns_path):
        return result

    with open(patterns_path, "r", encoding="utf-8") as f:
        patterns_data = json.load(f)

    pub_fingerprints = patterns_data.get("publisher_fingerprints", {})
    publishers = pub_fingerprints.get("publishers", {})
    journal_overrides = pub_fingerprints.get("journal_overrides", {})

    # Use first ~8000 chars (roughly first 2 pages) for fingerprinting
    # This covers title page, abstract, and any JSTOR/publisher footers
    scan_text = full_text[:8000]

    # ── Step 1: Check journal-specific overrides first (highest priority)
    for journal_key, journal_entry in journal_overrides.items():
        # Skip metadata keys like _doc, _learning_doc (they're strings, not dicts)
        if not isinstance(journal_entry, dict):
            continue
        j_pattern = journal_entry.get("journal_pattern", "")
        if j_pattern and re.search(j_pattern, scan_text):
            result["journal"] = journal_key
            result["publisher"] = journal_entry.get("publisher")
            if journal_entry.get("override_header_format"):
                result["predicted_format"] = journal_entry["override_header_format"]
            if journal_entry.get("preferred_pattern_indices"):
                result["preferred_indices"] = journal_entry["preferred_pattern_indices"]
            result["confidence"] = "high"
            result["fingerprints_matched"].append(f"journal:{journal_key}")
            print(f"  Journal detected: {journal_key} (publisher: {result['publisher']})")
            return result

    # ── Step 2: Check publisher fingerprints
    for pub_key, pub_info in publishers.items():
        if not isinstance(pub_info, dict):
            continue
        fingerprints = pub_info.get("fingerprints", [])
        matched = []
        for fp in fingerprints:
            if re.search(fp, scan_text):
                matched.append(fp)

        if matched:
            result["publisher"] = pub_key
            result["predicted_format"] = pub_info.get("predicted_header_format")
            result["preferred_indices"] = pub_info.get("preferred_pattern_indices")
            result["confidence"] = "high" if len(matched) >= 2 else "medium"
            result["fingerprints_matched"] = [f"publisher:{pub_key}:{m}" for m in matched]
            print(f"  Publisher detected: {pub_key} "
                  f"({len(matched)} fingerprints, confidence: {result['confidence']})")
            return result

    print("  Publisher: not detected (will try all header patterns)")
    return result


def split_into_sections(
    extracted_text_path: str,
    output_dir: str,
    page_metadata: list,
    max_pages_per_chunk: int = 4,
    force_method: str = "auto"
) -> list:
    """
    Split extracted text into per-section markdown files.

    THIS IS THE ANTI-SKIMMING FAILSAFE. Instead of sending one big file
    to an agent (which invites shallow reading), we produce small files —
    one per detected section — that force deep reading of each piece.

    The logic:
      1. Read the full extracted_text.md
      2. Scan for section headers (Introduction, Data, Results, etc.)
      3. If headers found → split at section boundaries
      4. If no headers found → fall back to 4-page chunks
      5. If any section is longer than max_pages_per_chunk → split it
         into sub-chunks (e.g., background_pt1.md, background_pt2.md)

    Args:
        extracted_text_path:  Path to the full extracted_text.md
        output_dir:           Parent directory (sections/ created inside)
        page_metadata:        Per-page metadata from extract_text()
        max_pages_per_chunk:  Maximum pages before a section gets sub-split
                              (default 4, same as split-pdf's chunk size)

    Returns:
        List of dicts describing each section file:
        [{"file": "sec_01_pp01-02_abstract.md",
          "label": "abstract",
          "pages": [1, 2],
          "is_subsplit": False}, ...]
    """
    # ─────────────────────────────────────────────────────────────
    # Step 1: Read the extracted text and split into per-page blocks
    # ─────────────────────────────────────────────────────────────
    with open(extracted_text_path, "r", encoding="utf-8") as f:
        full_text = f.read()

    # Parse out individual page blocks using the --- PAGE N --- markers
    # Each block is: (page_number, page_text)
    page_blocks = []
    page_pattern = re.compile(
        r"--- PAGE (\d+) \(PDF page \d+\) ---\n(.*?)\n--- END PAGE \d+ ---",
        re.DOTALL
    )
    for match in page_pattern.finditer(full_text):
        page_num = int(match.group(1))
        page_text = match.group(2).strip()
        page_blocks.append((page_num, page_text))

    if not page_blocks:
        print("  WARNING: No page blocks found in extracted text. Skipping section split.")
        return []

    # ─────────────────────────────────────────────────────────────
    # Step 1b: Detect publisher/journal format for prioritized matching
    #
    # If we recognize the publisher (Wiley, Springer, JSTOR, etc.),
    # we reorder the header patterns to try the most likely format
    # first. This is a small compute optimization that also improves
    # accuracy — fewer false positives from unlikely patterns.
    # ─────────────────────────────────────────────────────────────
    journal_info = detect_journal_format(full_text)

    # Reorder patterns if we have preferred indices from publisher detection
    if journal_info["preferred_indices"]:
        preferred = journal_info["preferred_indices"]
        # Build reordered list: preferred patterns first, then the rest
        ordered_patterns = [SECTION_HEADER_PATTERNS[i] for i in preferred
                           if i < len(SECTION_HEADER_PATTERNS)]
        ordered_patterns += [p for i, p in enumerate(SECTION_HEADER_PATTERNS)
                            if i not in preferred]
    else:
        ordered_patterns = SECTION_HEADER_PATTERNS

    # ─────────────────────────────────────────────────────────────
    # Step 2: Detect section headers on each page
    #
    # We scan the FULL page text for section headers. This is safe
    # because our regex patterns use ^ (start-of-line) in MULTILINE
    # mode — so inline mentions like "discussed in the Introduction"
    # won't false-match. Only lines that START with a section header
    # pattern will trigger.
    #
    # Earlier versions used [:500] but that missed mid-page section
    # transitions (e.g., page 2 of McCannon 2021 where "Introduction"
    # appears after 700+ chars of abstract/keywords/JEL codes).
    # ─────────────────────────────────────────────────────────────
    page_sections = []  # List of (page_num, section_label) tuples

    for page_num, page_text in page_blocks:
        scan_region = page_text  # Full page — anchored regexes prevent false positives
        detected_label = None

        for pattern in ordered_patterns:
            match = pattern.search(scan_region)
            if match:
                # Extract the section name from the match
                # The last group in each pattern is the section name
                groups = match.groups()
                # Use the last captured group as the label
                raw_label = groups[-1].strip()

                # Normalize to a clean filename-safe label
                detected_label = _normalize_label(raw_label)
                break

        page_sections.append((page_num, detected_label))

    # ─────────────────────────────────────────────────────────────
    # Step 3: Build sections from detected headers (or fall back)
    #
    # force_method controls the behavior:
    #   "auto"    → try headers first, fall back to chunks (default)
    #   "headers" → only use header detection (no fallback)
    #   "chunks"  → skip header detection, always use page chunks
    #              (use this if sectioning proves less efficient over time)
    # ─────────────────────────────────────────────────────────────
    detected_count = sum(1 for _, label in page_sections if label is not None)

    if force_method == "chunks":
        # User/skill explicitly requested page-chunk mode
        sections = _build_sections_from_chunks(page_blocks, max_pages_per_chunk)
        split_method = "chunks"
        print(f"  Section split: forced to {max_pages_per_chunk}-page chunks (--split-method=chunks)")
    elif detected_count >= 2:
        # We found at least 2 section headers → use header-based splitting
        sections = _build_sections_from_headers(page_blocks, page_sections)
        split_method = "headers"
        print(f"  Section split: detected {detected_count} section headers")
    elif force_method == "headers":
        # User forced headers but we didn't find enough
        sections = _build_sections_from_headers(page_blocks, page_sections)
        split_method = "headers"
        print(f"  Section split: forced headers mode, found only {detected_count} headers")
    else:
        # auto mode, not enough headers → fall back to fixed-size chunks
        sections = _build_sections_from_chunks(page_blocks, max_pages_per_chunk)
        split_method = "chunks"
        print(f"  Section split: no clear headers, using {max_pages_per_chunk}-page chunks")

    # ─────────────────────────────────────────────────────────────
    # Step 4: Adaptive sub-splitting for long sections
    #
    # If any section spans more than max_pages_per_chunk pages,
    # split it into parts (background_pt1, background_pt2, etc.)
    # This only triggers when necessary — short sections stay whole.
    # ─────────────────────────────────────────────────────────────
    final_sections = []
    for section in sections:
        if len(section["pages"]) > max_pages_per_chunk:
            # This section is too long → sub-split it
            sub_sections = _subsplit_section(section, max_pages_per_chunk)
            final_sections.extend(sub_sections)
        else:
            section["is_subsplit"] = False
            final_sections.append(section)

    # ─────────────────────────────────────────────────────────────
    # Step 5: Write each section to its own markdown file
    # ─────────────────────────────────────────────────────────────
    sections_dir = os.path.join(output_dir, "sections")
    os.makedirs(sections_dir, exist_ok=True)

    section_manifest = []
    for idx, section in enumerate(final_sections, 1):
        # Build the filename: sec_01_pp01-02_introduction.md
        page_start = section["pages"][0]
        page_end = section["pages"][-1]
        label = section["label"]

        filename = f"sec_{idx:02d}_pp{page_start:02d}-{page_end:02d}_{label}.md"
        filepath = os.path.join(sections_dir, filename)

        # Write the section file with a header that tells the agent
        # exactly what it's looking at and where it came from
        with open(filepath, "w", encoding="utf-8") as f:
            f.write(f"# Section: {section['display_label']}\n")
            f.write(f"**PDF pages:** {page_start}–{page_end}\n")
            f.write(f"**Split method:** {split_method}\n")
            if section["is_subsplit"]:
                f.write(f"**Note:** This is part of a longer section, "
                        f"sub-split to ensure deep reading.\n")
            f.write("\n---\n\n")
            f.write(section["text"])

        section_manifest.append({
            "file": filename,
            "label": label,
            "display_label": section["display_label"],
            "pages": section["pages"],
            "is_subsplit": section["is_subsplit"],
            "char_count": len(section["text"])
        })

    print(f"  Wrote {len(section_manifest)} section files to {sections_dir}/")
    for entry in section_manifest:
        pages = entry["pages"]
        print(f"    {entry['file']}  (pp. {pages[0]}–{pages[-1]}, "
              f"{entry['char_count']} chars)")

    return section_manifest


def _normalize_label(raw_label: str) -> str:
    """
    Turn a section title into a clean filename-safe label.

    "Data and Methods" → "data_and_methods"
    "Literature Review" → "literature_review"
    "Appendix A" → "appendix_a"
    """
    label = raw_label.lower().strip()
    # Replace spaces and special chars with underscores
    label = re.sub(r"[^a-z0-9]+", "_", label)
    # Remove leading/trailing underscores
    label = label.strip("_")
    # Truncate if absurdly long
    return label[:40] if label else "untitled"


def _build_sections_from_headers(
    page_blocks: list,
    page_sections: list
) -> list:
    """
    Group pages into sections based on detected header locations.

    Each section starts at a detected header and continues until the
    next header (or end of document). Pages before the first header
    become a "front_matter" section.
    """
    sections = []
    current_label = "front_matter"
    current_display = "Front Matter"
    current_pages = []
    current_text_parts = []

    for (page_num, page_text), (_, detected_label) in zip(page_blocks, page_sections):
        if detected_label is not None and current_pages:
            # We hit a new section header → save the current section
            sections.append({
                "label": current_label,
                "display_label": current_display,
                "pages": current_pages,
                "text": "\n\n".join(current_text_parts)
            })
            current_label = detected_label
            current_display = detected_label.replace("_", " ").title()
            current_pages = []
            current_text_parts = []
        elif detected_label is not None:
            # First header in the document
            current_label = detected_label
            current_display = detected_label.replace("_", " ").title()

        current_pages.append(page_num)
        current_text_parts.append(
            f"--- PAGE {page_num} ---\n{page_text}\n--- END PAGE {page_num} ---"
        )

    # Don't forget the last section
    if current_pages:
        sections.append({
            "label": current_label,
            "display_label": current_display,
            "pages": current_pages,
            "text": "\n\n".join(current_text_parts)
        })

    return sections


def _build_sections_from_chunks(
    page_blocks: list,
    chunk_size: int
) -> list:
    """
    Fall back: split pages into fixed-size chunks when no section
    headers are detected. Uses the same chunk size as split-pdf (4 pages).
    """
    sections = []
    for i in range(0, len(page_blocks), chunk_size):
        chunk = page_blocks[i:i + chunk_size]
        page_start = chunk[0][0]
        page_end = chunk[-1][0]

        text_parts = []
        pages = []
        for page_num, page_text in chunk:
            pages.append(page_num)
            text_parts.append(
                f"--- PAGE {page_num} ---\n{page_text}\n--- END PAGE {page_num} ---"
            )

        sections.append({
            "label": f"chunk_pp{page_start:02d}_{page_end:02d}",
            "display_label": f"Pages {page_start}–{page_end}",
            "pages": pages,
            "text": "\n\n".join(text_parts)
        })

    return sections


def _subsplit_section(section: dict, max_pages: int) -> list:
    """
    Split a long section into sub-parts when it exceeds the max page limit.

    "background" spanning 8 pages becomes:
      background_pt1 (pp 3-6), background_pt2 (pp 7-10)

    This only triggers when necessary — most sections are short enough
    to stay as a single file.
    """
    pages = section["pages"]
    base_label = section["label"]
    display_base = section["display_label"]

    # Re-parse the text into individual page blocks
    page_pattern = re.compile(
        r"(--- PAGE (\d+) ---\n.*?\n--- END PAGE \d+ ---)",
        re.DOTALL
    )
    page_texts = {}
    for match in page_pattern.finditer(section["text"]):
        pnum = int(match.group(2))
        page_texts[pnum] = match.group(1)

    sub_sections = []
    part_num = 0
    for i in range(0, len(pages), max_pages):
        part_num += 1
        chunk_pages = pages[i:i + max_pages]
        chunk_text_parts = [page_texts.get(p, "") for p in chunk_pages]

        sub_sections.append({
            "label": f"{base_label}_pt{part_num}",
            "display_label": f"{display_base} (Part {part_num})",
            "pages": chunk_pages,
            "text": "\n\n".join(chunk_text_parts),
            "is_subsplit": True
        })

    return sub_sections


def render_pages(pdf_path: str, output_dir: str, page_numbers: list, dpi: int = 200):
    """
    Render specific pages of a PDF to PNG images.

    Only called when the scanner identifies pages that need visual analysis
    (tables, figures, equations). This keeps things fast — we only render
    the pages that actually need it, not all 30+.

    Args:
        pdf_path:     Path to the original PDF
        output_dir:   Where to save PNGs (creates a pages/ subdirectory)
        page_numbers: List of page numbers to render (1-indexed)
        dpi:          Resolution for rendering (default 200, good for tables)
    """
    doc = fitz.open(pdf_path)
    pages_dir = os.path.join(output_dir, "pages")
    os.makedirs(pages_dir, exist_ok=True)

    rendered = []
    for page_num in page_numbers:
        if page_num < 1 or page_num > len(doc):
            print(f"  Skipping page {page_num} (out of range, PDF has {len(doc)} pages)")
            continue

        # fitz uses 0-indexed pages
        page = doc[page_num - 1]

        # Render to a pixmap (image in memory)
        # The matrix controls resolution: fitz.Matrix(2, 2) = 144 DPI
        # We calculate the scale factor from the desired DPI
        scale = dpi / 72.0  # PDF default is 72 DPI
        mat = fitz.Matrix(scale, scale)
        pix = page.get_pixmap(matrix=mat)

        # Save as PNG
        png_filename = f"page_{page_num:02d}.png"
        png_path = os.path.join(pages_dir, png_filename)
        pix.save(png_path)
        rendered.append(png_filename)
        print(f"  Rendered page {page_num} → {png_path}")

    doc.close()
    print(f"Rendered {len(rendered)} pages to {pages_dir}/")
    return rendered


def main():
    """
    Command-line entry point.

    Basic usage:
        python extract_pdf.py paper.pdf output_dir/

    With page rendering:
        python extract_pdf.py paper.pdf output_dir/ --render-pages 5,8,12

    Adjust section chunk size:
        python extract_pdf.py paper.pdf output_dir/ --max-section-pages 3
    """
    parser = argparse.ArgumentParser(
        description="Extract text and render pages from a PDF (cheap-scan1 pipeline)"
    )
    parser.add_argument("pdf_path", help="Path to the PDF file")
    parser.add_argument("output_dir", help="Directory to write output files")
    parser.add_argument(
        "--render-pages",
        type=str,
        default=None,
        help="Comma-separated list of page numbers to render as PNG (e.g., 5,8,12)"
    )
    parser.add_argument(
        "--dpi",
        type=int,
        default=200,
        help="DPI for rendered pages (default: 200)"
    )
    parser.add_argument(
        "--max-section-pages",
        type=int,
        default=4,
        help="Max pages per section chunk before sub-splitting (default: 4)"
    )
    parser.add_argument(
        "--no-split",
        action="store_true",
        help="Skip section splitting (just extract text + metadata)"
    )
    parser.add_argument(
        "--split-method",
        type=str,
        choices=["auto", "headers", "chunks"],
        default="auto",
        help="Force a split method: 'auto' (detect headers, fall back to chunks), "
             "'headers' (only use header detection), 'chunks' (always use page chunks). "
             "Default: auto. Use 'chunks' if header-based sectioning proves less efficient."
    )

    args = parser.parse_args()

    # Validate input
    if not os.path.exists(args.pdf_path):
        print(f"ERROR: PDF not found: {args.pdf_path}")
        sys.exit(1)

    # Create output directory
    os.makedirs(args.output_dir, exist_ok=True)

    # Step 1: Always extract text (produces extracted_text.md + metadata.json)
    metadata, text_path, page_metadata = extract_text(args.pdf_path, args.output_dir)

    # Step 2: Split into per-section files (the anti-skimming failsafe)
    # This is what downstream agents actually read — small focused chunks
    # that force deep reading instead of superficial skimming.
    if not args.no_split:
        section_manifest = split_into_sections(
            text_path, args.output_dir, page_metadata,
            args.max_section_pages, args.split_method
        )

        # Update metadata with section information
        metadata["sections"] = section_manifest
        # Determine actual split method from the manifest
        has_header_sections = any(
            not s.get("label", "").startswith("chunk_")
            for s in section_manifest
        )
        metadata["split_method"] = "headers" if has_header_sections else "chunks"
        meta_path = os.path.join(args.output_dir, "metadata.json")
        with open(meta_path, "w", encoding="utf-8") as f:
            json.dump(metadata, f, indent=2)

    # Step 3: Optionally render specific pages as PNG
    if args.render_pages:
        page_numbers = [int(p.strip()) for p in args.render_pages.split(",")]
        render_pages(args.pdf_path, args.output_dir, page_numbers, args.dpi)


if __name__ == "__main__":
    main()
