-- CSE 344, homework 2 solution

-- Q1

select distinct F.flight_num as flight_num
from Flights F, 
	 Carriers C, 
	 Weekdays W
where F.carrier_id = C.cid 
and C.name='Alaska Airlines Inc.' 
and F.origin_city='Seattle WA'
and F.dest_city='Boston MA' 
and W.did = F.day_of_week_id 
and W.day_of_week = 'Monday';

-- flight_num                    
-- ------------------------------
-- 12                            
-- 24                            
-- 734 
