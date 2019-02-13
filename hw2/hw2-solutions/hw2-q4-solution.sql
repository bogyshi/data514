-- CSE 344, homework 2 solution

-- Q4 

select distinct C.name as name 
from Flights F,
	Carriers C 
where C.cid = F.carrier_id
group by C.name, 
	C.cid, 
	F.year, 
	F.month_id, 
	F.day_of_month
having count(*) > 1000;

-- name                          
-- ------------------------------
-- American Airlines Inc.        
-- Comair Inc.                   
-- Delta Air Lines Inc.          
-- Envoy Air                     
-- ExpressJet Airlines Inc.      
-- ExpressJet Airlines Inc. (1)  
-- Northwest Airlines Inc.       
-- SkyWest Airlines Inc.         
-- Southwest Airlines Co.        
-- US Airways Inc.               
-- United Air Lines Inc.   


