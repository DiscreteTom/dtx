use log::debug;
use sha2::{Digest, Sha256};
use std::fs;
use std::path::PathBuf;

pub fn get_binary_path(
    url: &str,
    name: &str,
    entry: Option<&str>,
    cache_dir: &std::path::Path,
) -> Result<(PathBuf, PathBuf), Box<dyn std::error::Error>> {
    let url_hash = format!("{:x}", Sha256::digest(url.as_bytes()))[..8].to_string();
    let base_dir = cache_dir.join(name).join(&url_hash);

    if is_archive(url) {
        if let Some(entry_path) = entry {
            Ok((base_dir.join(entry_path), base_dir))
        } else {
            Err("Archive URL requires --entry parameter".into())
        }
    } else {
        let executable_name = if cfg!(windows) {
            format!("{}.exe", name)
        } else {
            name.to_string()
        };
        Ok((base_dir.join(executable_name), base_dir))
    }
}

fn is_archive(url: &str) -> bool {
    let url_lower = url.to_lowercase();
    url_lower.ends_with(".zip") || url_lower.ends_with(".tar.gz") || url_lower.ends_with(".tgz")
}

pub fn ensure_binary(
    url: &str,
    binary_path: &PathBuf,
    base_dir: &PathBuf,
    force: bool,
) -> Result<(), Box<dyn std::error::Error>> {
    if is_archive(url) {
        fs::create_dir_all(base_dir)?;
        debug!("Archive binary path: {:?}", binary_path);

        if !binary_path.exists() || force {
            debug!("Downloading and extracting {}", url);
            let response = reqwest::blocking::get(url)?;
            let bytes = response.bytes()?;

            if url.to_lowercase().ends_with(".zip") {
                extract_zip(&bytes, base_dir)?;
            } else if url.to_lowercase().ends_with(".tar.gz")
                || url.to_lowercase().ends_with(".tgz")
            {
                extract_tar_gz(&bytes, base_dir)?;
            }

            debug!("Extracted archive");

            #[cfg(unix)]
            if binary_path.exists() {
                use std::os::unix::fs::PermissionsExt;
                fs::set_permissions(binary_path, fs::Permissions::from_mode(0o755))?;
                debug!("Set executable permissions");
            }
        } else {
            debug!("Using cached archive");
        }
    } else {
        fs::create_dir_all(base_dir)?;
        debug!("Binary path: {:?}", binary_path);

        if !binary_path.exists() || force {
            debug!("Downloading {}", url);
            let response = reqwest::blocking::get(url)?;
            fs::write(binary_path, response.bytes()?)?;
            debug!("Downloaded and cached binary");

            #[cfg(unix)]
            {
                use std::os::unix::fs::PermissionsExt;
                fs::set_permissions(binary_path, fs::Permissions::from_mode(0o755))?;
                debug!("Set executable permissions");
            }
        } else {
            debug!("Using cached binary");
        }
    }

    Ok(())
}

fn extract_zip(
    bytes: &[u8],
    target_dir: &std::path::Path,
) -> Result<(), Box<dyn std::error::Error>> {
    let cursor = std::io::Cursor::new(bytes);
    let mut archive = zip::ZipArchive::new(cursor)?;

    for i in 0..archive.len() {
        let mut file = archive.by_index(i)?;
        let outpath = target_dir.join(file.name());

        if file.is_dir() {
            fs::create_dir_all(&outpath)?;
        } else {
            if let Some(p) = outpath.parent() {
                fs::create_dir_all(p)?;
            }
            let mut outfile = fs::File::create(&outpath)?;
            std::io::copy(&mut file, &mut outfile)?;

            #[cfg(unix)]
            {
                use std::os::unix::fs::PermissionsExt;
                if let Some(mode) = file.unix_mode() {
                    fs::set_permissions(&outpath, fs::Permissions::from_mode(mode))?;
                }
            }
        }
    }
    Ok(())
}

fn extract_tar_gz(
    bytes: &[u8],
    target_dir: &std::path::Path,
) -> Result<(), Box<dyn std::error::Error>> {
    let cursor = std::io::Cursor::new(bytes);
    let tar = flate2::read::GzDecoder::new(cursor);
    let mut archive = tar::Archive::new(tar);
    archive.unpack(target_dir)?;
    Ok(())
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_is_archive() {
        assert!(is_archive("test.zip"));
        assert!(is_archive("test.tar.gz"));
        assert!(is_archive("test.tgz"));
        assert!(is_archive("TEST.ZIP"));
        assert!(!is_archive("test.exe"));
        assert!(!is_archive("test"));
    }

    #[test]
    fn test_get_binary_path_regular() {
        use std::path::Path;
        let (path, _) = get_binary_path("https://example.com/tool", "mytool", None, Path::new("~/.dtx/cache")).unwrap();
        assert!(path.to_string_lossy().contains("mytool"));
        assert!(path.to_string_lossy().contains(".dtx/cache"));
    }

    #[test]
    fn test_get_binary_path_archive_with_entry() {
        use std::path::Path;
        let (path, base) = get_binary_path("https://example.com/tool.zip", "mytool", Some("bin/app"), Path::new("~/.dtx/cache")).unwrap();
        assert!(path.to_string_lossy().ends_with("bin/app"));
        assert!(base.to_string_lossy().contains("mytool"));
    }

    #[test]
    fn test_get_binary_path_archive_without_entry() {
        use std::path::Path;
        let result = get_binary_path("https://example.com/tool.zip", "mytool", None, Path::new("~/.dtx/cache"));
        assert!(result.is_err());
        assert!(result.unwrap_err().to_string().contains("Archive URL requires --entry parameter"));
    }

    #[test]
    fn test_ensure_binary_invalid_url() {
        use std::env;
        let temp_dir = env::temp_dir().join("dtx_test");
        let binary_path = temp_dir.join("test_binary");
        
        let result = ensure_binary("invalid://url", &binary_path, &temp_dir, false);
        assert!(result.is_err());
    }

    #[test]
    fn test_custom_cache_dir() {
        use std::path::Path;
        let custom_cache = Path::new("/tmp/custom_dtx");
        let (path, _) = get_binary_path("https://example.com/tool", "mytool", None, custom_cache).unwrap();
        assert!(path.to_string_lossy().contains("/tmp/custom_dtx"));
    }
}
