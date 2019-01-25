/*
For each origin city, find the percentage of departing flights shorter than 3 hours. For this question, treat
flights with NULL actual_time values as longer than 3 hours. (15 points)
Name the output columns origin_city and percentage Order by percentage value. Be careful to
handle cities without any flights shorter than 3 hours. We will accept both 0 and NULL as the result for
those cities.
[Output relation cardinality: 327]

*/


/*
origin_city



numFlights

percentage
Aberdeen SD

0

0


Cedar City UT

0

0


Cordova AK

0

0


Deadhorse AK

0

0


Dickinson ND

0

0


Dillingham AK

0

0


El Centro CA

0

0


Garden City KS

0

0


Gillette WY

0

0


Guam TT

0

0


Hattiesburg/Laurel MS

0

0


Hayden CO

0

0


Hilo HI

0

0


Hyannis MA

0

0


Laramie WY

0

0


Lewisburg WV

0

0


Marthas Vineyard MA

0

0


New Bern/Morehead/Beaufort NC

0

0


Niagara Falls NY

0

0


Pago Pago TT,0,0
*/
Select a.ogCity as origin_city,
ISNULL(c.numAbove,0),
ISNULL(b.numAbove,0),
d.numFlights,
((ISNULL(b.numAbove,0)*1.0)/d.numFlights*1.0) as percentage from
(
 Select Distinct FC.ogCity from allFlights as FC
)
as a
LEFT JOIN
(
Select Distinct FB.ogCity, Count(*) as numabove from allFlights as FB where FB.actualTime is NULL group by FB.ogCity
)
as b
ON a.ogCity = b.ogCity
LEFT JOIN
(
    Select Distinct FB.ogCity, Count(*) as numabove from allFlights as FB where FB.actualTime>180 group by FB.ogCity
)
as c
ON b.ogCity = c.ogCity
LEFT JOIN
(
    Select Distinct FD.ogCity, Count(*) as numFlights from allFlights as FD group by FD.ogCity
)
as d
ON b.ogCity = d.ogCity
order by percentage asc;
--THE ABOVE IS CORRECT. FOR SOME REASON THE SOLUTION BELOW IS NOT THE SAME
--alt solution

Select a.ogCity as origin_city,
((ISNULL(b.numAbove,0)*1.0)/d.numFlights*1.0) as percentage from
(
 Select Distinct FC.ogCity from allFlights as FC
)
as a
JOIN
(
Select Distinct FB.ogCity, Count(*) as numabove from allFlights as FB where FB.actualTime is NULL or FB.actualTime>180 group by FB.ogCity
)
as b
ON a.ogCity = b.ogCity
JOIN
(
    Select Distinct FD.ogCity, Count(*) as numFlights from allFlights as FD group by FD.ogCity
)
as d
ON b.ogCity = d.ogCity
order by percentage asc;

--THE ABOVE IS CORRECT


Select Distinct F.ogCity as city, Count(F.actualTime <180)/
from (
    Select F1.ogCity, MAX(F1.actualTime) as time
    from allFlights as F1
    group by F1.ogCity
    having MAX(F1.actualTime)<180
)s
JOIN allFlights as F
ON
F.ogCity = s.ogCity
order by F.ogCity DESC;

Select DISTINCT F.ogCity from
    (Select FT.ogCity, COUNT(*) as num
    from
    (
        Select FT2.ogCity as tCity, ISNULL(FT2.actualTime, 180) as modTimes FROM allFlights as FT2
    ) s2
    join allFlights as FT
    ON
    s2.tCity =  FT.ogCity
    where FT.actualTime<180
    group by FT.ogCity
    ) s
join allFlights as F
ON
s.ogCity = F.ogCity
order by F.ogCity asc;



Select a.numAbove+b.numAbove from
(
Select Distinct FA.ogCity, Count(*) as numabove from allFlights as FA where FA.actualTime>180 group by FA.ogCity
) as a JOIN
(
Select Distinct FB.ogCity, Count(*) as numabove from allFlights as FB where FB.actualTime is NULL group by FB.ogCity
) as b
ON a.ogCity = b.ogCity;

/*
Select Distinct ogCity from allFlights where actualTime>180 group by ogCity
affected rows = 216

Select Distinct ogCity from allFlights where actualTime<180 group by ogCity
affected rows = 325

Select Distinct ogCity from allFlights where actualTime is NULL group by ogCity
Affected rows: 299.

Select Distinct ogCity from allFlights
Affected rows: 327.

Select a.numAbove+b.numAbove from
(
Select Distinct FA.ogCity, Count(*) as numabove from allFlights as FA where FA.actualTime>180 group by FA.ogCity
) as a FULL OUTER JOIN
(
Select Distinct FB.ogCity, Count(*) as numabove from allFlights as FB where FB.actualTime is NULL group by FB.ogCity
) as b
ON a.ogCity = b.ogCity;
Affected rows: 307.



Select c.numAbove+b.numAbove from
(
 Select Distinct FC.ogCity from allFlights as FC
) as a JOIN
(
Select Distinct FB.ogCity, Count(*) as numabove from allFlights as FB where FB.actualTime is NULL group by FB.ogCity
) as b
ON a.ogCity = b.ogCity JOIN
(
   Select Distinct FA.ogCity, Count(*) as numabove from allFlights as FA where FA.actualTime>180 group by FA.ogCity

) as c
ON b.ogCity = c.ogCity;

Affected rows: 208.
It seems that all rows that were not found in each iteration are simple elimated. I want to ideally not have that be the case.
*/
