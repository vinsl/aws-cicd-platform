#!/usr/bin/env bash
# .devcontainer/post-create.sh
set -e

echo "=== Installing Python dependencies ==="
cd /workspaces/aws-cicd-platform
python -m venv .venv
source .venv/bin/activate
pip install -e .

echo "=== Devcontainer ready ==="