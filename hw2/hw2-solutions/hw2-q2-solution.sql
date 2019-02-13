-- CSE 344, homework 2 solution

-- Q2

select C.name as name, 
	F1.flight_num as f1_flight_num,
	F1.origin_city as f1_origin_city,
	F1.dest_city as f1_dest_city,
	F1.actual_time as f1_actual_time,
	F2.flight_num as f2_flight_num,
	F2.origin_city as f2_origin_city,
	F2.dest_city as f2_dest_city,
	F2.actual_time as f2_actual_time,
	F1.actual_time+F2.actual_time as actual_time
from Flights F1, Flights F2, Months M, Carriers C
where C.cid = F1.carrier_id 
and F1.origin_city = 'Seattle WA' 
and F2.dest_city = 'Boston MA' 
and F1.dest_city = F2.origin_city
and F1.year = F2.year 
and F1.month_id = F2.month_id 
and F1.day_of_month = F2.day_of_month
and F1.month_id = M.mid 
and M.month = 'July' 
and F1.day_of_month = 15 
and F1.year = 2015
and (F1.actual_time+F2.actual_time) < 420 
and F1.carrier_id = F2.carrier_id;

-- name                            flight_num  origin_city  dest_city   actual_time  flight_num  origin_city  dest_city   actual_time  F1.actual_time+F2.actual_time
-- ------------------------------  ----------  -----------  ----------  -----------  ----------  -----------  ----------  -----------  -----------------------------
-- American Airlines Inc.          42          Seattle WA   Chicago IL  228          26          Chicago IL   Boston MA   150          378                          
-- American Airlines Inc.          42          Seattle WA   Chicago IL  228          186         Chicago IL   Boston MA   137          365                          
-- American Airlines Inc.          42          Seattle WA   Chicago IL  228          288         Chicago IL   Boston MA   137          365                          
-- American Airlines Inc.          42          Seattle WA   Chicago IL  228          366         Chicago IL   Boston MA   150          378                          
-- American Airlines Inc.          42          Seattle WA   Chicago IL  228          1205        Chicago IL   Boston MA   128          356                          
-- American Airlines Inc.          42          Seattle WA   Chicago IL  228          1240        Chicago IL   Boston MA   130          358                          
-- American Airlines Inc.          42          Seattle WA   Chicago IL  228          1299        Chicago IL   Boston MA   133          361                          
-- American Airlines Inc.          42          Seattle WA   Chicago IL  228          1435        Chicago IL   Boston MA   133          361                          
-- American Airlines Inc.          42          Seattle WA   Chicago IL  228          1557        Chicago IL   Boston MA   122          350                          
-- American Airlines Inc.          42          Seattle WA   Chicago IL  228          2503        Chicago IL   Boston MA   127          355                          
-- American Airlines Inc.          44          Seattle WA   New York N  322          84          New York NY  Boston MA   74           396                          
-- American Airlines Inc.          44          Seattle WA   New York N  322          199         New York NY  Boston MA   80           402                          
-- American Airlines Inc.          44          Seattle WA   New York N  322          235         New York NY  Boston MA   91           413                          
-- American Airlines Inc.          44          Seattle WA   New York N  322          1443        New York NY  Boston MA   80           402                          
-- American Airlines Inc.          44          Seattle WA   New York N  322          2118        New York NY  Boston MA                322                          
-- American Airlines Inc.          44          Seattle WA   New York N  322          2121        New York NY  Boston MA   74           396                          
-- American Airlines Inc.          44          Seattle WA   New York N  322          2122        New York NY  Boston MA   65           387                          
-- American Airlines Inc.          44          Seattle WA   New York N  322          2126        New York NY  Boston MA   60           382                          
-- American Airlines Inc.          44          Seattle WA   New York N  322          2128        New York NY  Boston MA   83  


