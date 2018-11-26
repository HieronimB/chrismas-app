extern crate actix_web;

use std::env;
use std::path::PathBuf;
use actix_web::{App, HttpRequest, Result, fs::NamedFile, server};

fn index(_req: &HttpRequest) -> Result<NamedFile> {
    Ok(NamedFile::open(PathBuf::from("dist/assets/index.html"))?)
}

fn assets(req: &HttpRequest) -> Result<NamedFile> {
    let asset: PathBuf = req.match_info().query("asset")?;
    Ok(NamedFile::open(PathBuf::from("dist/assets").join(asset))?)
}

fn main() {
    let port= env::var("PORT").unwrap_or("8088".to_owned());

    server::new(|| {
        vec![
            App::new().prefix("/assets").resource("/{asset:.*}", |r| r.f(assets)),
            App::new().resource("/", |r| r.f(index))
        ]
    })
        .bind(format!("0.0.0.0:{}", port))
        .unwrap()
        .run();
}
