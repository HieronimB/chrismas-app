CREATE TABLE draw_result (
  participantId INTEGER REFERENCES participants(id) NOT NULL,
  drawnId INTEGER REFERENCES participants(id) NOT NULL,
  drawId UUID REFERENCES draws(id) NOT NULL,
  PRIMARY KEY (participantId, drawnId)
)