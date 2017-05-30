-- Authors: Rafał Wycichowski, Tomasz Baraniecki
-- 6
-- What makes user succesful?
-- Next results we will obtain by creating only one query for each results so we can save time.
-- In order to better analyse the second question we check our database for number of facts for following % of most followed users
-- all - 1790539 - 1% - 17905,39
-- 10
-- 4%
-- 7%
-- 13%
-- 16%
-- 19%
-- 22%

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
