#!/usr/bin/env python3
"""Post-tool diagnostics for changed Python files.

Cel:
- pokazać od razu, gdzie sa bledy w kodzie,
- zwracac komunikaty z `plik:linia:kolumna`,
- nie blokowac pracy, tylko powierzac diagnostyke.
"""

from __future__ import annotations

import json
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


def changed_python_files() -> list[str]:
    result = subprocess.run(
        ["git", "status", "--porcelain"],
        cwd=ROOT,
        capture_output=True,
        text=True,
        check=True,
    )

    files: list[str] = []
    for line in result.stdout.splitlines():
        if len(line) < 4:
            continue
        path = line[3:].strip()
        if path.endswith(".py"):
            files.append(path)
    return sorted(set(files))


def changed_sql_files() -> list[str]:
    result = subprocess.run(
        ["git", "status", "--porcelain"],
        cwd=ROOT,
        capture_output=True,
        text=True,
        check=True,
    )

    files: list[str] = []
    for line in result.stdout.splitlines():
        if len(line) < 4:
            continue
        path = line[3:].strip()
        if path.endswith(".sql"):
            files.append(path)
    return sorted(set(files))


def run_ruff(paths: list[str]) -> tuple[int, str]:
    if not paths:
        return 0, ""

    result = subprocess.run(
        ["python3", "-m", "ruff", "check", *paths],
        cwd=ROOT,
        capture_output=True,
        text=True,
    )
    output = (result.stdout + result.stderr).strip()
    return result.returncode, output


def run_sql_checks(paths: list[str]) -> list[str]:
    findings: list[str] = []
    for relative_path in paths:
        absolute_path = ROOT / relative_path
        try:
            lines = absolute_path.read_text(encoding="utf-8").splitlines()
        except OSError:
            continue

        allow_bulk_cleanup = relative_path.endswith("seed.sql")

        for line_number, line in enumerate(lines, start=1):
            for pattern, message in SQL_DENY_PATTERNS:
                if allow_bulk_cleanup and message != "Destrukcyjna instrukcja SQL: DROP DATABASE.":
                    continue
                if pattern.search(line):
                    findings.append(f"{relative_path}:{line_number}:1: {message}")
                    break
    return findings


def main() -> int:
    raw_input = sys.stdin.read().strip()
    if not raw_input:
        return 0

    try:
        json.loads(raw_input)
    except json.JSONDecodeError:
        return 0

    paths = changed_python_files()
    sql_paths = changed_sql_files()

    messages: list[str] = []

    if paths:
        code, output = run_ruff(paths)
        if code != 0 and output:
            messages.append("Bledy kodu wykryte przez ruff:\n" + output)

    if sql_paths:
        messages.extend(run_sql_checks(sql_paths))

    if messages:
        print(json.dumps({"systemMessage": "\n".join(messages)}))

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
