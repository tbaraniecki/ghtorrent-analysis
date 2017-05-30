-- Authors: Rafał Wycichowski, Tomasz Baraniecki
-- 9
-- What 10 projects are most watched?
SELECT w.project_id
FROM watchersOnePer as w
LIMIT 10;

SELECT w.project_id, p.name
FROM (SELECT w.project_id, w.sum
FROM watchersOnePer as w
LIMIT 10) as w,
projects_dimension as p
WHERE w.project_id = p.project_id
ORDER BY w.sum desc;

-- project_id |          name          
------------+--------------------------
--   14477484 | freecodecamp
--    5659677 | free-programming-books
--       6313 | jquery
--    4708601 | bootstrap
--       3231 | oh-my-zsh
--         37 | angular.js
--   10778840 | awesome
--    3905191 | react
--    1155356 | javascript
--       3377 | html5-boilerplate

-- What 10 users are most followed?
SELECT f.user_id, f.sum
FROM followersOnePer as f
LIMIT 10;

SELECT f.user_id, u.username
FROM (SELECT f.user_id, f.sum
FROM followersOnePer as f
LIMIT 10) as f,
users_dimension as u
WHERE f.user_id = u.user_id
ORDER BY f.sum desc;

-- user_id |     username     
-----------+------------------
--    5203 | torvalds
--    9236 | mojombo
--    1779 | paulirish
--    6240 | addyosmani
--     896 | JakeWharton
--  376498 | Tj
--    1570 | defunkt
--    1736 | douglascrockford
--   24452 | jeresig
--   10005 | schacon