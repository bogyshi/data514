Select DISTINCT(C.carrierName) as name
from allCarriers as C, allFlights as F, allMonths as M
where C.cid = F.carrierID and F.monthID = M.mid
group by C.carrierName ,M.mid,F.year, F.dayOfMonth
Having COUNT(*) > 1000;
