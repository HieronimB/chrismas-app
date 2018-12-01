#[macro_use]
extern crate serde_derive;
#[macro_use]
extern crate diesel;
extern crate dotenv;
extern crate actix_web;
extern crate rand;
extern crate core;

use std::env;
use std::path::PathBuf;
use actix_web::{App, HttpRequest,HttpResponse, Result, fs::NamedFile, server, http};
use actix_web::Query;
use actix_web::Json;
use actix_web::error::ErrorNotFound;
use rand::Rng;
use actix_web::error::ErrorInternalServerError;
use core::borrow::Borrow;
use db::Friend;

mod schema;
mod db;

fn index(_req: &HttpRequest) -> Result<NamedFile> {
    Ok(NamedFile::open(PathBuf::from("dist/assets/index.html"))?)
}

fn assets(req: &HttpRequest) -> Result<NamedFile> {
    let asset: PathBuf = req.match_info().query("asset")?;
    Ok(NamedFile::open(PathBuf::from("dist/assets").join(asset))?)
}

#[derive(Deserialize, Serialize)]
pub struct HttpFriend {
    firstname: String,
    lastname: String
}

fn draw(friend_param: Query<HttpFriend>) -> Result<Json<HttpFriend>> {
    let db_connection = db::establish_connection();
    let friend = db::fetch_friend(&friend_param.firstname.to_lowercase(),
                                                     &friend_param.lastname.to_lowercase(),
                                                        &db_connection);

    friend
        .and_then(|f| {
            let drawn = db::fetch_drawn(&f, &db_connection);
            drawn.or_else(|_| {
                let mut friends = db::fetch_friends(&f, &db_connection);
                let drawn = if db::fetch_number(&db_connection) == 3 {
                    let mut vec = db::is_excluded(&f, &db_connection).unwrap();
                    if vec.len() > 0 {
                        vec.remove(0)
                    } else {
                        let mut rng = rand::thread_rng();
                        let len = friends.len();
                        friends.remove(rng.gen_range(0, len))
                    }
                } else if db::fetch_number(&db_connection) == 2 {
                    let mut vec = db::is_excluded(&f, &db_connection).unwrap();
                    if vec.len() > 0 {
                        vec.remove(0)
                    } else {
                        let mut rng = rand::thread_rng();
                        let len = friends.len();
                        friends.remove(rng.gen_range(0, len))
                    }
                } else {
                    let mut rng = rand::thread_rng();
                    let len = friends.len();
                    friends.remove(rng.gen_range(0, len))
                };

                db::insert_drawn(&f, &drawn, &db_connection);
                Ok(Friend { id: drawn.id, firstname: drawn.firstname.clone(), lastname: drawn.lastname.clone() })
            })
        })
        .map(|f| Json(HttpFriend { firstname: f.firstname, lastname: f.lastname }))
        .map_err(|e| ErrorInternalServerError(e))
}

fn main() {
    let port= env::var("PORT").unwrap_or("8088".to_owned());

    server::new(|| {
        vec![
            App::new().prefix("/assets").resource("/{asset:.*}", |r| r.f(assets)),
            App::new().prefix("/api").resource("/draw", |r| r.method(http::Method::GET).with(draw)),
            App::new().resource("/", |r| r.f(index))
        ]
    })
        .bind(format!("0.0.0.0:{}", port))
        .unwrap()
        .run();
}
