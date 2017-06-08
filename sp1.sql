--create database
CREATE DATABASE dbe

--activate postgis
CREATE EXTENSION postgis

--version postgis
SELECT postgis_full_version();

--create table 'aula'
CREATE TABLE AULA1.LU_FRANCHISES(id char(3) PRIMARY KEY,
FRANCHISES VARCHAR(30));

--insert data in table
INSERT INTO AULA1.LU_FRANCHISES
VALUES
('BKG', 'Burger King'),
('CJR','Carl''s Jr'),
('HDE','Hardee'),
('INO','In-N-Out'),
('JIB','Jack in the Box'),
('KFC','Kentucky Fried Chicken'),
('MDC','McDonald'),
('PZH','Pizza Hut'),
('TCB','Taco Bell'),
('WDY','Wendys');

--select
SELECT *FROM AULA1.LU_FRANCHISES;

--create table restaurants
CREATE TABLE AULA1.restaurants(
	id serial PRIMARY KEY,
	franchise CHAR(3) NOT NULL,
	geom geometry(point,2163));

--foreing key
ALTER TABLE AULA1.restaurants
ADD CONSTRAINT fk_restaurants_lu_franchises FOREIGN KEY (franchise)
REFERENCES AULA1.LU_FRANCHISES(id) ON UPDATE CASCADE ON DELETE RESTRICT;

--indexing the fk
CREATE INDEX fki_restaurants_franchises ON aula1.restaurants(franchise);

--create table highways
CREATE TABLE aula1.highways 
(
gid integer NOT NULL,
feature character varying(80),
name character varying(120),
state character varying(2),
geom geometry(multilinestring,2163),
CONSTRAINT pk_highways PRIMARY KEY (gid)
);

--spatial index for highways table
CREATE INDEX idx_highways ON aula1.highways USING GIST(geom);

--load data
CREATE TABLE aula1.restaurants_staging(
franchise text,
lat double precision,
lon double precision);