#!/bin/sh
set -e

REPO="DiscreteTom/dtx"
INSTALL_DIR="${DTX_INSTALL_DIR:-$HOME/.local/bin}"

detect_platform() {
    OS=$(uname -s | tr '[:upper:]' '[:lower:]')
    ARCH=$(uname -m)
    LIBC=""
    
    case "$ARCH" in
        x86_64|amd64) ARCH="x86_64" ;;
        aarch64|arm64) ARCH="aarch64" ;;
        *) echo "Unsupported architecture: $ARCH"; exit 1 ;;
    esac
    
    case "$OS" in
        linux)
            OS="linux"
            # Check if glibc version is too old or not available
            if command -v ldd >/dev/null 2>&1; then
                GLIBC_VERSION=$(ldd --version 2>&1 | head -n1 | grep -oE '[0-9]+\.[0-9]+' | head -n1)
                GLIBC_MAJOR=$(echo "$GLIBC_VERSION" | cut -d. -f1)
                GLIBC_MINOR=$(echo "$GLIBC_VERSION" | cut -d. -f2)
                # Require glibc 2.38 or higher
                if [ "$GLIBC_MAJOR" -lt 2 ] || { [ "$GLIBC_MAJOR" -eq 2 ] && [ "$GLIBC_MINOR" -lt 38 ]; }; then
                    LIBC="-musl"
                fi
            else
                LIBC="-musl"
            fi
            ;;
        darwin) OS="macos" ;;
        *) echo "Unsupported OS: $OS"; exit 1 ;;
    esac
}

get_latest_release() {
    curl -sL "https://api.github.com/repos/$REPO/releases/latest" | grep '"tag_name"' | cut -d'"' -f4
}

main() {
    detect_platform
    VERSION="${DTX_VERSION:-$(get_latest_release)}"
    
    ARCHIVE="dtx-${OS}-${ARCH}${LIBC}.tar.gz"
    URL="https://github.com/$REPO/releases/download/$VERSION/$ARCHIVE"
    
    echo "Installing dtx $VERSION for $OS-$ARCH$LIBC..."
    
    mkdir -p "$INSTALL_DIR"
    curl -LsSf "$URL" | tar xz -C "$INSTALL_DIR"
    chmod +x "$INSTALL_DIR/dtx"
    
    echo "dtx installed to $INSTALL_DIR/dtx"
    
    case ":$PATH:" in
        *":$INSTALL_DIR:"*) ;;
        *) echo "\nAdd to PATH: export PATH=\"\$PATH:$INSTALL_DIR\"" ;;
    esac
}

main
