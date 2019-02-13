-- CSE 344, homework 2 solution

-- Q5   

select C.name as name, 100.0*sum(F.canceled)/count(*) as percent
from Flights F, 
	Carriers C 
where C.cid = F.carrier_id 
and F.origin_city = 'Seattle WA'
group by C.cid, C.name
having 100.0*sum(F.canceled)/count(*) > 0.5
order by 100.0*sum(F.canceled)/count(*);


--
-- name    percent
------------------
-- SkyWest Airlines Inc.,0.728291316526611
-- Frontier Airlines Inc.,0.840336134453782
-- United Air Lines Inc.,0.983767830791933
-- JetBlue Airways,1.00250626566416
-- Northwest Airlines Inc.,1.4336917562724
-- ExpressJet Airlines Inc.,3.2258064516129
