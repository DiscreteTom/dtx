#!/bin/bash
set -e

TEMP_CACHE="/tmp/dtx_test_cache"
export DTX_CACHE_DIR="$TEMP_CACHE"

rm -rf "$TEMP_CACHE"
echo "Using temp cache dir: $TEMP_CACHE"

echo "Testing direct binary download..."
OUTPUT=$(cargo run -- https://github.com/DiscreteTom/dtx-test-fixture/releases/download/v0.1.1/dtx-test-fixture-linux-x86_64 -- --version 2>&1)
echo "$OUTPUT" | grep -q "dtx-test-fixture 0.1.1" || { echo "ERROR: Version output incorrect"; exit 1; }
echo "Checking cache..."
test -f "$TEMP_CACHE/dtx-test-fixture-linux-x86_64/2c5f1687/dtx-test-fixture-linux-x86_64" || { echo "ERROR: Binary not found in cache"; exit 1; }
test -x "$TEMP_CACHE/dtx-test-fixture-linux-x86_64/2c5f1687/dtx-test-fixture-linux-x86_64" || { echo "ERROR: Binary not executable"; exit 1; }
echo "✓ Test passed"
echo ""

echo "Testing zip archive..."
OUTPUT=$(cargo run -- https://github.com/DiscreteTom/dtx-test-fixture/releases/download/v0.1.1/dtx-test-fixture-linux-x86_64.zip -e dtx-test-fixture-linux-x86_64 -- --version 2>&1)
echo "$OUTPUT" | grep -q "dtx-test-fixture 0.1.1" || { echo "ERROR: Version output incorrect"; exit 1; }
echo "Checking cache..."
test -f "$TEMP_CACHE/dtx-test-fixture-linux-x86_64/75ed4879/dtx-test-fixture-linux-x86_64" || { echo "ERROR: Binary not found in cache"; exit 1; }
test -x "$TEMP_CACHE/dtx-test-fixture-linux-x86_64/75ed4879/dtx-test-fixture-linux-x86_64" || { echo "ERROR: Binary not executable"; exit 1; }
test ! -f "$TEMP_CACHE/dtx-test-fixture-linux-x86_64/75ed4879/dtx-test-fixture-linux-x86_64.zip" || { echo "ERROR: Archive file should not be in cache"; exit 1; }
echo "✓ Test passed"
echo ""

echo "Testing tar.gz archive..."
OUTPUT=$(cargo run -- https://github.com/DiscreteTom/dtx-test-fixture/releases/download/v0.1.1/dtx-test-fixture-linux-x86_64.tar.gz -e dtx-test-fixture-linux-x86_64 -- --version 2>&1)
echo "$OUTPUT" | grep -q "dtx-test-fixture 0.1.1" || { echo "ERROR: Version output incorrect"; exit 1; }
echo "Checking cache..."
test -f "$TEMP_CACHE/dtx-test-fixture-linux-x86_64/f5a74e81/dtx-test-fixture-linux-x86_64" || { echo "ERROR: Binary not found in cache"; exit 1; }
test -x "$TEMP_CACHE/dtx-test-fixture-linux-x86_64/f5a74e81/dtx-test-fixture-linux-x86_64" || { echo "ERROR: Binary not executable"; exit 1; }
test ! -f "$TEMP_CACHE/dtx-test-fixture-linux-x86_64/f5a74e81/dtx-test-fixture-linux-x86_64.tar.gz" || { echo "ERROR: Archive file should not be in cache"; exit 1; }
echo "✓ Test passed"
echo ""

echo "Testing nested zip archive..."
OUTPUT=$(cargo run -- https://github.com/DiscreteTom/dtx-test-fixture/releases/download/v0.1.1/dtx-test-fixture-linux-x86_64-nested.zip -e bin/dtx-test-fixture-linux-x86_64 -- --version 2>&1)
echo "$OUTPUT" | grep -q "dtx-test-fixture 0.1.1" || { echo "ERROR: Version output incorrect"; exit 1; }
echo "Checking cache..."
test -f "$TEMP_CACHE/dtx-test-fixture-linux-x86_64/c8f7e1ac/bin/dtx-test-fixture-linux-x86_64" || { echo "ERROR: Binary not found in cache"; exit 1; }
test -x "$TEMP_CACHE/dtx-test-fixture-linux-x86_64/c8f7e1ac/bin/dtx-test-fixture-linux-x86_64" || { echo "ERROR: Binary not executable"; exit 1; }
test ! -f "$TEMP_CACHE/dtx-test-fixture-linux-x86_64/c8f7e1ac/dtx-test-fixture-linux-x86_64-nested.zip" || { echo "ERROR: Archive file should not be in cache"; exit 1; }
echo "✓ Test passed"
echo ""

echo "Testing nested tar.gz archive..."
OUTPUT=$(cargo run -- https://github.com/DiscreteTom/dtx-test-fixture/releases/download/v0.1.1/dtx-test-fixture-linux-x86_64-nested.tar.gz -e bin/dtx-test-fixture-linux-x86_64 -- --version 2>&1)
echo "$OUTPUT" | grep -q "dtx-test-fixture 0.1.1" || { echo "ERROR: Version output incorrect"; exit 1; }
echo "Checking cache..."
test -f "$TEMP_CACHE/dtx-test-fixture-linux-x86_64/4e9f06d2/bin/dtx-test-fixture-linux-x86_64" || { echo "ERROR: Binary not found in cache"; exit 1; }
test -x "$TEMP_CACHE/dtx-test-fixture-linux-x86_64/4e9f06d2/bin/dtx-test-fixture-linux-x86_64" || { echo "ERROR: Binary not executable"; exit 1; }
test ! -f "$TEMP_CACHE/dtx-test-fixture-linux-x86_64/4e9f06d2/dtx-test-fixture-linux-x86_64-nested.tar.gz" || { echo "ERROR: Archive file should not be in cache"; exit 1; }
echo "✓ Test passed"
echo ""

echo "Testing --name parameter..."
OUTPUT=$(cargo run -- https://github.com/DiscreteTom/dtx-test-fixture/releases/download/v0.1.1/dtx-test-fixture-linux-x86_64 -n my-custom-name -- --version 2>&1)
echo "$OUTPUT" | grep -q "dtx-test-fixture 0.1.1" || { echo "ERROR: Version output incorrect"; exit 1; }
echo "Checking cache..."
test -f "$TEMP_CACHE/my-custom-name/2c5f1687/my-custom-name" || { echo "ERROR: Binary not found with custom name in cache"; exit 1; }
test -x "$TEMP_CACHE/my-custom-name/2c5f1687/my-custom-name" || { echo "ERROR: Binary not executable"; exit 1; }
echo "✓ Test passed"
echo ""

echo "Testing --name parameter with zip..."
OUTPUT=$(cargo run -- https://github.com/DiscreteTom/dtx-test-fixture/releases/download/v0.1.1/dtx-test-fixture-linux-x86_64.zip -n my-zip-name -e dtx-test-fixture-linux-x86_64 -- --version 2>&1)
echo "$OUTPUT" | grep -q "dtx-test-fixture 0.1.1" || { echo "ERROR: Version output incorrect"; exit 1; }
echo "Checking cache..."
test -f "$TEMP_CACHE/my-zip-name/75ed4879/my-zip-name" || { echo "ERROR: Binary not found with custom name in cache"; exit 1; }
test -x "$TEMP_CACHE/my-zip-name/75ed4879/my-zip-name" || { echo "ERROR: Binary not executable"; exit 1; }
test ! -f "$TEMP_CACHE/my-zip-name/75ed4879/dtx-test-fixture-linux-x86_64" || { echo "ERROR: Original entry name should not exist"; exit 1; }
echo "✓ Test passed"
echo ""

echo "Testing --name parameter with tar.gz..."
OUTPUT=$(cargo run -- https://github.com/DiscreteTom/dtx-test-fixture/releases/download/v0.1.1/dtx-test-fixture-linux-x86_64.tar.gz -n my-tar-name -e dtx-test-fixture-linux-x86_64 -- --version 2>&1)
echo "$OUTPUT" | grep -q "dtx-test-fixture 0.1.1" || { echo "ERROR: Version output incorrect"; exit 1; }
echo "Checking cache..."
test -f "$TEMP_CACHE/my-tar-name/f5a74e81/my-tar-name" || { echo "ERROR: Binary not found with custom name in cache"; exit 1; }
test -x "$TEMP_CACHE/my-tar-name/f5a74e81/my-tar-name" || { echo "ERROR: Binary not executable"; exit 1; }
test ! -f "$TEMP_CACHE/my-tar-name/f5a74e81/dtx-test-fixture-linux-x86_64" || { echo "ERROR: Original entry name should not exist"; exit 1; }
echo "✓ Test passed"
echo ""

echo "Testing --name parameter with nested zip..."
OUTPUT=$(cargo run -- https://github.com/DiscreteTom/dtx-test-fixture/releases/download/v0.1.1/dtx-test-fixture-linux-x86_64-nested.zip -n my-nested-zip -e bin/dtx-test-fixture-linux-x86_64 -- --version 2>&1)
echo "$OUTPUT" | grep -q "dtx-test-fixture 0.1.1" || { echo "ERROR: Version output incorrect"; exit 1; }
echo "Checking cache..."
test -f "$TEMP_CACHE/my-nested-zip/c8f7e1ac/bin/my-nested-zip" || { echo "ERROR: Binary not found with custom name in cache"; exit 1; }
test -x "$TEMP_CACHE/my-nested-zip/c8f7e1ac/bin/my-nested-zip" || { echo "ERROR: Binary not executable"; exit 1; }
test ! -f "$TEMP_CACHE/my-nested-zip/c8f7e1ac/bin/dtx-test-fixture-linux-x86_64" || { echo "ERROR: Original entry name should not exist"; exit 1; }
echo "✓ Test passed"
echo ""

echo "Testing --name parameter with nested tar.gz..."
OUTPUT=$(cargo run -- https://github.com/DiscreteTom/dtx-test-fixture/releases/download/v0.1.1/dtx-test-fixture-linux-x86_64-nested.tar.gz -n my-nested-tar -e bin/dtx-test-fixture-linux-x86_64 -- --version 2>&1)
echo "$OUTPUT" | grep -q "dtx-test-fixture 0.1.1" || { echo "ERROR: Version output incorrect"; exit 1; }
echo "Checking cache..."
test -f "$TEMP_CACHE/my-nested-tar/4e9f06d2/bin/my-nested-tar" || { echo "ERROR: Binary not found with custom name in cache"; exit 1; }
test -x "$TEMP_CACHE/my-nested-tar/4e9f06d2/bin/my-nested-tar" || { echo "ERROR: Binary not executable"; exit 1; }
test ! -f "$TEMP_CACHE/my-nested-tar/4e9f06d2/bin/dtx-test-fixture-linux-x86_64" || { echo "ERROR: Original entry name should not exist"; exit 1; }
echo "✓ Test passed"
echo ""

rm -rf "$TEMP_CACHE"

echo "All integration tests passed!"
