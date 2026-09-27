#!/bin/bash
set -eu
cd "$(dirname "$0")/.."
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
cat > "$tmp/ssh" <<'SH'
#!/bin/sh
case "$*" in *os-release*) printf '%s' "$TEST_FIRMWARE";; esac
SH
cat > "$tmp/scp" <<'SH'
#!/bin/sh
touch "$TEST_SCP_MARKER"
SH
chmod +x "$tmp/ssh" "$tmp/scp"
export PATH="$tmp:$PATH" TEST_SCP_MARKER="$tmp/copied"
for TEST_FIRMWARE in 3.28.0.169 3.29.0.148; do
    export TEST_FIRMWARE
    ./install.sh -y > "$tmp/result"
    grep -q "Firmware: $TEST_FIRMWARE" "$tmp/result"
    grep -q 'Deployed 2 module(s)' "$tmp/result"
    test -f "$TEST_SCP_MARKER"
    rm "$TEST_SCP_MARKER"
done
export TEST_FIRMWARE=3.30.0.0
if ./install.sh -y > "$tmp/result"; then exit 1; fi
grep -q 'not supported' "$tmp/result"
test ! -e "$TEST_SCP_MARKER"
echo 'Installer firmware selection: OK'
