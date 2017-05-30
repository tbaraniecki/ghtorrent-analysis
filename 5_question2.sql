-- Authors: Rafał Wycichowski, Tomasz Baraniecki
-- 5
-- What makes user succesful?
-- In order to answer to that question we do similar steps like in sql file number 3
CREATE TABLE followersTenPer (
	user_id int,
	sum int
);
-- We check number of users that are followed
SELECT count(*) FROM(
SELECT user_id, sum(amount) as sum FROM facts
WHERE name LIKE '%follower%'
GROUP BY user_id
ORDER BY sum desc) as x;
-- answer: 1790539

-- We insert 10% of most followed users facts into table followersTenPer
INSERT INTO followersTenPer
SELECT user_id, sum(amount) as sum FROM facts
WHERE name LIKE '%follower%'
GROUP BY user_id
ORDER BY sum desc
LIMIT 179053;

-- We calculate how many types of facts there are in facts table
SELECT name, sum(amount) FROM facts GROUP BY name;

--         name         |    sum    
----------------------+-----------
-- forked               |  14664799
-- commit               | 502284865
-- pull_comment         |  10019022
-- commit_comment       |   3422105
-- pull                 |  39512989
-- issue_reporter       |  36672569
-- issue_assignee       |  36672569
-- follower             |  11616754
-- issue_comment        |  62478002

--We create facts table for 10% of most followed users
CREATE TABLE factsTwo (
	name char(20),
	project_id int,
	user_id int,
	year smallint,
	month smallint,
	language_id varchar,
	amount int
);

--We insert results to our new table
INSERT INTO factsTwo
SELECT f.name, f.project_id, f.user_id, f.year, f.month, f.language_id, f.amount FROM facts as f, followersTenPer as w WHERE f.user_id = w.user_id;

-- We create table so, we can compare what makes project succesful
CREATE TABLE FactsTwoDiagram (
	name char(20),
	sum int
);

-- We insert values
INSERT INTO FactsTwoDiagram
SELECT name, sum(amount) FROM factsTwo GROUP BY name;

--         name         |    sum    
------------------------+-----------
-- issue_reporter       |   7583513
-- commit               | 146159676
-- pull_comment         |   6229458
-- issue_comment        |  34290293
-- follower             |   7896039
-- forked               |   3253914
-- commit_comment       |   1696279
-- pull                 |  15103606
-- issue_assignee       |   1168304


-- We do the same steps for 1% of most followed users

CREATE TABLE followersOnePer (
	user_id int,
	sum int
);
INSERT INTO followersOnePer
SELECT user_id, sum(amount) as sum FROM facts
WHERE name LIKE '%follower%'
GROUP BY user_id
ORDER BY sum desc
LIMIT 17905;

CREATE TABLE factsTwoPer (
	name char(20),
	project_id int,
	user_id int,
	year smallint,
	month smallint,
	language_id varchar,
	amount int
);

INSERT INTO factsTwoPer
SELECT f.name, f.project_id, f.user_id, f.year, f.month, f.language_id, f.amount FROM facts as f, followersOnePer as w WHERE f.user_id = w.user_id;

CREATE TABLE FactsTwoPerDiagram (
	name char(20),
	sum int
);

INSERT INTO FactsTwoPerDiagram
SELECT name, sum(amount) FROM factsTwoPer GROUP BY name;

--         name         |   sum    
----------------------+----------
-- issue_reporter       |  2186028
-- commit               | 39492783
-- pull_comment         |  2154402
-- issue_comment        | 14025246
-- follower             |  4378478
-- forked               |   642165
-- commit_comment       |   566646
-- pull                 |  4129509
-- issue_assignee       |   322552
-- watchers             |  4700116