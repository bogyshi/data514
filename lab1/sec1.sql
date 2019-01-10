/*** CSEP 514 Section 01 -- A Tour of SQLite ***/


/* How to start: open a terminal, then type the command:
  		sqlite3 database
   where "database" is the name of the database file you want to use.
WARNING: If you don't specify a database file, sqlite3 won't complain, but your data will be lost!
*/


/* Useful commands for SQLite (not SQL commands!)

.help - lists other . commands
.headers on/off - show/hide column headers in query results
.mode - how to separate the columns in each row/tuple (for better formatting)
.read 'filename.sql' - read and execute SQL code from the given file
.separator , - changes the separator for importing files to , 
.show - see how we have set our parameters
.import 'file.txt' Table - loads the file 'file.txt' to the table Table, be careful to set the separator correctly!
.exit - exit from sqlite3
*/

/* The following are all SQL commands. They have to end with a ";" so that SQLite can read them! */


/* 
   Create tables
 */
-- SQLite ignores string length maximums (N in VARCHAR(N))
-- or fixed string lengths (N in CHAR(N)):
--    http://www.sqlite.org/datatype3.html
-- I've left them in so this code will work with other SQL
-- database management systems.
CREATE TABLE Class (
       dept VARCHAR(6),
       number INTEGER,
       title VARCHAR(75),
       PRIMARY KEY (dept, number)
);

-- Older versions of sqlite (including the one in Mac OS 10.6, unfortunately)
-- do not enforce FOREIGN KEY constraints.  Newer versions are opt-in
-- at both compile time and runtime (enter PRAGMA FOREIGN_KEYS = ON; into the sqlite command prompt):
--   http://www.sqlite.org/foreignkeys.html
CREATE TABLE Instructor (
       username VARCHAR(8),
       fname VARCHAR(50),
       lname VARCHAR(50),
       started_on CHAR(10),
       PRIMARY KEY (username)
);


/* Delete a table from the database */
-- DROP TABLE Instructor ; 
CREATE TABLE Teaches (
       username VARCHAR(8),
       dept VARCHAR(6),
       number INTEGER,
       PRIMARY KEY (username, dept, number),
       FOREIGN KEY (username) REFERENCES Instructor(username),
       FOREIGN KEY (dept, number) REFERENCES Class(dept, number)
);


/* 
   Sample data 
 */
INSERT INTO Class
       VALUES('CSE', 378, 'Machine Organization and Assembly Language');
INSERT INTO Class
       VALUES('CSE', 451, 'Introduction to Operating Systems');
INSERT INTO Class
       VALUES('CSE', 461, 'Introduction to Computer Communication Networks');

INSERT INTO Instructor
       VALUES('zahorjan', 'John', 'Zahorjan', '1985-01-01');
INSERT INTO Instructor
       VALUES('djw', 'David', 'Wetherall', '1999-07-01');
INSERT INTO Instructor
       VALUES('tom', 'Tom', 'Anderson', date('1997-10-01'));
INSERT INTO Instructor
       VALUES('levy', 'Hank', 'Levy', date('1988-04-01'));

INSERT INTO Teaches
       VALUES('zahorjan', 'CSE', 378);
INSERT INTO Teaches
       VALUES('tom', 'CSE', 451);
INSERT INTO Teaches
       VALUES('tom', 'CSE', 461);
INSERT INTO Teaches
       VALUES('zahorjan', 'CSE', 451);
INSERT INTO Teaches
       VALUES('zahorjan', 'CSE', 461);
INSERT INTO Teaches
       VALUES('djw', 'CSE', 461);
INSERT INTO Teaches
       VALUES('levy', 'CSE', 451);




/*
   Example queries
 */

-- What courses are offered?
title                                     
------------------------------------------
Machine Organization and Assembly Language
Introduction to Operating Systems         
Introduction to Computer Communication Net



-- Top two class by instructor name sorted (a first)
username    dept        number    
----------  ----------  ----------
djw         CSE         461       
levy        CSE         451 



-- Top two classes by instructor name sorted in reverse (z first)
username    dept        number    
----------  ----------  ----------
zahorjan    CSE         461       
zahorjan    CSE         451 




-- What's the first name of the instructor with login 'zahorjan'?
fname     
----------
John 


-- What's the first name of the instructor with login 'zahorjan'? 
-- Rename Instructor table to inst
fname     
----------
John 



-- If a string is used where a number is expected, 
-- SQLite will try to convert the string into the number
-- it represents.  SQLite also does the opposite conversion.

-- What 400-level CSE classes are offered?
dept        number      title                            
----------  ----------  ---------------------------------
CSE         451         Introduction to Operating Systems
CSE         461         Introduction to Computer Communic




-- What classes are taught by levy or djw
username    dept        number    
----------  ----------  ----------
djw         CSE         461       
levy        CSE         451



-- What classes have titles starting with Introduction?
dept        number      title                            
----------  ----------  ---------------------------------
CSE         451         Introduction to Operating Systems
CSE         461         Introduction to Computer Communic



-- If we misspell Introduction as INtroduction, how to catch that?
dept        number      title                            
----------  ----------  ---------------------------------
CSE         451         Introduction to Operating Systems
CSE         461         Introduction to Computer Communic



/*
   Fun with strings
 */

-- Show the class titles and their lengths.
title                                       LENGTH(title)
------------------------------------------  -------------
Machine Organization and Assembly Language  42           
Introduction to Operating Systems           33           
Introduction to Computer Communication Net  47 




-- Truncate all class titles to 12 characters.
dept        number      short_title 
----------  ----------  ------------
CSE         378         Machine Orga
CSE         451         Introduction
CSE         461         Introduction




/*
    ** Date and time representations
 */
-- SQLite does not have a separate data type for dates, times, 
-- or combined date and time.  Instead, these are represented
-- as specially formatted strings; dates are represented as yyyy-mm-dd
-- (see http://www.sqlite.org/lang_datefunc.html for more info).

-- Which instructors started before 1990?
username    fname       lname       started_on
----------  ----------  ----------  ----------
zahorjan    John        Zahorjan    1985-01-01
levy        Hank        Levy        1988-04-01



-- Which instructors started before now?
-- (Hopefully, this is all of them!)
username    fname       lname       started_on
----------  ----------  ----------  ----------
zahorjan    John        Zahorjan    1985-01-01
djw         David       Wetherall   1999-07-01
tom         Tom         Anderson    1997-10-01
levy        Hank        Levy        1988-04-01




-- Which instructors started on or after January 1, 20 years ago?
username    fname       lname       started_on
----------  ----------  ----------  ----------
djw         David       Wetherall   1999-07-01
tom         Tom         Anderson    1997-10-01

