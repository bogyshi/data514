.mode columns
.header on
CREATE TABLE Edges (
      Source integer,
      Destination integer
);
INSERT INTO Edges
       VALUES(10,5);
INSERT INTO Edges VALUES(6,25);
INSERT INTO Edges VALUES(1,3);
INSERT INTO Edges VALUES(4,4);

select * from Edges; --#1
select Source from Edges; --#1
Select * from Edges where Source>Destination; -- #1
insert into Edges
       Values('-1','1000');--#1
/*
"SQLite supports the concept of "type affinity" on columns. The type affinity of a column is the recommended type for data stored in that column. The important idea here is that the type is recommended, not required. Any column can still store any type of data. It is just that some columns, given the choice, will prefer to use one storage class over another. The preferred storage class for a column is called its "affinity". " ~ sqlite.org/datatype3.html
As we can see, since sqlite is not a static and rigid container for these values in the columns like most other SQL data base engines, it allows for the last insert to operate.
Answer found from here : http://www.sqlite.org/datatype3.html
*/
