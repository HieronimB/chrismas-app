use std::path::PathBuf;

use actix::Addr;
use actix_web::AsyncResponder;
use actix_web::FutureResponse;
use actix_web::Json;
use actix_web::State;
use actix_web::{fs::NamedFile, HttpRequest, HttpResponse, Result};
use futures::future::Future;
use serde_derive::Deserialize;

use crate::service::create_draw::CreateDraw;
use crate::service::execute_draw::ExecuteDraw;
use crate::service::find_drawn::FindDrawn;
use crate::service::find_participants::FindParticipants;
use crate::service::DbExecutor;
use actix_web::Path;
use log::info;
use uuid::Uuid;

pub struct AppState {
    pub db: Addr<DbExecutor>,
}

#[derive(Deserialize, Debug)]
pub struct DrawJson {
    pub name: String,
    pub participants: Vec<String>,
    pub excluded: Vec<(String, String)>,
}

#[derive(Deserialize, Debug)]
pub struct FindDrawnJson {
    pub draw_id: Uuid,
    pub participant: i32,
}

pub fn index(_req: &HttpRequest) -> Result<NamedFile> {
    Ok(NamedFile::open(PathBuf::from("dist/assets/index.html"))?)
}

pub fn assets(req: &HttpRequest) -> Result<NamedFile> {
    let asset: PathBuf = req.match_info().query("asset")?;
    Ok(NamedFile::open(PathBuf::from("dist/assets").join(asset))?)
}

pub fn new_draw(
    (state, draw_json): (State<AppState>, Json<DrawJson>),
) -> FutureResponse<HttpResponse> {
    let draw = draw_json.into_inner();
    info!("Creating new draw: {:?}", draw);
    state
        .db
        .send(CreateDraw {
            name: draw.name.clone(),
            participants: draw.participants,
            excluded: draw.excluded,
        })
        .flatten()
        .and_then(move |draw_id| state.db.send(ExecuteDraw { draw_id }).flatten())
        .map(|draw_id| HttpResponse::Ok().json(draw_id))
        .map_err(actix_web::Error::from)
        .responder()
}

pub fn find_drawn(
    (state, params): (State<AppState>, Path<(Uuid, String)>),
) -> FutureResponse<HttpResponse> {
    let (uuid, participant) = params.into_inner();
    info!("Find drawn: {:?}, {:?}", uuid, participant);
    state
        .db
        .send(FindDrawn {
            draw_id: uuid,
            participant,
        })
        .flatten()
        .map(|drawn_name| HttpResponse::Ok().json(drawn_name))
        .map_err(actix_web::Error::from)
        .responder()
}

pub fn find_participants(
    (state, draw_id): (State<AppState>, Path<Uuid>),
) -> FutureResponse<HttpResponse> {
    info!("Find participants: {:?}", draw_id);

    state
        .db
        .send(FindParticipants {
            draw_id: draw_id.into_inner(),
        })
        .flatten()
        .map(|participants| HttpResponse::Ok().json(participants))
        .map_err(actix_web::Error::from)
        .responder()
}
