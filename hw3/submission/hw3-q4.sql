/*
List all cities that cannot be reached from Seattle though a direct flight but can be reached with one stop
(i.e., with any two flights that go through an intermediate city). Do not include Seattle as one of these
destinations (even though you could get back with two flights). (15 points)
Name the output column city.

cardinality = 256
*/

Select DISTINCT F2.destCity as city
from allFlights as F1, allFlights as F2
where F1.ogCity = 'Seattle WA'
and F1.destCity = F2.ogCity
and F2.destCity <> 'Seattle WA'
and F2.destCity
NOT IN
  (
    Select Distinct FT.destCity from allFlights as FT
    where FT.ogCity = 'Seattle WA'
  );

/*
Rows:256
Time:14
Dothan AL
Toledo OH
Peoria IL
Yuma AZ
Bakersfield CA
Daytona Beach FL
Laramie WY
North Bend/Coos Bay OR
Erie PA
Guam TT
Columbus GA
Wichita Falls TX
Hartford CT
Myrtle Beach SC
Arcata/Eureka CA
Kotzebue AK
Medford OR
Providence RI
Green Bay WI
Santa Maria CA

*/
/*
seattle to memphis
memphis to dallas
seattle to nyc

another idea is to do a subquery where i find all cities that can be reached in two flights from Seattle
and then do a NOT IN statement from the outside query from the dest citys
so

Select F2.destCity from allFlights as F2 NOT IN
Select Distinct F2.destCity from allFlights as F2,allFLights as F1
where F1.ogCity = 'Seattle WA'
and F1.destCity = F2.ogCity
and F2.destCity <> 'Seattle WA'
)
*/
