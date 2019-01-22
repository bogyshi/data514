Select F.ogCity as origin_city, F.destCity as dest_city, MAX(F.actualTime) as time
from allFlights as F
group by F.ogCity,F.destCity;
-- Question, are we asking for all possible end destinations one city can have with only one stop what that maximum flight time looks like?
-- OR are we asking for only the list of cities with the same if equal maximum length actual time?