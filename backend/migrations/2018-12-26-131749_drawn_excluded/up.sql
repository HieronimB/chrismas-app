CREATE TABLE drawn_excluded (
  participantId INTEGER REFERENCES participants(id) NOT NULL,
  excludedId INTEGER REFERENCES participants(id) NOT NULL,
  drawId UUID REFERENCES draws(id) NOT NULL,
  PRIMARY KEY (participantId, excludedId)
)