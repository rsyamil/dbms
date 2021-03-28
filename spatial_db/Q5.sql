-- Database: q5

-- create extension POSTGIS;

-- DROP DATABASE q5;

CREATE TABLE q5 (name varchar PRIMARY KEY, 
		geom geometry);

INSERT INTO q5 VALUES
  ('Home', 'POINT(-118.284783540455 34.0283044718994)'),
  ('Trader Joes', 'POINT(-118.284526923231 34.0261080579962)'),
  ('USC Health', 'POINT(-118.288749144134 34.0251285463694)'),
  ('Viterbi Office', 'POINT(-118.289272410851 34.0204775813768)'),
  ('History Museum', 'POINT(-118.288649903908 34.0170527529244)'),
  ('Cookie Shop', 'POINT(-118.278754823367 34.0145455224395)'),
  ('Spudnut Donut', 'POINT(-118.278686411439 34.0252233397502)'),
  ('Hotdog Place', 'POINT(-118.275199487592 34.0282853363413)'),
  ('Victorian House', 'POINT(-118.285026742111 34.0301355494922)'),
  ('Himalayan House', 'POINT(-118.294058357395 34.0258917431771)'),
  ('Oldest Tree', 'POINT(-118.283372403804 34.014042337011)'),
  ('Library', 'POINT(-118.286656436605 34.0187472241584)'),  
  ('Running Track', 'POINT(-118.288264772227 34.0224005719085)');

SELECT name, ST_AsText(geom) FROM q5;

-- create convex hull
Select st_astext(ST_ConvexHull(ST_Collect(q5.geom))) As polygon
FROM q5

-- find 5 nearest neighbor from home (including HOME!)
SELECT
  q5table.name,
  ST_Distance(
    q5table.geom,
    'POINT(-118.284783540455 34.0283044718994)'::geometry
    ) AS distance
FROM
  q5 q5table
ORDER BY
  q5table.geom <->
  'POINT(-118.284783540455 34.0283044718994)'::geometry
LIMIT 5;


