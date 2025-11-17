mod cache;
mod executor;
mod utils;

use clap::Parser;

#[derive(Parser)]
#[command(name = "dtx")]
#[command(about = "Direct tool executor")]
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
    /// Arguments to pass to the executed binary
    #[arg(last = true)]
    app_args: Vec<String>,
}

fn main() -> Result<(), Box<dyn std::error::Error>> {
    env_logger::init();
    let args = Args::parse();

    let binary_name = if let Some(name) = args.name.as_deref() {
        name
    } else if let Some(entry) = args.entry.as_deref() {
        utils::extract_binary_name_from_path(entry)
    } else {
        utils::extract_binary_name_from_url(&args.url)
    };

    let binary_path = cache::get_binary_path(&args.url, binary_name, args.entry.as_deref())?;

    cache::ensure_binary(&args.url, &binary_path, args.force)?;

    let exit_code = executor::execute_binary(&binary_path, &args.app_args)?;
    std::process::exit(exit_code);
}
