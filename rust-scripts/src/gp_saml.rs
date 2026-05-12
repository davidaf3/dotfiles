use anyhow::{Result, anyhow};
use base64::prelude::*;
use hyper::{Client, client::HttpConnector};
use hyper_openssl::HttpsConnector;
use ini::Ini;
use openssl::ssl::{SslConnector, SslMethod, SslOptions};
use serde::Deserialize;
use serde_json::json;
use std::env;
use std::path::PathBuf;
use std::process::Stdio;
use std::sync::{Arc, Mutex};
use tokio::process::Command;
use tokio::sync::oneshot;
use webdriverbidi::events::EventType;
use webdriverbidi::model::browsing_context::{
    GetTreeParameters, NavigateParameters, ReadinessState,
};
use webdriverbidi::model::session::SubscriptionRequest;
use webdriverbidi::session::WebDriverBiDiSession;
use webdriverbidi::webdriver::capabilities::{CapabilitiesRequest, CapabilityRequest};

const GECKODRIVER_HOST: &str = "localhost";
const GECKODRIVER_PORT: u16 = 4444;
const FIREFOX_PROFILE: &str = "vpn-saml";

#[derive(Deserialize)]
struct NetworkResponseCompletedEvent {
    params: NetworkResponseCompletedEventParams,
}

#[derive(Deserialize)]
struct NetworkResponseCompletedEventParams {
    response: Response,
}

#[derive(Deserialize)]
struct Response {
    url: String,
    headers: Vec<Header>,
}

#[derive(Deserialize)]
struct Header {
    name: String,
    value: HeaderValue,
}

#[derive(Deserialize)]
struct HeaderValue {
    value: String,
}

pub async fn get_login(gateway_host: &str) -> Result<(String, String)> {
    let _geckodriver_process = Command::new("geckodriver")
        .arg("--host")
        .arg(GECKODRIVER_HOST)
        .arg("--port")
        .arg(GECKODRIVER_PORT.to_string())
        .stdout(Stdio::null())
        .stderr(Stdio::null())
        .kill_on_drop(true)
        .spawn()?;

    let prelogin_response = https_get_body_with_legacy_renegotiation(format!(
        "https://{}/ssl-vpn/prelogin.esp",
        gateway_host
    ))
    .await?;
    let prelogin_doc = roxmltree::Document::parse(&prelogin_response)?;
    let saml_request_b64 = prelogin_doc
        .descendants()
        .find(|n| n.has_tag_name("saml-request"))
        .and_then(|n| n.text())
        .ok_or(anyhow!("saml-request tag not found"))?;
    let saml_request = String::from_utf8(BASE64_STANDARD.decode(saml_request_b64)?)?;

    let mut session = init_webdriver_session().await?;
    let ctx = get_browsing_context(&mut session, 0).await?;
    session
        .session_subscribe(SubscriptionRequest::new(
            vec!["network.responseCompleted".into()],
            Some(vec![ctx.clone()]),
            None,
        ))
        .await?;

    let (tx, rx) = oneshot::channel::<(String, String)>();
    let tx_wrapper = Arc::new(Mutex::new(Some(tx)));
    session
        .register_event_handler(EventType::NetworkResponseCompleted, move |e| {
            let tx_wrapper = tx_wrapper.clone();
            async move {
                let e: Result<NetworkResponseCompletedEvent, _> = serde_json::from_value(e);
                if let Ok(e) = e
                    && e.params.response.url.contains("SAML")
                {
                    let headers = e.params.response.headers;
                    let cookie = headers
                        .iter()
                        .find(|h| h.name.to_lowercase() == "prelogin-cookie")
                        .map(|h| &h.value.value);
                    let username = headers
                        .iter()
                        .find(|h| h.name.to_lowercase() == "saml-username")
                        .map(|h| &h.value.value);
                    if let Some(username) = username
                        && let Some(cookie) = cookie
                    {
                        if let Ok(mut tx_guard) = tx_wrapper.lock() {
                            if let Some(tx) = tx_guard.take() {
                                let _ = tx.send((username.into(), cookie.into()));
                            }
                        }
                    }
                }
            }
        })
        .await;

    session
        .browsing_context_navigate(NavigateParameters::new(
            ctx,
            saml_request,
            Some(ReadinessState::Complete),
        ))
        .await?;

    let login = rx.await?;
    session.close().await?;
    Ok(login)
}

pub async fn init_webdriver_session() -> Result<WebDriverBiDiSession> {
    let mut always_match = CapabilityRequest::new();
    let profile_path = get_firefox_profile_path(FIREFOX_PROFILE)?;
    let firefox_options = json!({
        "args": ["-profile", profile_path]
    });
    always_match
        .extension
        .insert("moz:firefoxOptions".into(), firefox_options);
    let capabilities = CapabilitiesRequest::new(always_match);
    let mut session =
        WebDriverBiDiSession::new(GECKODRIVER_HOST.into(), GECKODRIVER_PORT, capabilities);
    session.start().await?;
    Ok(session)
}

fn get_firefox_profile_path(profile_name: &str) -> Result<String> {
    let mut firefox_dir = PathBuf::from(env::var("HOME")?);
    firefox_dir.push(".mozilla");
    firefox_dir.push("firefox");

    let mut profiles_ini_path = firefox_dir.clone();
    profiles_ini_path.push("profiles.ini");
    let profiles_ini = Ini::load_from_file(profiles_ini_path)?;
    let (_, profile) = profiles_ini
        .iter()
        .find(|(sec, props)| {
            sec.map_or(false, |sec| sec.starts_with("Profile"))
                && props.iter().any(|(k, v)| k == "Name" && v == profile_name)
        })
        .ok_or(anyhow!("Firefox profile not found"))?;

    let is_relative = profile
        .iter()
        .find(|&(k, _)| k == "IsRelative")
        .map_or(false, |(_, v)| v == "1");
    let (_, path) = profile
        .iter()
        .find(|&(k, _)| k == "Path")
        .ok_or(anyhow!("Firefox profile path not found"))?;

    if is_relative {
        let mut absolute_path = firefox_dir;
        absolute_path.push(path);
        Ok(absolute_path.to_string_lossy().into_owned())
    } else {
        Ok(path.into())
    }
}

pub async fn get_browsing_context(
    session: &mut WebDriverBiDiSession,
    idx: usize,
) -> Result<String> {
    let ctx_tree = session
        .browsing_context_get_tree(GetTreeParameters::new(None, None))
        .await?;
    match ctx_tree.contexts.get(idx) {
        Some(ctx_info) => Ok(ctx_info.context.clone()),
        None => Err(anyhow!("No browsing context at index {}", idx)),
    }
}

async fn https_get_body_with_legacy_renegotiation(uri: String) -> Result<String> {
    const SSL_OP_ALLOW_UNSAFE_LEGACY_RENEGOTIATION: u64 = 0x00040000;

    let mut builder = SslConnector::builder(SslMethod::tls())?;
    let current_opts = builder.options();
    let legacy_flag = SslOptions::from_bits_truncate(SSL_OP_ALLOW_UNSAFE_LEGACY_RENEGOTIATION);
    builder.set_options(current_opts | legacy_flag);

    let mut http = HttpConnector::new();
    http.enforce_http(false);
    let https = HttpsConnector::with_connector(http, builder)?;
    let client = Client::builder().build::<_, hyper::Body>(https);

    let response = client.get(uri.parse()?).await?;
    let body_bytes = hyper::body::to_bytes(response).await?;
    String::from_utf8(body_bytes.to_vec()).map_err(Into::into)
}
