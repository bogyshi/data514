USE Data514W
Create table allMonths(
  mid integer PRIMARY KEY,
  monthName varChar(9)
);
Create table allCarriers(
  cid varchar(7) PRIMARY KEY,
  carrierName varChar(83)
);
Create table allFlights(
  flightID integer PRIMARY KEY,
  year INTEGER,
  monthID INTEGER REFERENCES allMonths(mid),
  dayOfMonth Integer,
  dayOfWeekID integer REFERENCES allDays(did),
  carrierID varchar(7) REFERENCES allCarriers(cid),
  flightNum integer,
  ogCity varchar(34),
  ogState varChar(47),
  destCity varChar(34),
  destState varChar(47),
  departDT real,
  taxiTime real,
  arrivDT real,
  canceled int,
  actualTime real,
  distance real,
  capacity int,
  price real
);