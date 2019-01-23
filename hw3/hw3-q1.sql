Select Distinct F.ogCity as origin_city, F.destCity as dest_city, F.actualTime
from (
    Select F1.ogCity, MAX(F1.actualTime) as time
    from allFlights as F1
    group by F1.ogCity
)s
JOIN allFlights as F
ON
F.ogCity = s.ogCity
and
F.actualTime = s.time;
-- Question, are we asking for all possible end destinations one city can have with only one stop what that maximum flight time looks like?
-- OR are we asking for only the list of cities with the same if equal maximum length actual time?
