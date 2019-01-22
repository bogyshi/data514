Select SUM(F.capacity) as capacity
from allFlights as F, allMonths as M
where M.mid = F.monthID and  F.dayOfMonth=10
 and F.year = 2015 and M.monthName = 'July'
 and ((F.ogCity = 'Seattle WA' and F.destCity = 'San Francisco CA') or
  (F.ogCity = 'San Francisco CA' and F.destCity = 'Seattle WA'));
