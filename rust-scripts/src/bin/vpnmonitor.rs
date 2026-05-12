use anyhow::{Result, anyhow};
use rust_scripts::vpn;
use std::{
    io::{BufRead, BufReader},
    process::{Command, Stdio},
};

fn main() -> Result<()> {
    let mut active_vpn = vpn::get_vpn_names(true)?.into_iter().next();
    log_active_vpn(&active_vpn);
    let mut monitor = Command::new("nmcli")
        .arg("monitor")
        .stdout(Stdio::piped())
        .spawn()?;
    let stdout = monitor
        .stdout
        .take()
        .ok_or(anyhow!("stdout handle not present"))?;
    for line in BufReader::new(stdout).lines() {
        match line {
            Ok(line) => {
                if line.contains("connected")
                    || line.contains("disconnected")
                    || line.contains("unmanaged")
                {
                    let old_active_vpn = active_vpn;
                    active_vpn = vpn::get_vpn_names(true)?.into_iter().next();
                    if active_vpn != old_active_vpn {
                        log_active_vpn(&active_vpn);
                    }
                }
            }
            _ => {}
        }
    }
    Ok(())
}

fn log_active_vpn(active_vpn: &Option<String>) {
    match active_vpn {
        Some(active_vpn) => println!("{{\"text\": \"\", \"tooltip\": \"{}\"}}", active_vpn),
        None => println!("{{\"text\": \"\"}}"),
    }
}
