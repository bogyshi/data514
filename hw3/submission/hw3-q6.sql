/*
List the names of carriers that operate flights from Seattle to San Francisco, CA. Return each carrier's
name only once. Use a nested query to answer this question. (7 points)
Name the output column carrier.
[Output relation cardinality: 4]
*/

Select Distinct C.carrierName as carrier from allCarriers as C
where C.cid IN
  (
    Select F.carrierID from allFlights as F where
    F.ogCity = 'Seattle WA' and F.destCity = 'San Francisco CA'
  );
/*
Rows: 4
Time: 2s
Alaska Airlines Inc.
SkyWest Airlines Inc.
United Air Lines Inc.
Virgin America
*/
