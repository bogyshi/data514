/*
List all cities that cannot be reached from Seattle through a direct flight nor with one stop (i.e., with any
two flights that go through an intermediate city). Warning: this query might take a while to execute. We will
learn about how to speed this up in lecture. (15 points)
Name the output column city.
(You can assume all cities to be the collection of all origin_city or all dest_city)
(Note: Do not worry if this query takes a while to execute. We are mostly concerned with the results)
[Output relation cardinality: 3 or 4, depending on what you consider to be the set of all cities]

*/

--lets handle this in parts

--all cities that cannot be reached from Seattle though a direct flight
Select DISTINCT F.destCity as city
from allFlights as F
where F.destCity NOT IN
  (
    Select DISTINCT F2.destCity as city
    from allFlights as F1, allFlights as F2
    where
    (F1.ogCity = 'Seattle WA'
    and F1.destCity = F2.ogCity
    and F2.destCity <> 'Seattle WA')
  );



/*
Rows: 4
Time: 19s
Hattiesburg/Laurel MS
Devils Lake ND
St. Augustine FL
Seattle WA
*/
