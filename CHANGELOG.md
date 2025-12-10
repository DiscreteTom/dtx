# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Platform-specific URL options: `--linux-url`, `--macos-url`, `--windows-url`
- Platform-specific name options: `--linux-name`, `--macos-name`, `--windows-name`
- Platform-specific entry point options: `--linux-entry`, `--macos-entry`, `--windows-entry`
- Platform-specific argument options: `--linux-args`, `--macos-args`, `--windows-args`
- CLI definition and parsing logic modularization to `src/cli.rs`
- `Resolved` structure to simplify return values
- Maintained dtx syntax compatibility with original format
- Complete CLI parsing tests

## [0.1.1] - 2025-11-19

### Added
- `--version` flag to display version information

## [0.1.0] - 2025-11-19

### Added
- Cross-platform universal tool runner for Linux, macOS, and Windows
- Binary download and caching from URLs
- Archive support (ZIP and TAR.GZ)
- Custom binary naming with `--name` flag
- Entry point specification for archives with `--entry` flag
- Force refresh with `--force` flag
- Custom cache directory via `--cache-dir` or `DTX_CACHE_DIR` environment variable
- Installation script for Linux/macOS

[Unreleased]: https://github.com/DiscreteTom/dtx/compare/v0.1.1...HEAD
[0.1.1]: https://github.com/DiscreteTom/dtx/compare/v0.1.0...v0.1.1
[0.1.0]: https://github.com/DiscreteTom/dtx/releases/tag/v0.1.0
