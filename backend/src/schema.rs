table! {
    draw_result (friend, drawn) {
        friend -> Int4,
        drawn -> Int4,
    }
}

table! {
    drawn_excluded (friend, excluded) {
        friend -> Int4,
        excluded -> Int4,
    }
}

table! {
    flyway_schema_history (installed_rank) {
        installed_rank -> Int4,
        version -> Nullable<Varchar>,
        description -> Varchar,
        #[sql_name = "type"]
        type_ -> Varchar,
        script -> Varchar,
        checksum -> Nullable<Int4>,
        installed_by -> Varchar,
        installed_on -> Timestamp,
        execution_time -> Int4,
        success -> Bool,
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
    draw_result,
    drawn_excluded,
    flyway_schema_history,
    friends,
);
