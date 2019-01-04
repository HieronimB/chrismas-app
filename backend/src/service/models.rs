// Temporal silence until diesel-1.4.
// See <https://github.com/diesel-rs/diesel/issues/1785#issuecomment-422579609>.
#![allow(proc_macro_derive_resolution_fallback)]

use crate::db::schema::draw_result;
use crate::db::schema::drawn_excluded;
use crate::db::schema::draws;
use crate::db::schema::participants;
use diesel::{Insertable, Queryable};

#[derive(Insertable)]
#[table_name = "draws"]
pub struct NewDraw {
    pub name: String,
}

#[derive(Queryable)]
pub struct Draw {
    pub id: i32,
    pub name: String,
}

#[derive(Insertable)]
#[table_name = "participants"]
pub struct NewParticipants {
    pub name: String,
    pub drawid: i32,
}

#[derive(Queryable)]
pub struct Participants {
    pub id: i32,
    pub name: String,
    pub drawid: i32,
}

#[derive(Insertable)]
#[table_name = "drawn_excluded"]
pub struct NewExcluded {
    pub participantid: i32,
    pub excludedid: i32,
    pub drawid: i32,
}

#[derive(Insertable)]
#[table_name = "draw_result"]
pub struct NewDrawResult {
    pub participantid: i32,
    pub drawnid: i32,
    pub drawid: i32,
}
