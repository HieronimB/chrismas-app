use crate::service::models::*;
use crate::service::DbExecutor;
use crate::service::SystemError;
use ::actix;
use actix::prelude::*;
use actix_web::*;
use diesel::prelude::*;
use log::debug;
use uuid::Uuid;

pub struct CreateDraw {
    pub name: String,
    pub participants: Vec<String>,
    pub excluded: Vec<(String, String)>,
}

impl Message for CreateDraw {
    type Result = Result<Uuid, SystemError>;
}

impl Handler<CreateDraw> for DbExecutor {
    type Result = Result<Uuid, SystemError>;

    fn handle(&mut self, msg: CreateDraw, _: &mut Self::Context) -> Self::Result {
        use crate::db::schema::drawn_excluded;
        use crate::db::schema::draws;
        use crate::db::schema::participants;

        debug!("Inserting new draw: {}", msg.name);

        let new_draw = NewDraw {
            id: Uuid::new_v4(),
            name: msg.name.clone(),
        };

        let draw_result = diesel::insert_into(draws::table)
            .values(&new_draw)
            .get_result::<Draw>(&self.0);

        draw_result
            .and_then(|draw| {
                let new_participants: Vec<NewParticipants> = msg
                    .participants
                    .iter()
                    .map(|p| NewParticipants {
                        name: p.clone(),
                        drawid: draw.id,
                    })
                    .collect();

                let participants_result = diesel::insert_into(participants::table)
                    .values(&new_participants)
                    .get_results(&self.0);

                participants_result
                    .and_then(|participants: Vec<Participants>| {
                        let excluded: Vec<NewExcluded> = msg
                            .excluded
                            .iter()
                            .map(|e| {
                                let participant = participants
                                    .iter()
                                    .find(|p| p.name == e.0)
                                    .expect("Could not find participant inserted into database");
                                let excluded = participants
                                    .iter()
                                    .find(|p| p.name == e.1)
                                    .expect("Could not find draw_excluded inserted into database");

                                NewExcluded {
                                    participantid: participant.id,
                                    excludedid: excluded.id,
                                    drawid: draw.id,
                                }
                            })
                            .collect();

                        diesel::insert_into(drawn_excluded::table)
                            .values(&excluded)
                            .execute(&self.0)
                    })
                    .and(Ok(draw.id))
            })
            .map_err(SystemError::DieselError)
    }
}
