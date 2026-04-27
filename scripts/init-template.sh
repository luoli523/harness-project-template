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

OLD_NAME="di2vibe"
SELF="scripts/init-template.sh"

usage() {
  cat <<EOF
Bootstrap a freshly-cloned harness-project-template repo.

USAGE
  ./scripts/init-template.sh <new_package_name>
  ./scripts/init-template.sh -h | --help

ARGUMENTS
  <new_package_name>   New Python package name to replace the '$OLD_NAME' placeholder.
                       Must be a valid Python identifier:
                         - lowercase letters, digits, underscore
                         - starts with a letter
                         - matches: ^[a-z][a-z0-9_]*\$
                       Examples: orders_api, billing, user_service

OPTIONS
  -h, --help           Show this help and exit.

WHAT IT DOES (in order, idempotent)
  1. Install 'uv' via the official installer if it is not on PATH.
  2. Rename the example package src/$OLD_NAME -> src/<new_package_name>
     and replace every '$OLD_NAME' reference across source, tests,
     pyproject.toml, uv.lock, and docs (the script itself is excluded).
  3. Run 'uv sync --all-extras' to install runtime + dev deps.
  4. Run 'uv run pre-commit install' to register git hooks.
  5. Run the full gate chain: ruff check, ruff format --check, mypy, pytest.

PRECONDITIONS
  - Must be invoked from the repository root (the directory containing AGENTS.md).
  - Internet access (for installing uv if missing, and for 'uv sync').

EXIT CODES
  0   success
  2   bad usage (missing or invalid argument, wrong working directory)
  *   propagated from a failing step (uv install, sync, ruff, mypy, pytest, ...)

EXAMPLES
  ./scripts/init-template.sh orders_api
  ./scripts/init-template.sh user_service
EOF
}

# Help flags handled before any validation
case "${1:-}" in
  -h|--help)
    usage
    exit 0
    ;;
esac

NEW_NAME="${1:-}"

if [[ -z "$NEW_NAME" ]]; then
  echo "error: missing required argument <new_package_name>" >&2
  echo "       run with --help for full usage." >&2
  exit 2
fi

if ! [[ "$NEW_NAME" =~ ^[a-z][a-z0-9_]*$ ]]; then
  echo "error: '$NEW_NAME' is not a valid Python package name" >&2
  echo "       must be lowercase, start with a letter, and contain only [a-z0-9_]" >&2
  echo "       run with --help for full usage." >&2
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
