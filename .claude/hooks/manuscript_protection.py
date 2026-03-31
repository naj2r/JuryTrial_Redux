#!/usr/bin/env python3
"""
Manuscript Protection Hook for Claude Code

PreToolUse hook that blocks Write/Edit operations on protected Overleaf
.tex files (paper sections and presentation). Enforces the manuscript-
protection rule mechanically as defense-in-depth.

Behavior:
  - First attempt on a protected file: BLOCK (exit 2) with warning
  - Retry on same file in same session: ALLOW (exit 0)
    (User presumably approved after seeing the warning)

Protected files: Sections/1-introduction.tex through 6-conclusion.tex,
and presentation.tex. Infrastructure files (7-figuresAndTables.tex,
8-appendix.tex, bibliographyCiteDrive.bib, preamble.tex, tables)
are NOT protected.

Customize PROTECTED_SECTIONS below if your Overleaf project uses
different section filenames.
"""

import json
import os
import random
import sys

# Protected filename patterns (matched against end of normalized path)
# Customize these for your Overleaf project structure
PROTECTED_SECTIONS = [
    "1-introduction.tex",
    "2-background.tex",
    "3-data.tex",
    "4-methods.tex",
    "5-results.tex",
    "6-conclusion.tex",
    "presentation.tex",
]


def get_state_file(session_id):
    """Get session-specific state file path."""
    return os.path.expanduser(
        f"~/.claude/manuscript_protection_{session_id}.json"
    )


def cleanup_old_state_files():
    """Remove state files older than 7 days."""
    try:
        from datetime import datetime

        state_dir = os.path.expanduser("~/.claude")
        if not os.path.exists(state_dir):
            return
        cutoff = datetime.now().timestamp() - (7 * 24 * 60 * 60)
        for f in os.listdir(state_dir):
            if f.startswith("manuscript_protection_") and f.endswith(".json"):
                path = os.path.join(state_dir, f)
                try:
                    if os.path.getmtime(path) < cutoff:
                        os.remove(path)
                except OSError:
                    pass
    except Exception:
        pass


def load_state(session_id):
    """Load the set of already-warned file paths for this session."""
    state_file = get_state_file(session_id)
    if os.path.exists(state_file):
        try:
            with open(state_file, "r") as f:
                return set(json.load(f))
        except (json.JSONDecodeError, IOError):
            return set()
    return set()


def save_state(session_id, warned_files):
    """Save the set of already-warned file paths."""
    state_file = get_state_file(session_id)
    try:
        os.makedirs(os.path.dirname(state_file), exist_ok=True)
        with open(state_file, "w") as f:
            json.dump(list(warned_files), f)
    except IOError:
        pass


def normalize_path(path):
    """Normalize path for cross-platform comparison."""
    return path.replace("\\", "/").lower()


def is_protected(file_path):
    """Check if file path ends with a protected section filename."""
    normalized = normalize_path(file_path)
    return any(normalized.endswith(p.lower()) for p in PROTECTED_SECTIONS)


def main():
    # Periodically clean up old state files (10% chance per run)
    if random.random() < 0.1:
        cleanup_old_state_files()

    try:
        raw_input = sys.stdin.read()
        input_data = json.loads(raw_input)
    except (json.JSONDecodeError, IOError):
        sys.exit(0)  # Allow if can't parse

    tool_name = input_data.get("tool_name", "")
    tool_input = input_data.get("tool_input", {})
    session_id = input_data.get("session_id", "default")

    if tool_name not in ("Edit", "Write"):
        sys.exit(0)

    file_path = tool_input.get("file_path", "")
    if not file_path or not is_protected(file_path):
        sys.exit(0)

    # Protected file detected
    warned_files = load_state(session_id)
    warning_key = normalize_path(file_path)

    if warning_key in warned_files:
        # Already warned this session — user presumably approved
        sys.exit(0)

    # First attempt — block and warn
    warned_files.add(warning_key)
    save_state(session_id, warned_files)

    filename = os.path.basename(file_path)
    warning = (
        f"MANUSCRIPT PROTECTION: Edit blocked on '{filename}'.\n"
        f"Protected files (Sections/1-6*.tex, presentation.tex) "
        f"require explicit user instruction.\n"
        f"Mechanical fixes (citation keys, \\input{{}}, compilation "
        f"errors) are allowed if user-requested.\n"
        f"Put substantive content in QMD files instead.\n"
        f"If the user explicitly requested this edit, retry the tool call."
    )
    print(warning, file=sys.stderr)
    sys.exit(2)  # Block execution


if __name__ == "__main__":
    main()
