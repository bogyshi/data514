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

/*
Rows: 329
Time: 12s
Minneapolis MN	Aberdeen SD	106
Dallas/Fort Worth TX	Abilene TX	111
Anchorage AK	Adak Island AK	471.37
New York NY	Aguadilla PR	368.76
Atlanta GA	Akron OH	408.69
Atlanta GA	Albany GA	243.45
Atlanta GA	Albany NY	390.31
Houston TX	Albuquerque NM	492.81
Atlanta GA	Alexandria LA	391.05
Atlanta GA	Allentown/Bethlehem/Easton PA	456.95
Detroit MI	Alpena MI	80
Houston TX	Amarillo TX	390.73
Barrow AK	Anchorage AK	490.01
Atlanta GA	Appleton WI	405.07
San Francisco CA	Arcata/Eureka CA	476.89
Chicago IL	Asheville NC	279.81
Cincinnati OH	Ashland WV	84
Los Angeles CA	Aspen CO	304.59
Honolulu HI	Atlanta GA	649
Fort Lauderdale FL	Atlantic City NJ	212
*/