Select D.dayName as day_of_week, AVG(F.arrivDT) as delay
from allFlights as F,allDays as D where D.did = F.dayOfWeekID
group by day_of_week order by delay desc LIMIT 1;
