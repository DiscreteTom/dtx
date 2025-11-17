use log::debug;
use std::path::PathBuf;
use std::process::Command;

pub fn execute_binary(binary_path: &PathBuf, args: &[String]) -> Result<i32, Box<dyn std::error::Error>> {
    debug!("Executing with args: {:?}", args);
    let status = Command::new(binary_path)
        .args(args)
        .status()?;
    
    Ok(status.code().unwrap_or(1))
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_execute_binary_success() {
        // Use a simple command that should exist on most systems
        let result = execute_binary(&PathBuf::from("echo"), &["test".to_string()]);
        assert!(result.is_ok());
        assert_eq!(result.unwrap(), 0);
    }

    #[test]
    fn test_execute_binary_with_args() {
        let result = execute_binary(&PathBuf::from("echo"), &["hello".to_string(), "world".to_string()]);
        assert!(result.is_ok());
        assert_eq!(result.unwrap(), 0);
    }

    #[test]
    fn test_execute_nonexistent_binary() {
        let result = execute_binary(&PathBuf::from("nonexistent_binary_12345"), &[]);
        assert!(result.is_err());
    }
}
