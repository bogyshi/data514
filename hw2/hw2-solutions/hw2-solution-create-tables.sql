-- create-tables.sql
-- Import the flights datasets into the current database.
-- to run, do sqlite3 <db name> then .read <this file> at the sqlite3 prompt
-- CSE 344, homework 2 solution

create table Carriers(cid varchar(10) primary key, name varchar(100));

create table Months(mid int primary key, month varchar(10));	

create table Weekdays(did int primary key, day_of_week varchar(10));

create table Flights(
fid int, 
year int, 
month_id int references Months, 
day_of_month int, 
day_of_week_id int references Weekdays, 
carrier_id varchar(10) references Carriers, 
flight_num varchar(100), 
origin_city varchar(100), 
origin_state varchar(100), 
dest_city varchar(100), 
dest_state varchar(100), 
departure_delay real,  
taxi_out real, 
arrival_delay real, 
canceled int, 
actual_time real, 
distance real, 
capacity int,
price double,
primary key(fid));

.separator ","

PRAGMA foreign_keys=ON;

.import weekdays.csv Weekdays

.import months.csv Months

.import carriers.csv Carriers

.import flights-small.csv Flights
/* The data is somewhat dirty. Expect 4 errors related to primary key being duplicated. Ignore those errors */
