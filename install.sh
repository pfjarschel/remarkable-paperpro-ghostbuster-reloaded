#!/bin/bash
set -e

TARGET_IP="${1:-10.11.99.1}"
TARGET_USER="root"
SSH_TARGET="${TARGET_USER}@${TARGET_IP}"
REMOTE_DEST="/home/root/xovi/exthome/qt-resource-rebuilder"

echo "======================================================"
echo "  reMarkable Paper Pro - GhostBuster Installer"
echo "======================================================"
echo "Target device: ${SSH_TARGET}"
echo ""

# Check SSH connection
echo "[1/4] Checking connection to reMarkable tablet..."
if ! ssh -o ConnectTimeout=5 -o BatchMode=yes "${SSH_TARGET}" "true" 2>/dev/null; then
    echo "ERROR: Unable to connect to ${SSH_TARGET} via SSH."
    echo "Please ensure USB web interface or Wi-Fi SSH is enabled and keys are configured."
    echo "Usage: ./install.sh [device-ip]"
    exit 1
fi
echo "      Connected successfully!"

# Check if qt-resource-rebuilder directory exists
echo "[2/4] Verifying XOVI / qt-resource-rebuilder setup..."
if ! ssh "${SSH_TARGET}" "[ -d ${REMOTE_DEST} ]"; then
    echo "ERROR: ${REMOTE_DEST} does not exist on the device."
    echo "Please make sure XOVI and qt-resource-rebuilder are installed first."
    echo "See README.md for prerequisites."
    exit 1
fi
echo "      qt-resource-rebuilder directory found!"

# Copy hashed QMD diffs
echo "[3/4] Deploying GhostBuster extensions..."
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="${SCRIPT_DIR}/dist/3.28.0.169"

if [ ! -d "${DIST_DIR}" ]; then
    echo "ERROR: Distribution directory not found at ${DIST_DIR}."
    exit 1
fi

scp "${DIST_DIR}"/*.qmd "${SSH_TARGET}:${REMOTE_DEST}/"
echo "      Extensions transferred successfully!"

# Restart xochitl to load patches
echo "[4/4] Restarting xochitl..."
ssh "${SSH_TARGET}" "/home/root/xovi/start"
echo "      xochitl restarted!"

echo ""
echo "======================================================"
echo "  Installation Complete! 🎉"
echo "======================================================"
echo "Enjoy a crisp, ghost-free experience on your Paper Pro!"
echo "Features enabled:"
echo " - Instant screen refresh after erasing (~400ms)"
echo " - Automatic clear on page turns and hyperlink jumps"
echo " - Debounced clear on opening and closing Settings"
echo " - 5-finger manual clear gesture inside documents"
echo "======================================================"
