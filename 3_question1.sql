-- Authors: Rafał Wycichowski, Tomasz Baraniecki
-- 3
-- What makes project succesful?
-- We create table in which we insert 10% of most watched projects
CREATE TABLE watchersTenPer (
	project_id int,
	sum int
);

-- We start from counting how many projects are watched in total
SELECT count(*) FROM (
SELECT project_id, count(*) as sum FROM facts
WHERE name LIKE '%watchers%'
GROUP BY project_id
ORDER BY sum desc) as x;
-- answer: 4234456

-- We check best 10% of them
INSERT INTO watchersTenPer
SELECT project_id, count(*) as sum FROM facts
WHERE name LIKE '%watchers%'
GROUP BY project_id
ORDER BY sum desc
LIMIT 423446; -- 423446 is 10% of 4234456

-- We want to know how many facts there are for every kind of fact
CREATE TABLE FactsDiagram (
	name char(20),
	sum int
);

INSERT INTO FactsDiagram
SELECT name, sum(amount) FROM facts GROUP BY name;

--         name         |    sum    
------------------------+-----------
-- forked               |  14664799
-- commit               | 502284865
-- pull_comment         |  10019022
-- commit_comment       |   3422105
-- pull                 |  39512989
-- issue_reporter       |  36672569
-- issue_assignee       |  36672569
-- watchers             |  54746722
-- issue_comment        |  62478002

--We create facts table for 10% of most watched projects
CREATE TABLE factsOne (
	name char(20),
	project_id int,
	user_id int,
	year smallint,
	month smallint,
	language_id varchar,
	amount int
);

-- We count how many facts we got in total
SELECT SUM(amount) FROM facts;
-- answer: 772 090 396

-- We count if we correctly created sql query to select only projects from 10% of most succesfull projects
SELECT SUM(x.amount) FROM(
SELECT f.name, f.project_id, f.user_id, f.year, f.month, f.language_id, f.amount FROM facts as f, watchersTenPer as w WHERE f.project_id = w.project_id) as x;
-- answer: 249 973 755

-- We insert results to our new table
INSERT INTO factsOne
SELECT f.name, f.project_id, f.user_id, f.year, f.month, f.language_id, f.amount FROM facts as f, watchersTenPer as w WHERE f.project_id = w.project_id;

-- We create table, so we can compare what makes project succesful
CREATE TABLE FactsOneDiagram (
	name char(20),
	sum int
);

-- We insert results
INSERT INTO FactsOneDiagram
SELECT name, sum(amount) FROM factsOne GROUP BY name;

--         name         |   sum    
----------------------+----------
-- issue_reporter       | 18622891
-- commit               | 77957852
-- pull_comment         |  7025753
-- issue_comment        | 49618347
-- forked               | 10239012
-- commit_comment       |  1191045
-- pull                 | 18891960
-- issue_assignee       | 18622891
-- watchers             | 47804004

-- We do the same steps in order to calculate fact diagram for 1% of most watched projects
CREATE TABLE watchersOnePer (
	project_id int,
	sum int
);

INSERT INTO watchersOnePer
SELECT project_id, count(*) as sum FROM facts
WHERE name LIKE '%watchers%'
GROUP BY project_id
ORDER BY sum desc
LIMIT 42345;

CREATE TABLE factsOnePer (
	name char(20),
	project_id int,
	user_id int,
	year smallint,
	month smallint,
	language_id varchar,
	amount int
);

INSERT INTO factsOnePer
SELECT f.name, f.project_id, f.user_id, f.year, f.month, f.language_id, f.amount FROM facts as f, watchersOnePer as w WHERE f.project_id = w.project_id;

CREATE TABLE FactsOnePerDiagram (
	name char(20),
	sum int
);
INSERT INTO FactsOnePerDiagram
SELECT name, sum(amount) FROM factsOnePer GROUP BY name;

--         name         |   sum    
----------------------+----------
-- issue_reporter       |  9938161
-- commit               | 27729020
-- pull_comment         |  4326066
-- issue_comment        | 32008558
-- forked               |  6325383
-- commit_comment       |   590121
-- pull                 |  9933774
-- issue_assignee       |  9938161
-- watchers             | 34478828
