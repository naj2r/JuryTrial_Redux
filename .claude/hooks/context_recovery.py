#!/usr/bin/env python3
"""
Context Recovery Hook for Claude Code

SessionStart hook that outputs the most recent plan and session log
filenames as a system message. Helps Claude orient after context
compression, session resume, or fresh start.

Searches for quality_reports/plans/ and quality_reports/session_logs/
directories anywhere under the project root. Works regardless of
where $RB is configured.
"""

import glob
import json
import os
import sys


def find_directory(project_dir, target_subpath):
    """Find a directory matching target_subpath under project_dir."""
    # Try common locations first (fast path)
    for prefix in ["", "results_rebuild", "replication_book"]:
        candidate = os.path.join(project_dir, prefix, target_subpath)
        if os.path.isdir(candidate):
            return candidate

    # Fallback: recursive glob (slower but universal)
    pattern = os.path.join(project_dir, "**", target_subpath)
    matches = glob.glob(pattern, recursive=True)
    if matches:
        return matches[0]
    return None


def find_most_recent(directory, pattern="*.md"):
    """Find the most recently modified file matching pattern."""
    search_path = os.path.join(directory, pattern)
    files = glob.glob(search_path)
    if not files:
        return None
    return max(files, key=os.path.getmtime)


def main():
    try:
        input_data = json.load(sys.stdin)
    except Exception:
        sys.exit(0)

    # Determine project root from script location
    script_dir = os.path.dirname(os.path.abspath(__file__))
    claude_dir = os.path.dirname(script_dir)  # .claude/
    project_dir = os.path.dirname(claude_dir)  # project root

    parts = []

    plans_dir = find_directory(
        project_dir, os.path.join("quality_reports", "plans")
    )
    if plans_dir:
        recent_plan = find_most_recent(plans_dir)
        if recent_plan:
            parts.append(f"Recent plan: {os.path.basename(recent_plan)}")

    logs_dir = find_directory(
        project_dir, os.path.join("quality_reports", "session_logs")
    )
    if logs_dir:
        recent_log = find_most_recent(logs_dir)
        if recent_log:
            parts.append(
                f"Recent session log: {os.path.basename(recent_log)}"
            )

    if parts:
        parts.append(
            "Read these + MEMORY.md for context recovery. "
            "Check the autonomous work queue in the permanent agenda."
        )
        message = " | ".join(parts)
        result = {"systemMessage": message}
        print(json.dumps(result))

    sys.exit(0)


if __name__ == "__main__":
    main()
