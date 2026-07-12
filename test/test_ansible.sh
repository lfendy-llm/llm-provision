#!/usr/bin/env bash
#
# test_ansible.sh — Automated test for the Ansible playbook.
#
# Builds the test container, installs Ansible, mounts the ansible/
# directory, and runs the playbook to verify all tasks execute
# successfully.
#
# Usage:
#   cd /path/to/llm-provision
#   bash test/test_ansible.sh
#

set -euo pipefail

IMAGE_NAME="ubuntu-server-test"
CONTAINER_NAME="llm-provision-test"
EXEC_USER="localuser"
REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"
PLAYBOOK="playbooks/site.yml"
INVENTORY="inventory/local.ini"
ANSIBLE_DIR="${REPO_DIR}/ansible"
PASS=0
FAIL=0

cleanup() {
    echo ""
    echo "--- Cleaning up container ---"
    podman rm -f "$CONTAINER_NAME" 2>/dev/null || true
}
trap cleanup EXIT

# ---------------------------------------------------------------------------
# Build the image (if not already cached)
# ---------------------------------------------------------------------------
echo "=========================================="
echo "  Step 1: Build test container image"
echo "=========================================="
podman build -t "$IMAGE_NAME" "$REPO_DIR/test"

# ---------------------------------------------------------------------------
# Start the container
# ---------------------------------------------------------------------------
echo ""
echo "=========================================="
echo "  Step 2: Start container"
echo "=========================================="
podman rm -f "$CONTAINER_NAME" 2>/dev/null || true
podman run -d \
    --privileged \
    --name "$CONTAINER_NAME" \
    -v "$ANSIBLE_DIR:/home/$EXEC_USER/ansible" \
    "$IMAGE_NAME"
sleep 2

# ---------------------------------------------------------------------------
# Install Ansible inside the container
# ---------------------------------------------------------------------------
echo ""
echo "=========================================="
echo "  Step 3: Install Ansible"
echo "=========================================="
podman exec --user "$EXEC_USER" "$CONTAINER_NAME" \
    bash -c "sudo apt update -y && sudo apt install -y ansible"

# ---------------------------------------------------------------------------
# Run the Ansible playbook
# ---------------------------------------------------------------------------
echo ""
echo "=========================================="
echo "  Step 4: Run ansible-playbook"
echo "=========================================="
set +e
podman exec --user "$EXEC_USER" "$CONTAINER_NAME" \
    bash -c "cd ~/ansible && ansible-playbook $PLAYBOOK -i $INVENTORY"
EXIT_CODE=$?
set -e

echo ""

# ---------------------------------------------------------------------------
# Verify result
# ---------------------------------------------------------------------------
echo "=========================================="
echo "  Results"
echo "=========================================="

if [ "$EXIT_CODE" -eq 0 ]; then
    echo "  ✅ ansible-playbook completed successfully (exit code 0)"
    PASS=$((PASS + 1))
else
    echo "  ❌ ansible-playbook failed (exit code $EXIT_CODE)"
    FAIL=$((FAIL + 1))
fi

echo ""
echo "  Passed: $PASS"
echo "  Failed: $FAIL"
echo "=========================================="

if [ "$FAIL" -gt 0 ]; then
    exit 1
fi
