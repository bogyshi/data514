Select C.carrierName as name, SUM(F.departDT) as delay
from allMonths as M, allCarriers as C, allFlights as F
where M.mid = F.monthID and C.cid = F.carrierID
group by M.mid, C.carrierName;
