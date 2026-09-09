#!/bin/bash
set -e

TARGET_IP="${1:-10.11.99.1}"
TARGET_USER="root"
SSH_TARGET="${TARGET_USER}@${TARGET_IP}"
REMOTE_DEST="/home/root/xovi/exthome/qt-resource-rebuilder"

echo "======================================================"
echo "  reMarkable Paper Pro - GhostBuster Uninstaller"
echo "======================================================"
echo "Target device: ${SSH_TARGET}"
echo ""

echo "[1/3] Checking connection to reMarkable tablet..."
if ! ssh -o ConnectTimeout=5 -o BatchMode=yes "${SSH_TARGET}" "true" 2>/dev/null; then
    echo "ERROR: Unable to connect to ${SSH_TARGET} via SSH."
    exit 1
fi
echo "      Connected successfully!"

echo "[2/3] Removing GhostBuster extensions..."
ssh "${SSH_TARGET}" "rm -f ${REMOTE_DEST}/ghostbuster-*.qmd"
echo "      Extensions removed!"

echo "[3/3] Restarting xochitl..."
ssh "${SSH_TARGET}" "/home/root/xovi/start"
echo "      xochitl restarted!"

echo ""
echo "GhostBuster has been successfully uninstalled."
