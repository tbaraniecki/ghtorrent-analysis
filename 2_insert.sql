-- Authors: Rafał Wycichowski, Tomasz Baraniecki
--2 
--In second step we prepare tables in which we insert data, so we can easily access any data we may need

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

--------------------------

-- We also delete unneeded column and table, so we can save some disk space 

ALTER TABLE commits
DROP COLUMN sha;

ALTER TABLE commits
DROP COLUMN committer_id;
