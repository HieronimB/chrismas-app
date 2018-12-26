CREATE TABLE draw_result (
  participantId INTEGER REFERENCES participants(id),
  drawnId INTEGER REFERENCES participants(id),
  drawId INTEGER REFERENCES draws(id),
  PRIMARY KEY (participantId, drawnId)
)