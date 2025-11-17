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
