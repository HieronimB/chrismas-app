extern crate actix_web;

use std::path::PathBuf;
use actix_web::{App, HttpRequest, Result, http::Method, fs::NamedFile, server};

fn index(_req: &HttpRequest) -> Result<NamedFile> {
    Ok(NamedFile::open(PathBuf::from("dist/index.html"))?)
}

fn assets(req: &HttpRequest) -> Result<NamedFile> {
    let asset: PathBuf = req.match_info().query("asset")?;
    Ok(NamedFile::open(PathBuf::from("dist/assets").join(asset))?)
}

fn main() {
    server::new(|| {
        vec![
            App::new().prefix("/assets").resource("/{asset:.*}", |r| r.f(assets)),
            App::new().resource("/", |r| r.f(index))
        ]
    })
        .bind("127.0.0.1:8088")
        .unwrap()
        .run();
}
