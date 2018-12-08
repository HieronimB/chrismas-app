use diesel::prelude::*;
use dotenv::dotenv;
use std::env;
use crate::schema::draw_result;
use diesel::pg::PgConnection;
use diesel;
use crate::HttpFriend;
use diesel::expression::dsl::not;
use diesel::pg::expression::dsl::all;
use diesel::pg::expression::dsl::any;
use crate::schema::friends;

#[derive(Queryable, Debug, QueryableByName, Clone)]
#[table_name = "friends"]
pub struct Friend {
    pub id: i32,
    pub firstname: String,
    pub lastname: String,
}

#[derive(Queryable)]
pub struct DrawnResult {
    pub friend: i32,
    pub drawn: i32,
}

#[derive(Insertable)]
#[table_name = "draw_result"]
pub struct NewDrawn {
    pub friend: i32,
    pub drawn: i32,
}

pub fn establish_connection() -> PgConnection { //TODO establish connection only once
    dotenv().ok();

    let database_url = env::var("DATABASE_URL")
        .expect("DATABASE_URL must be set");
    PgConnection::establish(&database_url)
        .expect(&format!("Error connecting to {}", database_url))
}

pub fn fetch_number(connection: &PgConnection) -> usize {
    use crate::schema::draw_result;
    use crate::schema::friends;

    let count = friends::table
        .filter(friends::id.ne(all(
            draw_result::table
                .select(draw_result::friend)
        ))).load::<Friend>(connection);

    count.unwrap().len()
}

pub fn fetch_friends(friend: &Friend, connection: &PgConnection) -> Vec<Friend> {
    use crate::schema::friends::dsl::*;
    use crate::schema::draw_result;
    use crate::schema::friends;
    use crate::schema::drawn_excluded;
    let already_drawn = draw_result::table.select(draw_result::drawn);
    let drawn_by_friend = draw_result::table
        .select(draw_result::friend)
        .filter(draw_result::drawn.eq(friend.id));
    let excluded = drawn_excluded::table
        .select(drawn_excluded::excluded)
        .filter(drawn_excluded::friend.eq(friend.id));
    let result = friends
        .filter(not(friends::id.eq(friend.id)))
        .filter(friends::id.ne(all(already_drawn)))
        .filter(friends::id.ne(all(excluded)))
        .load::<Friend>(connection).expect("Error");
    result
}

pub fn fetch_friend(firstname_param: &str, lastname_param: &str, connection: &PgConnection) -> QueryResult<Friend> {
    use crate::schema::friends::dsl::*;
    use crate::schema::friends;
    let result = friends
        .filter(friends::firstname.eq(firstname_param))
        .filter(friends::lastname.eq(lastname_param))
        .first::<Friend>(connection);
    result
}

pub fn fetch_drawn(friend: &Friend, connection: &PgConnection) -> QueryResult<Friend> {
    use crate::schema::draw_result;
    use crate::schema::friends;
    let drawn_friend = draw_result::table
        .filter(draw_result::friend.eq(friend.id))
        .select(draw_result::drawn);
    let result = friends::table
        .filter(friends::id.eq(any(drawn_friend)))
        .first::<Friend>(connection);
    result
}

pub fn insert_drawn(friend: &Friend, drawn: &Friend, connection: &PgConnection) {
    use crate::schema::draw_result;

    let new_drawn = NewDrawn {
        friend: friend.id,
        drawn: drawn.id,
    };

    diesel::insert_into(draw_result::table)
        .values(&new_drawn)
        .get_result::<DrawnResult>(connection)
        .expect("Error saving new drawn result");
}

pub fn is_excluded(friend: &Friend, connection: &PgConnection) -> QueryResult<Vec<Friend>> {
    diesel::sql_query(format!("select * from friends f \
                                        where \
                                        not exists(select * from draw_result dr where f.id = dr.drawn) \
                                        and \
                                        f.id in (select excluded from drawn_excluded where friend in (select f.id from friends f where not exists (select * from draw_result dr where f.id = dr.friend) \
                                        and \
                                        f.id != {0}))\
                                        and
                                        f.id not in (select excluded from drawn_excluded de where de.friend = {0});",
                              friend.id)).load(connection)
}

