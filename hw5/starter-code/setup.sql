-- add all your SQL setup statements here.

-- You can assume that the following base table has been created with data loaded for you when we test your submission
-- (you still need to create and populate it in your instance however),
-- although you are free to insert extra ALTER COLUMN ... statements to change the column
-- names / types if you like.

/*
CREATE TABLE FLIGHTS
 (
 fid int NOT NULL PRIMARY KEY,
 year int,
  month_id int,
  day_of_month int,
  day_of_week_id int,
  carrier_id varchar(3),
  flight_num int,
  origin_city varchar(34),
  origin_state varchar(47),
  dest_city varchar(34),
  dest_state varchar(46),
  departure_delay double precision,
  taxi_out double precision,
  arrival_delay double precision,
  canceled int,
  actual_time double precision,
  distance double precision,
  capacity int,
  price double precision
)
*/
Create TABLE Users
(
	username varchar(20) PRIMARY KEY,
	password varchar(20) NOT NULL,
	balance real
)

Create TABLE Capacities
(
	flightID int REFERENCES FLIGHTS(fid),
	maxCapacity int,
	currentCapacity int
)

Create Table ReservationIDCounter(
	currentIDs int
)

INSERT into ReservationIDCounter VALUES(1)

Create TABLE UserSearches
(
	username varchar(20) REFERENCES Users(username),
	origin_city varchar(100),
	dest_city varchar(100),
	direct_flight bit,
	day_of_month int,
	num_iten int
)

Create Table Itineraries
(
	intineraryID int PRIMARY KEY,
	flight1 int REFERENCES FLIGHTS(fid),
	flight2 int REFERENCES FLIGHTS(fid)
)

Create Table Reservations
(
	reservationID int PRIMARY KEY,
	username varchar(20) REFERENCES Users(username),
	flightDay int,
	flight1 int REFERENCES FLIGHTS(fid),
	flight2 int REFERENCES FLIGHTS(fid) NULL,
	paid bit
)
