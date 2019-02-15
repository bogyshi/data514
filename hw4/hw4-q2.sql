PRAGMA foreign_keys=ON;
Create table insuranceCo(
  name varchar(100) PRIMARY KEY,
  phone int
);
Create table person(
  name varchar(100),
  ssn int PRIMARY KEY,
  licensePlate varchar(12) REFERENCES vehicle(licensePlate)
);
Create table driver(
  driverID int,
  ssn int references person(ssn)
);
create table NonProfessionalDriver(
  ssn int references driver(ssn),
  medicalHistory varchar(10000)
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
