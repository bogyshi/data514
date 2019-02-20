Create table parent_child(
  p1 int,
  p2 int
);
Create table person_living(
  x int
);
Select temp.p1, max(y) FROM
(
  Select Pt1.p1 as p1, Pt2.p3, count(*) as y
  from parent_child as Pt1, person_living as PL,
  (
    Select p1 as p3, p2 as p4 FROM parent_child
  ) as Pt2
  where Pt1.p1 = PL.x and Pt1.p2 = Pt2.p3
  group by Pt1.p1,Pt2.p3
) as temp
group by temp.p1;
