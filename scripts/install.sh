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
            if ! command -v gcc >/dev/null 2>&1; then
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
    
    echo "Installing dtx $VERSION for $OS-$ARCH..."
    
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
