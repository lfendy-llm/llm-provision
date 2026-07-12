#!/usr/bin/env bash
#
# init.sh — Bootstrap a fresh Ubuntu Server.
#
# This script is designed to be the very first thing you run on a new
# Ubuntu Server installation.  It will:
#   1.  Update package lists and upgrade all packages.
#   2.  Ensure git is installed.
#
# After this completes, run pull.sh to clone the llm-provision repository.
#
# Usage:
#   chmod +x init.sh
#   sudo ./init.sh
#

set -euo pipefail

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

echo ""
