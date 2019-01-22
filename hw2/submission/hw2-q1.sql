.mode columns
.header ON

Select DISTINCT F.flightNum as flight_num
from allFlights as F, allDays as D, allCarriers as C
where F.ogCity = 'Seattle WA' AND
F.destCity = 'Boston MA' and
F.carrierID = C.cid AND
C.carrierName = 'Alaska Airlines Inc.' and
F.dayOfWeekID = D.did AND
D.dayName = 'Monday';
--This isnt 3, whats wrong?
