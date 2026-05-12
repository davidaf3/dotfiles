use anyhow::Result;
use rust_scripts::dmenu::DMenu;
use rust_scripts::vpn;
use xshell::{Shell, cmd};

#[derive(Clone)]
enum NetworkMenuOption {
    Vpn,
    EditConnections,
}

fn main() -> Result<()> {
    let vpn_names = vpn::get_vpn_names(false)?;
    let mut builder = DMenu::builder();
    if !vpn_names.is_empty() {
        builder = builder.option("󰒘    VPN", NetworkMenuOption::Vpn);
    }
    let selected = builder
        .option("󰩮    Edit Connections", NetworkMenuOption::EditConnections)
        .build()
        .show()?;

    let sh = Shell::new()?;
    match selected {
        Some(NetworkMenuOption::Vpn) => vpn_menu(vpn_names),
        Some(NetworkMenuOption::EditConnections) => {
            cmd!(sh, "nm-connection-editor").run().map_err(Into::into)
        }
        None => Ok(()),
    }
}

fn vpn_menu(vpn_names: Vec<String>) -> Result<()> {
    let vpns = vpn_names.iter().map(|vpn_name| vpn::load_vpn(vpn_name));
    let mut menu_builder = DMenu::builder();
    for vpn in vpns {
        let vpn = vpn?;
        let label = format!(
            "{} {}",
            if vpn.is_active() { "󰄬" } else { " " },
            vpn.get_name()
        );
        menu_builder = menu_builder.option(&label, vpn);
    }
    menu_builder
        .prompt("VPN > ")
        .build()
        .show()?
        .map_or(Ok(()), |mut vpn| {
            if !vpn.is_active() {
                vpn.connect()
            } else {
                vpn.disconnect()
            }
        })
}
