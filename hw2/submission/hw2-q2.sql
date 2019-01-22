Select
C.carrierName as name,
F1.flightNum as f1_flight_num,
F1.ogCity as f1_origin_city,
F1.destCity as f1_dest_city,
F1.actualTime as f1_actual_time,
F2.flightNum as f2_flight_num,
F2.ogCity as f2_origin_city,
F2.destCity as f2_dest_city,
F2.actualTime as f2_actual_time,
F1.actualTime + F2.actualTime as actual_time
From allFlights as F1,
allFlights as F2,allMonths,
allCarriers as C
where
F1.carrierID = C.cid
and
F2.carrierID= C.cid
and
F1.carrierID=F2.carrierID
and
(
(F1.ogCity = 'Seattle WA'
and F2.destCity = 'Boston MA'
and F1.destCity = F2.ogCity)
or
(F1.ogCity = 'Seattle WA'
and F1.destCity = 'Boston MA'
and F2.ogCity = 'Seattle WA'
and F2.destCity = 'Boston MA'
and F1.flightID=F2.flightID)
)
and F1.dayOfMonth=15
and F1.year = 2015
and F1.monthID=mid
and F2.dayOfMonth=15
and F2.year = 2015
and F2.monthID=mid
and monthName='July'
and (F1.actualTime + F2.actualTime < 7*60)
;
/*
name                    f1_flight_num  f1_origin_city  f1_dest_city  f1_actual_time  f2_flight_num  f2_origin_city  f2_dest_city  f2_actual_time  actual_time
----------------------  -------------  --------------  ------------  --------------  -------------  --------------  ------------  --------------  -----------
American Airlines Inc.  42             Seattle WA      Chicago IL    228.0           26             Chicago IL      Boston MA     150.0           378.0
American Airlines Inc.  42             Seattle WA      Chicago IL    228.0           186            Chicago IL      Boston MA     137.0           365.0
American Airlines Inc.  42             Seattle WA      Chicago IL    228.0           288            Chicago IL      Boston MA     137.0           365.0
American Airlines Inc.  42             Seattle WA      Chicago IL    228.0           366            Chicago IL      Boston MA     150.0           378.0
American Airlines Inc.  42             Seattle WA      Chicago IL    228.0           1205           Chicago IL      Boston MA     128.0           356.0
American Airlines Inc.  42             Seattle WA      Chicago IL    228.0           1240           Chicago IL      Boston MA     130.0           358.0
American Airlines Inc.  42             Seattle WA      Chicago IL    228.0           1299           Chicago IL      Boston MA     133.0           361.0
American Airlines Inc.  42             Seattle WA      Chicago IL    228.0           1435           Chicago IL      Boston MA     133.0           361.0
American Airlines Inc.  42             Seattle WA      Chicago IL    228.0           1557           Chicago IL      Boston MA     122.0           350.0
American Airlines Inc.  42             Seattle WA      Chicago IL    228.0           2503           Chicago IL      Boston MA     127.0           355.0
American Airlines Inc.  44             Seattle WA      New York NY   322.0           84             New York NY     Boston MA     74.0            396.0
American Airlines Inc.  44             Seattle WA      New York NY   322.0           199            New York NY     Boston MA     80.0            402.0
American Airlines Inc.  44             Seattle WA      New York NY   322.0           235            New York NY     Boston MA     91.0            413.0
American Airlines Inc.  44             Seattle WA      New York NY   322.0           1443           New York NY     Boston MA     80.0            402.0
American Airlines Inc.  44             Seattle WA      New York NY   322.0           2118           New York NY     Boston MA                     322.0
American Airlines Inc.  44             Seattle WA      New York NY   322.0           2121           New York NY     Boston MA     74.0            396.0
American Airlines Inc.  44             Seattle WA      New York NY   322.0           2122           New York NY     Boston MA     65.0            387.0
American Airlines Inc.  44             Seattle WA      New York NY   322.0           2126           New York NY     Boston MA     60.0            382.0
American Airlines Inc.  44             Seattle WA      New York NY   322.0           2128           New York NY     Boston MA     83.0            405.0
American Airlines Inc.  44             Seattle WA      New York NY   322.0           2131           New York NY     Boston MA     70.0            392.0      
*/
