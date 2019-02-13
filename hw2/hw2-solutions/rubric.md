# Homework 2: Basic SQL Queries

#
# Grading Rubric

# A. IMPORTING THE FLIGHTS DATABASE

| **Problem** | **Deduction** |
| --- | --- |
| Missing a CREATE TABLE | -4 |
| Missing import statement | -4 |
| Incorrect/Missing PRIMARY KEY | -1 |
| Incorrect/Missing FOREIGN KEY | -1 |
| Not enforcing foreign\_keys (don&#39;t put &quot;PRAGMA- foreign\_keys=ON&quot;) before import | -2 |
| Misnamed Column | -1 |
| Varchar Column Too small | -2 |
| Incorrect import order | -4 |
| Incorrect Data Type (using str or just wrong type) | -1 |



# B. SQL QUERIES (10 per query)

## General

-1 for lack of comment indicating cardinality for output.

## Question 1

List the distinct flight numbers of all flights from Seattle to Boston by Alaska Airlines Inc. on Mondays. Also notice that, in the database, the city names include the state. So Seattle appears as Seattle WA.
_[Hint: Output relation cardinality: 3 rows]_
```
-- CSE 344, homework 2 solution

-- Q1

select distinct F.flight_num as flight_num
from Flights F, 
	 Carriers C, 
	 Weekdays W
where F.carrier_id = C.cid 
and C.name='Alaska Airlines Inc.' 
and F.origin_city='Seattle WA'
and F.dest_city='Boston MA' 
and W.did = F.day_of_week_id 
and W.day_of_week = 'Monday';

-- flight_num                    
-- ------------------------------
-- 12                            
-- 24                            
-- 734
```

| **Problem** | **Deduction** |
| --- | --- |
| Forgot to join with \_\_\_\_ table | -2 |
| Forgot a predicate in WHERE | -2 |
| Missing distinct | -2 |
|  Didn't explicitly specify Monday (ex: used day of week = 1) | -2  |
|   |   |
|   |   |
|   |   |

_               _

## Question 2

Find all flights from Seattle to Boston on July 15th 2015. Search only for itineraries that have one stop. Both legs of the flight must have occurred on the same day and must be with the same carrier. The total flight time (actual\_time) of the entire itinerary should be less than 7 hours (but notice that actual\_time is in minutes). For each itinerary, the query should return the name of the carrier, the first flight number, the origin and destination of that first flight, the flight time, the second flight number, the origin and destination of the second flight, the second flight time, and finally the total flight time.

Put the first 20 rows of your result right after your query as a comment.
_[Output relation cardinality: 488 rows]_

```
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



```


| **Problem** | **Deduction** |
| --- | --- |
| Forgot to join with \_\_\_\_ table | -2 |
| Forgot a predicate in WHERE | -2 |
| Missing column in select | -1 |
| Unnecessary GROUP/ORDER BY | -1 |
| Specifies July explicitly, instead of using month=7  | -1 |
|   |   |



## Question 3

Find the day of the week with the longest average arrival delay. Return the name of the day and the average delay.
_[Output relation cardinality: 1 row]_

```
-- CSE 344, homework 2 solution

--Q3 

select W.day_of_week as day_of_week, 
avg(F.arrival_delay) as delay
from Flights F, 
	Weekdays W 
where W.did = F.day_of_week_id
group by W.did, W.day_of_week
order by avg(F.arrival_delay) desc
limit 1;

-- day_of_week                     avg(F.arrival_delay)
-- ------------------------------  --------------------
-- Wednesday                       13.0125428064529 

```

| **Problem** | **Deduction** |
| --- | --- |
| Forgot to join with \_\_\_\_ table | -2 |
| Forgot a predicate in WHERE | -2 |
| Missing column in select | -2 (Increased from -1 because avg(F.arrival\_delay is a key point in the question) |
| Missing group by | -4 |
| Incorrect group by | -2 |
| Missing limit | -1 |
| Incorrect Order by direction | -1 |



## Question 4

Find the names of all airlines that ever flew more than 1000 flights in one day. Return only the names. Do not return any duplicates.
_[Output relation cardinality: 11 rows]_

```
-- CSE 344, homework 2 solution

-- Q4 

select distinct C.name as name, 
from Flights F,
	Carriers C 
where C.cid = F.carrier_id
group by C.name, 
	C.cid, 
	F.year, 
	F.month_id, 
	F.day_of_month
having count(*) > 1000;

-- name                          
-- ------------------------------
-- American Airlines Inc.        
-- Comair Inc.                   
-- Delta Air Lines Inc.          
-- Envoy Air                     
-- ExpressJet Airlines Inc.      
-- ExpressJet Airlines Inc. (1)  
-- Northwest Airlines Inc.       
-- SkyWest Airlines Inc.         
-- Southwest Airlines Co.        
-- US Airways Inc.               
-- United Air Lines Inc.   


```

| **Problem** | **Deduction** |
| --- | --- |
| Forgot to join with \_\_\_\_ table | -2 |
| Forgot a predicate in WHERE | -2 |
| Missing distinct | -1 |
| Missing group by | -4 |
| Incorrect group by | -2 |
| Missing having | -4 |
| Missing column in group by, noting that you may not need to group by both C.name and C.id | -1 |


## Question 5

Find all airlines that had more than 0.5 percent of their flights out of Seattle be canceled. Return the name of the airline and the percentage of canceled flight out of Seattle. Order the results by the percentage of canceled flights in ascending order.
_[Output relation cardinality: 6 rows]

```
-- CSE 344, homework 2 solution

-- Q5   

select C.name as name, 100.0*sum(F.canceled)/count(*) as percent
from Flights F, 
	Carriers C 
where C.cid = F.carrier_id 
and F.origin_city = 'Seattle WA'
group by C.cid, C.name
having 100.0*sum(F.canceled)/count(*) > 0.5
order by 100.0*sum(F.canceled)/count(*);


--
-- name    percent
------------------
-- SkyWest Airlines Inc.,0.728291316526611
-- Frontier Airlines Inc.,0.840336134453782
-- United Air Lines Inc.,0.983767830791933
-- JetBlue Airways,1.00250626566416
-- Northwest Airlines Inc.,1.4336917562724
-- ExpressJet Airlines Inc.,3.2258064516129

```

| **Problem** | **Deduction** |
| --- | --- |
| Forgot to join with \_\_\_\_ table | -2 |
| Forgot a predicate in WHERE | -2 |
| Missing column in select | -2 |
| Selecting something not in a group by | -2 |
| Missing group by | -4 |
| Missing having | -4 |
| Incorrect Average computation | -2 (Feel free to have -1 if they just forgot to add the .0 in the 100.0) |
| Used &gt;= instead of &gt; | -1 |

## Question 6

Find the average price of tickets between Seattle and New York, NY in the entire month.

Show the average price for each airline separately.

Name the output columns carrier and average\_price, in that order.

[Output relation cardinality: 3]

```
-- CSE 344, homework 2 solution

-- Q6 

select C.name as carrier, avg(F.price) as average_price 
from Flights F, Carriers C
where ((F.origin_city = 'Seattle WA' and F.dest_city = 'New York NY') OR
(F.origin_city = 'New York NY' and F.dest_city = 'Seattle WA')) and F.carrier_id = C.cid
group by F.carrier_id;

```

| **Problem** | **Deduction** |
| --- | --- |
| Forgot to join with \_\_\_\_ table | -2 |
| Forgot a predicate in WHERE | -2 |
| Missing column in select | -2 (Increased from -1 because avg(F.arrival\_delay is a key point in the question) |
| Missing group by | -4 |
| Incorrect Average computation | -2 |
| Not Bidirectional | -2 |



## Question 7

Find the total capacity of all direct flights that fly between Seattle and San Francisco, CA on July 10th, 2015.

Name the output column capacity.

[Output relation cardinality: 1]

```
-- CSE 344, homework 2 solution

-- Q7 

SELECT sum(F.capacity) AS capacity 
FROM Flights AS F, Months AS M
WHERE F.month_id = M.mid AND 
      F.day_of_month = 10 AND M.month = 'July' AND F.year = 2015
      ((F.origin_city = 'Seattle WA' AND F.dest_city = 'San Francisco CA') OR 
      (F.origin_city = 'San Francisco CA' AND F.dest_city = 'Seattle WA'));

```

| **Problem** | **Deduction** |
| --- | --- |
| Forgot to join with \_\_\_\_ table | -2 |
| Forgot a predicate in WHERE | -2 |
| Missing column in select | -2 (Increased from -1 because using sum is a big point of the question) |
| Missing/wrong group by | -4 |
| Incorrect Average computation | -2 |
| Not Bidirectional | -2 |
| Incorrect sum | -2|

## Question 8

Compute the total departure delay of each airline

across all flights in the entire month.

Name the output columns name and delay, in that order.

[Output relation cardinality: 22]

```
-- CSE 344, homework 2 solution

-- Q8 

select C.name as name, sum(F.departure_delay) as delay
from Carriers as C, Flights as F
where F.carrier_id = C.cid
group by C.name;

-------
-- American Airlines Inc.|1849386.0
-- Alaska Airlines Inc.|285111.0
-- JetBlue Airways|435562.0
-- Continental Air Lines Inc.|414226.0
-- Independence Air|201418.0
-- Delta Air Lines Inc.|1601314.0
-- ExpressJet Airlines Inc.|934691.0
-- Frontier Airlines Inc.|165126.0
-- AirTran Airways Corporation|473993.0
-- Hawaiian Airlines Inc.|386.0
-- America West Airlines Inc. (Merged with US Airways 9/05. Stopped reporting 10/07.)|173255.0
-- Envoy Air|771679.0
-- Spirit Air Lines|167894.0
-- Northwest Airlines Inc.|531356.0
-- Comair Inc.|282042.0
-- SkyWest Airlines Inc.|682158.0
-- ATA Airlines d/b/a ATA|38676.0
-- United Air Lines Inc.|1483777.0
-- US Airways Inc.|577268.0
-- Virgin America|52597.0
-- Southwest Airlines Co.|3056656.0
--ExpressJet Airlines Inc. (1)|483171.0

```

| **Problem** | **Deduction** |
| --- | --- |
| Forgot to join with \_\_\_\_ table | -2 |
| Forgot a predicate in WHERE | -2 |
| Missing column in select | -2 (Increased from -1 because using sum is a big point of the question) |
| Missing/wrong group by | -4 |
|   |   |
|   |   |