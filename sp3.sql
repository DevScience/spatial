-- 1 criar banco de dados
CREATE DATABASE bde;

-- 2 habilitar postgis
CREATE EXTENSION postgis;

-- 3 Verificar versão PostGIS / PostgreSQL
SELECT postgis_full_version();
SELECT version();

-- 4 Criar esquema a01
CREATE SCHEMA a01;

-- 5 criar tabela lu_franchises
CREATE TABLE a01.lu_franchises (id char(3) PRIMARY KEY
 , franchise varchar(30)); 
 
 -- 6 popular tabela lu_franchises
 INSERT INTO a01.lu_franchises(id, franchise) 
VALUES 
  ('BKG', 'Burger King'), 
  ('CJR', 'Carl''s Jr'),
  ('HDE', 'Hardee'), 
  ('INO', 'In-N-Out'), 
  ('JIB', 'Jack in the Box'), 
  ('KFC', 'Kentucky Fried Chicken'),
  ('MCD', 'McDonald'), 
  ('PZH', 'Pizza Hut'),
  ('TCB', 'Taco Bell'), 
  ('WDY', 'Wendys');

-- 7 criar tabela restaurants
CREATE TABLE a01.restaurants
(
  id serial primary key   
  , franchise char(3) NOT NULL
  , geom geometry(point,2163) 
);

-- 8 adicionar chave estrangeira na tabela restaurants
ALTER TABLE a01.restaurants 
  ADD CONSTRAINT fk_restaurants_lu_franchises
  FOREIGN KEY (franchise) 
  REFERENCES a01.lu_franchises (id)
  ON UPDATE CASCADE ON DELETE RESTRICT;

-- 9 criar indice
CREATE INDEX fki_restaurants_franchises 
 ON a01.restaurants (franchise);

-- 10 criar tabela highways com colun geometrica
CREATE TABLE a01.highways 
(
  gid integer NOT NULL,
  feature character varying(80),
  name character varying(120),
  state character varying(2),
  geom geometry(multilinestring,2163), 
  CONSTRAINT pk_highways PRIMARY KEY (gid)
);

-- 11 criar indice espacial na coluna geométrica (using gist)
CREATE INDEX idx_highways 
 ON a01.highways USING gist(geom); 
 
-- 12 criar tabela com coordenadas geograficas dos restaurantes
CREATE TABLE a01.restaurants_staging (
  franchise text, lat double precision, lon double precision);

-- 13 inserir dados csv na tabela restaurants_staging - usando PSQL console
copy a01.restaurants_staging FROM 'c:\restaurants.csv' DELIMITER as ',';

-- 14 Conferir se a tabela foi populada corretamente

-- 15 tentar abrir no qgis - não vai abrir pois não tem coluna geometrica

-- 16 inserir os dados de coordanadas da restaurants_staging como geometria na tabela restaurants
INSERT INTO a01.restaurants (franchise, geom)
SELECT franchise
 , ST_Transform(
   ST_SetSRID(ST_Point(lon , lat), 4326)
   , 2163) As geom
FROM a01.restaurants_staging;

-- 17 indexar a coluna espacial da tabela restaurants
CREATE INDEX idx_code_restaurants_geom 
  ON a01.restaurants USING gist(geom); 

-- 18 abrir no qgis, conectar o banco e visualizar

-- 19 importar o shapefile do mapa dos estados unidos para o BDE. 
-- Lembrar de alterar o Schema na janela de seleção de arquivo para a01. 
-- Verificar a projeção direto no arquivo .prj e indexar a coluna geom automaticamente 
-- quando da importação(nad83, epsg 4269)

-- 20 adicionar dados das rodovias (arquivo shapefile roadtrl020) usando o postgis shapefile loader. 
-- alterar schema para a01 e projeção para 4269. Desmarcar opção para criar índice automaticamente

-- 21 renomear a tabela roadtrl020 criada no passo anterior
ALTER TABLE a01.roadtrl020
  RENAME TO highways_staging;

-- 22 indexar a coluna espacial da tabela highways_staging
CREATE INDEX idx_highways_staging_geom 
  ON a01.highways_staging USING gist(geom); 

-- 23 abrir no qgis, conectar o banco e visualizar

-- 24 inserir dados das rodovias principais da tabela highways_staging (principal Highway) 
-- na tabela highways. Alterou epsg para 2163 (US National Atlas Equal Area)
INSERT INTO a01.highways (gid, feature, name, state, geom)
SELECT gid, feature, name, state, ST_Transform(geom, 2163)
FROM a01.highways_staging
WHERE feature LIKE 'Principal Highway%';

-- 25 indexar a coluna espacial da tabela highways_staging
CREATE INDEX idx_highways_geom 
  ON a01.highways USING gist(geom); 

-- 26 abrir no qgis, conectar o banco e visualizar

-- 27 verificar restaurantes existentes no raio de uma milha das rodovias principais 
--(a saída é uma tabela contendo o número total de restaurantes de cada franquia)
SELECT f.franchise, COUNT(DISTINCT r.id) As total 
FROM a01.restaurants As r 
  INNER JOIN a01.lu_franchises As f ON r.franchise = f.id
    INNER JOIN a01.highways As h 
      ON ST_DWithin(r.geom, h.geom, 1609) 
GROUP BY f.franchise
ORDER BY total DESC;

-- 28 verificar dados diretamente no data output do pgadmin

-- 29 quantas franquias Hardee's existem em um buffer de 20 milhas na Route 1 no estado de Maryland (a saída é um número: 3)
SELECT COUNT(DISTINCT r.id) As total
FROM a01.restaurants As r 
     INNER JOIN a01.highways As h 
     ON ST_DWithin(r.geom, h.geom, 1609*20)
WHERE r.franchise = 'HDE' 
 AND h.name  = 'US Route 1' AND h.state = 'MD';

-- 30 selecionar a US route 1 no estado de Maryland (fazer a consulta diretamente no qgis. Gerenciador BD, botão janela SQL. Carregar como nova janela, alterar coluna com valores inteiros únicos, inserir nome camada)
SELECT gid, name, geom 
FROM a01.highways
WHERE name = 'US Route 1' AND state = 'MD';

-- 31 criar um buffer de 20 milhas na US route 1
SELECT ST_Union(ST_Buffer(geom, 1609*20))
FROM a01.highways
WHERE name = 'US Route 1' AND state = 'MD';

-- 32 selecionar as franquias Hardee's existem em um buffer de 20 milhas na Route 1 no estado 
--de Maryland (fazer direto no qgis e visualizar)
SELECT r.id, r.geom
FROM a01.restaurants r
WHERE EXISTS 
 (SELECT gid FROM a01.highways 
  WHERE ST_DWithin(r.geom, geom, 1609*20) AND 
  name = 'US Route 1' 
   AND state = 'MD' AND r.franchise = 'HDE');