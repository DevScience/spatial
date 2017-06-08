-- create table rest
CREATE TABLE lu_franchises (
  id char(3) PRIMARY KEY,
  franchise varchar(30)
);
 
-- creating lookup table
INSERT INTO  lu_franchises(id, franchise)
VALUES
  ('BKG', 'Burger King'),
  ('CJR', 'Carls''s Jr'),
  ('HDE', 'Hardee'),
  ('INO', 'In-N-Out'),
  ('JIB', 'Jack in the Box'),
  ('KFC', 'Kentucky Fried Chicken'),
  ('MCD', 'McDonald''s'),
  ('PZH', 'Pizza Hut'),
  ('TCB', 'Taco Bell'),
  ('WDY', 'Wendy''s');
 
-- creating restaurants table
CREATE TABLE ch01.restaurants (
  id serial PRIMARY KEY,
  franchise char(3) NOT NULL,
  geom geometry(point, 2163)
);
 
-- creating spatial index
CREATE INDEX idx_code_restaurants_geom ON ch01.restaurants USING gist(geom);
 
-- foreign key
ALTER TABLE ch01.restaurants
ADD CONSTRAINT fk_restaurants_lu_franchises FOREIGN KEY (franchise)
REFERENCES ch01.lu_franchises (id) ON UPDATE CASCADE ON DELETE RESTRICT;
-- and indexing the fk
CREATE INDEX fki_restaurants_franchises ON ch01.restaurants (franchise);
 
-- highway table
CREATE TABLE ch01.highways (
  gid integer NOT NULL,
  feature varchar(80),
  name varchar(120),
  state varchar(2),
  geom geometry(multilinestring, 2163),
  CONSTRAINT pk_highways PRIMARY KEY (gid)
);
 
-- spatial index for highways table
CREATE INDEX idx_highways ON ch01.highways USING gist(geom);
 
-- LOAD DATA
CREATE TABLE ch01.restaurants_staging (
  franchise text,
  lat double precision,
  lon double precision
);
 
COPY ch01.restaurants_staging
 FROM '/Users/mitchellgritts/Documents/database/postgis/postgis-in-action/data/CH01/data/restaurants.csv' DELIMITER as ',';
 
-- insert into table
INSERT INTO ch01.restaurants (franchise, geom)
SELECT
  franchise,
  ST_Transform(ST_SetSRID(ST_Point(lon, lat), 4326), 2163) AS geom
FROM ch01.restaurants_staging;
 
shp2pgsql -s 4269:2163 -g geom -I /Users/mitchellgritts/Documents/database/postgis/postgis-in-action/data/CH01/data/roadtrl020.shp ch01.highways_staging | psql -h localhost -U mitchellgritts -p 5432 -d postgisia
 
-- insert into highways table
INSERT INTO ch01.highways (gid, feature, name, state, geom)
SELECT gid, feature, name, state, ST_Transform(geom, 2163)
FROM ch01.highways_staging
WHERE feature LIKE 'Principal Highway%';
 
-- vacuum
vacuum analyze ch01.highways;
 
-- run the query
SELECT
  f.franchise,
  COUNT(DISTINCT r.id) AS total
FROM ch01.restaurants AS r
  INNER JOIN ch01.lu_franchises AS f ON r.franchise = f.id
  INNER JOIN ch01.highways AS h ON ST_DWithin(r.geom, h.geom, 1609)
GROUP BY f.franchise
ORDER BY total DESC;
 
-- playground
SELECT
  f.franchise,
  COUNT(DISTINCT r.id) AS total
FROM ch01.restaurants AS r
  INNER JOIN ch01.lu_franchises AS f ON r.franchise = f.id
  INNER JOIN ch01.highways AS h ON ST_DWithin(r.geom, h.geom, 1609)
WHERE h.state = 'NV'
GROUP BY f.franchise
ORDER BY total DESC;
 
SELECT
  f.franchise,
  h.state
FROM ch01.restaurants AS r
  INNER JOIN ch01.lu_franchises AS f ON r.franchise = f.id
  INNER JOIN ch01.highways AS h ON ST_DWithin(r.geom, h.geom, 1609)
LIMIT 10;
 
-- i've uploaded hunt units, lets see how this works
WITH points AS (
  SELECT
    f.franchise,
    ST_Transform(r.geom, 4326) AS geom_4326
  FROM ch01.restaurants AS r
    INNER JOIN ch01.lu_franchises AS f ON r.franchise = f.id
    INNER JOIN ch01.highways AS h ON ST_DWithin(r.geom, h.geom, 1609)
    WHERE h.state = 'NV'
)
 
SELECT
  points.franchise,
  hu.huntunit,
  count(points.franchise)
FROM points 
  INNER JOIN hunt_units_stagin AS hu ON ST_Contains(hu.geom, points.geom_4326)
GROUP BY points.franchise, hu.huntunit;
 
SELECT
  ST_SetSRID(ST_Point(-118.9205, 39.5590), 4326) AS geom,
  hunt_units_stagin.huntunit
FROM hunt_units_stagin;
 
WITH points AS (
  SELECT
    ST_SetSRID(ST_Point(-118.9205, 39.5590), 4326) AS geom
)
 
SELECT
  points.geom,
  hunt_units_stagin.huntunit
FROM points
  INNER JOIN hunt_units_stagin ON ST_Contains(hunt_units_stagin.geom, points.geom);