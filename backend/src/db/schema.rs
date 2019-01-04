// Temporal silence until diesel-1.4.
// See <https://github.com/diesel-rs/diesel/issues/1785#issuecomment-422579609>.
#![allow(proc_macro_derive_resolution_fallback)]

table! {
    drawn_excluded (participantid, excludedid) {
        participantid -> Int4,
        excludedid -> Int4,
        drawid -> Int4,
    }
}

table! {
    draw_result (participantid, drawnid) {
        participantid -> Int4,
        drawnid -> Int4,
        drawid -> Int4,
    }
}

table! {
    draws (id) {
        id -> Int4,
        name -> Varchar,
    }
}

table! {
    participants (id) {
        id -> Int4,
        name -> Varchar,
        drawid -> Int4,
    }
}

joinable!(draw_result -> draws (drawid));
joinable!(drawn_excluded -> draws (drawid));
joinable!(participants -> draws (drawid));

allow_tables_to_appear_in_same_query!(drawn_excluded, draw_result, draws, participants,);
