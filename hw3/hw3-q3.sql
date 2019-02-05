/*
For each origin city, find the percentage of departing flights shorter than 3 hours. For this question, treat
flights with NULL actual_time values as longer than 3 hours. (15 points)
Name the output columns origin_city and percentage Order by percentage value. Be careful to
handle cities without any flights shorter than 3 hours. We will accept both 0 and NULL as the result for
those cities.
[Output relation cardinality: 327]

*/



Select a.ogCity as origin_city,
--ISNULL(c.numAbove,0) as over3,
--ISNULL(b.numAbove,0) as numnull,
--d.numFlights,
(1-((ISNULL(c.numAbove,0)+(ISNULL(b.numAbove,0)*1.0))/d.numFlights*1.0)) as percentage from
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
    Select Distinct FC.ogCity, Count(*) as numabove from allFlights as FC where FC.actualTime>180 group by FC.ogCity
)
as c
ON a.ogCity = c.ogCity
LEFT JOIN
(
    Select Distinct FD.ogCity, Count(*) as numFlights from allFlights as FD group by FD.ogCity
)
as d
ON a.ogCity = d.ogCity
order by percentage asc;
/*
Rows: 327
Time: 17s
Aberdeen SD	0.0000000000000
Cedar City UT	0.0000000000000
Cordova AK	0.0000000000000
Dickinson ND	0.0000000000000
Dillingham AK	0.0000000000000
Garden City KS	0.0000000000000
Gillette WY	0.0000000000000
Hattiesburg/Laurel MS	0.0000000000000
Hyannis MA	0.0000000000000
Laramie WY	0.0000000000000
Marthas Vineyard MA	0.0000000000000
New Bern/Morehead/Beaufort NC	0.0000000000000
Niagara Falls NY	0.0000000000000
Sault Ste. Marie MI	0.0000000000000
Sioux City IA	0.0000000000000
Victoria TX	0.0000000000000
Waterloo IA	0.0000000000000
West Yellowstone MT	0.0000000000000
Wrangell AK	0.0000000000000
Yakutat AK	0.0000000000000
*/
--THE ABOVE IS CORRECT. FOR SOME REASON THE SOLUTION BELOW IS NOT THE SAME
--alt solution
/*
Select a.ogCity as origin_city,
((ISNULL(b.numAbove,0)*1.0)/d.numFlights*1.0) as percentage from
(
 Select Distinct FC.ogCity from allFlights as FC
)
as a
Left JOIN
(
Select Distinct FB.ogCity, Count(*) as numabove from allFlights as FB where FB.actualTime is NULL or FB.actualTime>180 group by FB.ogCity
)
as b
ON a.ogCity = b.ogCity
Left JOIN
(
    Select Distinct FD.ogCity, Count(*) as numFlights from allFlights as FD group by FD.ogCity
)
as d
ON b.ogCity = d.ogCity
order by percentage asc;
*/

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
/*
Select f.ogCity as origin_city, ROUND((numAbove1+numAbove2)*100/numBelow,2) as perc 
from
(
	Select 
		(select count(f.flightID) from allFlights as f where f.actualTime is NULL group by f.ogCity)  as numAbove1,
		(select  f.ogCity , count(f.flightID) from allFlights as f where f.actualTime > 180 group by f.ogCity)  as numAbove2 ,
		(select f.ogCity , count(f.flightID) from allFlights as f group by f.ogCity) as numBelow from allFlights as f
);

*/