# Study of success on github based on GHTorrent project

## Table of contents
0. Authors
1. Introduction
2. Questions
3. 

# 0. Authors
[Tomasz Baraniecki](https://github.com/tbaraniecki)

[Rafał Wycichowski](https://github.com/Wyci)

supervisor: [Tomasz Kajdanowicz](https://github.com/kajdanowicz)

# 1. Introduction



# 2. Questions

1. What makes that project succeed? 
2. What makes that user is successfull? 
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
  <dd>sum of the same fact that happend in specified month.</dd>

  <dt>Types of fact</dt>
  <dd>commit, commit_comment, pull_request, pull, issue</dd>

  <dt>Dimensions</dt>
  <dd>user, project, language, time</dd>

  <dt></dt>
  <dd></dd>

  <dt></dt>
  <dd></dd>

  <dt></dt>
  <dd></dd>

  <dt>Hierachies: </dt>
  <dd>languages -> name 
time -> year -> month 
project -> id, name 
user -> id, name </dd>
</dl>

We decided that our Data Warehouse will be of star type. 

Facts table will include such facts as:
* commit
* commit comment
* pull request
* follower for user
* watcher for project
* issue_comment

Due to size of dataset we decided that we only need amount of type of facts in monthly period. 

Facts table schema: name, project_id, user_id, year, month, language_id, amount

user_dim: 

project_dim: 

language_dim: 


# 4. Preparing data

## 4.1. Setting up environment

We have choosen to work on Mac, using postresql because it allowed us to work in parallel on data we got.

Software: MacOS 10.12.5, Postgresql 9.6.1, Sublime Text, SSH.

Because we worked with such big dataset we tweak setting, to speed up queries.
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

## Obtaining source data

We downloaded database from here: http://ghtorrent.org/downloads.html . We have choosen MySQL database dump of 2017-01-01 (size: 46.48GB).
After untar and unzip we got following files. Each dump csv file represents one table. 

| name | size |
| --- | --- |
| commit_comments.csv | 617,4 MB |
| commit_parents.csv | 9,89 GB |
| commits.csv | 49,49GB |
| followers.csv | 412,1 MB |
| issue_comments.csv | 3,08 GB |

## Preparing source data

Dataset dump is in mysql, so first we create table and then we use postgresql copy command to import data.

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

## Import source data 

We had to create tables in order to import from CSV files.

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

## 4.2. Implementation of data warehouse.













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











