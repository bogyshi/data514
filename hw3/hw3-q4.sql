/*
List all cities that cannot be reached from Seattle though a direct flight but can be reached with one stop
(i.e., with any two flights that go through an intermediate city). Do not include Seattle as one of these
destinations (even though you could get back with two flights). (15 points)
Name the output column city.

cardinality = 256
*/

--lets handle this in parts

--all cities that cannot be reached from Seattle though a direct flight
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
Muskegon MI
Columbus OH
Elko NV
Pensacola FL
Islip NY
Evansville IN
Laredo TX
Sioux City IA
Lawton/Fort Sill OK
Latrobe PA
Atlantic City NJ
Iron Mountain/Kingsfd MI
Springfield IL
Eagle CO
White Plains NY
Waco TX
Savannah GA
Key West FL
Newburgh/Poughkeepsie NY
Bozeman MT
Rochester MN
Lansing MI
Worcester MA
Williston ND
Fargo ND
Alpena MI
Mobile AL
Cedar City UT
Champaign/Urbana IL
Visalia CA
Jacksonville/Camp Lejeune NC
Valparaiso FL
Tupelo MS
King Salmon AK
Aberdeen SD
Kalamazoo MI
Lexington KY
Santa Fe NM
Missoula MT
Idaho Falls ID
Wichita KS
Charleston/Dunbar WV
Chattanooga TN
Naples FL
Grand Island NE
Hayden CO
Lewiston ID
Montrose/Delta CO
Harrisburg PA
Butte MT
Allentown/Bethlehem/Easton PA
Brunswick GA
Inyokern CA
International Falls MN
Kodiak AK
Fayetteville NC
Moline IL
Bismarck/Mandan ND
Jackson WY
Shreveport LA
Niagara Falls NY
Augusta GA
Sarasota/Bradenton FL
Valdosta GA
Dubuque IA
Saginaw/Bay City/Midland MI
Monroe LA
Minot ND
Christiansted VI
Macon GA
Adak Island AK
Bristol/Johnson City/Kingsport TN
Rochester NY
Florence SC
New Bern/Morehead/Beaufort NC
Tallahassee FL
Twin Falls ID
La Crosse WI
Binghamton NY
Dickinson ND

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
