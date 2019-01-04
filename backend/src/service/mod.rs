use actix;
use actix::prelude::*;
use diesel::pg::PgConnection;

pub mod create_draw;
pub mod execute_draw;
mod models;

pub struct DbExecutor(pub PgConnection);

impl Actor for DbExecutor {
    type Context = SyncContext<Self>;
}
