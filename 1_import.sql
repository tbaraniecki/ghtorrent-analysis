-- Authors: Rafał Wycichowski, Tomasz Baraniecki
-- 1
-- We start our project by preparing our database and importing scv files. 

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

-- COPY users FROM '/Volumes/Data2/ghtorrent/mysql-2017-01-01/users.csv' DELIMITER ',' NULL AS '\N' ESCAPE AS '\' CSV;


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

-- COPY projects FROM '/Volumes/Data2/ghtorrent/mysql-2017-01-01/projects.csv' DELIMITER ',' NULL AS '\N' ESCAPE AS '\' CSV;

CREATE TABLE commits
(
	ID int,
	SHA varchar,
	AUTHOR_ID int,
	COMMITTER_ID int,
	PROJECT_ID int,
	CREATED_AT timestamp
);

-- COPY commits FROM '/Volumes/Data2/ghtorrent/mysql-2017-01-01/commits.csv' DELIMITER ',' NULL AS '\N' ESCAPE AS '\' CSV;

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

-- COPY commit_comments FROM ‘/Volumes/Data2/ghtorrent/mysql-2017-01-01/commit_comments.csv' DELIMITER ',' NULL AS '\N' ESCAPE AS '\' CSV;

CREATE TABLE commit_parents(
	COMMIT_ID int,
	PARENT_ID int
);

-- COPY  FROM '/Volumes/Data2/ghtorrent/mysql-2017-01-01/commit_parents.csv' DELIMITER ',' NULL AS '\N' ESCAPE AS '\' CSV;

CREATE TABLE followers(
	FOLLOWER_ID int,
	USER_ID int,
	CREATED_AT timestamp
);

-- COPY users FROM '/Volumes/Data2/ghtorrent/mysql-2017-01-01/followers.csv' DELIMITER ',' NULL AS '\N' ESCAPE AS '\' CSV;

CREATE TABLE pull_requests(
	ID int,
	HEAD_REPO_ID int,
	BASE_REPO_ID int,
	HEAD_COMMIT_ID int,
	BASE_COMMIT_ID int,
	PULLREQ_ID int,
	INTRA_BRANCH smallint
);

-- COPY pull_requests FROM '/Volumes/Data2/ghtorrent/mysql-2017-01-01/pull_requests.csv' DELIMITER ',' NULL AS '\N' ESCAPE AS '\' CSV;

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

-- COPY issues FROM '/Volumes/Data2/ghtorrent/mysql-2017-01-01/issues.csv' DELIMITER ',' NULL AS '\N' ESCAPE AS '\' CSV;

CREATE TABLE issue_comments(
	issue_id int,
	user_id int,
	comment_id text,
	created_at timestamp
);

-- COPY issue_comments FROM '/Volumes/Data2/ghtorrent/mysql-2017-01-01/issue_comments.csv' DELIMITER ',' NULL AS '\N' ESCAPE AS '\' CSV;

CREATE TABLE issue_events (
	event_id text,
	issue_id int,
	actor_id int,
	action varchar,
	action_specific varchar,
	created_at timestamp
);

-- COPY issue_events FROM '/Volumes/Data2/ghtorrent/mysql-2017-01-01/issue_events.csv' DELIMITER ',' NULL AS '\N' ESCAPE AS '\' CSV;

CREATE TABLE repo_labels(
	id int,
	repo_id int,
	name varchar
);

-- COPY repo_labels FROM '/Volumes/Data2/ghtorrent/mysql-2017-01-01/repo_labels.csv' DELIMITER ',' NULL AS '\N' ESCAPE AS '\' CSV;

CREATE TABLE issue_labels(
	label_id int,
	issue_id int
);

-- OPY issue_labels FROM '/Volumes/Data2/ghtorrent/mysql-2017-01-01/issue_labels.csv' DELIMITER ',' NULL AS '\N' ESCAPE AS '\' CSV;

CREATE TABLE organization_members (
	org_id int,
	user_id int,
	created_at timestamp
);

-- COPY organization_members FROM '/Volumes/Data2/ghtorrent/mysql-2017-01-01/organization_members.csv' DELIMITER ',' NULL AS '\N' ESCAPE AS '\' CSV;

CREATE TABLE project_commits (
	project_id int,
	commit_id int
);

-- COPY project_commits FROM '/Volumes/Data2/ghtorrent/mysql-2017-01-01/project_commits.csv' DELIMITER ',' NULL AS '\N' ESCAPE AS '\' CSV;

CREATE TABLE project_members (
	repo_id int,
	user_id int,
	created_at timestamp,
	ext_ref_id varchar
);

-- COPY project_members FROM '/Volumes/Data2/ghtorrent/mysql-2017-01-01/project_members.csv' DELIMITER ',' NULL AS '\N' ESCAPE AS '\' CSV;

CREATE TABLE project_languages (
	project_id int,
	language int,
	bytes int,
	created_at timestamp
);

-- COPY project_languages FROM '/Volumes/Data2/ghtorrent/mysql-2017-01-01/project_languages.csv' DELIMITER ',' NULL AS '\N' ESCAPE AS '\' CSV;

CREATE TABLE pull_request_comments (
	pull_request_id int,
	user_id int,
	comment_id int,
	position_id int,
	body varchar,
	commit_id int,
	created_at timestamp
);

-- COPY pull_request_comments FROM '/Volumes/Data2/ghtorrent/mysql-2017-01-01/pull_request_comments.csv' DELIMITER ',' NULL AS '\N' ESCAPE AS '\' CSV;

CREATE TABLE pull_request_commits (
	pull_request_id int,
	commit_id int
);

-- COPY pull_request_commits FROM '/Volumes/Data2/ghtorrent/mysql-2017-01-01/pull_request_commits.csv' DELIMITER ',' NULL AS '\N' ESCAPE AS '\' CSV;

CREATE TABLE pull_request_history (
	id int,
	pull_request_id int,
	created_at timestamp,
	action varchar,
	actor_id int
);

-- COPY pull_request_history FROM '/Volumes/Data2/ghtorrent/mysql-2017-01-01/pull_request_history.csv' DELIMITER ',' NULL AS '\N' ESCAPE AS '\' CSV;

CREATE TABLE repo_milestones(
	id int,
	repo_id int,
	name varchar
);

-- COPY repo_milestones FROM '/Volumes/Data2/ghtorrent/mysql-2017-01-01/repo_milestones.csv' DELIMITER ',' NULL AS '\N' ESCAPE AS '\' CSV;

CREATE TABLE schema_info (
	version int
);

-- COPY schema_info FROM '/Volumes/Data2/ghtorrent/mysql-2017-01-01/schema_info.csv' DELIMITER ',' NULL AS '\N' ESCAPE AS '\' CSV;

CREATE TABLE watchers (
	repo_id int,
	user_id int,
	created_at timestamp
);

-- COPY watchers FROM '/Volumes/Data2/ghtorrent/mysql-2017-01-01/watchers.csv' DELIMITER ',' NULL AS '\N' ESCAPE AS '\' CSV;