#!/bin/bash
set -e

# ANSI Color codes
BOLD="\033[1m"
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
CYAN="\033[0;36m"
DIM="\033[2m"
RESET="\033[0m"

TARGET_IP="10.11.99.1"
AUTO_YES=false

# Parse arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        -y|--yes)
            AUTO_YES=true
            shift
            ;;
        *)
            TARGET_IP="$1"
            shift
            ;;
    esac
done

TARGET_USER="root"
SSH_TARGET="${TARGET_USER}@${TARGET_IP}"
REMOTE_DEST="/home/root/xovi/exthome/qt-resource-rebuilder"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="${SCRIPT_DIR}/dist/3.28.0.169"

echo -e "${BOLD}${CYAN}======================================================${RESET}"
echo -e "${BOLD}${CYAN}   reMarkable Paper Pro - GhostBuster Installer       ${RESET}"
echo -e "${BOLD}${CYAN}======================================================${RESET}"
echo -e "Target device: ${BOLD}${SSH_TARGET}${RESET}"
echo ""

# Check SSH connection
echo -e "${BOLD}[1/4] Checking connection to reMarkable tablet...${RESET}"
if ! ssh -n -o ConnectTimeout=5 -o BatchMode=yes "${SSH_TARGET}" "true" 2>/dev/null; then
    echo -e "${YELLOW}ERROR: Unable to connect to ${SSH_TARGET} via SSH.${RESET}"
    echo "Please ensure your tablet is connected via USB or Wi-Fi and SSH keys are setup."
    echo "Usage: ./install.sh [device-ip] [-y|--yes]"
    exit 1
fi
echo -e "      ${GREEN}Connected successfully!${RESET}"

# Check if qt-resource-rebuilder directory exists
echo -e "${BOLD}[2/4] Verifying XOVI / qt-resource-rebuilder setup...${RESET}"
if ! ssh -n "${SSH_TARGET}" "[ -d ${REMOTE_DEST} ]"; then
    echo -e "${YELLOW}ERROR: ${REMOTE_DEST} does not exist on the device.${RESET}"
    echo "Please make sure XOVI and qt-resource-rebuilder are installed first."
    echo "See README.md for prerequisites."
    exit 1
fi
echo -e "      ${GREEN}qt-resource-rebuilder directory found!${RESET}"
echo ""

# Module Selection
echo -e "${BOLD}[3/4] Module Configuration${RESET}"
echo -e "${DIM}GhostBuster is modular. Most users only need the Page and Settings"
echo -e "modules to completely eliminate ghosting in daily use.${RESET}"
echo ""

INSTALL_PAGE=true
INSTALL_SETTINGS=true
INSTALL_ERASER=false
INSTALL_GLOBAL=false

if [ "$AUTO_YES" = true ]; then
    echo "Auto-mode: Installing recommended defaults (Page + Settings)."
else
    # 1. Page module
    echo -e "${BOLD}1. Page Turns & Navigation Auto-Clear${RESET}"
    echo -e "   Waits until views finish rendering before refreshing on page turns,"
    echo -e "   hyperlink jumps, and library folder navigation."
    echo -e "   ${GREEN}(Recommended)${RESET}"
    read -rp "   Install Page Turn module? [Y/n]: " ans_page
    if [[ "$ans_page" =~ ^[Nn]$ ]]; then
        INSTALL_PAGE=false
    fi
    echo ""

    # 2. Settings module
    echo -e "${BOLD}2. Settings Menu Auto-Clear${RESET}"
    echo -e "   Debounces the refresh by 400ms when opening and closing device"
    echo -e "   Settings and document settings (PDF/notebook/ebook)."
    echo -e "   ${GREEN}(Recommended)${RESET}"
    read -rp "   Install Settings module? [Y/n]: " ans_settings
    if [[ "$ans_settings" =~ ^[Nn]$ ]]; then
        INSTALL_SETTINGS=false
    fi
    echo ""

    # 3. Eraser module
    echo -e "${BOLD}3. Stylus Eraser Auto-Clear${RESET}"
    echo -e "   Triggers a full hardware refresh ~400ms after lifting the eraser."
    echo -e "   Usually unnecessary for light note-taking, but recommended if you"
    echo -e "   notice persistent green/black ghosting when erasing strokes."
    echo -e "   ${DIM}(Optional - default disabled)${RESET}"
    read -rp "   Install Stylus Eraser module? [y/N]: " ans_eraser
    if [[ "$ans_eraser" =~ ^[Yy]$ ]]; then
        INSTALL_ERASER=true
    fi
    echo ""

    # 4. Global 5-finger gesture
    echo -e "${BOLD}4. System-Wide 5-Finger Force Clear Gesture${RESET}"
    echo -e "   Enables a 5-finger screen tap gesture anywhere (Library, Documents,"
    echo -e "   Settings) for an immediate full hardware clear without breaking touch."
    echo -e "   Not usually needed with auto-clears, but great as an on-demand fallback."
    echo -e "   ${DIM}(Optional - default disabled)${RESET}"
    read -rp "   Install 5-Finger Gesture module? [y/N]: " ans_global
    if [[ "$ans_global" =~ ^[Yy]$ ]]; then
        INSTALL_GLOBAL=true
    fi
    echo ""
fi

# Prepare files to copy
TEMP_DEPLOY="$(mktemp -d)"
trap 'rm -rf "${TEMP_DEPLOY}"' EXIT

SELECTED_COUNT=0

if [ "$INSTALL_PAGE" = true ]; then
    cp "${DIST_DIR}/ghostbuster-page.qmd" "${TEMP_DEPLOY}/"
    SELECTED_COUNT=$((SELECTED_COUNT + 1))
fi

if [ "$INSTALL_SETTINGS" = true ]; then
    cp "${DIST_DIR}/ghostbuster-settings.qmd" "${TEMP_DEPLOY}/"
    SELECTED_COUNT=$((SELECTED_COUNT + 1))
fi

if [ "$INSTALL_ERASER" = true ]; then
    cp "${DIST_DIR}/ghostbuster-eraser.qmd" "${TEMP_DEPLOY}/"
    SELECTED_COUNT=$((SELECTED_COUNT + 1))
fi

if [ "$INSTALL_GLOBAL" = true ]; then
    cp "${DIST_DIR}/ghostbuster-global.qmd" "${TEMP_DEPLOY}/"
    SELECTED_COUNT=$((SELECTED_COUNT + 1))
fi

# Clean up previous GhostBuster extensions on device so unselected modules are removed
ssh -n "${SSH_TARGET}" "rm -f ${REMOTE_DEST}/ghostbuster-*.qmd"

if [ "$SELECTED_COUNT" -gt 0 ]; then
    scp "${TEMP_DEPLOY}"/*.qmd "${SSH_TARGET}:${REMOTE_DEST}/"
    echo -e "      ${GREEN}Deployed ${SELECTED_COUNT} module(s) successfully!${RESET}"
else
    echo -e "      ${YELLOW}No modules selected. All GhostBuster extensions removed.${RESET}"
fi

# Restart xochitl
echo -e "${BOLD}[4/4] Restarting xochitl...${RESET}"
ssh -n "${SSH_TARGET}" "/home/root/xovi/start"
echo -e "      ${GREEN}xochitl restarted!${RESET}"

echo ""
echo -e "${BOLD}${CYAN}======================================================${RESET}"
echo -e "${BOLD}${GREEN}  Installation Complete! 🎉${RESET}"
echo -e "${BOLD}${CYAN}======================================================${RESET}"
echo "Active configuration:"
[ "$INSTALL_PAGE" = true ]     && echo -e "  ${GREEN}✔${RESET} Page Turns & Folder Navigation"
[ "$INSTALL_SETTINGS" = true ] && echo -e "  ${GREEN}✔${RESET} Device & Document Settings Open & Close"
[ "$INSTALL_ERASER" = true ]   && echo -e "  ${GREEN}✔${RESET} Stylus Eraser Auto-Clear"
[ "$INSTALL_GLOBAL" = true ]   && echo -e "  ${GREEN}✔${RESET} 5-Finger Force Clear Gesture"
[ "$SELECTED_COUNT" -eq 0 ]    && echo -e "  ${YELLOW}(All modules disabled / stock behavior)${RESET}"
echo -e "${BOLD}${CYAN}======================================================${RESET}"
