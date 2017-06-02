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

| |100%|25%|22%|19%|16%|13%|10%|7%|4%|1%|10 best|
|:---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
|commit|72.20%|45.81%|44.85%|43.68%|42.21%|40.74%|38.56%|36.22%|33.15%|27.51%|8.10%|
|commit_comment|0.49%|0.57%|0.57%|0.57%|0.58%|0.59%|0.59%|0.60%|0.62%|0.59%|0.55%|
|forked|2.11%|4.34%|4.43%|4.55%|4.69%|4.85%|5.06%|5.32%|5.66%|6.28%|17.20%|
|issue_assignee|5.27%|8.50%|8.60%|8.72%|8.88%|8.99%|9.21%|9.41%|9.62%|9.86%|10.54%|
|issue_comment|8.98%|20.58%|21.10%|21.71%|22.48%|23.36%|24.54%|25.91%|27.83%|31.76%|39.66%|
|issue_reporter|5.27%|8.50%|8.60%|8.72%|8.88%|8.99%|9.21%|9.41%|9.62%|9.86%|10.54%|
|pull|5.68%|8.68%|8.76%|8.87%|9.01%|9.15%|9.34%|9.49%|9.65%|9.86%|9.76%|
|pull_comment|1.44%|3.03%|3.10%|3.17%|3.26%|3.34%|3.48%|3.64%|3.85%|4.29%|3.64%|

### Percentage of change in comparison to all projects



### Average of each fact per project.
[question1_facts_amount_per_project.csv](https://github.com/tbaraniecki/ghtorrent-analysis/blob/master/question1_facts_percentage.csv)

| |100%|25%|22%|19%|16%|13%|10%|7%|4%|1%|10 best|
|:---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
|commit|119|114|122|133|145|162|184|223|304|655|5396|
|commit_comment|1|1|2|2|2|2|3|4|6|14|367|
|forked|3|11|12|14|16|19|24|33|52|149|11460|
|issue_assignee|9|21|23|26|30|36|44|58|88|235|7027|
|issue_comment|15|51|58|66|77|93|117|159|255|756|26432|
|issue_reporter|9|21|23|26|30|36|44|58|88|235|7027|
|pull|9|22|24|27|31|36|45|58|88|235|6503|
|pull_comment|2|8|8|10|11|13|17|22|35|102|2428|
|sum|164|249|273|304|343|398|477|615|916|2380|66639|

## 6.3. Data analysis 

![alt text](https://github.com/tbaraniecki/ghtorrent-analysis/blob/master/question1_chart_distribution.png "Percentage distribution of facts concerning the project")

As we can see on chart above for all projects commits takes to 72% facts. When narrow our data to 25% of best projects we see that commits are no longer responsible for 3/4 of facts. We can see that for 1% best project dominant fact is issue_comment. 

![alt text](https://github.com/tbaraniecki/ghtorrent-analysis/blob/master/question1_chart_commit.png "Average amount of commits per project")

![alt text](https://github.com/tbaraniecki/ghtorrent-analysis/blob/master/question1_chart_commit_comment.png "Average amout of commit_comment per project")

![alt text](https://github.com/tbaraniecki/ghtorrent-analysis/blob/master/question1_chart_forked.png "Average amout of forks per project")

![alt text](https://github.com/tbaraniecki/ghtorrent-analysis/blob/master/question1_chart_issue_assignee.png "Average amout of issue_assignee per project")

![alt text](https://github.com/tbaraniecki/ghtorrent-analysis/blob/master/question1_chart_issue_comment.png "Average amout of issue comment per project")

![alt text](https://github.com/tbaraniecki/ghtorrent-analysis/blob/master/question1_chart_issue_count.png "Average amout of issues per project")

![alt text](https://github.com/tbaraniecki/ghtorrent-analysis/blob/master/question1_chart_pull.png "Average amout of pull per project")

![alt text](https://github.com/tbaraniecki/ghtorrent-analysis/blob/master/question1_chart_pull_comment.png "Average amout of pull_comment per project")

As we can see, for better projects, average count of each fact is rising, there is more work around them. 

Amount of issue_assignee and issue_reporter is the same - this is no error. For every issue there can only be one reporter (user who created the issue) and one assigned user. So we can conclude (project perspective) that amount of issue_assignee is equal to amout of issues.  

### Percentage of changes when looking for facts in comparison to all projects

![alt text](https://github.com/tbaraniecki/ghtorrent-analysis/blob/master/question1_chart_change_comments_per_commit.png "Change in comments per commits")

Best projects more than double comments per commit count.

![alt text](https://github.com/tbaraniecki/ghtorrent-analysis/blob/master/question1_chart_change_comments_per_issue.png "Change in comments per issue")

When we take 25% best we see that amount of comments per issue rises only half, so this will not help us determine what give success for project. 

![alt text](https://github.com/tbaraniecki/ghtorrent-analysis/blob/master/question1_chart_change_fork_count.png "Change in fork count")

As we can see fork count is significant bigger for best projects - 5 times or even more than 37 times! This on definetely counts as facts that can determine if project succeded.

![alt text](https://github.com/tbaraniecki/ghtorrent-analysis/blob/master/question1_chart_change_commit_per_fork.png "Change in commits per fork")

Based on our experience we can say that when project gets bigger forking is used to deliver smaller funcionalities. When comes to open source projects on GitHub we are using successfull one, we fork it to use as our own and not to make a lot of changes and then 

## 6.4. Conlusion of successfull project

We can easly say that whem your project reaches As we can see from charts above, 1% of best projects of GitHub, which we can call success have different distribution of type of facts per project than all of projects on GitHub. There is almost the same amount of commits as comments for issues. 

Based on data we have all successfull project have in common following:
- better than 1/8 ratio fork / commit.
- at least 3 comments per issue
- 9% of facts concerning project is about merging new features to master branch. (pull)
- in project adding new code is responsible for only up to 33% of facts
- at least 300 commits 

Success of the project is not from good new code, but mostly from collaboration between users and feedback from the ones who are actively using it.

# 7. Users

## 7.1. Quering data

We want to know what makes user succeded? We measure success on amount of followers per user. We will only users which have at least 1 follower. We will query total amount of each type of fact for users: 10 best, 1%, 4%, 7%, 10%, 13%, 16%, 19%, 22%, 25%, all.

* [Quering data for users](https://github.com/tbaraniecki/ghtorrent-analysis/blob/master/5_question2.sql)
* [Quering more data for users](https://github.com/tbaraniecki/ghtorrent-analysis/blob/master/6_question2adv.sql)

## 7.2. Result of queries

### Number of users.

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

### Amount of each fact for every amount of users from table above
[question2_facts_amount.csv]()

||100%|25%|22%|19%|16%|13%|10%|7%|4%|1%|10 best|
|:---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
|commit|502284865|208690036|199883665|189670954|178152668|164005529|146159676|122873709|93369401|39492783|107941|
|commit_comment|3422105|2183772|2119784|2043777|1959978|1845159|1696279|1500960|1217832|566646|1435|
|forked|14664799|5229716|4940084|4601049|4220847|3778149|3253914|2605050|1816848|642165|692|
|issue_assignee|36672569|1678672|1609048|1533378|1435992|1320443|1168304|973001|729335|322552|427|
|issue_comment|62478002|42921851|41698444|40364374|38848046|36921662|34290293|30896614|25921331|14025246|40724|
|issue_reporter|36672569|10440287|10037342|9588583|9068302|8408844|7583513|6512953|4764984|2186028|4235|
|pull|39512989|20755030|19997862|19098225|18079758|16781906|15103606|12945700|9549031|4129509|10250|
|pull_comment|10019022|7706993|7523420|7297286|7043038|6688960|6229458|5460781|4554476|2154402|6446|
|sum|705726920|299606357|287809649|274197626|258808629|239750652|215485043|183768768|141923238|63519331|172150|

We put that data into Excel and calculate more data.

### Percentage amount of each fact to sum of all facts.
[question2_facts_percentage.csv]()

||100%|25%|22%|19%|16%|13%|10%|7%|4%|1%|10 best|
|:---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
|commit|71.17%|69.65%|69.45%|69.17%|68.84%|68.41%|67.83%|66.86%|65.79%|62.17%|62.70%|
|commit_comment|0.48%|0.73%|0.74%|0.75%|0.76%|0.77%|0.79%|0.82%|0.86%|0.89%|0.83%|
|forked|2.08%|1.75%|1.72%|1.68%|1.63%|1.58%|1.51%|1.42%|1.28%|1.01%|0.40%|
|issue_assignee|5.20%|0.56%|0.56%|0.56%|0.55%|0.55%|0.54%|0.53%|0.51%|0.51%|0.25%|
|issue_comment|8.85%|14.33%|14.49%|14.72%|15.01%|15.40%|15.91%|16.81%|18.26%|22.08%|23.66%|
|issue_reporter|5.20%|3.48%|3.49%|3.50%|3.50%|3.51%|3.52%|3.54%|3.36%|3.44%|2.46%|
|pull|5.60%|6.93%|6.95%|6.97%|6.99%|7.00%|7.01%|7.04%|6.73%|6.50%|5.95%|
|pull_comment|1.42%|2.57%|2.61%|2.66%|2.72%|2.79%|2.89%|2.97%|3.21%|3.39%|3.74%|
|sum|100%|100%|100%|100%|100%|100%|100%|100%|100%|100%|100%|

### Average of each fact per user.
[question2_facts_amount_per_user.csv]()

||100%|25%|22%|19%|16%|13%|10%|7%|4%|1%|10 best|
|:---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
|commit|281|466|507|558|622|705|816|980|1304|2206|10794|
|commit_comment|2|5|5|6|7|8|9|12|17|32|144|
|forked|8|12|13|14|15|16|18|21|25|36|69|
|issue_assignee|20|4|4|5|5|6|7|8|10|18|43|
|issue_comment|35|96|106|119|136|159|192|247|362|783|4072|
|issue_reporter|20|23|25|28|32|36|42|52|67|122|424|
|pull|22|46|51|56|63|72|84|103|133|231|1025|
|pull_comment|6|17|19|21|25|29|35|44|64|120|645|
|sum|394|669|731|806|903|1030|1203|1466|1982|3548|17215|

### Percentage of amount change for facts 

## 7.3. Analysing the data

![alt text]( "Percentage distribution of facts concerning the user")

For every fact we will check value change when compared to base value which is value for all users. 




## 7.4. Conclusions on the project


# 8. Languages

## 8.1. Quering data

We want data in range 09.2013 - 09.2016.

### Simple query

We sum up facts for every language. 
[Query for simple query languages](https://github.com/tbaraniecki/ghtorrent-analysis/blob/master/7_question3.sql)

### Advanced query

We want to get information about every fact for each language. 

[Query for advanced query for languages](https://github.com/tbaraniecki/ghtorrent-analysis/blob/master/8_question3adv.sql)

We exported result of query from table *question3*.
```sql
copy (SELECT * FROM question3) TO '/Users/tomek/code/dw/question3.csv' WITH CSV DELIMITER ',' HEADER;
```

## 8.2. Result of query

### All facts sum up for every language for each month between 09-2013 and 09-2016. 
[Results](https://github.com/tbaraniecki/ghtorrent-analysis/blob/master/question_3_results-simple.csv)

### For every programming language, every fact for each month between 09-2013 and 09-2016. 
[Results](https://github.com/tbaraniecki/ghtorrent-analysis/blob/master/question_3_results-advanced.csv)

By mistake we included followers to our query. We decided to use inverse grep to get rid of rows with "follower".
```bash
grep -v "follower" question_3_results-advanced.csv > question3_results-changed-without-follower.csv
```

## 8.3. Analysing the data

We will take into consideration all facts. We count average monthly amount of each fact for range 09-2013 and 09-2016 and then check if average of each fact from 07-2016, 08-2016, 09-2016 is bigger. We take into consideration 10 facts, so if at least 5 of them qualifies, we assume that programming language is evolving. 

[Result of calculation in Excel](https://github.com/tbaraniecki/ghtorrent-analysis/blob/master/question3_results_final.csv)

```bash
grep "up" question3_short.csv > question3_results_up.csv
```

[List of programming languages on GitHub which are rising](https://github.com/tbaraniecki/ghtorrent-analysis/blob/master/question3_results_up.csv)

```bash
grep "down" question3_short.csv > question3_results_down.csv
```

[List of programming languages on GitHub which are not going to survive](https://github.com/tbaraniecki/ghtorrent-analysis/blob/master/question3_results_down.csv)





