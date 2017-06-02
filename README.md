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

> GHTorrent monitors the Github public event time line. For each event, it retrieves its contents and their dependencies, exhaustively.

# 2. The problem

Our study has to answer for:

1. What makes that project succeeded? 
2. What makes that user succeeded?
3. Whats programming languages are rising and what programming languages are going to be forget?

We decided that we will analyze some of the events that occur when developers are using GitHub. 
As we know, GitHub is repository, as well as project management tool. GitHub is using git, which is distributed repository system. 
In the table below we wrote events which we are interested in and what they mean for us. For the purpose of this raport we will call those events as facts.

| name | project perspective | user perspective | language perspective |
| --- | --- | --- | --- |
| commit | project is maintained | user is programming | language is used |
| commit_comments | project has more than one developer and code that is being created is checked | user supervises other user | language is very actively used |
| watchers | user found project interested for him | ... | users are interested in projects in this specific language |
| followers | ... | other users are interested in his public activity on github | ... |
| forked | users found this project very interesting and want to develop new feature | user is working on new feature | language is very actively used |
| issue_assignee | some user was assigned to solve issue | user was assigned to solve issue | language is actively used |
| issue_comment | it means that there is discussion on project issue  | user is participating in discussion on issue | language is actively used |
| issue_reporter | user added issue for project | user is actively participating in maintaining project | language is actively used |
| pull | possible discussion on changes pushed to repository | user wants to tell other users of repo about changes he made to repo | language is actively used |
| pull_comment | there is review and discussion on potential changes that could be merged into main branch of project | user is discussing on new feature | language is very actively used |

# 3. Design stage

<dl>
  <dt>Source data</dt>
  <dd>http://ghtorrent.org - dump from 2017-01-01</dd>

  <dt>ER Diagram</dt>
  <dd>http://ghtorrent.org/files/schema.pdf</dd>

  <dt>Business Process</dt>
  <dd>Developing software</dd>

  <dt>Grain</dt>
  <dd>a monthly sum of choosen facts that occurs on GitHub.com</dd>

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

Postgresql 9.6.1, Sublime Text, Terminal (ZSH)

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
After untar and ungzip we got following files. Each dump csv file represents one table. 

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

We created tables and then used copy command.

[SQL queries for importing data](https://github.com/tbaraniecki/ghtorrent-analysis/blob/master/1_import.sql)

# 5. Creating data warehouse

[SQL queries for creating data warehouse model and inserting data](https://github.com/tbaraniecki/ghtorrent-analysis/blob/master/2_insert.sql)

Statistics after creating dimensional model

* Facts table contains ~772.000.000 records.

# 6. Project.

## 6.1. Quering data

We want to know what makes project succeded. So we measure success on amount of watchers per project. We will query total amount of each type of fact for projects: 10 best, 1%, 4%, 7%, 10%, 13%, 16%, 19%, 22%, 25%, all. 

* [Quering data for projects](https://github.com/tbaraniecki/ghtorrent-analysis/blob/master/3_question1.sql)
* [Quering more data for projects](https://github.com/tbaraniecki/ghtorrent-analysis/blob/master/4_question1adv.sql)

## 6.2. Result of queries

### Number of projects.
| percentage | amount |
| ---: | ---: |
| 10 | 10 |
| 1% | 42 345 |
| 4% | 169 378 |
| 7% | 296 412 |
| 10% | 423 446 |
| 13% | 550 479 |
| 16% | 677 513 |
| 19% | 804 547 |
| 22% | 931 580 |
| 25% | 1 058 614 |
| 100% | 4 234 456 |

### Amount of each fact for every amount of projects from table above. 
[question1_facts_amount.csv](https://github.com/tbaraniecki/ghtorrent-analysis/blob/master/question1_facts_amount.csv)

| |all|25%|22.00%|19%|16.00%|13%|10%|7%|4%|1%|10 best|
|:---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
|commit|502284865|120637829|114044246|106707997|98016297|89195302|77957852|66072697|51460177|27729020|53955|
|commit_comment|3422105|1509909|1450684|1403791|1347155|1286233|1191045|1095203|957976|590121|3667|
|forked|14664799|11423644|11273477|11103236|10888426|10611321|10239012|9699805|8787683|6325383|114600|
|issue_assignee|36672569|22376132|21861461|21299929|20620420|19682637|18622891|17171782|14932963|9938161|70270|
|issue_comment|62478002|54195492|53661676|53042170|52204942|51140685|49618347|47275516|43197602|32008558|264317|
|issue_reporter|36672569|22376132|21861461|21299929|20620420|19682637|18622891|17171782|14932963|9938161|70270|
|pull|39512989|22854817|22272249|21669761|20921751|20029839|18891960|17305847|14982575|9933774|65034|
|pull_comment|10019022|7989733|7872238|7741251|7570391|7314754|7025753|6642968|5969090|4326066|24276|
|total|695707898|263363688|254297492|244268064|232189802|218943408|202169751|182435600|155221029|100789244|666389|

We put that data into Excel and calculate more data.

### Percentage amount of each fact to sum of all facts.
[question1_facts_percentage.csv](https://github.com/tbaraniecki/ghtorrent-analysis/blob/master/question1_facts_amount_per_project.csv)

TABLE

### Average of each fact per project.
[question1_facts_amount_per_project.csv](https://github.com/tbaraniecki/ghtorrent-analysis/blob/master/question1_facts_percentage.csv)

TABLE

## 6.3. Data analysis 




# 7. Users

## 7.1. Quering data

We want to know what makes user succeded? We measure success on amount of followers per user. We will only users which have at least 1 follower. We will query total amount of each type of fact for users: 10 best, 1%, 4%, 7%, 10%, 13%, 16%, 19%, 22%, 25%, all.

* [Quering data for users](https://github.com/tbaraniecki/ghtorrent-analysis/blob/master/5_question2.sql)
* [Quering more data for users](https://github.com/tbaraniecki/ghtorrent-analysis/blob/master/6_question2adv.sql)

## 7.2. Result of queries

Number of users.

| percentage | amount |
| ---: | ---: |
| 10 | 10 |
| 1% | 17 905 |
| 4% | 71622 |
| 7% | 125338 |
| 10% | 179053 |
| 13% | 232770 |
| 16% | 286486 |
| 19% | 340202 |
| 22% | 393919 |
| 25% | 447635 |
| 100% | 1790539 |

## 7.2. Analysing the data



# 8. Languages

# 8.1. Quering data

# 8.2. 

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

