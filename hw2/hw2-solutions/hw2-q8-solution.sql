-- CSE 344, homework 2 solution

-- Q8 

select C.name as name, sum(F.departure_delay) as delay
from Carriers as C, Flights as F
where F.carrier_id = C.cid
group by C.name;

-------
-- American Airlines Inc.|1849386.0
-- Alaska Airlines Inc.|285111.0
-- JetBlue Airways|435562.0
-- Continental Air Lines Inc.|414226.0
-- Independence Air|201418.0
-- Delta Air Lines Inc.|1601314.0
-- ExpressJet Airlines Inc.|934691.0
-- Frontier Airlines Inc.|165126.0
-- AirTran Airways Corporation|473993.0
-- Hawaiian Airlines Inc.|386.0
-- America West Airlines Inc. (Merged with US Airways 9/05. Stopped reporting 10/07.)|173255.0
-- Envoy Air|771679.0
-- Spirit Air Lines|167894.0
-- Northwest Airlines Inc.|531356.0
-- Comair Inc.|282042.0
-- SkyWest Airlines Inc.|682158.0
-- ATA Airlines d/b/a ATA|38676.0
-- United Air Lines Inc.|1483777.0
-- US Airways Inc.|577268.0
-- Virgin America|52597.0
-- Southwest Airlines Co.|3056656.0
--ExpressJet Airlines Inc. (1)|483171.0
