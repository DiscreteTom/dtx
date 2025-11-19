# dtx - Direct Tool Executor

[![GitHub Release](https://img.shields.io/github/v/release/DiscreteTom/dtx)](https://github.com/DiscreteTom/dtx/releases)

A cross-platform universal tool runner that downloads and caches binaries from URLs, similar to `npx` but for any binary application. Works on Linux, macOS, and Windows.

## Installation

### Linux

```bash
curl -LsSf https://raw.githubusercontent.com/DiscreteTom/dtx/main/scripts/install.sh | sh
```

### Windows

Download from the [releases page](https://github.com/DiscreteTom/dtx/releases) and put `dtx.exe` in your PATH.

### MacOS

<details>

<summary>Build from source</summary>

```bash
git clone git@github.com:DiscreteTom/dtx.git
cd dtx
cargo build --release
cp target/release/dtx /usr/local/bin/dtx
```

</details>

## Usage

### Full CLI Usage

<details>

<summary><code>dtx --help</code></summary>

```sh
Direct tool executor

Usage: dtx [OPTIONS] <URL> [-- <APP_ARGS>...]

Arguments:
  <URL>          URL to the binary to download and execute
  [APP_ARGS]...  Arguments to pass to the executed binary

Options:
  -n, --name <NAME>            Custom name for the binary (defaults to filename from URL)
  -e, --entry <ENTRY>          Entry binary path within archive (for zip/tar.gz files)
  -f, --force                  Force refresh cache, re-download even if cached
      --cache-dir <CACHE_DIR>  Cache directory path [env: DTX_CACHE_DIR=] [default: ~/.dtx/cache]
  -h, --help                   Print help
```

</details>

### Basic Examples

Run a binary directly from URL:

```bash
dtx https://github.com/user/repo/releases/download/v1.0.0/tool -- --help
```

### Archive Support

For `.zip` files:

```bash
dtx https://example.com/app.zip --entry bin/app -- --help
```

For `.tar.gz` files:

```bash
dtx https://example.com/tool.tar.gz --entry tool/bin/tool -- --version
```

### Use with Binary MCP Servers

```json
{
  "mcpServers": {
    "server": {
      "command": "dtx",
      "args": [
        "https://example.com/mcp.tar.gz",
        "--entry",
        "bin/server",
        "--",
        "params"
      ]
    }
  }
}
```

## Cache

By default, binaries are cached in `~/.dtx/cache/<name>/<url-hash>/` to avoid re-downloading.

Set the `DTX_CACHE_DIR` environment variable to use a custom cache location:

```bash
export DTX_CACHE_DIR=/tmp/.dtx/cache
```

## [CHANGELOG](./CHANGELOG.md)
