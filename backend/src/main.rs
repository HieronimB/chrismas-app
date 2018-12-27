#[macro_use]
extern crate serde_derive;
#[macro_use]
extern crate diesel;
extern crate actix_web;
extern crate core;
extern crate dotenv;
extern crate rand;

use crate::draw::BacktrackingAlgorithm;
use crate::db_executor::DbExecutor;
use crate::db_executor::CreateDraw;
use actix_web::error::ErrorInternalServerError;
use actix_web::error::ErrorNotFound;
use actix_web::Json;
use actix_web::Query;
use actix_web::{fs::NamedFile, http, server, App, HttpRequest, HttpResponse, Result};
use core::borrow::Borrow;
use rand::Rng;
use std::env;
use std::path::PathBuf;
use actix_web::dev::HttpResponseBuilder;
use actix::Addr;
use actix::SyncArbiter;
use diesel::pg::PgConnection;
use actix_web::Error;
use futures::Future;
use dotenv::dotenv;
use actix_web::AsyncResponder;
use diesel::Connection;

mod draw;
mod schema;
mod db_executor;

struct State {
    db: Addr<DbExecutor>,
}

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
    lastname: String,
}

fn draw(friend_param: Query<HttpFriend>) -> Result<Json<HttpFriend>> {
//    let db_connection = db::establish_connection();
//    let friend = db::fetch_friend(
//        &friend_param.firstname.to_lowercase(),
//        &friend_param.lastname.to_lowercase(),
//        &db_connection,
//    );
//
//    friend
//        .and_then(|f| {
//            let drawn = db::fetch_drawn(&f, &db_connection);
//            drawn.or_else(|_| {
//                let mut friends = db::fetch_friends(&f, &db_connection);
//                let drawn = if db::fetch_number(&db_connection) == 3 {
//                    let mut vec = db::is_excluded(&f, &db_connection).unwrap();
//                    if vec.len() > 0 {
//                        vec.remove(0)
//                    } else {
//                        let mut rng = rand::thread_rng();
//                        let len = friends.len();
//                        friends.remove(rng.gen_range(0, len))
//                    }
//                } else if db::fetch_number(&db_connection) == 2 {
//                    let mut vec = db::is_excluded(&f, &db_connection).unwrap();
//                    if vec.len() > 0 {
//                        vec.remove(0)
//                    } else {
//                        let mut rng = rand::thread_rng();
//                        let len = friends.len();
//                        friends.remove(rng.gen_range(0, len))
//                    }
//                } else {
//                    let mut rng = rand::thread_rng();
//                    let len = friends.len();
//                    friends.remove(rng.gen_range(0, len))
//                };
//
//                //db::insert_drawn(&f, &drawn, &db_connection);
//                Ok(Friend {
//                    id: drawn.id,
//                    firstname: drawn.firstname.clone(),
//                    lastname: drawn.lastname.clone(),
//                })
//            })
//        })
//        .map(|f| {
//            Json(HttpFriend {
//                firstname: f.firstname,
//                lastname: f.lastname,
//            })
//        })
//        .map_err(|e| ErrorInternalServerError(e))
    Ok(Json(HttpFriend {
                firstname: "k".to_string(),
                lastname: "h".to_string(),
            }))
}

fn make_draw(req: &HttpRequest) -> HttpResponse {
//    let db_connection = db::establish_connection();
//    let all_friends = db::fetch_all_friends(&db_connection);
//    let drawn_excluded = db::fetch_all_drawn_excluded(&db_connection);
//    let all_friends_ids: Vec<i32> = all_friends.iter().map(|f| f.id).collect();
//    let drawn_excluded_ids: Vec<(i32, i32)> = drawn_excluded.iter().map(|de| (de.friend, de.excluded)).collect();
//
//    let backtracking_algorithm =
//        BacktrackingAlgorithm::new(all_friends_ids.clone(), all_friends_ids, drawn_excluded_ids);
//    let result = backtracking_algorithm.draw();
//    db::insert_drawn(result, &db_connection);
    HttpResponse::new(http::StatusCode::OK)
}

fn new_draw(req: &HttpRequest<State>) -> Box<Future<Item=HttpResponse, Error=Error>> {
    let name = &req.match_info()["name"];

    req.state().db.send(CreateDraw{name: name.to_owned()})
        .from_err()
        .and_then(|res| {
            match res {
                Ok(response) => Ok(HttpResponse::Ok().body(response)),
                Err(_) => Ok(HttpResponse::InternalServerError().into())
            }
        })
        .responder()
}

fn main() {
    dotenv().ok();
    let port = env::var("PORT").unwrap_or("8088".to_owned());
    let sys = actix::System::new("chrismas-app");

    let addr = SyncArbiter::start(3, move || {
        let database_url = env::var("DATABASE_URL").expect("DATABASE_URL must be set");
        DbExecutor(PgConnection::establish(&database_url).unwrap())
    });

    server::new(move || {
        vec![
            App::new()
                .prefix("/assets")
                .resource("/{asset:.*}", |r| r.f(assets))
                .boxed(),
            App::new()
                .prefix("/api")
                .resource("/draw", |r| r.method(http::Method::GET).with(draw))
                .resource("/make-draw", |r| r.method(http::Method::GET).f(make_draw))
                .boxed(),
            App::with_state(State{db: addr.clone()})
                .resource("/db/{name}", |r| r.method(http::Method::GET).a(new_draw))
                .boxed(),
            App::new()
                .resource("/", |r| r.f(index))
                .boxed(),
        ]
    })
    .bind(format!("0.0.0.0:{}", port))
    .unwrap().start();

    println!("Started http server: 127.0.0.1:8080");

    let _ = sys.run();
}
