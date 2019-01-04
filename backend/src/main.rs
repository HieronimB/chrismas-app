#[macro_use]
extern crate diesel;

use std::env;

use actix::SyncArbiter;
use actix_web::{http, server, App};
use diesel::pg::PgConnection;
use diesel::Connection;
use dotenv::dotenv;

use crate::controllers::AppState;
use crate::service::DbExecutor;

mod controllers;
mod db;
mod draw;
mod service;

fn main() {
    dotenv().ok();
    let port = env::var("PORT").unwrap_or_else(|_| "8088".to_owned());
    let sys = actix::System::new("chrismas-app");

    let addr = SyncArbiter::start(3, move || {
        let database_url = env::var("DATABASE_URL").expect("DATABASE_URL must be set");
        DbExecutor(PgConnection::establish(&database_url).unwrap())
    });

    server::new(move || {
        vec![
            App::with_state(AppState { db: addr.clone() })
                .prefix("/api")
                .resource("/create", |r| {
                    r.method(http::Method::POST).with(controllers::new_draw)
                })
                .resource("/execute", |r| {
                    r.method(http::Method::POST).with(controllers::execute_draw)
                })
                .boxed(),
            App::new()
                .resource("/assets/{asset:.*}", |r| r.f(controllers::assets))
                .resource("/", |r| r.f(controllers::index))
                .boxed(),
        ]
    })
    .bind(format!("0.0.0.0:{}", port))
    .unwrap()
    .start();

    println!("Started http server: 127.0.0.1:8080");

    let _ = sys.run();
}
