-- Authors: Rafał Wycichowski, Tomasz Baraniecki
-- 4
-- What makes project succesful?
-- Next results we will obtain by creating only one querry for each results so we can save time.
-- In order to better analyse the first question  we check our database for number of facts for following % of most watched projects:
-- all - 4234456 
-- 10
-- 4%
-- 7%
-- 13%
-- 16%
-- 19%
-- 22%

-- 10 best projects
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

-- time - 2:20

-- 4% best projects 169 378 of 4 234 456
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

 -- time - 5:54
 
 -- 7% best projects 296 412 of 4 234 456
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

-- time - 6:31

-- 13% best projects 550 479 of 4 234 456
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

-- time - 6:24 

-- 16% best projects 677 513 of 4 234 456
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

-- time - 6:19

-- 19% best projects 804547 of 4 234 456
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

-- time - 6:39

-- 22% best projects 931 580 of 4 234 456
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

-- time 6:11

-- 25% best projects 1 058 614 of 4 234 456
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