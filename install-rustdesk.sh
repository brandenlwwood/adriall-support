#!/bin/bash
# ============================================================
# Adriall Remote Support — RustDesk Installer for Linux
# Usage: curl -fsSL <url>/install-rustdesk.sh | sudo bash
# ============================================================

set -e

VERSION="1.4.1"
SERVER="minewood.redirectme.net"
KEY="6PgU7uQGTcmBvA86IlJ1QNuDve4ILtFq0iu4pbiQ3hY="

echo ""
echo "========================================"
echo "  Adriall Remote Support Setup"
echo "========================================"
echo ""

# Check root
if [ "$EUID" -ne 0 ]; then
    echo "Please run as root: sudo bash $0"
    exit 1
fi

# Detect architecture
ARCH=$(uname -m)
case "$ARCH" in
    x86_64)  DEB_ARCH="x86_64" ;;
    aarch64) DEB_ARCH="aarch64" ;;
    armv7l)  DEB_ARCH="armv7" ;;
    *)
        echo "Unsupported architecture: $ARCH"
        exit 1
        ;;
esac

# Generate random password
PASSWORD=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | head -c 8)

# Step 1: Download
echo "[1/4] Downloading RustDesk v${VERSION} for ${ARCH}..."
cd /tmp
wget -q "https://github.com/rustdesk/rustdesk/releases/download/${VERSION}/rustdesk-${VERSION}-${DEB_ARCH}.deb" -O rustdesk.deb
echo "       Downloaded."

# Step 2: Install
echo "[2/4] Installing RustDesk..."
DEBIAN_FRONTEND=noninteractive apt-get install -y ./rustdesk.deb > /dev/null 2>&1
echo "       Installed."

# Step 3: Configure
echo "[3/4] Configuring for Adriall remote support..."
systemctl stop rustdesk 2>/dev/null || true
sleep 1

# Find the actual user (not root if using sudo)
REAL_USER="${SUDO_USER:-$USER}"
REAL_HOME=$(eval echo ~$REAL_USER)

# Write config for both user and root
for CFG_DIR in "$REAL_HOME/.config/rustdesk" "/root/.config/rustdesk"; do
    mkdir -p "$CFG_DIR"
    cat > "$CFG_DIR/RustDesk2.toml" << TOML
rendezvous_server = '${SERVER}:21116'
nat_type = 1
serial = 0
unlock_pin = ''

[options]
custom-rendezvous-server = '${SERVER}'
relay-server = '${SERVER}'
api-server = 'http://${SERVER}:21116'
key = '${KEY}'
TOML
    chown -R $REAL_USER:$(id -gn $REAL_USER) "$CFG_DIR" 2>/dev/null || true
done

# Set permanent password
rustdesk --password "$PASSWORD" 2>/dev/null || true

# Step 4: Start service
echo "[4/4] Starting RustDesk..."
systemctl enable rustdesk > /dev/null 2>&1
systemctl restart rustdesk
sleep 3

# Get ID
RUSTDESK_ID=$(rustdesk --get-id 2>/dev/null || echo "unknown")

# Clean up
rm -f /tmp/rustdesk.deb

echo ""
echo "========================================"
echo "  Setup Complete!"
echo "========================================"
echo ""
echo "  Your Remote Support ID:  $RUSTDESK_ID"
echo "  Your Password:           $PASSWORD"
echo ""
echo "  Please share these with your Adriall"
echo "  support technician so they can connect."
echo ""
echo "========================================"
echo ""
