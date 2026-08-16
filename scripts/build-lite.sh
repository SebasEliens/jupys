#!/usr/bin/env bash
# Builds the JupyterLite site from content/ into dist/. Dev-only files (.venv,
# lockfiles, etc.) are excluded via content/.jupyterlite.ignore, not copying.
set -euo pipefail
cd "$(dirname "$0")/.."

rm -rf dist .jupyterlite.doit.db

uv run jupyter lite build --contents content --output-dir dist
cp index.html dist/index.html

echo "Built site in ./dist"
echo "Preview locally with: uv run jupyter lite serve --output-dir dist"
