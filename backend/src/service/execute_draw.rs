use crate::draw::backtracking_algorithm::BacktrackingAlgorithm;
use crate::service::models::*;
use crate::service::DbExecutor;
use actix;
use actix::prelude::*;
use actix_web::error;
use actix_web::*;
use diesel::prelude::*;
use log::debug;
use rand::thread_rng;
use rand::seq::SliceRandom;

pub struct ExecuteDraw {
    pub name: String,
}

impl Message for ExecuteDraw {
    type Result = Result<usize, Error>;
}

impl Handler<ExecuteDraw> for DbExecutor {
    type Result = Result<usize, Error>;

    fn handle(&mut self, msg: ExecuteDraw, _: &mut Self::Context) -> Self::Result {
        use crate::db::schema::draw_result;
        use crate::db::schema::drawn_excluded;
        use crate::db::schema::draws;
        use crate::db::schema::participants;

        debug!("Executing draw: {}", msg.name);

        let draw_result: QueryResult<i32> = draws::table
            .select(draws::id)
            .filter(draws::name.eq(&msg.name))
            .first::<i32>(&self.0);

        draw_result
            .and_then(|drawid| {
                let mut participants: Vec<i32> = participants::table
                    .select(participants::id)
                    .filter(participants::drawid.eq(drawid))
                    .load::<i32>(&self.0)?;

                participants.shuffle(&mut thread_rng());
                let participants_to_draw = participants.clone();

                participants.shuffle(&mut thread_rng());

                let excluded = drawn_excluded::table
                    .select((drawn_excluded::participantid, drawn_excluded::excludedid))
                    .filter(drawn_excluded::drawid.eq(drawid))
                    .load::<(i32, i32)>(&self.0)?;

                let bta = BacktrackingAlgorithm::new(participants_to_draw, participants, excluded);
                let draw_result = bta.draw();

                let new_draw_result: Vec<NewDrawResult> = draw_result
                    .iter()
                    .map(|dr| NewDrawResult {
                        participantid: dr.0,
                        drawnid: dr.1,
                        drawid,
                    })
                    .collect();

                diesel::insert_into(draw_result::table)
                    .values(&new_draw_result)
                    .execute(&self.0)
            })
            .map_err(error::ErrorInternalServerError)
    }
}
