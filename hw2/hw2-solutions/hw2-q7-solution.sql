-- CSE 344, homework 2 solution

-- Q7 

SELECT sum(F.capacity) AS capacity 
FROM Flights AS F, Months AS M
WHERE F.month_id = M.mid AND 
      F.day_of_month = 10 AND M.month = 'July' AND F.year = 2015 AND
      ((F.origin_city = 'Seattle WA' AND F.dest_city = 'San Francisco CA') OR 
      (F.origin_city = 'San Francisco CA' AND F.dest_city = 'Seattle WA'));
