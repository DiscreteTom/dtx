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

Usage: dtx [OPTIONS] [URL] [-- <APP_ARGS>...]

Arguments:
  [URL]          URL to the binary to download and execute
  [APP_ARGS]...  Arguments to pass to the executed binary

Options:
  -n, --name <NAME>              Custom name for the binary (defaults to filename from URL)
  -e, --entry <ENTRY>            Entry binary path within archive (for zip/tar.gz files)
  -f, --force                    Force refresh cache, re-download even if cached
      --cache-dir <CACHE_DIR>    Cache directory path [env: DTX_CACHE_DIR=] [default: ~/.dtx/cache]
      --linux-url <LINUX_URL>    URL for Linux platform
      --macos-url <MACOS_URL>    URL for macOS platform
      --windows-url <WINDOWS_URL>
                                 URL for Windows platform
      --linux-name <LINUX_NAME>  Custom name for Linux binary
      --macos-name <MACOS_NAME>  Custom name for macOS binary
      --windows-name <WINDOWS_NAME>
                                 Custom name for Windows binary
      --linux-entry <LINUX_ENTRY>
                                 Entry binary path for Linux archives
      --macos-entry <MACOS_ENTRY>
                                 Entry binary path for macOS archives
      --windows-entry <WINDOWS_ENTRY>
                                 Entry binary path for Windows archives
      --linux-args <LINUX_ARGS>  Platform-specific arguments for Linux (comma-separated)
      --macos-args <MACOS_ARGS>  Platform-specific arguments for macOS (comma-separated)
      --windows-args <WINDOWS_ARGS>
                                 Platform-specific arguments for Windows (comma-separated)
  -h, --help                     Print help
  -V, --version                  Print version
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

## Multi-platform Support

The multi-platform feature allows you to specify different binaries for different operating systems in a single command. This is useful when you need to support multiple platforms with platform-specific binaries.

### Platform-specific URLs

Specify different download URLs for each platform:

```bash
dtx --linux-url https://example.com/tool-linux \
    --macos-url https://example.com/tool-macos \
    --windows-url https://example.com/tool-windows \
    -- --help
```

The tool will automatically select the appropriate URL based on the current platform.

### Platform-specific Configuration

You can also specify platform-specific names, entry points, and arguments:

```bash
dtx --linux-url https://example.com/tool-linux.tar.gz \
    --linux-entry bin/tool \
    --windows-url https://example.com/tool-windows.zip \
    --windows-entry tool.exe \
    -- --version
```

### Platform-specific Arguments

Use platform-specific arguments when different platforms require different parameters:

```bash
dtx https://example.com/tool \
    --linux-args "--config,/etc/tool.conf" \
    --windows-args "--config,C:\tool.conf" \
    -- --verbose
```

Note: Platform-specific arguments use comma-separated values and are prepended to the common arguments passed after `--`.

### Fallback Behavior

Platform-specific options take precedence over generic options. If no platform-specific option is provided, the tool falls back to the generic option:

```bash
# Uses linux-url on Linux, falls back to url on macOS/Windows
dtx https://example.com/tool \
    --linux-url https://example.com/tool-linux
```

## Cache

By default, binaries are cached in `~/.dtx/cache/<name>/<url-hash>/` to avoid re-downloading.

Set the `DTX_CACHE_DIR` environment variable to use a custom cache location:

```bash
export DTX_CACHE_DIR=/tmp/.dtx/cache
```

## [CHANGELOG](./CHANGELOG.md)
