#!/usr/bin/env bash
#
# init.sh — Bootstrap a fresh Ubuntu Server and pull the llm-provision repo.
#
# This script is designed to be the very first thing you run on a new
# Ubuntu Server installation.  It will:
#   1.  Update package lists and upgrade all packages.
#   2.  Ensure git is installed.
#   3.  Clone (or pull) the llm-provision repository from GitHub.
#
# Usage:
#   chmod +x init.sh
#   sudo ./init.sh
#

set -euo pipefail

# ---------------------------------------------------------------------------
# Remote repository URL (hardcoded)
# ---------------------------------------------------------------------------
REMOTE_URL="git@github.com:lfendy-llm/llm-provision.git"

# ---------------------------------------------------------------------------
# Step 1 — Update & upgrade
# ---------------------------------------------------------------------------
echo "========================================"
echo "  Step 1: apt update && apt upgrade"
echo "========================================"
sudo apt update -y
sudo apt upgrade -y

# ---------------------------------------------------------------------------
# Step 2 — Ensure git is installed
# ---------------------------------------------------------------------------
echo ""
echo "========================================"
echo "  Step 2: Ensure git is installed"
echo "========================================"
if ! command -v git &>/dev/null; then
    echo "git not found — installing..."
    sudo apt install -y git
else
    echo "git is already installed ($(git --version))"
fi

# ---------------------------------------------------------------------------
# Step 3 — Clone / pull the llm-provision repository
# ---------------------------------------------------------------------------
echo ""
echo "========================================"
echo "  Step 3: Clone / pull llm-provision"
echo "========================================"

# REMOTE_URL is set at the top of the script
REPO_NAME="$(basename "$REMOTE_URL" .git)"
TARGET_DIR="${HOME}/${REPO_NAME}"

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
