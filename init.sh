#!/usr/bin/env bash
#
# init.sh — Bootstrap a fresh Ubuntu Server and provision it.
#
# This script is designed to be run on a new Ubuntu Server installation.
# Alternatively, pipe it from GitHub:
#   curl -fsSL https://raw.githubusercontent.com/lfendy-llm/llm-provision/refs/heads/main/init.sh | sudo bash
#
# It will:
#   1.  Update package lists and upgrade all packages.
#   2.  Ensure git is installed.
#   3.  Ensure make is installed.
#   4.  Ensure Ansible is installed.
#   5.  Clone the llm-provision repository (if not already present).
#   6.  Run the Ansible playbook (make provision).
#
# Usage:
#   chmod +x init.sh
#   sudo ./init.sh
#

set -euo pipefail

REMOTE_URL="https://github.com/lfendy-llm/llm-provision.git"

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

# ---------------------------------------------------------------------------
# Step 5 — Clone the llm-provision repository (if not already present)
# ---------------------------------------------------------------------------
TARGET_DIR="${HOME}/repos/llm-provision"

if [[ -d "$TARGET_DIR" ]]; then
    echo ""
    echo "========================================"
    echo "  Step 5: Skipped — ${TARGET_DIR} already exists"
    echo "========================================"
else
    echo ""
    echo "========================================"
    echo "  Step 5: Clone llm-provision"
    echo "========================================"
    echo "Cloning ${REMOTE_URL} into ${TARGET_DIR}..."
    git clone "$REMOTE_URL" "$TARGET_DIR"
    echo ""
    echo "========================================"
    echo "  Done! Repository is at ${TARGET_DIR}"
    echo "========================================"
fi

# ---------------------------------------------------------------------------
# Step 6 — Run the Ansible playbook
# ---------------------------------------------------------------------------
echo ""
echo "========================================"
echo "  Step 6: Run Ansible playbook"
echo "========================================"
cd "${TARGET_DIR}/ansible"
sudo make provision

echo ""
echo "========================================"
echo "  init.sh complete!"
echo "========================================"
