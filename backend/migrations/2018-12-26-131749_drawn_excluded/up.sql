CREATE TABLE drawn_excluded (
  participantId INTEGER REFERENCES participants(id),
  excludedId INTEGER REFERENCES participants(id),
  drawId INTEGER REFERENCES draws(id),
  PRIMARY KEY (participantId, excludedId)
)