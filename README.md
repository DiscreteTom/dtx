# dtx - Direct Tool Executor

A cross-platform universal tool runner that downloads and caches binaries from URLs, similar to `npx` but for any binary application. Works on Linux, macOS, and Windows.

## Installation

```bash
cargo install --path .
```

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
  -n, --name <NAME>    Custom name for the binary (defaults to filename from URL)
  -e, --entry <ENTRY>  Entry binary path within archive (for zip/tar.gz files)
  -f, --force          Force refresh cache, re-download even if cached
  -h, --help           Print help
```

</details>

### Basic Examples

Run a binary directly from URL:

```bash
dtx https://github.com/user/repo/releases/download/v1.0.0/tool -- --help
```

Custom binary name:

```bash
dtx -n mytool https://example.com/binary -- --version
```

Force refresh cache:

```bash
dtx -f https://example.com/tool -- --config config.json
```

### Archive Support

For ZIP files:

```bash
dtx https://example.com/app.zip --entry bin/app -- --help
```

For TAR.GZ files:

```bash
dtx https://example.com/tool.tar.gz --entry tool/bin/tool -- --version
```

## Cache

Binaries are cached in `~/.dtx/cache/<name>/<url-hash>/` to avoid re-downloading.
