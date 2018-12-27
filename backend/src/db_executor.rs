use actix;
use actix_web::*;
use actix::prelude::*;
use actix_web::*;
use diesel::pg::PgConnection;
use actix_web::Error;
use diesel::prelude::*;

pub struct DbExecutor(pub PgConnection);

impl Actor for DbExecutor {
    type Context = SyncContext<Self>;
}

pub struct CreateDraw {
    pub name: String,
}

impl Message for CreateDraw {
    type Result = Result<String, Error>;
}

impl Handler<CreateDraw> for DbExecutor {
    type Result = Result<String, Error>;

    fn handle(&mut self, msg: CreateDraw, _: &mut Self::Context) -> Self::Result {
        println!("Db handler: {}", msg.name);
        Ok("Ok handler".to_string())
    }
}