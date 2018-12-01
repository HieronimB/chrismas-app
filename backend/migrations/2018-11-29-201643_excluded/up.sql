-- Your SQL goes here
CREATE TABLE drawn_excluded (
  friend INTEGER REFERENCES friends(id),
  excluded INTEGER REFERENCES friends(id),
  PRIMARY KEY (friend, excluded)
)