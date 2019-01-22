Select C.carrierName as name, AVG(F.canceled) as percent
from allCarriers as C,allFlights as F
where C.cid=F.carrierID and F.ogCity = 'Seattle WA'
group by name
having percent > 0.005
order by percent asc;
