CREATE TABLE participants (
  id SERIAL PRIMARY KEY,
  name VARCHAR NOT NULL,
  drawId INTEGER REFERENCES draws(id) NOT NULL
)