#[macro_use]
extern crate diesel;

use std::env;

use actix::SyncArbiter;
use actix_web::middleware::Logger;
use actix_web::{http, server, App};
use diesel::pg::PgConnection;
use diesel::Connection;
use dotenv::dotenv;
use env_logger;

use crate::controllers::AppState;
use crate::service::DbExecutor;

mod controllers;
mod db;
mod draw;
mod service;

fn main() {
    dotenv().ok();
    env_logger::init();
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
                .resource("/drawn/{draw_id}/{participant}", |r| {
                    r.method(http::Method::GET).with(controllers::find_drawn)
                })
                .resource("/participants/{draw_id}", |r| {
                    r.method(http::Method::GET)
                        .with(controllers::find_participants)
                })
                .middleware(Logger::default())
                .boxed(),
            App::new()
                .resource("/assets/{asset:.*}", |r| r.f(controllers::assets))
                .resource("/{tail:.*}", |r| r.f(controllers::index))
                .boxed(),
        ]
    })
    .bind(format!("0.0.0.0:{}", port))
    .unwrap()
    .start();

    let _ = sys.run();
}
