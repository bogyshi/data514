.mode columns
.header on
PRAGMA foreign_keys=ON;
CREATE TABLE Likes (
      drinker varchar(30),
      likes varchar(30)
);
CREATE TABLE Frequents (
      drinker varchar(30) REFERENCES Likes(drinker),
      bar varchar(30)
);
CREATE TABLE Serves (
      bar varchar(30)  REFERENCES Frequents(bar),
      beer varchar(30)
);

Select F.bar, Count(*) as numPatrons
from Frequents as F
where F.drinker IN
(
  Select Distinct L1.Drinker
  from Likes as L2, Likes as L1
  where L1.drinker = F.drinker and L2.drinker = F.Drinker
  and L1.likes = 'heineken'
  and L2.likes = 'bud'
)
group by F.bar;

--find all drinkers that frequent some bar that serves some beer that they like
Select Distinct L.drinker from
Likes as L, Frequents as F where
L.drinker IN
(
  Select F.drinker from Frequents as F, Serves as S
  where F.drinker = L.drinker
  and F.bar = S.bar
  and S.beer = L.likes
);
