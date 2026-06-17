#!/usr/bin/env python3
"""Pre-commit checks for staged Python and SQL files.

Zasada:
- sprawdzamy tylko staged pliki,
- pokazujemy lokalizacje bledow w formacie `plik:linia:kolumna`,
- blokujemy commit, jesli sa problemy.
"""

from __future__ import annotations

import re
import subprocess
import sys
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
SQL_DENY_PATTERNS = [
    (re.compile(r"^\s*drop\s+database\b", re.IGNORECASE), "Destrukcyjna instrukcja SQL: DROP DATABASE."),
    (re.compile(r"^\s*delete\s+from\b(?!.*\bwhere\b)", re.IGNORECASE), "Podejrzana instrukcja SQL: DELETE bez WHERE."),
    (re.compile(r"^\s*update\b(?!.*\bwhere\b)", re.IGNORECASE), "Podejrzana instrukcja SQL: UPDATE bez WHERE."),
]


def staged_files() -> list[str]:
    result = subprocess.run(
        ["git", "diff", "--cached", "--name-only", "--diff-filter=ACM"],
        cwd=ROOT,
        capture_output=True,
        text=True,
        check=True,
    )
    return [line.strip() for line in result.stdout.splitlines() if line.strip()]


def run_ruff(paths: list[str]) -> list[str]:
    if not paths:
        return []

    result = subprocess.run(
        ["python3", "-m", "ruff", "check", *paths],
        cwd=ROOT,
        capture_output=True,
        text=True,
    )
    output = (result.stdout + result.stderr).strip()
    if result.returncode == 0:
        return []
    return ["Bledy kodu wykryte przez ruff:\n" + output]


def run_sql_checks(paths: list[str]) -> list[str]:
    findings: list[str] = []
    for relative_path in paths:
        absolute_path = ROOT / relative_path
        try:
            content = absolute_path.read_text(encoding="utf-8")
            lines = content.splitlines()
        except OSError:
            continue

        allow_bulk_cleanup = (
            "/db/" in f"/{relative_path}" and "dane SYNTETYCZNE" in content and "USE baseFunds;" in content
        )

        for line_number, line in enumerate(lines, start=1):
            for pattern, message in SQL_DENY_PATTERNS:
                if allow_bulk_cleanup and message != "Destrukcyjna instrukcja SQL: DROP DATABASE.":
                    continue
                if pattern.search(line):
                    findings.append(f"{relative_path}:{line_number}:1: {message}")
                    break
    return findings


def main() -> int:
    files = staged_files()
    python_files = [path for path in files if path.endswith(".py")]
    sql_files = [path for path in files if path.endswith(".sql")]

    messages: list[str] = []
    messages.extend(run_ruff(python_files))
    messages.extend(run_sql_checks(sql_files))

    if messages:
        print("\n".join(messages), file=sys.stderr)
        return 1

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
