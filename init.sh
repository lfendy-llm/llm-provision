#!/usr/bin/env bash
#
# init.sh — Bootstrap a fresh Ubuntu Server.
#
# This script is designed to be the very first thing you run on a new
# Ubuntu Server installation.  It will:
#   1.  Update package lists and upgrade all packages.
#   2.  Ensure git is installed.
#   3.  Ensure make is installed.
#   4.  Ensure Ansible is installed.
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

# ---------------------------------------------------------------------------
# Step 3 — Ensure make is installed
# ---------------------------------------------------------------------------
echo ""
echo "========================================"
echo "  Step 3: Ensure make is installed"
echo "========================================"
if ! command -v make &>/dev/null; then
    echo "make not found — installing..."
    sudo apt install -y make
else
    echo "make is already installed ($(make --version 2>&1 | head -1))"
fi

# ---------------------------------------------------------------------------
# Step 4 — Ensure Ansible is installed
# ---------------------------------------------------------------------------
echo ""
echo "========================================"
echo "  Step 4: Ensure Ansible is installed"
echo "========================================"
if ! command -v ansible-playbook &>/dev/null; then
    echo "ansible not found — installing..."
    sudo apt install -y ansible
else
    echo "ansible is already installed ($(ansible --version 2>&1 | head -1))"
fi

echo ""
