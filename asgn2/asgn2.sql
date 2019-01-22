.mode columns
.header on
CREATE TABLE Arc (
      x integer,
      y integer
);
INSERT INTO Arc VALUES (1,2);
INSERT INTO Arc VALUES (1,2);
INSERT INTO Arc VALUES (2,3);
INSERT INTO Arc VALUES (3,4);
INSERT INTO Arc VALUES (3,4);
INSERT INTO Arc VALUES (4,1);
INSERT INTO Arc VALUES (4,1);
INSERT INTO Arc VALUES (4,1);
INSERT INTO Arc VALUES (4,2);
/*
The below makes sense, as we are creating two instances of the table by creating
Arc a1 and Arc a2, and a1.x and a2.y are al the xs and all the ys from each table respecitvely
we are then asking for the counts for all times when there is a y in the first table that equals
an x in the second table. wo looking through, we can count how many times a y is ever equal to an x
note this is much different that asking for tuples where x and y are the same
as we cant look over all xs and ys, as they are matched pairwise alone.
*/
SELECT a1.x, a2.y
FROM Arc a1, Arc a2;

SELECT a1.x, a2.y, COUNT(*)
FROM Arc a1, Arc a2;

SELECT a1.x, a2.y
FROM Arc a1, Arc a2
WHERE a1.y = a2.x;

SELECT a1.x, a2.y, COUNT(*)
FROM Arc a1, Arc a2
WHERE a1.y = a2.x;

SELECT a1.x, a2.y, COUNT(*)
FROM Arc a1, Arc a2
WHERE a1.y = a2.x
GROUP BY a1.x, a2.y;

CREATE TABLE R (
      A integer,
      B integer
);
CREATE TABLE S (
      C integer,
      D integer
);
CREATE TABLE T (
      E integer,
      F integer
);

INSERT INTO R VALUES (0,1);
INSERT INTO R VALUES (1,0);
INSERT INTO R VALUES (1,1);
INSERT INTO S VALUES (0,1);
INSERT INTO S VALUES (1,0);
INSERT INTO S VALUES (1,1);
INSERT INTO T VALUES (0,1);
INSERT INTO T VALUES (1,0);
INSERT INTO T VALUES (1,1);

SELECT A, F, SUM(C), SUM(D)
     FROM R, S, T
     WHERE B = C AND D = E;

SELECT A, F, SUM(C), SUM(D)
     FROM R, S, T
     WHERE B = C AND D = E
     GROUP BY A, F;

SELECT A, F, SUM(C), SUM(D)
     FROM R, S, T
     WHERE B = C AND D = E
     GROUP BY A, F
     HAVING COUNT(*) > 1;
/*
When we ask for information form all three tables, it generates the entire possible space
meaing we get every combination of tuples from R,S, and T. It then filters based on the SELECT
and WHERE statement to reduce the set size. after which the SUM is computed.
the group by seperates into all tuples of A,F in which the where statement is true and sums the counts for C and D
*/

Create TABLE Scores (
    Team varChar(50),
    Day varChar(10),
    Opponent varChar(50),
    Runs integer
);

INSERT INTO SCORES VALUES('Dragons', 'Sunday', 'Swallows',4);
INSERT INTO SCORES VALUES('Tigers', 'Sunday', 'Bay Stars',9);
INSERT INTO SCORES VALUES('Carp', 'Sunday', null,null);
INSERT INTO SCORES VALUES('Swallows', 'Sunday', 'Dragons',7);
INSERT INTO SCORES VALUES('Bay Stars', 'Sunday', 'Tigers',2);
INSERT INTO SCORES VALUES('Giants', 'Sunday', null,null);
INSERT INTO SCORES VALUES('Dragons', 'Monday', 'Carp',null);
INSERT INTO SCORES VALUES('Tigers', 'Monday', null,null);
INSERT INTO SCORES VALUES('Carp', 'Monday', 'Dragons',null);
INSERT INTO SCORES VALUES('Swallows', 'Monday', 'Giants',0);
INSERT INTO SCORES VALUES('Bay Stars', 'Monday', null,null);
INSERT INTO SCORES VALUES('Giants', 'Monday', 'Swallows',5);

SELECT Opponent, COUNT(*), AVG(Runs)
     FROM Scores
     GROUP BY Opponent;
