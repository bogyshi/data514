SELECT *
  FROM MyRestaurants
 WHERE Liked = 1 AND
       Last_visit < date('now', '-3 month');