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

Project is part of Data Warehouses course. 




# 2. Questions

1. What makes that project succeed? 
2. What makes that user is successfull? 
3. Whats programming languages are rising and what programming languages are going to be forget?

# 3. Design stage

. Source data: http://ghtorrent.org - dump from 2017-01
. ER Diagram: http://ghtorrent.org/files/schema.pdf

Business Process: 

Grain: sum of the same fact that happend in specified month.

Types of fact: commit, commit_comment, pull_request, pull, issue

Dimensions: user, project, language, time

Numeric measures for facts: every instance

Hierachies: 
languages -> name
time -> year -> month
project -> id, name
user -> id, name

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

Machine: MacBook Pro with 16GB of RAM and 512GB of hard drive. 

Software: Postgresql 9.6.1, Sublime Text, Google Drive, Terminal 

We are using Postgresql with tweaked settings:

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

## Importing source data

We have tables in csv files, where each one represents one table. Our dataset dump is in mysql, so first we create table and then we use postgresql copy command to import data.

We had problem with escaping characters such as \” which caused import to crash and in some cases there were null value so used NULL AS ‘\N’ and ESCAPE AS ‘\’.

We encountered another problem in importing, because github uses null timestamp: “0000-00-00 00:00:00” to store data for column “update_at” - it meant that the project was never updated so we decided to change it to null. Command below we had to run for every csv file where was timestamp. 

Due to file sizes we change each file using terminal commands.

Change timestamp to NULL.
```bash
sed -i -e 's=“0000-00-00 00:00:00”=\\N=g' commits.csv
```

Delete the first line of file.
```bash
sed -i -e "1d" projects.csv
```

```bash
sed -i -e 's/",N"/"\N"/g' projects.csv
```

Change NULL to \N.
```bash
sed -i -e 's/NULL/\N/g' projects.csv
```


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

## 4.2. Implementation of data warehouse.













## Statistics after creating dimensional model

Facts table contains ~772.000.000 records.
Projects - 1 mln records
Users - 1 mln records. 





































