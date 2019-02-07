use actix;
use actix::prelude::*;
use diesel::pg::PgConnection;

pub mod create_draw;
pub mod execute_draw;
pub mod find_drawn;
pub mod find_participants;
mod models;

pub struct DbExecutor(pub PgConnection);

impl Actor for DbExecutor {
    type Context = SyncContext<Self>;
}

//TODO Improve error handling
pub enum SystemError {
    Mailbox(actix::MailboxError),
    DieselError(diesel::result::Error),
}

impl std::convert::From<actix::MailboxError> for SystemError {
    fn from(e: actix::MailboxError) -> Self {
        SystemError::Mailbox(e)
    }
}

impl std::convert::From<SystemError> for actix_web::Error {
    fn from(e: SystemError) -> Self {
        match e {
            SystemError::Mailbox(e) => actix_web::error::ErrorInternalServerError(e),
            SystemError::DieselError(e) => actix_web::error::ErrorInternalServerError(e),
        }
    }
}
