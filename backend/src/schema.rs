table! {
    drawn_excluded (friend, excluded) {
        friend -> Int4,
        excluded -> Int4,
    }
}

table! {
    draw_result (friend, drawn) {
        friend -> Int4,
        drawn -> Int4,
    }
}

table! {
    friends (id) {
        id -> Int4,
        firstname -> Varchar,
        lastname -> Varchar,
    }
}

allow_tables_to_appear_in_same_query!(
    drawn_excluded,
    draw_result,
    friends,
);
