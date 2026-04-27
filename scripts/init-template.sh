#!/usr/bin/env bash
# Bootstrap a freshly-cloned harness-project-template repo.
#
# Steps (idempotent):
#   1. Install uv if missing
#   2. Rename example package: di2vibe -> $1 (across source, configs, tests, docs)
#   3. uv sync --all-extras
#   4. uv run pre-commit install
#   5. Run the full gate chain (ruff + mypy + pytest)
#
# Usage:
#   ./scripts/init-template.sh <new_package_name>
#   e.g. ./scripts/init-template.sh orders_api

set -euo pipefail

NEW_NAME="${1:-}"
OLD_NAME="di2vibe"
SELF="scripts/init-template.sh"

if [[ -z "$NEW_NAME" ]]; then
  echo "usage: $0 <new_package_name>" >&2
  echo "  must be a valid Python identifier (lowercase, [a-z0-9_], starts with letter)" >&2
  exit 2
fi

if ! [[ "$NEW_NAME" =~ ^[a-z][a-z0-9_]*$ ]]; then
  echo "error: '$NEW_NAME' is not a valid Python package name" >&2
  echo "  must be lowercase, start with a letter, and contain only [a-z0-9_]" >&2
  exit 2
fi

if [[ "$NEW_NAME" == "$OLD_NAME" ]]; then
  echo "error: new name is the same as the placeholder ('$OLD_NAME')" >&2
  exit 2
fi

# Must run from repo root (where AGENTS.md lives)
if [[ ! -f AGENTS.md || ! -d src ]]; then
  echo "error: run this from the repository root" >&2
  exit 2
fi

# --- 1. Ensure uv is installed -------------------------------------------------
if ! command -v uv >/dev/null 2>&1; then
  echo "==> uv not found; installing via astral.sh installer"
  curl -LsSf https://astral.sh/uv/install.sh | sh
  export PATH="$HOME/.local/bin:$PATH"
fi
echo "==> uv: $(uv --version)"

# --- 2. Rename the package -----------------------------------------------------
if [[ -d "src/$OLD_NAME" ]]; then
  echo "==> renaming src/$OLD_NAME -> src/$NEW_NAME"
  if git ls-files --error-unmatch "src/$OLD_NAME" >/dev/null 2>&1; then
    git mv "src/$OLD_NAME" "src/$NEW_NAME"
  else
    mv "src/$OLD_NAME" "src/$NEW_NAME"
  fi

  # macOS BSD sed needs an empty extension arg; GNU sed does not
  if [[ "$(uname)" == "Darwin" ]]; then
    sed_inplace=(sed -i '')
  else
    sed_inplace=(sed -i)
  fi

  # Replace remaining references; exclude the script itself so it stays reusable
  echo "==> replacing remaining '$OLD_NAME' references"
  files=()
  while IFS= read -r f; do
    files+=("$f")
  done < <(
    grep -rl "$OLD_NAME" . \
      --exclude-dir=.git \
      --exclude-dir=.venv \
      --exclude-dir=__pycache__ \
      --exclude-dir=.mypy_cache \
      --exclude-dir=.ruff_cache \
      --exclude-dir=.pytest_cache \
      --exclude="$(basename "$SELF")" 2>/dev/null || true
  )
  if [[ ${#files[@]} -gt 0 ]]; then
    "${sed_inplace[@]}" "s/$OLD_NAME/$NEW_NAME/g" "${files[@]}"
    printf '    %s\n' "${files[@]}"
  fi
elif [[ -d "src/$NEW_NAME" ]]; then
  echo "==> src/$NEW_NAME already exists; skipping rename"
else
  echo "error: neither src/$OLD_NAME nor src/$NEW_NAME exists" >&2
  exit 2
fi

# --- 3. Install deps -----------------------------------------------------------
echo "==> uv sync --all-extras"
uv sync --all-extras

# --- 4. pre-commit hooks -------------------------------------------------------
echo "==> uv run pre-commit install"
uv run pre-commit install

# --- 5. Gate chain -------------------------------------------------------------
echo "==> ruff check"
uv run ruff check .
echo "==> ruff format --check"
uv run ruff format --check .
echo "==> mypy src"
uv run mypy src
echo "==> pytest"
uv run pytest

echo
echo "done. your service package is at src/$NEW_NAME"
echo "  start dev server: uv run uvicorn $NEW_NAME.main:app --reload"
echo "  next: edit AGENTS.md + README.md to describe your service, then write your first spec."
