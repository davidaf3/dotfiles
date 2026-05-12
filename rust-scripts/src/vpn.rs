use crate::gp_saml;
use anyhow::{Result, anyhow};
use itertools::Itertools;
use nom::{
    IResult, Parser,
    bytes::complete::{is_not, tag},
    character::complete::multispace0,
    multi::separated_list0,
    sequence::{delimited, separated_pair},
};
use std::collections::HashMap;
use url::Url;
use xshell::{Shell, cmd};

pub trait Vpn {
    fn connect(&mut self) -> Result<()>;
    fn disconnect(&mut self) -> Result<()>;
    fn get_name(&self) -> &str;
    fn is_active(&self) -> bool;
}

struct GenericVpn {
    name: String,
    active: bool,
    data: HashMap<String, String>,
}

impl GenericVpn {
    fn new(name: &str, active: bool, data: HashMap<String, String>) -> Self {
        Self {
            name: name.into(),
            active,
            data,
        }
    }
}

impl Vpn for GenericVpn {
    fn connect(&mut self) -> Result<()> {
        let name = &self.name;
        let sh = Shell::new()?;
        cmd!(sh, "nmcli con up {name}").run()?;
        self.active = true;
        Ok(())
    }

    fn disconnect(&mut self) -> Result<()> {
        let name = &self.name;
        let sh = Shell::new()?;
        cmd!(sh, "nmcli con down {name}").run()?;
        self.active = false;
        Ok(())
    }

    fn get_name(&self) -> &str {
        &self.name
    }

    fn is_active(&self) -> bool {
        self.active
    }
}

struct GpVpn {
    inner: GenericVpn,
    gateway_host: String,
}

impl GpVpn {
    fn try_new(inner: GenericVpn) -> Result<Self> {
        let gateway_url = inner
            .data
            .get("gateway")
            .ok_or(anyhow!("Gateway not found in vpn.data"))
            .and_then(|url| Url::parse(url).map_err(Into::into))?;
        let gateway_host = gateway_url
            .host_str()
            .ok_or(anyhow!("Can't get gateway host"))?;
        Ok(Self {
            inner,
            gateway_host: gateway_host.into(),
        })
    }
}

impl Vpn for GpVpn {
    fn connect(&mut self) -> Result<()> {
        let sh = Shell::new()?;
        let rt = tokio::runtime::Builder::new_multi_thread()
            .enable_all()
            .build()?;
        let name = &self.inner.name;
        let (username, cookie) = rt.block_on(gp_saml::get_login(&self.gateway_host))?;
        cmd!(sh, "nmcli con up {name} --ask")
            .stdin(format!("{}\n{}\n", username, cookie))
            .run()?;
        self.inner.active = true;
        Ok(())
    }

    fn disconnect(&mut self) -> Result<()> {
        self.inner.disconnect()
    }

    fn get_name(&self) -> &str {
        self.inner.get_name()
    }

    fn is_active(&self) -> bool {
        self.inner.is_active()
    }
}

pub fn get_vpn_names(only_active: bool) -> Result<Vec<String>> {
    let sh = Shell::new()?;
    let active_flag = only_active.then_some("--active");
    Ok(
        cmd!(sh, "nmcli -g name,type -e no con show {active_flag...}")
            .read()?
            .lines()
            .map(|conn| conn.rsplit_once(':'))
            .flatten()
            .filter(|(_, type_)| *type_ == "vpn" || *type_ == "wireguard")
            .map(|(name, _)| name.into())
            .collect_vec(),
    )
}

pub fn load_vpn(vpn_name: &str) -> Result<Box<dyn Vpn>> {
    let sh = Shell::new()?;
    let show_res = cmd!(
        sh,
        "nmcli -g connection.type,vpn.data,GENERAL.STATE -e no con show {vpn_name}"
    )
    .read()?;
    let mut show_lines = show_res.lines();

    let type_ = show_lines
        .next()
        .ok_or(anyhow!("nmcli con show returned empty string"))?;
    let vpn_data = if type_ == "vpn" {
        show_lines
            .next()
            .ok_or(anyhow!("Unexpected end of nmcli con show output"))
            .and_then(|line| parse_vpn_data(line).map_err(|e| anyhow!(e.to_string())))?
            .1
    } else {
        HashMap::new()
    };
    let active = show_lines.next().map_or(false, |line| line == "activated");

    let generic_vpn = GenericVpn::new(vpn_name, active, vpn_data);
    if let Some(protocol) = generic_vpn.data.get("protocol") {
        if protocol == "gp" {
            return Ok(Box::new(GpVpn::try_new(generic_vpn)?));
        }
    }
    return Ok(Box::new(generic_vpn));
}

fn parse_value(input: &str) -> IResult<&str, &str> {
    is_not(" =,\t\r\n").parse(input)
}

fn parse_pair(input: &str) -> IResult<&str, (&str, &str)> {
    separated_pair(
        parse_value,
        delimited(multispace0, tag("="), multispace0),
        parse_value,
    )
    .parse(input)
}

fn parse_vpn_data(input: &str) -> IResult<&str, HashMap<String, String>> {
    let (input, pairs) =
        separated_list0(delimited(multispace0, tag(","), multispace0), parse_pair).parse(input)?;
    let map: HashMap<String, String> = pairs
        .into_iter()
        .map(|(k, v)| (k.to_string(), v.to_string()))
        .collect();
    Ok((input, map))
}
