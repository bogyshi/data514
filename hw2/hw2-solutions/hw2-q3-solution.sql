-- CSE 344, homework 2 solution

--Q3 

select W.day_of_week as day_of_week, 
avg(F.arrival_delay) as delay
from Flights F, 
	Weekdays W 
where W.did = F.day_of_week_id
group by W.did, W.day_of_week
order by avg(F.arrival_delay) desc
limit 1;

-- day_of_week                     avg(F.arrival_delay)
-- ------------------------------  --------------------
-- Wednesday                       13.0125428064529 


