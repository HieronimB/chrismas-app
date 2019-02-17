use crate::service::DbExecutor;
use crate::service::SystemError;
use actix::Handler;
use actix::Message;
use diesel::prelude::*;
use log::debug;
use uuid::Uuid;

pub struct FindDrawn {
    pub draw_id: Uuid,
    pub participant: String,
}

impl Message for FindDrawn {
    type Result = Result<String, SystemError>;
}

impl Handler<FindDrawn> for DbExecutor {
    type Result = Result<String, SystemError>;

    fn handle(&mut self, msg: FindDrawn, _ctx: &mut Self::Context) -> Self::Result {
        use crate::db::schema::draw_result;
        use crate::db::schema::participants;

        debug!("Executing find drawn: {} {}", msg.draw_id, msg.participant);

        let participant_id_result: QueryResult<i32> = participants::table
            .select(participants::id)
            .filter(participants::name.eq(&msg.participant))
            .filter(participants::drawid.eq(&msg.draw_id))
            .first::<i32>(&self.0);

        participant_id_result
            .and_then(|participant_id| {
                let drawn_id_result: QueryResult<i32> = draw_result::table
                    .select(draw_result::drawnid)
                    .filter(draw_result::drawid.eq(&msg.draw_id))
                    .filter(draw_result::participantid.eq(participant_id))
                    .first::<i32>(&self.0);

                drawn_id_result.and_then(|drawn_id| {
                    participants::table
                        .select(participants::name)
                        .filter(participants::id.eq(drawn_id))
                        .first::<String>(&self.0)
                })
            })
            .map_err(SystemError::DieselError)
    }
}
