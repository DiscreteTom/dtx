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

TEMP_CACHE="/tmp/dtx_test_cache"
export DTX_CACHE_DIR="$TEMP_CACHE"
ARCH="${DTX_ARCH:-x86_64}"

rm -rf "$TEMP_CACHE"
echo "Using temp cache dir: $TEMP_CACHE"

# Determine which binary to use
if [ -n "$DTX_BIN" ]; then
    echo "Using provided DTX_BIN: $DTX_BIN"
else
    VERSION="${DTX_VERSION:-dev}"
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
        curl -L -o dtx "https://github.com/DiscreteTom/dtx/releases/download/$VERSION/dtx-linux-$ARCH"
        chmod +x dtx
        mkdir -p target/debug
        mv dtx target/debug/dtx
        DTX_BIN="./target/debug/dtx"
        echo "Testing with downloaded version: $VERSION ($ARCH)"
    fi
fi

echo "Testing direct binary download..."
OUTPUT=$($DTX_BIN https://github.com/DiscreteTom/dtx-test-fixture/releases/download/v0.1.1/dtx-test-fixture-linux-$ARCH -- --version 2>&1)
echo "$OUTPUT" | grep -q "dtx-test-fixture 0.1.1" || { echo "ERROR: Version output incorrect"; exit 1; }
echo "Checking cache..."
test -f "$TEMP_CACHE/dtx-test-fixture-linux-$ARCH/2c5f1687/dtx-test-fixture-linux-$ARCH" || { echo "ERROR: Binary not found in cache"; exit 1; }
test -x "$TEMP_CACHE/dtx-test-fixture-linux-$ARCH/2c5f1687/dtx-test-fixture-linux-$ARCH" || { echo "ERROR: Binary not executable"; exit 1; }
echo "✓ Test passed"
echo ""

echo "Testing zip archive..."
OUTPUT=$($DTX_BIN https://github.com/DiscreteTom/dtx-test-fixture/releases/download/v0.1.1/dtx-test-fixture-linux-$ARCH.zip -e dtx-test-fixture-linux-$ARCH -- --version 2>&1)
echo "$OUTPUT" | grep -q "dtx-test-fixture 0.1.1" || { echo "ERROR: Version output incorrect"; exit 1; }
echo "Checking cache..."
test -f "$TEMP_CACHE/dtx-test-fixture-linux-$ARCH/75ed4879/dtx-test-fixture-linux-$ARCH" || { echo "ERROR: Binary not found in cache"; exit 1; }
test -x "$TEMP_CACHE/dtx-test-fixture-linux-$ARCH/75ed4879/dtx-test-fixture-linux-$ARCH" || { echo "ERROR: Binary not executable"; exit 1; }
test ! -f "$TEMP_CACHE/dtx-test-fixture-linux-$ARCH/75ed4879/dtx-test-fixture-linux-$ARCH.zip" || { echo "ERROR: Archive file should not be in cache"; exit 1; }
echo "✓ Test passed"
echo ""

echo "Testing tar.gz archive..."
OUTPUT=$($DTX_BIN https://github.com/DiscreteTom/dtx-test-fixture/releases/download/v0.1.1/dtx-test-fixture-linux-$ARCH.tar.gz -e dtx-test-fixture-linux-$ARCH -- --version 2>&1)
echo "$OUTPUT" | grep -q "dtx-test-fixture 0.1.1" || { echo "ERROR: Version output incorrect"; exit 1; }
echo "Checking cache..."
test -f "$TEMP_CACHE/dtx-test-fixture-linux-$ARCH/f5a74e81/dtx-test-fixture-linux-$ARCH" || { echo "ERROR: Binary not found in cache"; exit 1; }
test -x "$TEMP_CACHE/dtx-test-fixture-linux-$ARCH/f5a74e81/dtx-test-fixture-linux-$ARCH" || { echo "ERROR: Binary not executable"; exit 1; }
test ! -f "$TEMP_CACHE/dtx-test-fixture-linux-$ARCH/f5a74e81/dtx-test-fixture-linux-$ARCH.tar.gz" || { echo "ERROR: Archive file should not be in cache"; exit 1; }
echo "✓ Test passed"
echo ""

echo "Testing nested zip archive..."
OUTPUT=$($DTX_BIN https://github.com/DiscreteTom/dtx-test-fixture/releases/download/v0.1.1/dtx-test-fixture-linux-$ARCH-nested.zip -e bin/dtx-test-fixture-linux-$ARCH -- --version 2>&1)
echo "$OUTPUT" | grep -q "dtx-test-fixture 0.1.1" || { echo "ERROR: Version output incorrect"; exit 1; }
echo "Checking cache..."
test -f "$TEMP_CACHE/dtx-test-fixture-linux-$ARCH/c8f7e1ac/bin/dtx-test-fixture-linux-$ARCH" || { echo "ERROR: Binary not found in cache"; exit 1; }
test -x "$TEMP_CACHE/dtx-test-fixture-linux-$ARCH/c8f7e1ac/bin/dtx-test-fixture-linux-$ARCH" || { echo "ERROR: Binary not executable"; exit 1; }
test ! -f "$TEMP_CACHE/dtx-test-fixture-linux-$ARCH/c8f7e1ac/dtx-test-fixture-linux-$ARCH-nested.zip" || { echo "ERROR: Archive file should not be in cache"; exit 1; }
echo "✓ Test passed"
echo ""

echo "Testing nested tar.gz archive..."
OUTPUT=$($DTX_BIN https://github.com/DiscreteTom/dtx-test-fixture/releases/download/v0.1.1/dtx-test-fixture-linux-$ARCH-nested.tar.gz -e bin/dtx-test-fixture-linux-$ARCH -- --version 2>&1)
echo "$OUTPUT" | grep -q "dtx-test-fixture 0.1.1" || { echo "ERROR: Version output incorrect"; exit 1; }
echo "Checking cache..."
test -f "$TEMP_CACHE/dtx-test-fixture-linux-$ARCH/4e9f06d2/bin/dtx-test-fixture-linux-$ARCH" || { echo "ERROR: Binary not found in cache"; exit 1; }
test -x "$TEMP_CACHE/dtx-test-fixture-linux-$ARCH/4e9f06d2/bin/dtx-test-fixture-linux-$ARCH" || { echo "ERROR: Binary not executable"; exit 1; }
test ! -f "$TEMP_CACHE/dtx-test-fixture-linux-$ARCH/4e9f06d2/dtx-test-fixture-linux-$ARCH-nested.tar.gz" || { echo "ERROR: Archive file should not be in cache"; exit 1; }
echo "✓ Test passed"
echo ""

echo "Testing --name parameter..."
OUTPUT=$($DTX_BIN https://github.com/DiscreteTom/dtx-test-fixture/releases/download/v0.1.1/dtx-test-fixture-linux-$ARCH -n my-custom-name -- --version 2>&1)
echo "$OUTPUT" | grep -q "dtx-test-fixture 0.1.1" || { echo "ERROR: Version output incorrect"; exit 1; }
echo "Checking cache..."
test -f "$TEMP_CACHE/my-custom-name/2c5f1687/my-custom-name" || { echo "ERROR: Binary not found with custom name in cache"; exit 1; }
test -x "$TEMP_CACHE/my-custom-name/2c5f1687/my-custom-name" || { echo "ERROR: Binary not executable"; exit 1; }
echo "✓ Test passed"
echo ""

echo "Testing --name parameter with zip..."
OUTPUT=$($DTX_BIN https://github.com/DiscreteTom/dtx-test-fixture/releases/download/v0.1.1/dtx-test-fixture-linux-$ARCH.zip -n my-zip-name -e dtx-test-fixture-linux-$ARCH -- --version 2>&1)
echo "$OUTPUT" | grep -q "dtx-test-fixture 0.1.1" || { echo "ERROR: Version output incorrect"; exit 1; }
echo "Checking cache..."
test -f "$TEMP_CACHE/my-zip-name/75ed4879/my-zip-name" || { echo "ERROR: Binary not found with custom name in cache"; exit 1; }
test -x "$TEMP_CACHE/my-zip-name/75ed4879/my-zip-name" || { echo "ERROR: Binary not executable"; exit 1; }
test ! -f "$TEMP_CACHE/my-zip-name/75ed4879/dtx-test-fixture-linux-$ARCH" || { echo "ERROR: Original entry name should not exist"; exit 1; }
echo "✓ Test passed"
echo ""

echo "Testing --name parameter with tar.gz..."
OUTPUT=$($DTX_BIN https://github.com/DiscreteTom/dtx-test-fixture/releases/download/v0.1.1/dtx-test-fixture-linux-$ARCH.tar.gz -n my-tar-name -e dtx-test-fixture-linux-$ARCH -- --version 2>&1)
echo "$OUTPUT" | grep -q "dtx-test-fixture 0.1.1" || { echo "ERROR: Version output incorrect"; exit 1; }
echo "Checking cache..."
test -f "$TEMP_CACHE/my-tar-name/f5a74e81/my-tar-name" || { echo "ERROR: Binary not found with custom name in cache"; exit 1; }
test -x "$TEMP_CACHE/my-tar-name/f5a74e81/my-tar-name" || { echo "ERROR: Binary not executable"; exit 1; }
test ! -f "$TEMP_CACHE/my-tar-name/f5a74e81/dtx-test-fixture-linux-$ARCH" || { echo "ERROR: Original entry name should not exist"; exit 1; }
echo "✓ Test passed"
echo ""

echo "Testing --name parameter with nested zip..."
OUTPUT=$($DTX_BIN https://github.com/DiscreteTom/dtx-test-fixture/releases/download/v0.1.1/dtx-test-fixture-linux-$ARCH-nested.zip -n my-nested-zip -e bin/dtx-test-fixture-linux-$ARCH -- --version 2>&1)
echo "$OUTPUT" | grep -q "dtx-test-fixture 0.1.1" || { echo "ERROR: Version output incorrect"; exit 1; }
echo "Checking cache..."
test -f "$TEMP_CACHE/my-nested-zip/c8f7e1ac/bin/my-nested-zip" || { echo "ERROR: Binary not found with custom name in cache"; exit 1; }
test -x "$TEMP_CACHE/my-nested-zip/c8f7e1ac/bin/my-nested-zip" || { echo "ERROR: Binary not executable"; exit 1; }
test ! -f "$TEMP_CACHE/my-nested-zip/c8f7e1ac/bin/dtx-test-fixture-linux-$ARCH" || { echo "ERROR: Original entry name should not exist"; exit 1; }
echo "✓ Test passed"
echo ""

echo "Testing --name parameter with nested tar.gz..."
OUTPUT=$($DTX_BIN https://github.com/DiscreteTom/dtx-test-fixture/releases/download/v0.1.1/dtx-test-fixture-linux-$ARCH-nested.tar.gz -n my-nested-tar -e bin/dtx-test-fixture-linux-$ARCH -- --version 2>&1)
echo "$OUTPUT" | grep -q "dtx-test-fixture 0.1.1" || { echo "ERROR: Version output incorrect"; exit 1; }
echo "Checking cache..."
test -f "$TEMP_CACHE/my-nested-tar/4e9f06d2/bin/my-nested-tar" || { echo "ERROR: Binary not found with custom name in cache"; exit 1; }
test -x "$TEMP_CACHE/my-nested-tar/4e9f06d2/bin/my-nested-tar" || { echo "ERROR: Binary not executable"; exit 1; }
test ! -f "$TEMP_CACHE/my-nested-tar/4e9f06d2/bin/dtx-test-fixture-linux-$ARCH" || { echo "ERROR: Original entry name should not exist"; exit 1; }
echo "✓ Test passed"
echo ""

rm -rf "$TEMP_CACHE"

echo "All integration tests passed!"

