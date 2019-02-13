-- CSE 344, homework 2 solution

-- Q6 

select C.name as carrier, avg(F.price) as average_price 
from Flights F, Carriers C
where ((F.origin_city = 'Seattle WA' and F.dest_city = 'New York NY') OR
(F.origin_city = 'New York NY' and F.dest_city = 'Seattle WA')) and F.carrier_id = C.cid
group by F.carrier_id;
