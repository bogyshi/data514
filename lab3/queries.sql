-- who teaches cse 451
Select I.fname, I.lname
from instructor as I, teaches as T
where T.username = I.username and T.number = 451;
--check

--what courses doe zahorjan teach?
Select T.dept, T.number
from teaches as T
where T.username = 'zahorjan';

Select c.title from class c, teaches t
where c.dept = t.dept and t.username = 'zahorjan' and c.number = t.number;
--the c.dept = t.dept is to let us JOIN on something between the tables

--check



--Which courses do both levy and zahorjan teach
-- This problem is hinting at a self join
Select Distinct(C.title)
from teaches as T1, teaches as T2, class as C
where T1.username = 'levy' and T2.username = 'zahorjan' and T1.number = T2.number and C.number = T1.number;
--can think of these as finding the pieces and then doing an inner JOIN

select t1.dept, t1.number from teaches as t1, teaches as t2
where t1.username='levy' and t2.username='zahorjan'
and t1.dept=t2.dept and t1.number = t2.number;
-- to solve this with subqueries

-- how many classes are there in course catalog
select count(*) from class;

--what are the highest and lowest class numbers
select max(number),min(number) from class;


--how many instructors teach each classes

Select t.dept,t.number, count(t.username)
from teaches as t
group by t.dept,t.number;
--check

--order instructors who teach in most departements
select i.fname, i.lname, count(distinct t.dept) FROM
instructor as i, teaches as t
where i.username = t.username
group by i.fname, i.lname
order by count(distinct(t.dept)) asc;
