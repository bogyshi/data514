CREATE TABLE Edges (
       source INTEGER,
       destination INTEGER
);

INSERT INTO Edges VALUES (10, 5);
INSERT INTO Edges VALUES (6, 25);
INSERT INTO Edges VALUES (1, 3);
INSERT INTO Edges VALUES (4, 4);

SELECT *
  FROM Edges;

SELECT source
  FROM Edges;

SELECT *
  FROM Edges
 WHERE source > destination;

INSERT INTO Edges VALUES ('-1', '2000');
-- This throws no error because SQL does not check value type against the
-- declared column type. Type affinity is a suggestion not a rule