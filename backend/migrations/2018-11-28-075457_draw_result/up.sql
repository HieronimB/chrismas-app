-- Your SQL goes here
CREATE TABLE draw_result (
  friend INTEGER REFERENCES friends(id),
  drawn INTEGER REFERENCES friends(id),
  PRIMARY KEY (friend, drawn)
)