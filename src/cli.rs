use clap::Parser;
use std::path::PathBuf;

#[derive(Parser, Debug)]
#[command(name = "dtx")]
#[command(about = "Direct tool executor")]
#[command(version)]
pub struct Args {
    #[arg(required_unless_present_any = ["linux_url", "macos_url", "windows_url"])]
    pub url: Option<String>,
    #[arg(short, long)]
    pub name: Option<String>,
    #[arg(short, long)]
    pub entry: Option<String>,
    #[arg(short, long)]
    pub force: bool,
    #[arg(long, env = "DTX_CACHE_DIR", default_value = "~/.dtx/cache")]
    pub cache_dir: PathBuf,
    #[arg(long)]
    pub linux_url: Option<String>,
    #[arg(long)]
    pub macos_url: Option<String>,
    #[arg(long)]
    pub windows_url: Option<String>,
    #[arg(long)]
    pub linux_name: Option<String>,
    #[arg(long)]
    pub macos_name: Option<String>,
    #[arg(long)]
    pub windows_name: Option<String>,
    #[arg(long)]
    pub linux_entry: Option<String>,
    #[arg(long)]
    pub macos_entry: Option<String>,
    #[arg(long)]
    pub windows_entry: Option<String>,
    #[arg(long, value_delimiter = ',')]
    pub linux_args: Vec<String>,
    #[arg(long, value_delimiter = ',')]
    pub macos_args: Vec<String>,
    #[arg(long, value_delimiter = ',')]
    pub windows_args: Vec<String>,
    #[arg(last = true)]
    pub app_args: Vec<String>,
}

#[derive(Clone, Copy)]
enum Platform {
    Linux,
    Macos,
    Windows,
}

fn current_platform() -> Platform {
    if cfg!(target_os = "windows") {
        Platform::Windows
    } else if cfg!(target_os = "macos") {
        Platform::Macos
    } else {
        Platform::Linux
    }
}

pub struct Resolved {
    pub url: String,
    pub name: String,
    pub entry: Option<String>,
    pub app_args: Vec<String>,
}

fn resolve_effective(args: &Args, platform: Platform) -> Result<Resolved, Box<dyn std::error::Error>> {
    let url = match platform {
        Platform::Linux => args.linux_url.clone().or_else(|| args.url.clone()),
        Platform::Macos => args.macos_url.clone().or_else(|| args.url.clone()),
        Platform::Windows => args.windows_url.clone().or_else(|| args.url.clone()),
    }.ok_or("Missing URL for current platform")?;

    let platform_name = match platform {
        Platform::Linux => args.linux_name.as_deref(),
        Platform::Macos => args.macos_name.as_deref(),
        Platform::Windows => args.windows_name.as_deref(),
    };

    let platform_entry = match platform {
        Platform::Linux => args.linux_entry.as_deref(),
        Platform::Macos => args.macos_entry.as_deref(),
        Platform::Windows => args.windows_entry.as_deref(),
    };

    let name = if let Some(n) = platform_name {
        n.to_string()
    } else if let Some(n) = args.name.as_deref() {
        n.to_string()
    } else if let Some(e) = platform_entry {
        crate::utils::extract_binary_name_from_path(e).to_string()
    } else if let Some(e) = args.entry.as_deref() {
        crate::utils::extract_binary_name_from_path(e).to_string()
    } else {
        crate::utils::extract_binary_name_from_url(&url).to_string()
    };

    let entry = if let Some(e) = platform_entry {
        Some(e.to_string())
    } else {
        args.entry.clone()
    };

    let mut effective_args = match platform {
        Platform::Linux => args.linux_args.clone(),
        Platform::Macos => args.macos_args.clone(),
        Platform::Windows => args.windows_args.clone(),
    };
    effective_args.extend(args.app_args.clone());

    Ok(Resolved { url, name, entry, app_args: effective_args })
}

pub fn parse() -> Args {
    Args::parse()
}

pub fn resolve_for_current_platform(args: &Args) -> Result<Resolved, Box<dyn std::error::Error>> {
    let platform = current_platform();
    resolve_effective(args, platform)
}

pub fn expand_cache_dir(p: PathBuf) -> PathBuf {
    if p.starts_with("~") {
        if let Some(home) = dirs::home_dir() {
            home.join(p.strip_prefix("~/").unwrap_or(p.as_path()))
        } else {
            p
        }
    } else {
        p
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn parse_linux_precedence() {
        let args = Args::parse_from([
            "dtx",
            "--linux-url",
            "https://example.com/linux",
            "--linux-name",
            "ln",
            "--linux-args",
            "a",
            "--",
            "b",
        ]);
        let r = resolve_effective(&args, Platform::Linux).unwrap();
        assert_eq!(r.url, "https://example.com/linux");
        assert_eq!(r.name, "ln");
        assert!(r.entry.is_none());
        assert_eq!(r.app_args, vec!["a", "b"]);
    }

    #[test]
    fn parse_windows_entry_and_args() {
        let args = Args::parse_from([
            "dtx",
            "--windows-entry",
            "win/app.exe",
            "--windows-args",
            "x",
            "https://example.com/app.zip",
            "--",
            "y",
        ]);
        let r = resolve_effective(&args, Platform::Windows).unwrap();
        assert_eq!(r.url, "https://example.com/app.zip");
        assert_eq!(r.name, "app.exe");
        assert_eq!(r.entry, Some("win/app.exe".to_string()));
        assert_eq!(r.app_args, vec!["x", "y"]);
    }

    #[test]
    fn parse_positional_only_with_app_args() {
        let args = Args::parse_from([
            "dtx",
            "https://example.com/tool",
            "--",
            "--foo",
            "bar",
        ]);
        let r = resolve_effective(&args, Platform::Linux).unwrap();
        assert_eq!(r.url, "https://example.com/tool");
        assert_eq!(r.name, "tool");
        assert!(r.entry.is_none());
        assert_eq!(r.app_args, vec!["--foo", "bar"]);
    }

    #[test]
    fn parse_multiple_values_delimited() {
        let args = Args::parse_from([
            "dtx",
            "--linux-url",
            "https://example.com/linux",
            "--linux-args",
            "a,b,c",
            "--",
            "d",
        ]);
        let r = resolve_effective(&args, Platform::Linux).unwrap();
        assert_eq!(r.app_args, vec!["a", "b", "c", "d"]);
    }
}
