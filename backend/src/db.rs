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
use schema::friends;

#[derive(Queryable, Debug, QueryableByName, Clone)]
#[table_name = "friends"]
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

pub fn fetch_number(connection: &PgConnection) -> usize {
    use schema::draw_result;
    use schema::friends;

    let count = friends::table
        .filter(friends::id.ne(all(
            draw_result::table
                .select(draw_result::friend)
        ))).load::<Friend>(connection);

    count.unwrap().len()
}

pub fn fetch_friends(friend: &Friend, connection: &PgConnection) -> Vec<Friend> {
    use schema::friends::dsl::*;
    use schema::draw_result;
    use schema::friends;
    use schema::drawn_excluded;
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
    use schema::friends::dsl::*;
    use schema::friends;
    let result = friends
        .filter(friends::firstname.eq(firstname_param))
        .filter(friends::lastname.eq(lastname_param))
        .first::<Friend>(connection);
    result
}

pub fn fetch_drawn(friend: &Friend, connection: &PgConnection) -> QueryResult<Friend> {
    use schema::draw_result;
    use schema::friends;
    let drawn_friend = draw_result::table
        .filter(draw_result::friend.eq(friend.id))
        .select(draw_result::drawn);
    let result = friends::table
        .filter(friends::id.eq(any(drawn_friend)))
        .first::<Friend>(connection);
    result
}

pub fn insert_drawn(friend: &Friend, drawn: &Friend, connection: &PgConnection) {
    use::schema::draw_result;

    let new_drawn = NewDrawn {
        friend: friend.id,
        drawn: drawn.id
    };

    diesel::insert_into(draw_result::table)
        .values(&new_drawn)
        .get_result::<DrawnResult>(connection)
        .expect("Error saving new drawn result");
}

pub fn is_excluded(friend: &Friend, connection: &PgConnection) -> QueryResult<Vec<Friend>> {

    diesel::sql_query(format!("select * from friends f where not exists(select * from draw_result dr where f.id = dr.drawn) and f.id in (select excluded from drawn_excluded where friend in (select f.id from friends f where not exists (select * from draw_result dr where f.id = dr.friend) and f.id != {}));", friend.id)).load(connection)


//    use schema::friends;
//    use schema::drawn_excluded;
//    use::schema::draw_result;
//
//    let dr = draw_result::table.filter(draw_result::drawn.eq(friends::id));
//    let ff: Vec<Friend> = friends::table
//        .filter( not(diesel::dsl::exists(dr)))
//        .load::<Friend>(&establish_connection()).unwrap();
//
//   let excluded_friends_ids: Vec<i32> = drawn_excluded::friend.eq(any(friends::table
//            .select(friends::id)
//            .filter(not(diesel::dsl::exists(draw_result::table.filter(draw_result::friend.eq(friends::id)))))
//            .filter(friends::id.ne(friend.id))
//        )).load(&establish_connection());
//
//
//    let filtered: Vec<Friend> = ff.iter()
//        .filter(|ff| excluded_friends_ids.contains(&ff.id))
//        .collect();
//
//    filtered.first().unwrap_or(ff[0]);


////    let excluded = drawn_excluded::table
////        .select(drawn_excluded::excluded)
////        .filter(bla).first(&establish_connection());
//
////    let val = friends::table
////        .filter(friends::id.eq(any(excluded)))
////        .first::<Friend>(&establish_connection());
//
//    friends::table
////        .select(friends::id)
//        .filter(not(diesel::dsl::exists(draw_result::table.filter(draw_result::friend.eq(friends::id)))))
//        .filter(friends::id.ne(friend.id)).first::<Friend>(&establish_connection());
//
//    friends::table
//        .filter(not(diesel::dsl::exists(draw_result::table.filter(draw_result::drawn.eq(friends::id)))))
//        .filter(friends::id.eq(any(drawn_excluded::table
//                                                    .select(drawn_excluded::excluded)
//                                                    .filter(drawn_excluded::friend.eq(any(friends::table
//                                                                                                        .select(friends::id)
//                                                                                                        .filter(not(diesel::dsl::exists(draw_result::table.filter(draw_result::friend.eq(friends::id)))))
//                                                                                                        .filter(friends::id.eq(friend.id))
//        )
//                                                    ))
//        ))).first::<Friend>(&establish_connection())
}

