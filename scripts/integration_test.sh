#!/bin/bash
# Integration test script for dtx
#
# Usage:
#   bash scripts/integration_test.sh                          # Build and test debug version
#   DTX_VERSION=release bash scripts/integration_test.sh      # Build and test release version
#   DTX_VERSION=v1.0.0 bash scripts/integration_test.sh       # Download and test specific version
#   DTX_BIN=./target/release/dtx bash scripts/integration_test.sh  # Test specific binary
#   DTX_ARCH=aarch64 DTX_VERSION=v1.0.0 bash scripts/integration_test.sh  # Download ARM version

set -e

VERSION="${DTX_VERSION:-dev}"
ARCH="${DTX_ARCH:-x86_64}"

FIXTURE_VERSION="v0.1.2"
TEMP_CACHE="/tmp/dtx_test_cache"
export DTX_CACHE_DIR="$TEMP_CACHE"

# Test fixture URLs
URL_DIRECT="https://github.com/DiscreteTom/dtx-test-fixture/releases/download/$FIXTURE_VERSION/dtx-test-fixture-linux-$ARCH"
URL_ZIP="$URL_DIRECT.zip"
URL_TAR="$URL_DIRECT.tar.gz"
URL_NESTED_ZIP="$URL_DIRECT-nested.zip"
URL_NESTED_TAR="$URL_DIRECT-nested.tar.gz"

# Generate URL hash (first 8 chars of SHA256)
url_hash() {
    echo -n "$1" | sha256sum | cut -c1-8
}

# Pre-calculate hashes
HASH_DIRECT=$(url_hash "$URL_DIRECT")
HASH_ZIP=$(url_hash "$URL_ZIP")
HASH_TAR=$(url_hash "$URL_TAR")
HASH_NESTED_ZIP=$(url_hash "$URL_NESTED_ZIP")
HASH_NESTED_TAR=$(url_hash "$URL_NESTED_TAR")

rm -rf "$TEMP_CACHE"
echo "Using temp cache dir: $TEMP_CACHE"

# Determine which binary to use
if [ -n "$DTX_BIN" ]; then
    echo "Using provided DTX_BIN: $DTX_BIN"
else
    if [ "$VERSION" = "release" ]; then
        echo "Building release version..."
        cargo build --release
        DTX_BIN="./target/release/dtx"
        echo "Testing with release build: $DTX_BIN"
    elif [ "$VERSION" = "dev" ]; then
        echo "Building debug version..."
        cargo build
        DTX_BIN="./target/debug/dtx"
        echo "Testing with debug build: $DTX_BIN"
    else
        echo "Downloading version $VERSION for $ARCH..."
        TARGET="${ARCH}-unknown-linux-musl"
        curl -L -o dtx.tar.gz "https://github.com/DiscreteTom/dtx/releases/download/$VERSION/dtx-$VERSION-$TARGET.tar.gz"
        tar xzf dtx.tar.gz
        chmod +x dtx
        mkdir -p target/debug
        mv dtx target/debug/dtx
        rm dtx.tar.gz
        DTX_BIN="./target/debug/dtx"
        echo "Testing with downloaded version: $VERSION ($TARGET)"
    fi
fi

echo "Testing direct binary download..."
URL=$URL_DIRECT
HASH=$HASH_DIRECT
OUTPUT=$($DTX_BIN $URL -- --version 2>&1)
echo "$OUTPUT" | grep -q "dtx-test-fixture ${FIXTURE_VERSION#v}" || { echo "ERROR: Version output incorrect"; exit 1; }
echo "Checking cache..."
test -f "$TEMP_CACHE/dtx-test-fixture-linux-$ARCH/$HASH/dtx-test-fixture-linux-$ARCH" || { echo "ERROR: Binary not found in cache"; exit 1; }
test -x "$TEMP_CACHE/dtx-test-fixture-linux-$ARCH/$HASH/dtx-test-fixture-linux-$ARCH" || { echo "ERROR: Binary not executable"; exit 1; }
echo "✓ Test passed"
echo ""

echo "Testing zip archive..."
URL=$URL_ZIP
HASH=$HASH_ZIP
OUTPUT=$($DTX_BIN $URL -e dtx-test-fixture-linux-$ARCH -- --version 2>&1)
echo "$OUTPUT" | grep -q "dtx-test-fixture ${FIXTURE_VERSION#v}" || { echo "ERROR: Version output incorrect"; exit 1; }
echo "Checking cache..."
test -f "$TEMP_CACHE/dtx-test-fixture-linux-$ARCH/$HASH/dtx-test-fixture-linux-$ARCH" || { echo "ERROR: Binary not found in cache"; exit 1; }
test -x "$TEMP_CACHE/dtx-test-fixture-linux-$ARCH/$HASH/dtx-test-fixture-linux-$ARCH" || { echo "ERROR: Binary not executable"; exit 1; }
test ! -f "$TEMP_CACHE/dtx-test-fixture-linux-$ARCH/$HASH/dtx-test-fixture-linux-$ARCH.zip" || { echo "ERROR: Archive file should not be in cache"; exit 1; }
echo "✓ Test passed"
echo ""

echo "Testing tar.gz archive..."
URL=$URL_TAR
HASH=$HASH_TAR
OUTPUT=$($DTX_BIN $URL -e dtx-test-fixture-linux-$ARCH -- --version 2>&1)
echo "$OUTPUT" | grep -q "dtx-test-fixture ${FIXTURE_VERSION#v}" || { echo "ERROR: Version output incorrect"; exit 1; }
echo "Checking cache..."
test -f "$TEMP_CACHE/dtx-test-fixture-linux-$ARCH/$HASH/dtx-test-fixture-linux-$ARCH" || { echo "ERROR: Binary not found in cache"; exit 1; }
test -x "$TEMP_CACHE/dtx-test-fixture-linux-$ARCH/$HASH/dtx-test-fixture-linux-$ARCH" || { echo "ERROR: Binary not executable"; exit 1; }
test ! -f "$TEMP_CACHE/dtx-test-fixture-linux-$ARCH/$HASH/dtx-test-fixture-linux-$ARCH.tar.gz" || { echo "ERROR: Archive file should not be in cache"; exit 1; }
echo "✓ Test passed"
echo ""

echo "Testing nested zip archive..."
URL=$URL_NESTED_ZIP
HASH=$HASH_NESTED_ZIP
OUTPUT=$($DTX_BIN $URL -e bin/dtx-test-fixture-linux-$ARCH -- --version 2>&1)
echo "$OUTPUT" | grep -q "dtx-test-fixture ${FIXTURE_VERSION#v}" || { echo "ERROR: Version output incorrect"; exit 1; }
echo "Checking cache..."
test -f "$TEMP_CACHE/dtx-test-fixture-linux-$ARCH/$HASH/bin/dtx-test-fixture-linux-$ARCH" || { echo "ERROR: Binary not found in cache"; exit 1; }
test -x "$TEMP_CACHE/dtx-test-fixture-linux-$ARCH/$HASH/bin/dtx-test-fixture-linux-$ARCH" || { echo "ERROR: Binary not executable"; exit 1; }
test ! -f "$TEMP_CACHE/dtx-test-fixture-linux-$ARCH/$HASH/dtx-test-fixture-linux-$ARCH-nested.zip" || { echo "ERROR: Archive file should not be in cache"; exit 1; }
echo "✓ Test passed"
echo ""

echo "Testing nested tar.gz archive..."
URL=$URL_NESTED_TAR
HASH=$HASH_NESTED_TAR
OUTPUT=$($DTX_BIN $URL -e bin/dtx-test-fixture-linux-$ARCH -- --version 2>&1)
echo "$OUTPUT" | grep -q "dtx-test-fixture ${FIXTURE_VERSION#v}" || { echo "ERROR: Version output incorrect"; exit 1; }
echo "Checking cache..."
test -f "$TEMP_CACHE/dtx-test-fixture-linux-$ARCH/$HASH/bin/dtx-test-fixture-linux-$ARCH" || { echo "ERROR: Binary not found in cache"; exit 1; }
test -x "$TEMP_CACHE/dtx-test-fixture-linux-$ARCH/$HASH/bin/dtx-test-fixture-linux-$ARCH" || { echo "ERROR: Binary not executable"; exit 1; }
test ! -f "$TEMP_CACHE/dtx-test-fixture-linux-$ARCH/$HASH/dtx-test-fixture-linux-$ARCH-nested.tar.gz" || { echo "ERROR: Archive file should not be in cache"; exit 1; }
echo "✓ Test passed"
echo ""

echo "Testing --name parameter..."
URL=$URL_DIRECT
HASH=$HASH_DIRECT
OUTPUT=$($DTX_BIN $URL -n my-custom-name -- --version 2>&1)
echo "$OUTPUT" | grep -q "dtx-test-fixture ${FIXTURE_VERSION#v}" || { echo "ERROR: Version output incorrect"; exit 1; }
echo "Checking cache..."
test -f "$TEMP_CACHE/my-custom-name/$HASH/my-custom-name" || { echo "ERROR: Binary not found with custom name in cache"; exit 1; }
test -x "$TEMP_CACHE/my-custom-name/$HASH/my-custom-name" || { echo "ERROR: Binary not executable"; exit 1; }
echo "✓ Test passed"
echo ""

echo "Testing --name parameter with zip..."
URL=$URL_ZIP
HASH=$HASH_ZIP
OUTPUT=$($DTX_BIN $URL -n my-zip-name -e dtx-test-fixture-linux-$ARCH -- --version 2>&1)
echo "$OUTPUT" | grep -q "dtx-test-fixture ${FIXTURE_VERSION#v}" || { echo "ERROR: Version output incorrect"; exit 1; }
echo "Checking cache..."
test -f "$TEMP_CACHE/my-zip-name/$HASH/my-zip-name" || { echo "ERROR: Binary not found with custom name in cache"; exit 1; }
test -x "$TEMP_CACHE/my-zip-name/$HASH/my-zip-name" || { echo "ERROR: Binary not executable"; exit 1; }
test ! -f "$TEMP_CACHE/my-zip-name/$HASH/dtx-test-fixture-linux-$ARCH" || { echo "ERROR: Original entry name should not exist"; exit 1; }
echo "✓ Test passed"
echo ""

echo "Testing --name parameter with tar.gz..."
URL=$URL_TAR
HASH=$HASH_TAR
OUTPUT=$($DTX_BIN $URL -n my-tar-name -e dtx-test-fixture-linux-$ARCH -- --version 2>&1)
echo "$OUTPUT" | grep -q "dtx-test-fixture ${FIXTURE_VERSION#v}" || { echo "ERROR: Version output incorrect"; exit 1; }
echo "Checking cache..."
test -f "$TEMP_CACHE/my-tar-name/$HASH/my-tar-name" || { echo "ERROR: Binary not found with custom name in cache"; exit 1; }
test -x "$TEMP_CACHE/my-tar-name/$HASH/my-tar-name" || { echo "ERROR: Binary not executable"; exit 1; }
test ! -f "$TEMP_CACHE/my-tar-name/$HASH/dtx-test-fixture-linux-$ARCH" || { echo "ERROR: Original entry name should not exist"; exit 1; }
echo "✓ Test passed"
echo ""

echo "Testing --name parameter with nested zip..."
URL=$URL_NESTED_ZIP
HASH=$HASH_NESTED_ZIP
OUTPUT=$($DTX_BIN $URL -n my-nested-zip -e bin/dtx-test-fixture-linux-$ARCH -- --version 2>&1)
echo "$OUTPUT" | grep -q "dtx-test-fixture ${FIXTURE_VERSION#v}" || { echo "ERROR: Version output incorrect"; exit 1; }
echo "Checking cache..."
test -f "$TEMP_CACHE/my-nested-zip/$HASH/bin/my-nested-zip" || { echo "ERROR: Binary not found with custom name in cache"; exit 1; }
test -x "$TEMP_CACHE/my-nested-zip/$HASH/bin/my-nested-zip" || { echo "ERROR: Binary not executable"; exit 1; }
test ! -f "$TEMP_CACHE/my-nested-zip/$HASH/bin/dtx-test-fixture-linux-$ARCH" || { echo "ERROR: Original entry name should not exist"; exit 1; }
echo "✓ Test passed"
echo ""

echo "Testing --name parameter with nested tar.gz..."
URL=$URL_NESTED_TAR
HASH=$HASH_NESTED_TAR
OUTPUT=$($DTX_BIN $URL -n my-nested-tar -e bin/dtx-test-fixture-linux-$ARCH -- --version 2>&1)
echo "$OUTPUT" | grep -q "dtx-test-fixture ${FIXTURE_VERSION#v}" || { echo "ERROR: Version output incorrect"; exit 1; }
echo "Checking cache..."
test -f "$TEMP_CACHE/my-nested-tar/$HASH/bin/my-nested-tar" || { echo "ERROR: Binary not found with custom name in cache"; exit 1; }
test -x "$TEMP_CACHE/my-nested-tar/$HASH/bin/my-nested-tar" || { echo "ERROR: Binary not executable"; exit 1; }
test ! -f "$TEMP_CACHE/my-nested-tar/$HASH/bin/dtx-test-fixture-linux-$ARCH" || { echo "ERROR: Original entry name should not exist"; exit 1; }
echo "✓ Test passed"
echo ""

rm -rf "$TEMP_CACHE"

echo "All integration tests passed!"

