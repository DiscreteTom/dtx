mod cache;
mod executor;
mod utils;
mod cli;

use cli::{parse, resolve_for_current_platform, expand_cache_dir, Resolved};

fn main() -> Result<(), Box<dyn std::error::Error>> {
    env_logger::init();
    let args = parse();
    let cache_dir = expand_cache_dir(args.cache_dir.clone());

    let Resolved { url, name, entry, app_args } = resolve_for_current_platform(&args)?;

    let (binary_path, base_dir, entry_path) = cache::get_binary_path(&url, &name, entry.as_deref(), &cache_dir)?;

    cache::ensure_binary(&url, &binary_path, &base_dir, entry_path, args.force)?;

    let exit_code = executor::execute_binary(&binary_path, &app_args)?;
    std::process::exit(exit_code);
}
