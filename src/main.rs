mod cache;
mod executor;
mod utils;

use clap::Parser;
use std::path::PathBuf;

#[derive(Parser)]
#[command(name = "dtx")]
#[command(about = "Direct tool executor")]
#[command(version)]
struct Args {
    /// URL to the binary to download and execute
    url: String,
    /// Custom name for the binary (defaults to filename from URL)
    #[arg(short, long)]
    name: Option<String>,
    /// Entry binary path within archive (for zip/tar.gz files)
    #[arg(short, long)]
    entry: Option<String>,
    /// Force refresh cache, re-download even if cached
    #[arg(short, long)]
    force: bool,
    /// Cache directory path
    #[arg(long, env = "DTX_CACHE_DIR", default_value = "~/.dtx/cache")]
    cache_dir: PathBuf,
    /// Arguments to pass to the executed binary
    #[arg(last = true)]
    app_args: Vec<String>,
}

fn main() -> Result<(), Box<dyn std::error::Error>> {
    env_logger::init();
    let args = Args::parse();

    let cache_dir = if args.cache_dir.starts_with("~") {
        if let Some(home) = dirs::home_dir() {
            home.join(args.cache_dir.strip_prefix("~/").unwrap_or(args.cache_dir.as_path()))
        } else {
            args.cache_dir
        }
    } else {
        args.cache_dir
    };

    let binary_name = if let Some(name) = args.name.as_deref() {
        name
    } else if let Some(entry) = args.entry.as_deref() {
        utils::extract_binary_name_from_path(entry)
    } else {
        utils::extract_binary_name_from_url(&args.url)
    };

    let (binary_path, base_dir, entry_path) = cache::get_binary_path(&args.url, binary_name, args.entry.as_deref(), &cache_dir)?;

    cache::ensure_binary(&args.url, &binary_path, &base_dir, entry_path, args.force)?;

    let exit_code = executor::execute_binary(&binary_path, &args.app_args)?;
    std::process::exit(exit_code);
}
