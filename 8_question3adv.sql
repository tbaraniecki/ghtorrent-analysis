-- Authors: Rafał Wycichowski, Tomasz Baraniecki
-- 8
-- Which languages are growing up and with are falling down? -- more advanced answer
-- 09.2013 - 09.2016

-- We want to see if our main query is correct by checking this:
(SELECT l, fact_name, SUM(sum) as sum FROM (SELECT language_id as l, name as fact_name, SUM(amount) as sum FROM facts WHERE year=2013 AND month=9 GROUP BY (language_id, fact_name) UNION SELECT l.language, f.name as fact_name, 0 FROM language_dimension as l, fact_names as f) as x GROUP BY l, fact_name) as a,

-- We want to see if our main query is correct by checking this:
SELECT l.language, f.name as fact_name, 0 
FROM language_dimension as l, fact_names as f
ORDER BY (l.language, f.name);

-- We create table of fact names so we can easly access it in main query and export it to csv
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

--  1.2009 - 09.2016
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
