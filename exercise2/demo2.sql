-- CSE 344 -- Basic SQL
-- Readings: 6.1, 6.2
--------------------------------------------------------------------------
------
--
--in this demo we use the following schema:
-- Product(pname, price, category, manufacturer)
-- Company(cname, country)
--------------------------------------------------------------------------
------
create table Company
(
  cname varchar(20) primary key,
  country varchar(20)
);
insert into Company  values ('GizmoWorks', 'USA');
insert into Company  values ('Canon',    'Japan');
insert into Company  values ('Hitachi',  'Japan');
--------------------------------------------------------------------------
------
--
--note: sql lite is REALLY light: it accepts many erroneous command,
-- which other RDBMS would not accept.  We will flag these as alerts.
-- Alert 1: As mentioned in the lecture 2 notes, sqlite allows a key to be
insert into Company values(NULL, 'Somewhere');
-- this is dangerous, since we cannot uniquely identify the tuple
-- better delete it before we get into trouble
delete from Company where country = 'Somewhere';
--------------------------------------------------------------------------
------
create table Product(
  pname varchar(20) primary key,
  price float,
  category varchar(20),
  manufacturer varchar(20) references Company
);
-- Alert 2: sqlite does NOT enforce foreign keys by default. To enable
-- foreign keys use the following command. The command will have no
-- effect if your version of SQLite was not compiled with foreign keys
-- enabled. Do not worry about it.
PRAGMA foreign_keys=ON;
insert into Product values('Gizmo',      19.99, 'gadget', 'GizmoWorks');
insert into Product values('PowerGizmo', 29.99, 'gadget', 'GizmoWorks');
insert into Product values('SingleTouch', 149.99, 'photography', 'Canon');
insert into Product values('MultiTouch', 199.99, 'photography',
'Hitachi');
insert into Product values('SuperGizmo', 49.99, 'gadget', 'Hitachi');
-- If we try:
insert into Product values('MultiTouch2', 199.99, 'photography', 'H2');
-- We should get an error if foreign keys got enforced
-- Error: foreign key constraint failed
--------------------------------------------------------------------------
------
--
--Notice that the data we created is stored on disk.
-- Quit sqlite3
--
--See that database file on disk has now a non-zero size.
-- It's a binary file. It contains the data for all our relations in one
--file.
-- When we come back to sqlite3, all our data is there.
--------------------------------------------------------------------------
------
--
--1. SELECTION queries select a subset of the table:
-- Before we start, let's switch to a better query output format
.mode column
.header ON
-- What do you think the following queries return?
select *
from Product
where price > 100.0;
select *
from Product
where pname like '%e%';
--------------------------------------------------------------------------
------
--
--2.  PROJECTION queries keep a subset of the attributes
select price, category
from Product;
--------------------------------------------------------------------------
------
--
--some minor variations: DISTINCT and ORDER BY
-- This query returns duplicates:
select category
from Product;
-- Wait a minute... didn't we say that relations were sets?
--Why
-- do we suddently see bags? Why isn't the DBMS eliminating duplicates?
--
-- Key reason is performance: eliminating duplicates is an expensive
-- operations.
-- So the DBMS will leave them if the user/application can tolerate them.
-- (Later we will learn that we also need to retain duplicates when we
-- compute aggregate values.)
-- To eliminate duplicates, use DISTINCT:
select distinct category
from Product;
-- We can also order the outputs using ORDER BY
-- order alphabetically by name:
select *
from product
order by pname;
-- order by price descending
select *
from product
order by price desc;
-- order by manufacturer, then price descenting
select *
from product
order by manufacturer, price desc;
-- What happens if we order on an attribute that we do NOT return ?
-- First, let's try:
select *
from Product
order by manufacturer;
-- Now, let's try:
select category
from Product
order by manufacturer;
-- What happens if we also do DISTINCT ?
-- The query should fail but...
-- Alert 3: sqlite does the wrong thing here, again:
select distinct category
from Product
order by manufacturer;
--------------------------------------------------------------------------
------
--
-- 3.  JOINS
-- What should the following query return?
select pname, price
from   Product, Company
where  manufacturer=cname and country='Japan' and price < 150;
-- Let's analyze it together on the white board.
-- Note that manufacturer=cname is called the "join predicate"
--------------------------------------------------------------------------
------
--
--***** In class:
-- *****
--Retreive all American companies that manufacture products in the 'gadget'
--category
--
--
--
--
--
--
SELECT DISTINCT cname
FROM Product, Company
WHERE country = 'USA' AND category = 'gadget'
AND manufacturer = cname;
-- **** Retreive all Japanese companies that manufacture products in
--      both the 'gadget' and the 'photography' categories
--
--
--
--
--
--
SELECT DISTINCT cname
FROM Product P1, Product P2, Company
WHERE country = 'Japan'
AND P1.category = 'gadget'
AND P2.category = 'photography'
AND P1.manufacturer = cname AND P2.manufacturer = cname;
-- Here is another example that illustrates outer joins:
-- Let's start with two tables:
--Employee(id, name) and Sales(employeeID, productID)
-- The tables have the following content
-- (1,'Joe')         (1, 344)
-- (2,'Jack')        (1, 355)
-- (3,'Jill')        (2, 544)
-- If we run a simple join, Jill will not appear in the result
-- because she did not make any sells.
-- If we run a left outer-join, Gill will be returned with a null sale.
-- We can similarly do right outer joins and full outer joins (but not in
-- sqlite)
-- Here is the example to run in sqlite:
create table Employee(id int, name varchar(10));
create table Sales(employeeID int, productID int);
insert into Employee values(1,'Joe');
insert into Employee values(2,'Jack');
insert into Employee values(3,'Jill');
insert into Sales values(1,344);
insert into Sales values(1,355);
insert into Sales values(2,544);
-- The following will miss Jill
select * from Employee E, Sales S where E.id = S.employeeID;
