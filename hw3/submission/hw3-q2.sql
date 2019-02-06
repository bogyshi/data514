/*
Find all origin cities that only serve flights shorter than 3 hours. You can assume that flights with NULL
actual_time are not 3 hours or more. (15 points)
Name the output column city and sort them. List each city only once in the result.
[Output relation cardinality: 109]
*/

Select Distinct F.ogCity as city
from (
    Select F1.ogCity, MAX(F1.actualTime) as time
    from allFlights as F1
    group by F1.ogCity
    having MAX(F1.actualTime)<180
)s
JOIN allFlights as F
ON
F.ogCity = s.ogCity
order by F.ogCity asc;

/*
Returns 109 rows, time: 13s
Aberdeen SD
Abilene TX
Alpena MI
Ashland WV
Augusta GA
Barrow AK
Beaumont/Port Arthur TX
Bemidji MN
Bethel AK
Binghamton NY
Brainerd MN
Bristol/Johnson City/Kingsport TN
Butte MT
Carlsbad CA
Casper WY
Cedar City UT
Chico CA
College Station/Bryan TX
Columbia MO
Columbus GA
*/
