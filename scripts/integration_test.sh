#!/bin/bash
set -e

TEMP_CACHE="/tmp/dtx_test_cache"
export DTX_CACHE_DIR="$TEMP_CACHE"

echo "Using temp cache dir: $TEMP_CACHE"

echo "Testing archive download with entry..."
cargo run -- https://github.com/BurntSushi/ripgrep/releases/download/15.1.0/ripgrep-15.1.0-x86_64-unknown-linux-musl.tar.gz -e ripgrep-15.1.0-x86_64-unknown-linux-musl/rg -- --version
echo "Cache contents:"
find "$TEMP_CACHE" -type f 2>/dev/null || echo "No files found"
rm -rf "$TEMP_CACHE"

echo "All integration tests passed!"
