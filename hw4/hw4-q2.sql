PRAGMA foreign_keys=ON;
Create table insuranceCo(
  name varchar(100) PRIMARY KEY,
  phone int
);
Create table person(
  name varchar(100),
  ssn int PRIMARY KEY
);
Create table driver(
  driverID int,
  ssn int references person(ssn)
);
create table NonProfessionalDriver(
  ssn int references driver(ssn)
);
create table ProfessionalDriver(
  ssn int references driver(ssn),
  medicalHistory varchar(10000)
);
create table vehicle(
  licensePlate varchar(12) PRIMARY KEY,
  year int
);
create table car(
  make varchar(100),
  licensePlate varchar(100) references vehicle(licensePlate)
);
create table truck(
  capacity varchar(100),
  licensePlate varchar(100) references vehicle(licensePlate)
);
create table drives(
  licensePlate varchar(100) references vehicle(licensePlate),
  ssn int references person(ssn)
);
create table operates(
  licensePlate varchar(12) references vehicle(licensePlate),
  ssn int references person(ssn)
);
create table owns(
  licensePlate varchar(12) references vehicle(licensePlate),
  ssn int references person(ssn)
);
create table insures(
  maxliability real,
  name varchar(100) references insuranceCo(name),
  licensePlate varchar(12) references vehicle(licensePlate)
);
/*
2q1)
my insures relation represents the insures relationship in the ER diagram. This is my representation as we have a realtionship with its own attribute,
so it isnt really feasible to combine the data in one of the two other relations

2q2)
My operates relation is different than the drives representation simply due to how a professional driver can drive 0 or many trucks, unlike our drives relation with
nonprofessional drivers. Another way to think about it is that a professional driver operates at least one truck.
*/
