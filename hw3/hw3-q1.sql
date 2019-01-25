/*
For each origin city, find the destination city (or cities) with the longest direct flight. By direct flight, we
mean a flight with no intermediate stops. Judge the longest flight in time, not distance. (15 points)
Name the output columns origin_city, dest_city, and time representing the the flight time
between them. Do not include duplicates of the same origin/destination city pair. Order the result by
origin_city and then dest_city.
[Output relation cardinality: 334 rows]
*/
with a AS (
  SELECT F.flightID,F.ogCity,F.actualTime,F.destCity
  FROM allFlights as F
),b as(
  SELECT F.ogCity, MAX(F.actualTime) as actualTime
  FROM allFlights as F
  GROUP BY F.ogCity
)
Select distinct(a.destCity) as dest_city, a.ogCity as origin_city, a.actualTime as time
from a inner join b ON a.ogCity = b.ogCity and a.actualTime = b.actualTime
order by a.ogCity ASC, a.destCity ASC;
--this only outputs 329
-- further note, there are no duplicates, or if there are, there are equal number duplicates in both origin
-- and destination cities.


-- Question, are we asking for all possible end destinations one city can have with only one stop what that maximum flight time looks like?
-- OR are we asking for only the list of cities with the same if equal maximum length actual time?
