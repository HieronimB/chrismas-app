use diesel::prelude::*;
use dotenv::dotenv;
use std::env;
use schema::draw_result;
use diesel::pg::PgConnection;
use diesel;
use HttpFriend;
use diesel::expression::dsl::not;
use diesel::pg::expression::dsl::all;
use diesel::pg::expression::dsl::any;

#[derive(Queryable, Debug)]
pub struct Friend {
    pub id: i32,
    pub firstname: String,
    pub lastname: String
}

#[derive(Queryable)]
pub struct DrawnResult {
    pub friend: i32,
    pub drawn: i32,
}

#[derive(Insertable)]
#[table_name="draw_result"]
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

pub fn fetch_friends(friend: &Friend) -> Vec<Friend> {
    use schema::friends::dsl::*;
    use schema::draw_result;
    use schema::friends;
    let connection = establish_connection();
    let already_drawn = draw_result::table.select(draw_result::drawn);
    let drawn_by_friend = draw_result::table
        .select(draw_result::friend)
        .filter(draw_result::drawn.eq(friend.id));
    let result = friends
        .filter(not(friends::id.eq(friend.id)))
        .filter(friends::id.ne(all(already_drawn)))
        .filter(friends::id.ne(all(drawn_by_friend)))
        .load::<Friend>(&connection).expect("Error");
    result
}

pub fn fetch_friend(firstname_param: &str, lastname_param: &str) -> QueryResult<Friend> {
    use schema::friends::dsl::*;
    use schema::friends;
    let connection = establish_connection();
    let result = friends
        .filter(friends::firstname.eq(firstname_param))
        .filter(friends::lastname.eq(lastname_param))
        .first::<Friend>(&connection);
    result
}

pub fn fetch_drawn(friend: &Friend) -> QueryResult<Friend> {
    use schema::draw_result;
    use schema::friends;
    let drawn_friend = draw_result::table
        .filter(draw_result::friend.eq(friend.id))
        .select(draw_result::drawn);
    let result = friends::table
        .filter(friends::id.eq(any(drawn_friend)))
        .first::<Friend>(&establish_connection());
    result
}

pub fn insert_drawn(friend: &Friend, drawn: &Friend) {
    use::schema::draw_result;

    let new_drawn = NewDrawn {
        friend: friend.id,
        drawn: drawn.id
    };

    diesel::insert_into(draw_result::table)
        .values(&new_drawn)
        .get_result::<DrawnResult>(&establish_connection())
        .expect("Error saving new drawn result");
}

