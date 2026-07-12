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

echo "========================================"
echo "  apt update && apt upgrade"
echo "========================================"
sudo apt-get update -y
sudo apt-get upgrade -y

echo ""
echo "========================================"
echo "  Ensure git is installed"
echo "========================================"
if ! command -v git &>/dev/null; then
    echo "git not found — installing..."
    sudo apt-get install -y git
else
    echo "git is already installed ($(git --version))"
fi

echo ""
echo "========================================"
echo "  Ensure curl is installed"
echo "========================================"
if ! command -v curl &>/dev/null; then
    echo "curl not found — installing..."
    sudo apt-get install -y curl
else
    echo "curl is already installed ($(curl --version 2>&1 | head -1))"
fi

echo ""
echo "========================================"
echo "  Ensure make is installed"
echo "========================================"
if ! command -v make &>/dev/null; then
    echo "make not found — installing..."
    sudo apt-get install -y make
else
    echo "make is already installed ($(make --version 2>&1 | head -1))"
fi

echo ""
echo "========================================"
echo "  Ensure Ansible is installed"
echo "========================================"
if ! command -v ansible-playbook &>/dev/null; then
    echo "ansible not found — installing..."
    sudo apt-get install -y ansible
else
    echo "ansible is already installed ($(ansible --version 2>&1 | head -1))"
fi
