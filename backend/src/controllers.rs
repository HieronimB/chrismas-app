use std::path::PathBuf;

use actix::Addr;
use actix_web::AsyncResponder;
use actix_web::FutureResponse;
use actix_web::Json;
use actix_web::State;
use actix_web::{fs::NamedFile, HttpRequest, HttpResponse, Result};
use futures::future::Future;

use crate::service::create_draw::CreateDraw;
use crate::service::execute_draw::ExecuteDraw;
use crate::service::DbExecutor;

pub struct AppState {
    pub db: Addr<DbExecutor>,
}

#[derive(Deserialize, Debug)]
pub struct Draw {
    pub name: String,
    pub participants: Vec<String>,
    pub excluded: Vec<(String, String)>,
}

pub fn index(_req: &HttpRequest) -> Result<NamedFile> {
    Ok(NamedFile::open(PathBuf::from("dist/assets/index.html"))?)
}

pub fn assets(req: &HttpRequest) -> Result<NamedFile> {
    let asset: PathBuf = req.match_info().query("asset")?;
    Ok(NamedFile::open(PathBuf::from("dist/assets").join(asset))?)
}

pub fn new_draw((state, draw_json): (State<AppState>, Json<Draw>)) -> FutureResponse<HttpResponse> {
    let draw = draw_json.into_inner();
    println!("New draw: {:?}", draw);
    state
        .db
        .send(CreateDraw {
            name: draw.name,
            participants: draw.participants,
            excluded: draw.excluded,
        })
        .from_err()
        .and_then(|res| match res {
            Ok(_response) => Ok(HttpResponse::Ok().finish()),
            Err(_) => Ok(HttpResponse::InternalServerError().into()),
        })
        .responder()
}

pub fn execute_draw(
    (state, draw_json): (State<AppState>, Json<Draw>),
) -> FutureResponse<HttpResponse> {
    println!("Execute draw");
    let draw = draw_json.into_inner();
    state
        .db
        .send(ExecuteDraw { name: draw.name })
        .from_err()
        .and_then(|res| match res {
            Ok(_response) => Ok(HttpResponse::Ok().finish()),
            Err(_) => Ok(HttpResponse::InternalServerError().into()),
        })
        .responder()
}
