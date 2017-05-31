# Study of success on github based on GHTorrent project

*Authors*
* [Tomasz Baraniecki](https://github.com/tbaraniecki)
* [Rafał Wycichowski](https://github.com/Wyci)
* supervisor: [Tomasz Kajdanowicz](https://github.com/kajdanowicz)

## Table of contents
1. [Introduction](#1-introduction)
2. [Questions](#2-questions)
3. [Design Stage](https://github.com/tbaraniecki/ghtorrent-analysis#3-design-stage)
4. [Preparing data](https://github.com/tbaraniecki/ghtorrent-analysis#4-preparing-data)
4.1. [Setting up environment](https://github.com/tbaraniecki/ghtorrent-analysis#41-setting-up-environment)
4.2. [Obtaining source data](https://github.com/tbaraniecki/ghtorrent-analysis#42-obtaining-source-data)
4.3. [Preparing source data](https://github.com/tbaraniecki/ghtorrent-analysis#43-preparing-source-data)
4.4. [Importing source data](https://github.com/tbaraniecki/ghtorrent-analysis#44-importing-source-data)
5. [Creating data warehouse](https://github.com/tbaraniecki/ghtorrent-analysis#5-creating-data-warehouse)
6. [Project](https://github.com/tbaraniecki/ghtorrent-analysis#6-project)
6.1. [Quering data](https://github.com/tbaraniecki/ghtorrent-analysis#61-quering-data)
6.2. [Analysing projects data]()
7. [Users](https://github.com/tbaraniecki/ghtorrent-analysis#7-quering-data-for-users)
8. [Programming languages](https://github.com/tbaraniecki/ghtorrent-analysis#8-quering-languages-data)
8.1. []()
8.2. []()
9. Conclusions

# 1. Introduction

This is study of GHTorrent project data on Wroclaw University of Technology.

# 2. Questions

Our study has to answer for:

1. What makes that project succeeded? 
2. What makes that user succeeded?
3. Whats programming languages are rising and what programming languages are going to be forget?

# 3. Design stage

<dl>
  <dt>Source data</dt>
  <dd>http://ghtorrent.org - dump from 2017-01-01</dd>

  <dt>ER Diagram</dt>
  <dd>http://ghtorrent.org/files/schema.pdf</dd>

  <dt>Business Process</dt>
  <dd></dd>

  <dt>Grain</dt>
  <dd>a monthly sum of each fact that occurs when GitHub.com is used by users</dd>

  <dt>Facts</dt>
  <dd>commit, commit_comment, watcher, follower, pull, pull_comment, forked, issue_reporter, issue_assignee, issue_comment</dd>

  <dt>Dimensions</dt>
  <dd>user, project, programming language, time</dd>

  <dt>Data Warehouse scheme</dt>
  <dd>star</dd>

  <dt>Hierachies: </dt>
  <dd>time: year -> month</dd>
</dl>

## Design of data warehouse

<dl>
	<dt>facts</dt>
  <dd>name, project_id, user_id, year, month, language_id, amount</dd>

  <dt>projects_dimension</dt>
  <dd>project_id, name</dd>

  <dt>users_dimension</dt>
  <dd>user_id, username</dd>

  <dt>language_dimension</dt>
  <dd>language</dd>
</dl>

# 4. Preparing data

## 4.1. Setting up environment

Postgresql 9.6.1, Sublime Text, Terminal with ZSH 

Tweaked settings
```bash
shared_buffers = 2048MB
temp_buffers = 1024MB
work_mem = 4096MB
maintenance_work_mem = 1024MB
dynamic_shared_memory_type = posix
effective_cache_size = 8GB
default_statistics_target = 1000
logging_collector = off
```

## 4.2. Obtaining source data

MySQL database dump of 2017-01-01 (size: 46.48GB, http://ghtorrent.org/downloads.html).
After untar and unzip we got following files. Each dump csv file represents one table. 

| name | size |
| --- | --- |
| commit_comments.csv | 617.4 MB |
| commit_parents.csv | 9.89 GB |
| commits.csv | 49.49 GB |
| followers.csv | 412.1 MB |
| issue_comments.csv | 3.08 GB |
| issue_events.csv | 3.63 GB |
| issue_labels.csv | 198.6 MB |
| issess.csv | 2.15 GB |
| organizational_members.csv | 13.7 MB |
| project_commits.csv | 86.96 GB |
| project_languages.csv | 3.21 GB | 
| project_members.csv | 449.4 MB |
| projects.csv | 6.99 GB |
| pull_request_comments.csv | 1.67 GB |
| pull_request_commits.csv | 1.53 GB |
| pull_request_history.csv | 2.24 GB |
| pull_request.csv | 835.6 MB |
| repo_labels.csv | 3.08 GB |
| repo_milestones.csv | 0 |
| users.csv | 1.22 GB |
| watchers.csv | 2.05 GB |

## 4.3. Preparing source data

Database dump is in mysql. We created table and then we used postgresql copy command to import data.

We had problem with escaping characters such as \” which caused import to crash and in some cases there were null value so used NULL AS ‘\N’ and ESCAPE AS ‘\’.

Change NULL to \N.
```bash
sed -i -e 's/NULL/\N/g' projects.csv
```

GitHub uses zero timestamp: “0000-00-00 00:00:00” for column “update_at” - it meant that the project was never updated so we decided to change it to null.

Change timestamp to \N.
```bash
sed -i -e 's=“0000-00-00 00:00:00”=\\N=g' commits.csv
```

Delete first line of dump files which contains header information.
```bash
sed -i -e "1d" projects.csv
```

Due to git specification, commit timestamp is based on computer clock. So we have a lot of commits before with years like 1975 and 2018 - 2030.

## 4.4. Importing source data 

We created table and then used copy command.

```sql
CREATE TABLE users (
	ID int,
	LOGIN varchar,
	COMPANY varchar,
	CREATED_AT timestamp,
	TYPE varchar,
	FAKE smallint,
	DELETED smallint, 
	LONG double precision,
	LAT double precision,
	COUNTRY_CODE char(3),
	STATE varchar, 
	CITY varchar, 
	LOCATION varchar
);
```
```sql
COPY users FROM '/Volumes/Data2/ghtorrent/mysql-2017-01-01/users.csv' DELIMITER ',' NULL AS '\N' ESCAPE AS '\' CSV;
```
```sql
CREATE TABLE projects
(
	ID int,
	URL varchar,
	OWNER_ID int,
	NAME varchar,
	DESCRIPTION varchar,
	LANGUAGE varchar,
	CREATED_AT timestamp,
	FORKED_FROM int,
	DELETED smallint,
	UPDATET_AT timestamp
);
```
```sql
COPY projects FROM '/Volumes/Data2/ghtorrent/mysql-2017-01-01/projects.csv' DELIMITER ',' NULL AS '\N' ESCAPE AS '\' CSV;
```
```sql
CREATE TABLE commits
(
	ID int,
	SHA varchar,
	AUTHOR_ID int,
	COMMITTER_ID int,
	PROJECT_ID int,
	CREATED_AT timestamp
);
```
```sql
COPY commits FROM '/Volumes/Data2/ghtorrent/mysql-2017-01-01/commits.csv' DELIMITER ',' NULL AS '\N' ESCAPE AS '\' CSV;
```
```sql
CREATE TABLE commit_comments(
	ID int,
	COMMIT_ID int,
	USER_ID int,
	BODY varchar,
	LINE int,
	POSITION int,
	COMMENT_ID int,
	CREATED_AT timestamp
);
```
```sql
COPY commit_comments FROM ‘/Volumes/Data2/ghtorrent/mysql-2017-01-01/commit_comments.csv' DELIMITER ',' NULL AS '\N' ESCAPE AS '\' CSV;
```
```sql
CREATE TABLE commit_parents(
	COMMIT_ID int,
	PARENT_ID int
);
```
```sql
COPY  FROM '/Volumes/Data2/ghtorrent/mysql-2017-01-01/commit_parents.csv' DELIMITER ',' NULL AS '\N' ESCAPE AS '\' CSV;
```
```sql
CREATE TABLE followers(
	FOLLOWER_ID int,
	USER_ID int,
	CREATED_AT timestamp
);
```
```sql
COPY users FROM '/Volumes/Data2/ghtorrent/mysql-2017-01-01/followers.csv' DELIMITER ',' NULL AS '\N' ESCAPE AS '\' CSV;
```
```sql
CREATE TABLE pull_requests(
	ID int,
	HEAD_REPO_ID int,
	BASE_REPO_ID int,
	HEAD_COMMIT_ID int,
	BASE_COMMIT_ID int,
	PULLREQ_ID int,
	INTRA_BRANCH smallint
);
```
```sql
COPY pull_requests FROM '/Volumes/Data2/ghtorrent/mysql-2017-01-01/pull_requests.csv' DELIMITER ',' NULL AS '\N' ESCAPE AS '\' CSV;
```
```sql
CREATE TABLE issues(
	ID int,
	REPO_ID int,
	REPORTER_ID int,
	assignee_id int,
	pull_request int,
	pull_request_id int,
	created_at timestamp,
	issue_id int
);
```
```sql
COPY issues FROM '/Volumes/Data2/ghtorrent/mysql-2017-01-01/issues.csv' DELIMITER ',' NULL AS '\N' ESCAPE AS '\' CSV;
```
```sql
CREATE TABLE issue_comments(
	issue_id int,
	user_id int,
	comment_id text,
	created_at timestamp
);
```
```sql
COPY issue_comments FROM '/Volumes/Data2/ghtorrent/mysql-2017-01-01/issue_comments.csv' DELIMITER ',' NULL AS '\N' ESCAPE AS '\' CSV;
```
```sql
CREATE TABLE issue_events (
	event_id text,
	issue_id int,
	actor_id int,
	action varchar,
	action_specific varchar,
	created_at timestamp
);
```
```sql
COPY issue_events FROM '/Volumes/Data2/ghtorrent/mysql-2017-01-01/issue_events.csv' DELIMITER ',' NULL AS '\N' ESCAPE AS '\' CSV;
```
```sql
CREATE TABLE repo_labels(
	id int,
	repo_id int,
	name varchar
);
```
```sql
COPY repo_labels FROM '/Volumes/Data2/ghtorrent/mysql-2017-01-01/repo_labels.csv' DELIMITER ',' NULL AS '\N' ESCAPE AS '\' CSV;
```
```sql
CREATE TABLE issue_labels(
	label_id int,
	issue_id int
);
```
```sql
COPY issue_labels FROM '/Volumes/Data2/ghtorrent/mysql-2017-01-01/issue_labels.csv' DELIMITER ',' NULL AS '\N' ESCAPE AS '\' CSV;
```
```sql
CREATE TABLE organization_members (
	org_id int,
	user_id int,
	created_at timestamp
);
```
```sql
COPY organization_members FROM '/Volumes/Data2/ghtorrent/mysql-2017-01-01/organization_members.csv' DELIMITER ',' NULL AS '\N' ESCAPE AS '\' CSV;
```
```sql
CREATE TABLE project_commits (
	project_id int,
	commit_id int
);
```
```sql
COPY project_commits FROM '/Volumes/Data2/ghtorrent/mysql-2017-01-01/project_commits.csv' DELIMITER ',' NULL AS '\N' ESCAPE AS '\' CSV;
```
```sql
CREATE TABLE project_members (
	repo_id int,
	user_id int,
	created_at timestamp,
	ext_ref_id varchar
);
```
```sql
COPY project_members FROM '/Volumes/Data2/ghtorrent/mysql-2017-01-01/project_members.csv' DELIMITER ',' NULL AS '\N' ESCAPE AS '\' CSV;
```
```sql
CREATE TABLE project_languages (
	project_id int,
	language int,
	bytes int,
	created_at timestamp
);
```
```sql
COPY project_languages FROM '/Volumes/Data2/ghtorrent/mysql-2017-01-01/project_languages.csv' DELIMITER ',' NULL AS '\N' ESCAPE AS '\' CSV;
```
```sql
CREATE TABLE pull_request_comments (
	pull_request_id int,
	user_id int,
	comment_id int,
	position_id int,
	body varchar,
	commit_id int,
	created_at timestamp
);
```
```sql
COPY pull_request_comments FROM '/Volumes/Data2/ghtorrent/mysql-2017-01-01/pull_request_comments.csv' DELIMITER ',' NULL AS '\N' ESCAPE AS '\' CSV;
```
```sql
CREATE TABLE pull_request_commits (
	pull_request_id int,
	commit_id int
);
```
```sql
COPY pull_request_commits FROM '/Volumes/Data2/ghtorrent/mysql-2017-01-01/pull_request_commits.csv' DELIMITER ',' NULL AS '\N' ESCAPE AS '\' CSV;
```
```sql
CREATE TABLE pull_request_history (
	id int,
	pull_request_id int,
	created_at timestamp,
	action varchar,
	actor_id int
);
```
```sql
COPY pull_request_history FROM '/Volumes/Data2/ghtorrent/mysql-2017-01-01/pull_request_history.csv' DELIMITER ',' NULL AS '\N' ESCAPE AS '\' CSV;
```
```sql
CREATE TABLE repo_milestones(
	id int,
	repo_id int,
	name varchar
);
```
```sql
COPY repo_milestones FROM '/Volumes/Data2/ghtorrent/mysql-2017-01-01/repo_milestones.csv' DELIMITER ',' NULL AS '\N' ESCAPE AS '\' CSV;
```
```sql
CREATE TABLE schema_info (
	version int
);
```
```sql
COPY schema_info FROM '/Volumes/Data2/ghtorrent/mysql-2017-01-01/schema_info.csv' DELIMITER ',' NULL AS '\N' ESCAPE AS '\' CSV;
```
```sql
CREATE TABLE watchers (
	repo_id int,
	user_id int,
	created_at timestamp
);
```
```sql
COPY watchers FROM '/Volumes/Data2/ghtorrent/mysql-2017-01-01/watchers.csv' DELIMITER ',' NULL AS '\N' ESCAPE AS '\' CSV;
```

# 5. Creating data warehouse

Create tables for dimension and facts.

```sql
-- dimension
CREATE TABLE projects_dimension(
	project_id int,
	name varchar
);

-- dimension
CREATE TABLE users_dimension (
	user_id int,
	username varchar
);

-- dimension
CREATE TABLE language_dimension (
	language varchar,
);

-- fact
CREATE TABLE facts (
	name char(20),
	project_id int,
	user_id int,
	year smallint,
	month smallint,
	language_id varchar,
	amount int
);
```

Inserting dimensions data.
```sql
-- projects_dimension
INSERT INTO projects_dimension (project_id, name)
SELECT projects.id, projects.name FROM projects;

-- users_dimension
INSERT INTO users_dimension (user_id, name)
SELECT users.id, users.name FROM users;

-- language_dimension
INSERT INTO language_dimension (language)
SELECT language FROM projects GROUP BY language ORDER BY langauge;

ALTER TABLE language_dimension ADD language_id SERIAL PRIMARY KEY;
```

Inserting facts data.
```sql
--commits
INSERT INTO facts 
SELECT 'commit' as w, 
commits.project_id as p, 
commits.committer_id as u, 
EXTRACT(YEAR FROM commits.created_at) as y, 
EXTRACT(MONTH FROM commits.created_at) as m, 
projects.language as l, 
COUNT(*) as count 
FROM commits, projects 
where projects.id = commits.project_id GROUP BY (w,p,u,y,m,l) ORDER BY count desc;

--commit_comment
INSERT INTO facts 
SELECT 'commit_comment' as w, 
commits.project_id as p, 
commit_comments.user_id as u,
EXTRACT(YEAR FROM commit_comments.created_at) as y, 
EXTRACT(MONTH FROM commit_comments.created_at) as m, 
projects.language as l, 
COUNT(*) as count 
FROM commit_comments, projects, commits
WHERE projects.id = commits.project_id AND commit_comments.commit_id = commits.id
GROUP BY (w,p,u,y,m,l) 
ORDER BY count desc;

--watchers
INSERT INTO facts 
SELECT 'watchers' as w, 
watchers.repo_id as p, 
watchers.user_id as u, 
EXTRACT(YEAR FROM watchers.created_at) as y, 
EXTRACT(MONTH FROM watchers.created_at) as m, 
projects.language as l, 
COUNT(*) as count FROM watchers, 
projects where projects.id = watchers.repo_id GROUP BY (w,p,u,y,m,l);

--followers
INSERT INTO facts 
SELECT 'follower' as f,
-1 as p, 
followers.user_id as u, 
EXTRACT(YEAR FROM followers.created_at) as y, 
EXTRACT(MONTH FROM followers.created_at) as m, 
'\N' as l, 
COUNT(*) as c
FROM followers GROUP BY (f,p,u,y,m,l) ORDER BY c desc;

--pull
INSERT INTO facts 
SELECT 'pull' as w, 
pull_requests.base_repo_id as p,
commits.committer_id as u,
EXTRACT(YEAR FROM pull_request_history.created_at) as y, 
EXTRACT(MONTH FROM pull_request_history.created_at) as m, 
projects.language as l, 
COUNT(*) as count 
FROM pull_requests, projects, commits, pull_request_history
WHERE projects.id = pull_requests.base_repo_id AND pull_request.head_commit_id = commits.id AND pull_request_history.pull_request_id = pull_request.id
GROUP BY (w,p,u,y,m,l) 
ORDER BY count desc;

--pull_comment
INSERT INTO facts 
SELECT 'pull_comment' as w, 
pull_requests.base_repo_id as p,
pull_request_comments.user_id as u,
EXTRACT(YEAR FROM pull_request_comments.created_at) as y, 
EXTRACT(MONTH FROM pull_request_comments.created_at) as m, 
projects.language as l, 
COUNT(*) as count 
FROM pull_request_comments, projects, pull_requests
WHERE projects.id = pull_requests.base_repo_id AND pull_requests.id = pull_request_comments.pull_request_id
GROUP BY (w,p,u,y,m,l) 
ORDER BY count desc;

--forked
INSERT INTO facts 
SELECT 'forked' as w, 
p2.forked_from as p,
p2.owner_id as u,
EXTRACT(YEAR FROM p2.created_at) as y, 
EXTRACT(MONTH FROM p2.created_at) as m, 
p2.language as l, 
COUNT(*) as count 
FROM projects as p1, projects as p2
WHERE p1.id = p2.forked_from
GROUP BY (w,p,u,y,m,l) 
ORDER BY count desc;

--issue_reporter
INSERT INTO facts 
SELECT 'issue_reporter' as w, 
issues.repo_id as p,
issues.reporter_id as u,
EXTRACT(YEAR FROM issues.created_at) as y, 
EXTRACT(MONTH FROM issues.created_at) as m, 
projects.language as l, 
COUNT(*) as count 
FROM issues, projects
WHERE projects.id = issues.repo_id
GROUP BY (w,p,u,y,m,l) 
ORDER BY count desc;

--issue_assignee
INSERT INTO facts 
SELECT 'issue_assignee' as w, 
issues.repo_id as p,
issues.assignee_id as u,
EXTRACT(YEAR FROM issues.created_at) as y, 
EXTRACT(MONTH FROM issues.created_at) as m, 
projects.language as l, 
COUNT(*) as count 
FROM issues, projects
WHERE projects.id = issues.repo_id
GROUP BY (w,p,u,y,m,l) 
ORDER BY count desc;

--issue_comment
INSERT INTO facts 
SELECT 'issue_comment' as w, 
issues.repo_id as p,
issue_comments.user_id as u,
EXTRACT(YEAR FROM issue_comments.created_at) as y, 
EXTRACT(MONTH FROM issue_comments.created_at) as m, 
projects.language as l, 
COUNT(*) as count 
FROM issues, projects, issue_comments
WHERE projects.id = issues.repo_id AND issues.id = issue_comments.issue_id
GROUP BY (w,p,u,y,m,l) 
ORDER BY count desc;
```

We deleted unneeded data from imported source data, so we could save some disk space.

```sql
ALTER TABLE commits
DROP COLUMN sha;

ALTER TABLE commits
DROP COLUMN committer_id;
```

Statistics after creating dimensional model

* Facts table contains ~772.000.000 records.
* Projects - 1 mln records
* Users - 1 mln records. 

# 6. Project.

## 6.1. Quering data

We start from counting how many projects are watched in total.
```sql
SELECT count(*) FROM (
SELECT project_id, count(*) as sum FROM facts
WHERE name LIKE '%watchers%'
GROUP BY project_id
ORDER BY sum desc) as x;
```
Answer: 4.234.456. 

| amount | count | 
| --- | ---: |
| 10 | 10 |
| 1% | 42 345 |
| 4% | 169 378 |
| 7% | 296 412 |
| 10% | 423 446 |
| 13% | 550 479 |
| 16% | 677 513 |
| 19% | 804 547 |
| 22% | 931 580 |
| 25% | 1 058 614 |
| all | 4 234 456 |


We check best 10% of them.
```sql
CREATE TABLE watchersTenPer (
	project_id int,
	sum int
);

INSERT INTO watchersTenPer
SELECT project_id, count(*) as sum FROM facts
WHERE name LIKE '%watchers%'
GROUP BY project_id
ORDER BY sum desc
LIMIT 423446; -- 423446 is 10% of 4234456
```

We want to know how many facts there are for every kind of fact
```sql
CREATE TABLE FactsDiagram (
	name char(20),
	sum int
);

INSERT INTO FactsDiagram
SELECT name, sum(amount) FROM facts GROUP BY name;
```

|         name         |    sum    |
|----------------------|---------:|
| forked               |  14664799 |
| commit               | 502284865 |
| pull_comment         |  10019022 |
| commit_comment       |   3422105 |
| pull                 |  39512989 |
| issue_reporter       |  36672569 |
| issue_assignee       |  36672569 |
| watchers             |  54746722 |
| issue_comment        |  62478002 |


Firstly we created new tables and then we put answers there, but later we have rewriten queries, so You can skip block below. 
```sql
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
```

Next results we will obtain by creating only one query for each results so we can save time.
In order to better analyse the first question we check our database for number of facts for following % of most watched projects:
first 10, 1%, 4%, 7%, 10%, 13%, 16%, 19%, 22%, 25%.


10 best projects
```sql
SELECT f.name, sum(f.amount)
FROM (SELECT project_id,  count(*) as sum FROM facts
WHERE name LIKE '%watchers%'
GROUP BY project_id
ORDER BY sum desc
LIMIT 10) as p,
facts as f
WHERE f.project_id = p.project_id
GROUP BY f.name
ORDER BY f.name; 

--         name         |  sum   
----------------------+--------
-- commit               |  53955
-- commit_comment       |   3667
-- forked               | 114600
-- issue_assignee       |  70270
-- issue_comment        | 264317
-- issue_reporter       |  70270
-- pull                 |  65034
-- pull_comment         |  24276
-- watchers             | 493874

-- query time - 2:20
```

1% best projects 42345 of 4 234 456
```sql
SELECT f.name, sum(f.amount)
FROM (SELECT project_id,  count(*) as sum FROM facts
WHERE name LIKE '%watchers%'
GROUP BY project_id
ORDER BY sum desc
LIMIT 42345) as p,
facts as f
WHERE f.project_id = p.project_id
GROUP BY f.name
ORDER BY f.name; 

         name         |   sum    
----------------------+----------
 commit               | 27729020
 commit_comment       |   590121
 forked               |  6325383
 issue_assignee       |  9938161
 issue_comment        | 32008558
 issue_reporter       |  9938161
 pull                 |  9933774
 pull_comment         |  4326066
 watchers             | 34478828

-- query time - 7:54
```

4% best projects 169 378 of 4 234 456
```sql
SELECT f.name, sum(f.amount)
FROM (SELECT project_id,  count(*) as sum FROM facts
WHERE name LIKE '%watchers%'
GROUP BY project_id
ORDER BY sum desc
LIMIT 169378) as p,
facts as f
WHERE f.project_id = p.project_id
GROUP BY f.name
ORDER BY f.name; 

--         name         |   sum    
----------------------+----------
-- commit               | 51460177
-- commit_comment       |   957976
-- forked               |  8787683
-- issue_assignee       | 14932963
-- issue_comment        | 43197602
-- issue_reporter       | 14932963
-- pull                 | 14982575
-- pull_comment         |  5969090
-- watchers             | 43528455

-- query time - 5:54
```

7% best projects 296 412 of 4 234 456
```sql
 SELECT f.name, sum(f.amount)
 FROM (SELECT project_id,  count(*) as sum FROM facts
 WHERE name LIKE '%watchers%'
 GROUP BY project_id
 ORDER BY sum desc
 LIMIT 296412) as p,
 facts as f
 WHERE f.project_id = p.project_id
 GROUP BY f.name
 ORDER BY f.name; 
 
--         name         |   sum    
----------------------+----------
-- commit               | 66072697
-- commit_comment       |  1095203
-- forked               |  9699805
-- issue_assignee       | 17171782
-- issue_comment        | 47275516
-- issue_reporter       | 17171782
-- pull                 | 17305847
-- pull_comment         |  6642968
-- watchers             | 46305788

-- query time - 6:31
```

10% best projects 423 446 of 4 234 456
```sql
 SELECT f.name, sum(f.amount)
 FROM (SELECT project_id,  count(*) as sum FROM facts
 WHERE name LIKE '%watchers%'
 GROUP BY project_id
 ORDER BY sum desc
 LIMIT 423446) as p,
 facts as f
 WHERE f.project_id = p.project_id
 GROUP BY f.name
 ORDER BY f.name; 
 
         name         |   sum    
----------------------+----------
 commit               | 77957852
 commit_comment       |  1191045
 forked               | 10239012
 issue_assignee       | 18622891
 issue_comment        | 49618347
 issue_reporter       | 18622891
 pull                 | 18891960
 pull_comment         |  7025753
 watchers             | 47804004

-- query time - 6:50
```

13% best projects 550 479 of 4 234 456
```sql
SELECT f.name, sum(f.amount)
FROM (SELECT project_id,  count(*) as sum FROM facts
WHERE name LIKE '%watchers%'
GROUP BY project_id
ORDER BY sum desc
LIMIT 550479) as p,
facts as f
WHERE f.project_id = p.project_id
GROUP BY f.name
ORDER BY f.name; 

--         name         |   sum    
------------------------+----------
-- commit               | 89195302
-- commit_comment       |  1286233
-- forked               | 10611321
-- issue_assignee       | 19682637
-- issue_comment        | 51140685
-- issue_reporter       | 19682637
-- pull                 | 20029839
-- pull_comment         |  7314754
-- watchers             | 48789740

-- query time - 6:24 
```

16% best projects 677 513 of 4 234 456
```sql
SELECT f.name, sum(f.amount)
FROM (SELECT project_id,  count(*) as sum FROM facts
WHERE name LIKE '%watchers%'
GROUP BY project_id
ORDER BY sum desc
LIMIT 677513) as p,
facts as f
WHERE f.project_id = p.project_id
GROUP BY f.name
ORDER BY f.name; 
--         name         |   sum    
------------------------+----------
-- commit               | 98016297
-- commit_comment       |  1347155
-- forked               | 10888426
-- issue_assignee       | 20620420
-- issue_comment        | 52204942
-- issue_reporter       | 20620420
-- pull                 | 20921751
-- pull_comment         |  7570391
-- watchers             | 49494892

-- query time - 6:19
```

19% best projects 804547 of 4 234 456
```sql
SELECT f.name, sum(f.amount)
FROM (SELECT project_id,  count(*) as sum FROM facts
WHERE name LIKE '%watchers%'
GROUP BY project_id
ORDER BY sum desc
LIMIT 804547) as p,
facts as f
WHERE f.project_id = p.project_id
GROUP BY f.name
ORDER BY f.name;

--         name         |    sum    
------------------------+-----------
-- commit               | 106707997
-- commit_comment       |   1403791
-- forked               |  11103236
-- issue_assignee       |  21299929
-- issue_comment        |  53042170
-- issue_reporter       |  21299929
-- pull                 |  21669761
-- pull_comment         |   7741251
-- watchers             |  50044933

-- query time - 6:39
```

22% best projects 931 580 of 4 234 456
```sql
SELECT f.name, sum(f.amount)
FROM (SELECT project_id,  count(*) as sum FROM facts
WHERE name LIKE '%watchers%'
GROUP BY project_id
ORDER BY sum desc
LIMIT 931580) as p,
facts as f
WHERE f.project_id = p.project_id
GROUP BY f.name
ORDER BY f.name;

--         name         |    sum    
------------------------+-----------
-- commit               | 114044246
-- commit_comment       |   1450684
-- forked               |  11273477
-- issue_assignee       |  21861461
-- issue_comment        |  53661676
-- issue_reporter       |  21861461
-- pull                 |  22272249
-- pull_comment         |   7872238
-- watchers             |  50490747

-- query time 6:11
```

25% best projects 1 058 614 of 4 234 456
```sql
SELECT f.name, sum(f.amount)
FROM (SELECT project_id,  count(*) as sum FROM facts
WHERE name LIKE '%watchers%'
GROUP BY project_id
ORDER BY sum desc
LIMIT 1058614) as p,
facts as f
WHERE f.project_id = p.project_id
GROUP BY f.name
ORDER BY f.name;

--         name         |    sum    
------------------------+-----------
-- commit               | 120637829
-- commit_comment       |   1509909
-- forked               |  11423644
-- issue_assignee       |  22376132
-- issue_comment        |  54195492
-- issue_reporter       |  22376132
-- pull                 |  22854817
-- pull_comment         |   7989733
-- watchers             |  50871849

-- time 6:20
```

Fact *watchers* is actually useless for anylysis since we base our best project on amount of watchers fact per project. 

## 8.2. Analysing data. 





# 7. Users

We want to know what makes user succeded? We measure success on number of user followers. We want to study chages in amount of type of facts and their percentage for best users: 10 users, 1%, 4%, 7%, 10%, 13%, 16%, 19%, 22%, 25%. 

## 7.1. Quering data

```sql
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
```

Next results we will obtain by creating only one query for each results so we can save time. In order to better analyse the second question we check our database for number of facts for following % of most followed users
* all - 1790539 - 1% - 17905,39
* 10
* 4%
* 7%
* 13%
* 16%
* 19%
* 22%
* 25%

```sql
-- 10 most followed users
SELECT f.name, sum(f.amount)
FROM (SELECT user_id, sum(amount) as sum FROM facts
WHERE name LIKE '%follower%'
GROUP BY user_id
ORDER BY sum desc
LIMIT 10) as p,
facts as f
WHERE f.user_id = p.user_id
GROUP BY f.name
ORDER BY f.name; 

--         name         |  sum   
------------------------+--------
-- commit               | 107941
-- commit_comment       |   1435
-- follower             | 197011
-- forked               |    692
-- issue_assignee       |    427
-- issue_comment        |  40724
-- issue_reporter       |   4235
-- pull                 |  10250
-- pull_comment         |   6446
-- watchers             |   2291

-- time - 1:32

-- 4% of most followed users - 71622 of 1790539
SELECT f.name, sum(f.amount)
FROM (SELECT user_id, sum(amount) as sum FROM facts
WHERE name LIKE '%follower%'
GROUP BY user_id
ORDER BY sum desc
LIMIT 71622) as p,
facts as f
WHERE f.user_id = p.user_id
GROUP BY f.name
ORDER BY f.name; 

--         name         |   sum    
------------------------+----------
-- commit               | 93369401
-- commit_comment       |  1217832
-- follower             |  6314126
-- forked               |  1816848
-- issue_assignee       |   729335
-- issue_comment        | 25921331
-- issue_reporter       |  4764984
-- pull                 |  9549031
-- pull_comment         |  4554476
-- watchers             | 12859749
 
-- time 6:18
 
-- 7% of most followed users - 125338 of 1790539
SELECT f.name, sum(f.amount)
FROM (SELECT user_id, sum(amount) as sum FROM facts
WHERE name LIKE '%follower%'
GROUP BY user_id
ORDER BY sum desc
LIMIT 125338) as p,
facts as f
WHERE f.user_id = p.user_id
GROUP BY f.name
ORDER BY f.name; 

--         name         |    sum    
------------------------+-----------
-- commit               | 122873709
-- commit_comment       |   1500960
-- follower             |   7263298
-- forked               |   2605050
-- issue_assignee       |    973001
-- issue_comment        |  30896614
-- issue_reporter       |   6512953
-- pull                 |  12945700
-- pull_comment         |   5460781
-- watchers             |  18185338

-- time 6:00

-- 13% of most followed users - 232770 of 1790539
SELECT f.name, sum(f.amount)
FROM (SELECT user_id, sum(amount) as sum FROM facts
WHERE name LIKE '%follower%'
GROUP BY user_id
ORDER BY sum desc
LIMIT 232770) as p,
facts as f
WHERE f.user_id = p.user_id
GROUP BY f.name
ORDER BY f.name; 

--         name         |    sum    
------------------------+-----------
-- commit               | 164005529
-- commit_comment       |   1845159
-- follower             |   8368352
-- forked               |   3778149
-- issue_assignee       |   1320443
-- issue_comment        |  36921662
-- issue_reporter       |   8408844
-- pull                 |  16781906
-- pull_comment         |   6688960
-- watchers             |  25612235
 
 -- time - 6:24

-- 16% of most followed users - 286486 of 1790539
SELECT f.name, sum(f.amount)
FROM (SELECT user_id, sum(amount) as sum FROM facts
WHERE name LIKE '%follower%'
GROUP BY user_id
ORDER BY sum desc
LIMIT 286486) as p,
facts as f
WHERE f.user_id = p.user_id
GROUP BY f.name
ORDER BY f.name; 

--         name         |    sum    
------------------------+-----------
-- commit               | 178152668
-- commit_comment       |   1959978
-- follower             |   8741205
-- forked               |   4220847
-- issue_assignee       |   1435992
-- issue_comment        |  38848046
-- issue_reporter       |   9068302
-- pull                 |  18079758
-- pull_comment         |   7043038
-- watchers             |  28243021
 
-- 6:12

-- 19% of most followed users - 340202 of 1790539
SELECT f.name, sum(f.amount)
FROM (SELECT user_id, sum(amount) as sum FROM facts
WHERE name LIKE '%follower%'
GROUP BY user_id
ORDER BY sum desc
LIMIT 340202) as p,
facts as f
WHERE f.user_id = p.user_id
GROUP BY f.name
ORDER BY f.name; 

--         name         |    sum    
------------------------+-----------
-- commit               | 189670954
-- commit_comment       |   2043777
-- follower             |   9047495
-- forked               |   4601049
-- issue_assignee       |   1533378
-- issue_comment        |  40364374
-- issue_reporter       |   9588583
-- pull                 |  19098225
-- pull_comment         |   7297286
-- watchers             |  30406631

-- time - 6:53

-- 22% of most followed users - 393919 of 1790539
SELECT f.name, sum(f.amount)
FROM (SELECT user_id, sum(amount) as sum FROM facts
WHERE name LIKE '%follower%'
GROUP BY user_id
ORDER BY sum desc
LIMIT 393919) as p,
facts as f
WHERE f.user_id = p.user_id
GROUP BY f.name
ORDER BY f.name; 

--         name         |    sum    
------------------------+-----------
-- commit               | 199883665
-- commit_comment       |   2119784
-- follower             |   9312934
-- forked               |   4940084
-- issue_assignee       |   1609048
-- issue_comment        |  41698444
-- issue_reporter       |  10037342
-- pull                 |  19997862
-- pull_comment         |   7523420
-- watchers             |  32229631
 
 -- time - 6:36

-- 25% of most followed users - 447635 of 1790539
SELECT f.name, sum(f.amount)
FROM (SELECT user_id, sum(amount) as sum FROM facts
WHERE name LIKE '%follower%'
GROUP BY user_id
ORDER BY sum desc
LIMIT 447635) as p,
facts as f
WHERE f.user_id = p.user_id
GROUP BY f.name
ORDER BY f.name; 

--         name         |    sum    
------------------------+-----------
-- commit               | 208690036
-- commit_comment       |   2183772
-- follower             |   9527798
-- forked               |   5229716
-- issue_assignee       |   1678672
-- issue_comment        |  42921851
-- issue_reporter       |  10440287
-- pull                 |  20755030
-- pull_comment         |   7706993
-- watchers             |  33656761
 
 -- time - 5:21
```

# 8. Quering languages data

Which languages are growing up and with are falling down?


## 8.2. Simple query

In order to answer this question we will do simple query that will provide us with results we want in date range: 09.2013 - 09.2016

```sql
SELECT 
l.language as language,
a.sum as "2013-09",
b.sum as "2013-10",
c.sum as "2013-11",
d.sum as "2013-12",
aa.sum as "2014-01",
ab.sum as "2014-02",
ac.sum as "2014-03",
ad.sum as "2014-04",
ae.sum as "2014-05",
af.sum as "2014-06",
ag.sum as "2014-07",
ah.sum as "2014-08",
ai.sum as "2014-09",
aj.sum as "2014-10",
ak.sum as "2014-11",
al.sum as "2014-12",
ba.sum as "2015-01",
bb.sum as "2015-02",
bc.sum as "2015-03",
bd.sum as "2015-04",
be.sum as "2015-05",
bf.sum as "2015-06",
bg.sum as "2015-07",
bh.sum as "2015-08",
bi.sum as "2015-09",
bj.sum as "2015-10",
bk.sum as "2015-11",
bl.sum as "2015-12",
ca.sum as "2016-01",
cb.sum as "2016-02",
cc.sum as "2016-03",
cd.sum as "2016-04",
ce.sum as "2016-05",
cf.sum as "2016-06",
cg.sum as "2016-07",
ch.sum as "2016-08",
ci.sum as "2016-09"
FROM language_dimension as l,
(SELECT l, SUM(sum) as sum FROM(SELECT language_id as l, SUM(amount) as sum FROM facts WHERE year=2013 AND month=9 GROUP BY language_id UNION SELECT language, 0 FROM language_dimension) as x GROUP BY l ORDER BY sum desc) as a,
(SELECT l, SUM(sum) as sum FROM(SELECT language_id as l, SUM(amount) as sum FROM facts WHERE year=2013 AND month=10 GROUP BY language_id UNION SELECT language, 0 FROM language_dimension) as x GROUP BY l ORDER BY sum desc) as b,
(SELECT l, SUM(sum) as sum FROM(SELECT language_id as l, SUM(amount) as sum FROM facts WHERE year=2013 AND month=1 GROUP BY language_id UNION SELECT language, 0 FROM language_dimension) as x GROUP BY l ORDER BY sum desc) as c,
(SELECT l, SUM(sum) as sum FROM(SELECT language_id as l, SUM(amount) as sum FROM facts WHERE year=2013 AND month=12 GROUP BY language_id UNION SELECT language, 0 FROM language_dimension) as x GROUP BY l ORDER BY sum desc) as d,
(SELECT l, SUM(sum) as sum FROM(SELECT language_id as l, SUM(amount) as sum FROM facts WHERE year=2014 AND month=1 GROUP BY language_id UNION SELECT language, 0 FROM language_dimension) as x GROUP BY l ORDER BY sum desc) as aa,
(SELECT l, SUM(sum) as sum FROM(SELECT language_id as l, SUM(amount) as sum FROM facts WHERE year=2014 AND month=2 GROUP BY language_id UNION SELECT language, 0 FROM language_dimension) as x GROUP BY l ORDER BY sum desc) as ab,
(SELECT l, SUM(sum) as sum FROM(SELECT language_id as l, SUM(amount) as sum FROM facts WHERE year=2014 AND month=3 GROUP BY language_id UNION SELECT language, 0 FROM language_dimension) as x GROUP BY l ORDER BY sum desc) as ac,
(SELECT l, SUM(sum) as sum FROM(SELECT language_id as l, SUM(amount) as sum FROM facts WHERE year=2014 AND month=4 GROUP BY language_id UNION SELECT language, 0 FROM language_dimension) as x GROUP BY l ORDER BY sum desc) as ad,
(SELECT l, SUM(sum) as sum FROM(SELECT language_id as l, SUM(amount) as sum FROM facts WHERE year=2014 AND month=5 GROUP BY language_id UNION SELECT language, 0 FROM language_dimension) as x GROUP BY l ORDER BY sum desc) as ae,
(SELECT l, SUM(sum) as sum FROM(SELECT language_id as l, SUM(amount) as sum FROM facts WHERE year=2014 AND month=6 GROUP BY language_id UNION SELECT language, 0 FROM language_dimension) as x GROUP BY l ORDER BY sum desc) as af,
(SELECT l, SUM(sum) as sum FROM(SELECT language_id as l, SUM(amount) as sum FROM facts WHERE year=2014 AND month=7 GROUP BY language_id UNION SELECT language, 0 FROM language_dimension) as x GROUP BY l ORDER BY sum desc) as ag,
(SELECT l, SUM(sum) as sum FROM(SELECT language_id as l, SUM(amount) as sum FROM facts WHERE year=2014 AND month=8 GROUP BY language_id UNION SELECT language, 0 FROM language_dimension) as x GROUP BY l ORDER BY sum desc) as ah,
(SELECT l, SUM(sum) as sum FROM(SELECT language_id as l, SUM(amount) as sum FROM facts WHERE year=2014 AND month=9 GROUP BY language_id UNION SELECT language, 0 FROM language_dimension) as x GROUP BY l ORDER BY sum desc) as ai,
(SELECT l, SUM(sum) as sum FROM(SELECT language_id as l, SUM(amount) as sum FROM facts WHERE year=2014 AND month=10 GROUP BY language_id UNION SELECT language, 0 FROM language_dimension) as x GROUP BY l ORDER BY sum desc) as aj,
(SELECT l, SUM(sum) as sum FROM(SELECT language_id as l, SUM(amount) as sum FROM facts WHERE year=2014 AND month=11 GROUP BY language_id UNION SELECT language, 0 FROM language_dimension) as x GROUP BY l ORDER BY sum desc) as ak,
(SELECT l, SUM(sum) as sum FROM(SELECT language_id as l, SUM(amount) as sum FROM facts WHERE year=2014 AND month=12 GROUP BY language_id UNION SELECT language, 0 FROM language_dimension) as x GROUP BY l ORDER BY sum desc) as al,
(SELECT l, SUM(sum) as sum FROM(SELECT language_id as l, SUM(amount) as sum FROM facts WHERE year=2015 AND month=1 GROUP BY language_id UNION SELECT language, 0 FROM language_dimension) as x GROUP BY l ORDER BY sum desc) as ba,
(SELECT l, SUM(sum) as sum FROM(SELECT language_id as l, SUM(amount) as sum FROM facts WHERE year=2015 AND month=2 GROUP BY language_id UNION SELECT language, 0 FROM language_dimension) as x GROUP BY l ORDER BY sum desc) as bb,
(SELECT l, SUM(sum) as sum FROM(SELECT language_id as l, SUM(amount) as sum FROM facts WHERE year=2015 AND month=3 GROUP BY language_id UNION SELECT language, 0 FROM language_dimension) as x GROUP BY l ORDER BY sum desc) as bc,
(SELECT l, SUM(sum) as sum FROM(SELECT language_id as l, SUM(amount) as sum FROM facts WHERE year=2015 AND month=4 GROUP BY language_id UNION SELECT language, 0 FROM language_dimension) as x GROUP BY l ORDER BY sum desc) as bd,
(SELECT l, SUM(sum) as sum FROM(SELECT language_id as l, SUM(amount) as sum FROM facts WHERE year=2015 AND month=5 GROUP BY language_id UNION SELECT language, 0 FROM language_dimension) as x GROUP BY l ORDER BY sum desc) as be,
(SELECT l, SUM(sum) as sum FROM(SELECT language_id as l, SUM(amount) as sum FROM facts WHERE year=2015 AND month=6 GROUP BY language_id UNION SELECT language, 0 FROM language_dimension) as x GROUP BY l ORDER BY sum desc) as bf,
(SELECT l, SUM(sum) as sum FROM(SELECT language_id as l, SUM(amount) as sum FROM facts WHERE year=2015 AND month=7 GROUP BY language_id UNION SELECT language, 0 FROM language_dimension) as x GROUP BY l ORDER BY sum desc) as bg,
(SELECT l, SUM(sum) as sum FROM(SELECT language_id as l, SUM(amount) as sum FROM facts WHERE year=2015 AND month=8 GROUP BY language_id UNION SELECT language, 0 FROM language_dimension) as x GROUP BY l ORDER BY sum desc) as bh,
(SELECT l, SUM(sum) as sum FROM(SELECT language_id as l, SUM(amount) as sum FROM facts WHERE year=2015 AND month=9 GROUP BY language_id UNION SELECT language, 0 FROM language_dimension) as x GROUP BY l ORDER BY sum desc) as bi,
(SELECT l, SUM(sum) as sum FROM(SELECT language_id as l, SUM(amount) as sum FROM facts WHERE year=2015 AND month=10 GROUP BY language_id UNION SELECT language, 0 FROM language_dimension) as x GROUP BY l ORDER BY sum desc) as bj,
(SELECT l, SUM(sum) as sum FROM(SELECT language_id as l, SUM(amount) as sum FROM facts WHERE year=2015 AND month=11 GROUP BY language_id UNION SELECT language, 0 FROM language_dimension) as x GROUP BY l ORDER BY sum desc) as bk,
(SELECT l, SUM(sum) as sum FROM(SELECT language_id as l, SUM(amount) as sum FROM facts WHERE year=2015 AND month=12 GROUP BY language_id UNION SELECT language, 0 FROM language_dimension) as x GROUP BY l ORDER BY sum desc) as bl,
(SELECT l, SUM(sum) as sum FROM(SELECT language_id as l, SUM(amount) as sum FROM facts WHERE year=2016 AND month=1 GROUP BY language_id UNION SELECT language, 0 FROM language_dimension) as x GROUP BY l ORDER BY sum desc) as ca,
(SELECT l, SUM(sum) as sum FROM(SELECT language_id as l, SUM(amount) as sum FROM facts WHERE year=2016 AND month=2 GROUP BY language_id UNION SELECT language, 0 FROM language_dimension) as x GROUP BY l ORDER BY sum desc) as cb,
(SELECT l, SUM(sum) as sum FROM(SELECT language_id as l, SUM(amount) as sum FROM facts WHERE year=2016 AND month=3 GROUP BY language_id UNION SELECT language, 0 FROM language_dimension) as x GROUP BY l ORDER BY sum desc) as cc,
(SELECT l, SUM(sum) as sum FROM(SELECT language_id as l, SUM(amount) as sum FROM facts WHERE year=2016 AND month=4 GROUP BY language_id UNION SELECT language, 0 FROM language_dimension) as x GROUP BY l ORDER BY sum desc) as cd,
(SELECT l, SUM(sum) as sum FROM(SELECT language_id as l, SUM(amount) as sum FROM facts WHERE year=2016 AND month=5 GROUP BY language_id UNION SELECT language, 0 FROM language_dimension) as x GROUP BY l ORDER BY sum desc) as ce,
(SELECT l, SUM(sum) as sum FROM(SELECT language_id as l, SUM(amount) as sum FROM facts WHERE year=2016 AND month=6 GROUP BY language_id UNION SELECT language, 0 FROM language_dimension) as x GROUP BY l ORDER BY sum desc) as cf,
(SELECT l, SUM(sum) as sum FROM(SELECT language_id as l, SUM(amount) as sum FROM facts WHERE year=2016 AND month=7 GROUP BY language_id UNION SELECT language, 0 FROM language_dimension) as x GROUP BY l ORDER BY sum desc) as cg,
(SELECT l, SUM(sum) as sum FROM(SELECT language_id as l, SUM(amount) as sum FROM facts WHERE year=2016 AND month=8 GROUP BY language_id UNION SELECT language, 0 FROM language_dimension) as x GROUP BY l ORDER BY sum desc) as ch,
(SELECT l, SUM(sum) as sum FROM(SELECT language_id as l, SUM(amount) as sum FROM facts WHERE year=2016 AND month=9 GROUP BY language_id UNION SELECT language, 0 FROM language_dimension) as x GROUP BY l ORDER BY sum desc) as ci
WHERE a.l = l.language AND b.l = l.language AND c.l = l.language AND d.l = l.language AND aa.l = l.language AND ab.l = l.language AND ac.l = l.language AND ad.l = l.language AND ae.l = l.language AND af.l = l.language AND ag.l = l.language AND ah.l = l.language AND ai.l = l.language AND aj.l = l.language AND ak.l = l.language AND al.l = l.language AND ba.l = l.language AND bb.l = l.language AND bc.l = l.language AND bd.l = l.language AND be.l = l.language AND bf.l = l.language AND bg.l = l.language AND bh.l = l.language AND bi.l = l.language AND bj.l = l.language AND bk.l = l.language AND bl.l = l.language AND ca.l = l.language AND cb.l = l.language AND cc.l = l.language AND cd.l = l.language AND ce.l = l.language AND cf.l = l.language AND cg.l = l.language AND ch.l = l.language AND ci.l = l.language 
ORDER BY a.sum desc;
```

## 8.2. Languages - more advanced answear
We want to see if our main query is correct by checking this.

```sql
(SELECT l, fact_name, SUM(sum) as sum FROM (SELECT language_id as l, name as fact_name, SUM(amount) as sum FROM facts WHERE year=2013 AND month=9 GROUP BY (language_id, fact_name) UNION SELECT l.language, f.name as fact_name, 0 FROM language_dimension as l, fact_names as f) as x GROUP BY l, fact_name) as a,
```

We want to see if our main query is correct by checking this:
```sql
SELECT l.language, f.name as fact_name, 0 
FROM language_dimension as l, fact_names as f
ORDER BY (l.language, f.name);
```

We create table of fact names so we can easly access it in main query and export it to csv.

```sql
CREATE TABLE fact_names(
	name char(20)
)

INSERT INTO fact_names
SELECT name FROM facts GROUP BY name ORDER BY name asc; 

CREATE TABLE question3(
	language varchar,
	fact_name char(20),
	"2013-09" int,
	"2013-10" int,
	"2013-11" int,
	"2013-12" int,
	"2014-01" int,
	"2014-02" int,
	"2014-03" int,
	"2014-04" int,
	"2014-05" int,
	"2014-06" int,
	"2014-07" int,
	"2014-08" int,
	"2014-09" int,
	"2014-10" int,
	"2014-11" int,
	"2014-12" int,
	"2015-01" int,
	"2015-02" int,
	"2015-03" int,
	"2015-04" int,
	"2015-05" int,
	"2015-06" int,
	"2015-07" int,
	"2015-08" int,
	"2015-09" int,
	"2015-10" int,
	"2015-11" int,
	"2015-12" int,
	"2016-01" int,
	"2016-02" int,
	"2016-03" int,
	"2016-04" int,
	"2016-05" int,
	"2016-06" int,
	"2016-07" int,
	"2016-08" int,
	"2016-09" int
)
```

1.2013 - 09.2016
```sql
INSERT INTO question3
SELECT 
l.language as language,
f.name as fact_name,
a.sum as "2013-09",
b.sum as "2013-10",
c.sum as "2013-11",
d.sum as "2013-12",
aa.sum as "2014-01",
ab.sum as "2014-02",
ac.sum as "2014-03",
ad.sum as "2014-04",
ae.sum as "2014-05",
af.sum as "2014-06",
ag.sum as "2014-07",
ah.sum as "2014-08",
ai.sum as "2014-09",
aj.sum as "2014-10",
ak.sum as "2014-11",
al.sum as "2014-12",
ba.sum as "2015-01",
bb.sum as "2015-02",
bc.sum as "2015-03",
bd.sum as "2015-04",
be.sum as "2015-05",
bf.sum as "2015-06",
bg.sum as "2015-07",
bh.sum as "2015-08",
bi.sum as "2015-09",
bj.sum as "2015-10",
bk.sum as "2015-11",
bl.sum as "2015-12",
ca.sum as "2016-01",
cb.sum as "2016-02",
cc.sum as "2016-03",
cd.sum as "2016-04",
ce.sum as "2016-05",
cf.sum as "2016-06",
cg.sum as "2016-07",
ch.sum as "2016-08",
ci.sum as "2016-09"
FROM language_dimension as l,
fact_names as f,
(SELECT l, fact_name, SUM(sum) as sum FROM (SELECT language_id as l, name as fact_name, SUM(amount) as sum FROM facts WHERE year=2013 AND month=9 GROUP BY (language_id, fact_name) UNION SELECT l.language, f.name as fact_name, 0 FROM language_dimension as l, fact_names as f) as x GROUP BY l, fact_name) as a,
(SELECT l, fact_name, SUM(sum) as sum FROM (SELECT language_id as l, name as fact_name, SUM(amount) as sum FROM facts WHERE year=2013 AND month=10 GROUP BY (language_id, fact_name) UNION SELECT l.language, f.name as fact_name, 0 FROM language_dimension as l, fact_names as f) as x GROUP BY l, fact_name) as b,
(SELECT l, fact_name, SUM(sum) as sum FROM (SELECT language_id as l, name as fact_name, SUM(amount) as sum FROM facts WHERE year=2013 AND month=11 GROUP BY (language_id, fact_name) UNION SELECT l.language, f.name as fact_name, 0 FROM language_dimension as l, fact_names as f) as x GROUP BY l, fact_name) as c,
(SELECT l, fact_name, SUM(sum) as sum FROM (SELECT language_id as l, name as fact_name, SUM(amount) as sum FROM facts WHERE year=2013 AND month=12 GROUP BY (language_id, fact_name) UNION SELECT l.language, f.name as fact_name, 0 FROM language_dimension as l, fact_names as f) as x GROUP BY l, fact_name) as d,
(SELECT l, fact_name, SUM(sum) as sum FROM (SELECT language_id as l, name as fact_name, SUM(amount) as sum FROM facts WHERE year=2014 AND month=1 GROUP BY (language_id, fact_name) UNION SELECT l.language, f.name as fact_name, 0 FROM language_dimension as l, fact_names as f) as x GROUP BY l, fact_name) as aa,
(SELECT l, fact_name, SUM(sum) as sum FROM (SELECT language_id as l, name as fact_name, SUM(amount) as sum FROM facts WHERE year=2014 AND month=2 GROUP BY (language_id, fact_name) UNION SELECT l.language, f.name as fact_name, 0 FROM language_dimension as l, fact_names as f) as x GROUP BY l, fact_name) as ab,
(SELECT l, fact_name, SUM(sum) as sum FROM (SELECT language_id as l, name as fact_name, SUM(amount) as sum FROM facts WHERE year=2014 AND month=3 GROUP BY (language_id, fact_name) UNION SELECT l.language, f.name as fact_name, 0 FROM language_dimension as l, fact_names as f) as x GROUP BY l, fact_name) as ac,
(SELECT l, fact_name, SUM(sum) as sum FROM (SELECT language_id as l, name as fact_name, SUM(amount) as sum FROM facts WHERE year=2014 AND month=4 GROUP BY (language_id, fact_name) UNION SELECT l.language, f.name as fact_name, 0 FROM language_dimension as l, fact_names as f) as x GROUP BY l, fact_name) as ad,
(SELECT l, fact_name, SUM(sum) as sum FROM (SELECT language_id as l, name as fact_name, SUM(amount) as sum FROM facts WHERE year=2014 AND month=5 GROUP BY (language_id, fact_name) UNION SELECT l.language, f.name as fact_name, 0 FROM language_dimension as l, fact_names as f) as x GROUP BY l, fact_name) as ae,
(SELECT l, fact_name, SUM(sum) as sum FROM (SELECT language_id as l, name as fact_name, SUM(amount) as sum FROM facts WHERE year=2014 AND month=6 GROUP BY (language_id, fact_name) UNION SELECT l.language, f.name as fact_name, 0 FROM language_dimension as l, fact_names as f) as x GROUP BY l, fact_name) as af,
(SELECT l, fact_name, SUM(sum) as sum FROM (SELECT language_id as l, name as fact_name, SUM(amount) as sum FROM facts WHERE year=2014 AND month=7 GROUP BY (language_id, fact_name) UNION SELECT l.language, f.name as fact_name, 0 FROM language_dimension as l, fact_names as f) as x GROUP BY l, fact_name) as ag,
(SELECT l, fact_name, SUM(sum) as sum FROM (SELECT language_id as l, name as fact_name, SUM(amount) as sum FROM facts WHERE year=2014 AND month=8 GROUP BY (language_id, fact_name) UNION SELECT l.language, f.name as fact_name, 0 FROM language_dimension as l, fact_names as f) as x GROUP BY l, fact_name) as ah,
(SELECT l, fact_name, SUM(sum) as sum FROM (SELECT language_id as l, name as fact_name, SUM(amount) as sum FROM facts WHERE year=2014 AND month=9 GROUP BY (language_id, fact_name) UNION SELECT l.language, f.name as fact_name, 0 FROM language_dimension as l, fact_names as f) as x GROUP BY l, fact_name) as ai,
(SELECT l, fact_name, SUM(sum) as sum FROM (SELECT language_id as l, name as fact_name, SUM(amount) as sum FROM facts WHERE year=2014 AND month=10 GROUP BY (language_id, fact_name) UNION SELECT l.language, f.name as fact_name, 0 FROM language_dimension as l, fact_names as f) as x GROUP BY l, fact_name) as aj,
(SELECT l, fact_name, SUM(sum) as sum FROM (SELECT language_id as l, name as fact_name, SUM(amount) as sum FROM facts WHERE year=2014 AND month=11 GROUP BY (language_id, fact_name) UNION SELECT l.language, f.name as fact_name, 0 FROM language_dimension as l, fact_names as f) as x GROUP BY l, fact_name) as ak,
(SELECT l, fact_name, SUM(sum) as sum FROM (SELECT language_id as l, name as fact_name, SUM(amount) as sum FROM facts WHERE year=2014 AND month=12 GROUP BY (language_id, fact_name) UNION SELECT l.language, f.name as fact_name, 0 FROM language_dimension as l, fact_names as f) as x GROUP BY l, fact_name) as al,
(SELECT l, fact_name, SUM(sum) as sum FROM (SELECT language_id as l, name as fact_name, SUM(amount) as sum FROM facts WHERE year=2015 AND month=1 GROUP BY (language_id, fact_name) UNION SELECT l.language, f.name as fact_name, 0 FROM language_dimension as l, fact_names as f) as x GROUP BY l, fact_name) as ba,
(SELECT l, fact_name, SUM(sum) as sum FROM (SELECT language_id as l, name as fact_name, SUM(amount) as sum FROM facts WHERE year=2015 AND month=2 GROUP BY (language_id, fact_name) UNION SELECT l.language, f.name as fact_name, 0 FROM language_dimension as l, fact_names as f) as x GROUP BY l, fact_name) as bb,
(SELECT l, fact_name, SUM(sum) as sum FROM (SELECT language_id as l, name as fact_name, SUM(amount) as sum FROM facts WHERE year=2015 AND month=3 GROUP BY (language_id, fact_name) UNION SELECT l.language, f.name as fact_name, 0 FROM language_dimension as l, fact_names as f) as x GROUP BY l, fact_name) as bc,
(SELECT l, fact_name, SUM(sum) as sum FROM (SELECT language_id as l, name as fact_name, SUM(amount) as sum FROM facts WHERE year=2015 AND month=4 GROUP BY (language_id, fact_name) UNION SELECT l.language, f.name as fact_name, 0 FROM language_dimension as l, fact_names as f) as x GROUP BY l, fact_name) as bd,
(SELECT l, fact_name, SUM(sum) as sum FROM (SELECT language_id as l, name as fact_name, SUM(amount) as sum FROM facts WHERE year=2015 AND month=5 GROUP BY (language_id, fact_name) UNION SELECT l.language, f.name as fact_name, 0 FROM language_dimension as l, fact_names as f) as x GROUP BY l, fact_name) as be,
(SELECT l, fact_name, SUM(sum) as sum FROM (SELECT language_id as l, name as fact_name, SUM(amount) as sum FROM facts WHERE year=2015 AND month=6 GROUP BY (language_id, fact_name) UNION SELECT l.language, f.name as fact_name, 0 FROM language_dimension as l, fact_names as f) as x GROUP BY l, fact_name) as bf,
(SELECT l, fact_name, SUM(sum) as sum FROM (SELECT language_id as l, name as fact_name, SUM(amount) as sum FROM facts WHERE year=2015 AND month=7 GROUP BY (language_id, fact_name) UNION SELECT l.language, f.name as fact_name, 0 FROM language_dimension as l, fact_names as f) as x GROUP BY l, fact_name) as bg,
(SELECT l, fact_name, SUM(sum) as sum FROM (SELECT language_id as l, name as fact_name, SUM(amount) as sum FROM facts WHERE year=2015 AND month=8 GROUP BY (language_id, fact_name) UNION SELECT l.language, f.name as fact_name, 0 FROM language_dimension as l, fact_names as f) as x GROUP BY l, fact_name) as bh,
(SELECT l, fact_name, SUM(sum) as sum FROM (SELECT language_id as l, name as fact_name, SUM(amount) as sum FROM facts WHERE year=2015 AND month=9 GROUP BY (language_id, fact_name) UNION SELECT l.language, f.name as fact_name, 0 FROM language_dimension as l, fact_names as f) as x GROUP BY l, fact_name) as bi,
(SELECT l, fact_name, SUM(sum) as sum FROM (SELECT language_id as l, name as fact_name, SUM(amount) as sum FROM facts WHERE year=2015 AND month=10 GROUP BY (language_id, fact_name) UNION SELECT l.language, f.name as fact_name, 0 FROM language_dimension as l, fact_names as f) as x GROUP BY l, fact_name) as bj,
(SELECT l, fact_name, SUM(sum) as sum FROM (SELECT language_id as l, name as fact_name, SUM(amount) as sum FROM facts WHERE year=2015 AND month=11 GROUP BY (language_id, fact_name) UNION SELECT l.language, f.name as fact_name, 0 FROM language_dimension as l, fact_names as f) as x GROUP BY l, fact_name) as bk,
(SELECT l, fact_name, SUM(sum) as sum FROM (SELECT language_id as l, name as fact_name, SUM(amount) as sum FROM facts WHERE year=2015 AND month=12 GROUP BY (language_id, fact_name) UNION SELECT l.language, f.name as fact_name, 0 FROM language_dimension as l, fact_names as f) as x GROUP BY l, fact_name) as bl,
(SELECT l, fact_name, SUM(sum) as sum FROM (SELECT language_id as l, name as fact_name, SUM(amount) as sum FROM facts WHERE year=2016 AND month=1 GROUP BY (language_id, fact_name) UNION SELECT l.language, f.name as fact_name, 0 FROM language_dimension as l, fact_names as f) as x GROUP BY l, fact_name) as ca,
(SELECT l, fact_name, SUM(sum) as sum FROM (SELECT language_id as l, name as fact_name, SUM(amount) as sum FROM facts WHERE year=2016 AND month=2 GROUP BY (language_id, fact_name) UNION SELECT l.language, f.name as fact_name, 0 FROM language_dimension as l, fact_names as f) as x GROUP BY l, fact_name) as cb,
(SELECT l, fact_name, SUM(sum) as sum FROM (SELECT language_id as l, name as fact_name, SUM(amount) as sum FROM facts WHERE year=2016 AND month=3 GROUP BY (language_id, fact_name) UNION SELECT l.language, f.name as fact_name, 0 FROM language_dimension as l, fact_names as f) as x GROUP BY l, fact_name) as cc,
(SELECT l, fact_name, SUM(sum) as sum FROM (SELECT language_id as l, name as fact_name, SUM(amount) as sum FROM facts WHERE year=2016 AND month=4 GROUP BY (language_id, fact_name) UNION SELECT l.language, f.name as fact_name, 0 FROM language_dimension as l, fact_names as f) as x GROUP BY l, fact_name) as cd,
(SELECT l, fact_name, SUM(sum) as sum FROM (SELECT language_id as l, name as fact_name, SUM(amount) as sum FROM facts WHERE year=2016 AND month=5 GROUP BY (language_id, fact_name) UNION SELECT l.language, f.name as fact_name, 0 FROM language_dimension as l, fact_names as f) as x GROUP BY l, fact_name) as ce,
(SELECT l, fact_name, SUM(sum) as sum FROM (SELECT language_id as l, name as fact_name, SUM(amount) as sum FROM facts WHERE year=2016 AND month=6 GROUP BY (language_id, fact_name) UNION SELECT l.language, f.name as fact_name, 0 FROM language_dimension as l, fact_names as f) as x GROUP BY l, fact_name) as cf,
(SELECT l, fact_name, SUM(sum) as sum FROM (SELECT language_id as l, name as fact_name, SUM(amount) as sum FROM facts WHERE year=2016 AND month=7 GROUP BY (language_id, fact_name) UNION SELECT l.language, f.name as fact_name, 0 FROM language_dimension as l, fact_names as f) as x GROUP BY l, fact_name) as cg,
(SELECT l, fact_name, SUM(sum) as sum FROM (SELECT language_id as l, name as fact_name, SUM(amount) as sum FROM facts WHERE year=2016 AND month=8 GROUP BY (language_id, fact_name) UNION SELECT l.language, f.name as fact_name, 0 FROM language_dimension as l, fact_names as f) as x GROUP BY l, fact_name) as ch,
(SELECT l, fact_name, SUM(sum) as sum FROM (SELECT language_id as l, name as fact_name, SUM(amount) as sum FROM facts WHERE year=2016 AND month=9 GROUP BY (language_id, fact_name) UNION SELECT l.language, f.name as fact_name, 0 FROM language_dimension as l, fact_names as f) as x GROUP BY l, fact_name) as ci
WHERE a.l = l.language AND b.l = l.language AND c.l = l.language AND d.l = l.language AND aa.l = l.language AND ab.l = l.language AND ac.l = l.language AND ad.l = l.language AND ae.l = l.language AND af.l = l.language AND ag.l = l.language AND ah.l = l.language AND ai.l = l.language AND aj.l = l.language AND ak.l = l.language AND al.l = l.language AND ba.l = l.language AND bb.l = l.language AND bc.l = l.language AND bd.l = l.language AND be.l = l.language AND bf.l = l.language AND bg.l = l.language AND bh.l = l.language AND bi.l = l.language AND bj.l = l.language AND bk.l = l.language AND bl.l = l.language AND ca.l = l.language AND cb.l = l.language AND cc.l = l.language AND cd.l = l.language AND ce.l = l.language AND cf.l = l.language AND cg.l = l.language AND ch.l = l.language AND ci.l = l.language
AND a.fact_name = f.name AND b.fact_name = f.name AND c.fact_name = f.name AND d.fact_name = f.name AND aa.fact_name = f.name AND ab.fact_name = f.name AND ac.fact_name = f.name AND ad.fact_name = f.name AND ae.fact_name = f.name AND af.fact_name = f.name AND ag.fact_name = f.name AND ah.fact_name = f.name AND ai.fact_name = f.name AND aj.fact_name = f.name AND ak.fact_name = f.name AND al.fact_name = f.name AND ba.fact_name = f.name AND bb.fact_name = f.name AND bc.fact_name = f.name AND bd.fact_name = f.name AND be.fact_name = f.name AND bf.fact_name = f.name AND bg.fact_name = f.name AND bh.fact_name = f.name AND bi.fact_name = f.name AND bj.fact_name = f.name AND bk.fact_name = f.name AND bl.fact_name = f.name AND ca.fact_name = f.name AND cb.fact_name = f.name AND cc.fact_name = f.name AND cd.fact_name = f.name AND ce.fact_name = f.name AND cf.fact_name = f.name AND cg.fact_name = f.name AND ch.fact_name = f.name AND ci.fact_name = f.name 
ORDER BY l.language, fact_name;
```

We exported result of query from table *question3*.
```sql
copy (SELECT * FROM question3) TO '/Users/tomek/code/dw/question3.csv' WITH CSV DELIMITER ',' HEADER;
````

