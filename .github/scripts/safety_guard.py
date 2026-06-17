#!/usr/bin/env python3
"""Hook runtime logic for workspace safety checks.

Dlaczego sa dwa pliki:
- `.github/hooks/fund-safety.json` jest konfiguracja hooka (kiedy i jaki command uruchomic).
- ten plik (`safety_guard.py`) zawiera logike decyzyjna i zwraca JSON `allow|ask|deny`.
"""

from __future__ import annotations

import json
import re
import sys
from typing import Any


DENY_PATTERNS = [
    r"git\s+reset\s+--hard",
    r"git\s+checkout\s+--",
    r"rm\s+-rf\s+/",
    r"rm\s+-rf\s+\.",
    r"\bdrop\s+database\b",
    r"\bupdate\b(?![\s\S]*\bwhere\b)",
]

ASK_PATTERNS = [
    r"\bdrop\s+table\b",
    r"\btruncate\b",
    r"\bdelete\s+from\b",
    r"\bupdate\b[\s\S]*\bwhere\b",
    r"\binsert\s+into\b",
    r"\balter\s+table\b",
    r"\bcreate\s+login\b",
    r"\bpassword\b",
    r"\bsecret\b",
    r"DB_PASSWORD",
]

SCAN_KEYS = {"command", "input", "sql", "query"}


def flatten_strings(value: Any) -> list[str]:
    if isinstance(value, str):
        return [value]
    if isinstance(value, dict):
        collected: list[str] = []
        for item in value.values():
            collected.extend(flatten_strings(item))
        return collected
    if isinstance(value, list):
        collected = []
        for item in value:
            collected.extend(flatten_strings(item))
        return collected
    return []


def collect_relevant_text(value: Any) -> list[str]:
    if isinstance(value, str):
        return [value]
    if isinstance(value, list):
        collected: list[str] = []
        for item in value:
            collected.extend(collect_relevant_text(item))
        return collected
    if isinstance(value, dict):
        collected: list[str] = []
        for key, item in value.items():
            if key in SCAN_KEYS:
                collected.extend(flatten_strings(item))
            elif isinstance(item, (dict, list)):
                collected.extend(collect_relevant_text(item))
        return collected
    return []


def decision_response(decision: str, reason: str) -> dict[str, Any]:
    return {
        "hookSpecificOutput": {
            "hookEventName": "PreToolUse",
            "permissionDecision": decision,
            "permissionDecisionReason": reason,
        },
        "systemMessage": reason,
    }


def main() -> int:
    raw_input = sys.stdin.read().strip()
    if not raw_input:
        return 0

    try:
        payload = json.loads(raw_input)
    except json.JSONDecodeError:
        print(
            json.dumps(
                decision_response(
                    "deny",
                    "Zablokowano przez workspace safety hook: niepoprawny format danych hooka.",
                )
            )
        )
        return 0

    searchable = "\n".join(collect_relevant_text(payload))

    for pattern in DENY_PATTERNS:
        if re.search(pattern, searchable, flags=re.IGNORECASE):
            print(
                json.dumps(
                    decision_response(
                        "deny",
                        "Zablokowano przez workspace safety hook: destrukcyjna komenda shell lub git.",
                    )
                )
            )
            return 0

    for pattern in ASK_PATTERNS:
        if re.search(pattern, searchable, flags=re.IGNORECASE):
            print(
                json.dumps(
                    decision_response(
                        "ask",
                        "Wykryto potencjalna operacje zapisu, prace na sekretach albo zmiane uprzywilejowana. Potwierdz zakres przed kontynuacja.",
                    )
                )
            )
            return 0

    print(json.dumps(decision_response("allow", "Dozwolone przez workspace safety hook.")))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
