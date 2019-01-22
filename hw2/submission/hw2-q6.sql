Select C.carrierName as carrier, AVG(F.price) as average_price
from allCarriers as C, allFlights as F, allMonths as M
where C.cid=F.carrierID and M.mid=F.monthID
and ((F.ogCity = 'Seattle WA' and F.destCity = 'New York NY') or
 (F.ogCity = 'New York NY' and F.destCity = 'Seattle WA'))
group by C.carrierName,M.mid;
