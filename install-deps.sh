#!/usr/bin/env bash
#
# install-deps.sh — Install dependencies for llm-provision.
#
# Shared between init.sh (run on a fresh server) and
# Dockerfile.llm-provision-test-cached (pre-cached at build time) so they stay in sync.
#
# Usage:
#   sudo bash install-deps.sh
#

set -euo pipefail

# Use sudo only when not already root
if [ "$(id -u)" -eq 0 ]; then
  SUDO=""
else
  SUDO="sudo"
fi

echo "========================================"
echo "  install-deps: apt update && apt upgrade"
echo "========================================"
$SUDO apt-get update -y
$SUDO apt-get upgrade -y

echo ""
echo "========================================"
echo "  install-deps: Ensure git is installed"
echo "========================================"
if ! command -v git &>/dev/null; then
    echo "git not found — installing..."
    $SUDO apt-get install -y git
else
    echo "git is already installed ($(git --version))"
fi


echo ""
echo "========================================"
echo "  install-deps: Ensure make is installed"
echo "========================================"
if ! command -v make &>/dev/null; then
    echo "make not found — installing..."
    $SUDO apt-get install -y make
else
    echo "make is already installed ($(make --version 2>&1 | head -1))"
fi

echo ""
echo "========================================"
echo "  install-deps: Ensure Ansible is installed"
echo "========================================"
if ! command -v ansible-playbook &>/dev/null; then
    echo "ansible not found — installing..."
    $SUDO apt-get install -y ansible
else
    echo "ansible is already installed ($(ansible --version 2>&1 | head -1))"
fi
