#!/usr/bin/env bash
#
# init.sh — Bootstrap a fresh Ubuntu Server and provision it.
#
# Alternatively, pipe it from GitHub:
#   curl -fsSL https://raw.githubusercontent.com/lfendy-llm/llm-provision/refs/heads/main/init.sh | sudo bash
#
# It will:
#   3.  Run the Ansible playbooks (bootstrap then provision).
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
echo "  init.sh: Step 1 — Install dependencies"
echo "========================================"

SCRIPT_DIR="${HOME}/repos/llm-provision"
if [[ -f "${SCRIPT_DIR}/install-deps.sh" ]]; then
    sudo bash "${SCRIPT_DIR}/install-deps.sh"
else
    curl -fsSL "https://raw.githubusercontent.com/lfendy-llm/llm-provision/refs/heads/main/install-deps.sh?ts=$(date +%s)" | sudo bash
fi

# ---------------------------------------------------------------------------
# Step 2 — Clone the llm-provision repository (if not already present)
# ---------------------------------------------------------------------------
TARGET_DIR="${HOME}/repos/llm-provision"

if [[ -d "$TARGET_DIR" ]]; then
    echo ""
    echo "========================================"
    echo "  init.sh: Step 2 — Skipped (already exists)"
    echo "========================================"
else
    echo ""
    echo "========================================"
    echo "  init.sh: Step 2 — Clone llm-provision"
    echo "========================================"
    echo "Cloning ${REMOTE_URL} into ${TARGET_DIR}..."
    git clone "$REMOTE_URL" "$TARGET_DIR"
    echo ""
    echo "========================================"
    echo "  init.sh: Done — Repository is at ${TARGET_DIR}"
    echo "========================================"
fi

# ---------------------------------------------------------------------------
# Step 3 — Run the Ansible playbooks
# ---------------------------------------------------------------------------
echo ""
echo "========================================"
echo "  init.sh: Step 3 — Run Ansible playbooks"
echo "========================================"
cd "${TARGET_DIR}/ansible"
sudo make bootstrap
sudo make provision
echo ""
echo "========================================"
echo "  init.sh: Complete!"
echo "========================================"
