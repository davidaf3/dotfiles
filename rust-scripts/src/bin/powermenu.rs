use anyhow::Result;
use rust_scripts::command::Command;
use rust_scripts::dmenu::DMenu;

fn main() -> Result<()> {
    DMenu::builder()
        .option("󰤄    Suspend", Command::new("systemctl", &["suspend"]))
        .option("󰐥    Power Off", Command::new("systemctl", &["poweroff"]))
        .option("󰜉    Restart", Command::new("systemctl", &["reboot"]))
        .option(
            "󰍃    Log Out",
            Command::new("niri", &["msg", "action", "quit"]),
        )
        .build()
        .show()?
        .map_or(Ok(()), |cmd| cmd.run())
}
