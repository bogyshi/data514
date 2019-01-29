/*
Express the same query as above, but do so without using a nested query. Again, name the output
column carrier. (8 points)
*/


Select Distinct C.carrierName as carrier from allCarriers as C, allFlights as F
where F.ogCity = 'Seattle WA' and F.destCity = 'San Francisco CA' and F.carrierID = C.cid;

/*
Rows: 4
Time: 2s
Alaska Airlines Inc.
SkyWest Airlines Inc.
United Air Lines Inc.
Virgin America
*/
