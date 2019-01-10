.header on
.mode columns
select * from MyRestaurants where isGood = 1
  and lastVisit <= date('now','-3 month')
