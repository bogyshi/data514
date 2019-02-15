create table languages(
  languageID primary key,
  languageName varchar(100)
);
create table users(
  userID int primary key,
  languageID int references languages,
  name varchar(100)
);
create table dictionary(
  languageID int references languages,
  word varchar(100)
);
create table searches(
  searchID int,
  languageID int references languages,
  userID int,
  word varchar(100)
);

INSERT INTO languages Values (1, "English");
INSERT INTO languages Values (2, "French");
INSERT INTO languages Values (3, "Japanese");

INSERT INTO users Values (1,1,'fred');
INSERT INTO users Values (2,1,'ross');
INSERT INTO users Values (3,3,'lizzy');
INSERT INTO dictionary Values (1,'meat');
INSERT INTO dictionary Values (1,'hamburger');
INSERT INTO dictionary Values (1,'onion');
INSERT INTO dictionary Values (1,'zebra');
INSERT INTO dictionary Values (1,'horse');
INSERT INTO dictionary Values (3,'nihow');

INSERT INTO searches Values (1,1,1,'meat');
INSERT INTO searches Values (1,1,1,'onion');
INSERT INTO searches Values (2,1,1,'meat');
INSERT INTO searches Values (3,1,2,'onion');
INSERT INTO searches Values (3,1,2,'hamburger');

--INSERT INTO searches Values (4,3,3,'nihow');


Select S.word, count(*) as frequency from searches as S group by S.word Having frequency>1  order by frequency desc LIMIT 1;
Select D.word from dictionary as D where D.word NOT IN (
  Select Distinct S.word from searches as S
);

Select L.languageName from languages as L where L.languageID not in (
  Select Distinct S.languageID from searches as S
);

Select Distinct U.name from users as U where U.userID IN (
  Select S.userID from searches as S group by S.searchID,S.userID having count(S.word)>=2
);
