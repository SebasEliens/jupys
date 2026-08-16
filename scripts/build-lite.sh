#!/usr/bin/env bash
# Assembles the notebook projects into a staging content/ dir (excluding venvs,
# lockfiles, and other dev-only cruft) and builds the JupyterLite site into dist/.
set -euo pipefail
cd "$(dirname "$0")/.."

PROJECTS=(piketty-complex-systems colonial-extraction-gis)

rm -rf content dist .jupyterlite.doit.db
mkdir -p content

for proj in "${PROJECTS[@]}"; do
  rsync -a \
    --exclude='.venv/' \
    --exclude='.python-version' \
    --exclude='uv.lock' \
    --exclude='pyproject.toml' \
    --exclude='main.py' \
    --exclude='__pycache__/' \
    --exclude='.ipynb_checkpoints/' \
    "$proj/" "content/$proj/"
done

uv run jupyter lite build --contents content --output-dir dist
cp index.html dist/index.html

echo "Built site in ./dist"
echo "Preview locally with: uv run jupyter lite serve --output-dir dist"
