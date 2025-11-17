fn extract_name_from_string(input: &str) -> &str {
    let filename = input.split('/').last().unwrap_or("binary");

    if filename.is_empty() {
        return "binary";
    }

    // Remove .exe extension on Windows (case insensitive)
    #[cfg(windows)]
    {
        if filename.to_lowercase().ends_with(".exe") {
            &filename[..filename.len() - 4]
        } else {
            filename
        }
    }
    #[cfg(not(windows))]
    {
        filename
    }
}

pub fn extract_binary_name_from_url(url: &str) -> &str {
    extract_name_from_string(url)
}

pub fn extract_binary_name_from_path(path: &str) -> &str {
    extract_name_from_string(path)
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_extract_binary_name_from_url() {
        assert_eq!(extract_binary_name_from_url("https://example.com/tool"), "tool");
        assert_eq!(extract_binary_name_from_url("https://github.com/user/repo/releases/download/v1.0.0/myapp"), "myapp");
        assert_eq!(extract_binary_name_from_url(""), "binary");
        assert_eq!(extract_binary_name_from_url("no-slash"), "no-slash");
    }

    #[test]
    fn test_extract_binary_name_from_path() {
        assert_eq!(extract_binary_name_from_path("bin/tool"), "tool");
        assert_eq!(extract_binary_name_from_path("app/bin/myapp"), "myapp");
        assert_eq!(extract_binary_name_from_path(""), "binary");
        assert_eq!(extract_binary_name_from_path("tool"), "tool");
    }

    #[test]
    #[cfg(windows)]
    fn test_extract_binary_name_windows() {
        assert_eq!(extract_binary_name_from_url("https://example.com/tool.exe"), "tool");
        assert_eq!(extract_binary_name_from_url("https://example.com/app.EXE"), "app");
        assert_eq!(extract_binary_name_from_path("bin/tool.exe"), "tool");
        assert_eq!(extract_binary_name_from_path("app.Exe"), "app");
    }

    #[test]
    #[cfg(not(windows))]
    fn test_extract_binary_name_unix() {
        assert_eq!(extract_binary_name_from_url("https://example.com/tool.exe"), "tool.exe");
        assert_eq!(extract_binary_name_from_path("bin/tool.exe"), "tool.exe");
    }
}
