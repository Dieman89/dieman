use worker::*;

const ORIGIN: &str = "https://dieman.dev";

fn cors(origin: &str) -> Headers {
    let h = Headers::new();
    h.set("Access-Control-Allow-Origin", origin).ok();
    h.set("Access-Control-Allow-Methods", "GET, POST, OPTIONS").ok();
    h.set("Access-Control-Allow-Headers", "Content-Type").ok();
    h
}

fn json(body: String, origin: &str, status: u16) -> Result<Response> {
    let h = cors(origin);
    h.set("Content-Type", "application/json").ok();
    Ok(Response::ok(body)?.with_headers(h).with_status(status))
}

fn count(n: u64) -> String { format!(r#"{{"count":{n}}}"#) }
fn error(msg: &str) -> String { format!(r#"{{"error":"{msg}"}}"#) }

async fn get_count(kv: &kv::KvStore, key: &str) -> u64 {
    kv.get(key).text().await.ok().flatten().and_then(|s| s.parse().ok()).unwrap_or(0)
}

async fn handle_stat(req: &Request, kv: &kv::KvStore, key: &str, origin: &str) -> Result<Response> {
    match req.method() {
        Method::Get => json(count(get_count(kv, key).await), origin, 200),
        Method::Post => {
            let n = get_count(kv, key).await + 1;
            kv.put(key, n.to_string())?.execute().await?;
            json(count(n), origin, 200)
        }
        _ => json(error("Method not allowed"), origin, 405),
    }
}

#[event(fetch)]
async fn main(req: Request, env: Env, _ctx: Context) -> Result<Response> {
    let origin = req.headers().get("Origin")?.unwrap_or_else(|| ORIGIN.into());
    let allowed = origin == ORIGIN;

    if req.method() == Method::Options {
        return match allowed {
            true => Ok(Response::empty()?.with_headers(cors(&origin))),
            false => Response::error("Forbidden", 403),
        };
    }

    if !allowed {
        return json(error("Forbidden"), &origin, 403);
    }

    let path = req.url()?.path().to_string();
    let kv = env.kv("POST_STATS")?;

    for prefix in ["hearts", "views"] {
        if let Some(id) = path.strip_prefix(&format!("/api/{prefix}/")) {
            let key = format!("{prefix}:{}", urlencoding::decode(id).unwrap_or_default());
            return handle_stat(&req, &kv, &key, &origin).await;
        }
    }

    json(error("Not found"), &origin, 404)
}
