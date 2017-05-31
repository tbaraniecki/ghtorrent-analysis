# Study of success on github based on GHTorrent project

*Authors*
* [Tomasz Baraniecki](https://github.com/tbaraniecki)
* [Rafał Wycichowski](https://github.com/Wyci)
* supervisor: [Tomasz Kajdanowicz](https://github.com/kajdanowicz)

## Table of contents
1. [Introduction](#1-introduction)
2. [Questions](#2-questions)
3. 

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
  <dd>
* languages -> name 
* time: year -> month 
* project: id, name 
* user: id, name </dd>
</dl>

We decided that our Data Warehouse will be of star type. 

Facts table will include such facts as:
* commit
* commit comment
* pull request
* follower for user
* watcher for project
* issue_comment

Due to size of dataset we decided that we only need amount of each type of fact in monthly period. 

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

## 4.4. Importing source data 

For every table that we needed, we created table and then used copy command.

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

We created tables for dimensions and fact table. 

```sql
--dimension
CREATE TABLE projects_dimension(
	project_id int,
	name varchar
);

--dimension
CREATE TABLE users_dimension (
	user_id int,
	username varchar
);

--dimension
CREATE TABLE language_dimension (
	language varchar,
);

CREATE TABLE facts (
	name char(20),
	project_id int,
	user_id int,
	year smallint,
	month smallint,
	language_id varchar,
	amount int
);

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

We also deleted unneeded data from imported source data, so we could save some disk space.

```sql
ALTER TABLE commits
DROP COLUMN sha;

ALTER TABLE commits
DROP COLUMN committer_id;
```

# 6. Quering data for facts related to projects.

We create table in which we insert 10% of most watched projects
```sql
CREATE TABLE watchersTenPer (
	project_id int,
	sum int
);
```

We start from counting how many projects are watched in total.
```sql
SELECT count(*) FROM (
SELECT project_id, count(*) as sum FROM facts
WHERE name LIKE '%watchers%'
GROUP BY project_id
ORDER BY sum desc) as x;
```
Answer: 4234456

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



# 7. Quering data for users


# 8. Quering languages data

Which languages are growing up and with are falling down?

In order to answer this question we will do simple query that will provide us with results we want in date range: 09.2013 - 09.2016




============================




## Statistics after creating dimensional model

Facts table contains ~772.000.000 records.
Projects - 1 mln records
Users - 1 mln records. 



















# Languages

## Preparing answear data

### Simple answear 



### Advanced answear

We exported result of query from table *question3*.
```sql
copy (SELECT * FROM question3) TO '/Users/tomek/code/dw/question3.csv' WITH CSV DELIMITER ',' HEADER;
````











