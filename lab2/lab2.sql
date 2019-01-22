.mode columns
.header on

CREATE TABLE Population (
rank INTEGER,
country VARCHAR(30) PRIMARY KEY,
population DOUBLE,
percentage FLOAT
);
CREATE TABLE GDP (
rank INTEGER,
country VARCHAR(30) PRIMARY KEY,
gdp DOUBLE
);
CREATE TABLE Airport (
code VARCHAR(30) PRIMARY KEY,
name VARCHAR(30),
country VARCHAR(30)
);
.mode csv
.import 'airport.csv' airport
.import 'gdp.csv' GDP
.import 'population.csv' Population

/*-- What is the percentage of the population from the top 10 populated countries?
Top_Sum
58.9241749607129
-- How many countries do have less than 1,000,000 population?
Small_Countries
68
-- How many countries have airports?
Airport_Count
247
-- Top 10 countries with most airports, in descending order
country
Count
-------------  ----------
United States  2238
Australia
617
Canada
533
Papua New Gui 380
Brazil
288
Indonesia
205
China
187
Colombia
167
United Kingdo 151
France
144

-- Order the top 10 countries by total GDP per capita (gdp / population)
country
GDP_per_capita
----------  -----------------
Seychelles  0.282666666666667
Saint Kitt  0.256076923076923
Antigua an 0.196681818181818
Luxembourg 0.158883485309017
Dominica
0.152507462686567
Brunei
0.119825
Iceland
0.118570005575638
Grenada
0.102855769230769
Saint Vinc
0.092908256880733
Barbados
0.087
*/

select SUM(population) from Population; --#1
Select SUM(percentage) from Population where rank<11;
Select country from Population where population < 1000000;
Select Count(DISTINCT country) from Airport;

Select Country, Count(*) from Airport group by Country Order by Count(*) desc limit 10;

Select population.Country , gdp/population from gdp,population where gdp.country = population.country group by population.Country Order by gdp/population desc limit 10;
