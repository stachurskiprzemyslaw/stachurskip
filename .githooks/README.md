# Git Hooks (wersjonowane)

Ten katalog zawiera wersjonowane hooki Git dla calego zespolu.

## Aktywacja

Po klonowaniu repo uruchom:

```bash
git config core.hooksPath .githooks
chmod +x .githooks/pre-commit
```

Od tego momentu `pre-commit` uruchamia `python3 .github/scripts/pre_commit_check.py`.
