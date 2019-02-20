T0(name,p1,p2) = female(name) X parent_child(p1,p2)--we first generate cartesian product of parent child and female relations
T1(name,p1,p2,p) = T0(name,p1,p2) X person_living(p)--to handle correlated subquery, we then genreate the cartesian product between our previous and the person living relation
T2(name,p1,p2,p) = T1 where name = p1 AND p = p2-- we now handle the selection and condition specified within the subquery
T3(p,name) = person_living(p) JOIN (p=name) male(name) -- we now generate the table from the outer query
T4(p) = project[p](T3) -- we then project to the data we are interested in
T5(a.p) = rename[a.p] T4(p) -- we then rename to avoid ambiguous calls
T6(a.p,name,p1,p2,p) = T5(a.p) join(a.p!=p) T2(name,p1,p2,p) -- we then finally join to handle the not exists clause
T7(a.p) project[a.p](T6) --we project to our final answer
