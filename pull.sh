#!/usr/bin/env bash
#
# pull.sh — Bootstrap a fresh Ubuntu Server and pull the llm-provision repo.
#
# This script runs init.sh first (apt update/upgrade, ensure git), then
# clones or pulls the llm-provision repository from GitHub.
#
# Usage:
#   chmod +x pull.sh
#   sudo ./pull.sh
#

set -euo pipefail

# ---------------------------------------------------------------------------
# Remote repository URL (hardcoded)
# ---------------------------------------------------------------------------
REMOTE_URL="https://github.com/lfendy-llm/llm-provision.git"

# ---------------------------------------------------------------------------
# Step 1 & 2 — Run init.sh (apt update/upgrade, ensure git)
# ---------------------------------------------------------------------------
echo "========================================"
echo "  Running init.sh (apt + git)"
echo "========================================"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [[ -f "${SCRIPT_DIR}/init.sh" ]]; then
    # Local file — e.g. when run from the cloned repo
    bash "${SCRIPT_DIR}/init.sh"
else
    # Fetch from GitHub — e.g. when piped directly from curl
    curl -fsSL "https://raw.githubusercontent.com/lfendy-llm/llm-provision/refs/heads/main/init.sh" | bash
fi

# ---------------------------------------------------------------------------
# Step 3 — Clone / pull the llm-provision repository
# ---------------------------------------------------------------------------
echo ""
echo "========================================"
echo "  Step 3: Clone / pull llm-provision"
echo "========================================"

TARGET_DIR="${HOME}/repos/llm-provision"

if [[ -d "$TARGET_DIR" ]]; then
    echo "Repository already exists at ${TARGET_DIR} — pulling latest changes..."
    cd "$TARGET_DIR"
    git pull
else
    echo "Cloning ${REMOTE_URL} into ${TARGET_DIR}..."
    git clone "$REMOTE_URL" "$TARGET_DIR"
fi

echo ""
echo "========================================"
echo "  Done! Repository is at ${TARGET_DIR}"
echo "========================================"
