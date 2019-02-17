use crate::service::DbExecutor;
use crate::service::SystemError;
use actix::Handler;
use actix::Message;
use diesel::prelude::*;
use log::debug;
use uuid::Uuid;

pub struct FindParticipants {
    pub draw_id: Uuid,
}

impl Message for FindParticipants {
    type Result = Result<Vec<String>, SystemError>;
}

impl Handler<FindParticipants> for DbExecutor {
    type Result = Result<Vec<String>, SystemError>;

    fn handle(&mut self, msg: FindParticipants, _ctx: &mut Self::Context) -> Self::Result {
        use crate::db::schema::participants;

        debug!("Executing find participants: {}", msg.draw_id);

        let participants: QueryResult<Vec<String>> = participants::table
            .select(participants::name)
            .filter(participants::drawid.eq(&msg.draw_id))
            .load::<String>(&self.0);

        participants.map_err(SystemError::DieselError)
    }
}
