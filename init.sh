#!/usr/bin/env bash
#
# init.sh — Bootstrap a fresh Ubuntu Server and provision it.
#
# Alternatively, pipe it from GitHub:
#   curl -fsSL https://raw.githubusercontent.com/lfendy-llm/llm-provision/refs/heads/main/init.sh | sudo bash
#
# It will:
#   1.  Install dependencies (via install-deps.sh).
#   2.  Clone the llm-provision repository (if not already present).
#   3.  Run the Ansible playbook (make provision).
#
# Usage:
#   chmod +x init.sh
#   sudo ./init.sh
#

set -euo pipefail

REMOTE_URL="https://github.com/lfendy-llm/llm-provision.git"

# ---------------------------------------------------------------------------
# Step 1 — Install dependencies
# ---------------------------------------------------------------------------
echo "========================================"
echo "  Step 1: Install dependencies"
echo "========================================"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [[ -f "${SCRIPT_DIR}/install-deps.sh" ]]; then
    sudo bash "${SCRIPT_DIR}/install-deps.sh"
else
    curl -fsSL "https://raw.githubusercontent.com/lfendy-llm/llm-provision/refs/heads/main/install-deps.sh" | sudo bash
fi

# ---------------------------------------------------------------------------
# Step 2 — Clone the llm-provision repository (if not already present)
# ---------------------------------------------------------------------------
TARGET_DIR="${HOME}/repos/llm-provision"

if [[ -d "$TARGET_DIR" ]]; then
    echo ""
    echo "========================================"
    echo "  Step 2: Skipped — ${TARGET_DIR} already exists"
    echo "========================================"
else
    echo ""
    echo "========================================"
    echo "  Step 2: Clone llm-provision"
    echo "========================================"
    echo "Cloning ${REMOTE_URL} into ${TARGET_DIR}..."
    git clone "$REMOTE_URL" "$TARGET_DIR"
    echo ""
    echo "========================================"
    echo "  Done! Repository is at ${TARGET_DIR}"
    echo "========================================"
fi

# ---------------------------------------------------------------------------
# Step 3 — Run the Ansible playbook
# ---------------------------------------------------------------------------
echo ""
echo "========================================"
echo "  Step 3: Run Ansible playbook"
echo "========================================"
cd "${TARGET_DIR}/ansible"
sudo make provision

echo ""
echo "========================================"
echo "  init.sh complete!"
echo "========================================"
