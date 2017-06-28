-- Criar esquema a02
CREATE SCHEMA a02;

-- criar uma geometria tipo "ponto"
CREATE TABLE a02.pontos 
 (id serial NOT NULL PRIMARY KEY
    , p geometry(POINT)
    , pz geometry(POINTZ)
    , pm geometry(POINTM)
    , pzm geometry(POINTZM)
    , p_srid geometry(POINT,4269) );
	
-- Inserir pontos na tabela
INSERT INTO a02.pontos(p, pz, pm
   , pzm, p_srid)
 VALUES 
    ( ST_GeomFromText('POINT(1 -1)') 
   ,  ST_GeomFromText('POINT Z(1 -1 1)') 
   ,  ST_GeomFromText('POINT M(1 -1 1)') 
   ,  ST_GeomFromText('POINT ZM(1 -1 1 1)') 
   ,  ST_GeomFromText('POINT(1 -1)',4269) )
 ;
-- visualizar no qgis
 
-- Criar uma geometria tipo "linha" aberta
CREATE TABLE a02.linha_aberta 
 (id serial PRIMARY KEY, 
  nome varchar(20),
  linhas geometry(LINESTRING)
 );
 
-- Inserir geometria na tabela
  INSERT INTO a02.linha_aberta (nome, linhas)
  VALUES
   ('Open', ST_GeomFromText('LINESTRING(0 0, 1 1, 1 -1)'));
 
-- visualizar no qgis


-- Criar uma geometria tipo "linha" fechada
 CREATE TABLE a02.linhas_f 
 (id serial PRIMARY KEY, 
  nome varchar(20),
  linhas geometry(LINESTRING)
 );
 
-- Inserir geometria na tabela
 INSERT INTO a02.linhas_f (nome, linhas)
  VALUES
   ('Closed', ST_GeomFromText('LINESTRING(0 0, 1 1, 1 -1, 0 0)'));
   
-- visualizar no qgis

-- Criar uma geometria tipo "linha" complexa
 CREATE TABLE a02.linhas_comp 
 (id serial PRIMARY KEY, 
  nome varchar(20),
  linhas geometry(LINESTRING)
 );
 
-- Inserir geometria na tabela
INSERT INTO a02.linhas_comp (nome, linhas)
  VALUES
   ('complex', ST_GeomFromText('LINESTRING(2 0,0 0,1 1,1 -1)'));
 
-- visualizar no qgis
  
-- Testar se essa geometria é simples com comando
SELECT ST_IsSimple(ST_GeomFromText('LINESTRING(2 0,0 0,1 1,1 -1)'));

-- verdadeiro ou falso??

-- Criar tabela para poligono simples
 CREATE TABLE a02.poligono_s 
 (id serial PRIMARY KEY, 
  nome varchar(20)
  );
  
-- Inserir coluna para armazenar a geometria
  ALTER TABLE a02.poligono_s ADD COLUMN poligono geometry(POLYGON);

-- Inserir geometria (poligono simples)
INSERT INTO a02.poligono_s (nome, poligono)
VALUES (
'Triangulo',
ST_GeomFromText('POLYGON((0 0, 1 1, 1 -1, 0 0))')
);

-- Visualizar no Qgis

-- Criar tabela para poligono com furo
CREATE TABLE a02.poligono_f 
 (id serial PRIMARY KEY, 
  nome varchar(20)
  );

-- Adicionar a coluna geométrica
  ALTER TABLE a02.poligono_f ADD COLUMN poligono geometry(POLYGON);

-- Inserir os dados geométricos
 INSERT INTO a02.poligono_f (nome,poligono)
VALUES (
'quadrado 2 furos',
ST_GeomFromText('POLYGON(
(-0.25 -1.25,-0.25 1.25,2.5 1.25,2.5 -1.25,-0.25 -1.25),
(2.25 0,1.25 1,1.25 -1,2.25 0),(1 -1,1 1,0 0,1 -1))'
)
);

-- Visualizar no Qgis

-- criar tabela para poligono invalido
 CREATE TABLE a02.poligono_inv
 (id serial PRIMARY KEY, 
  nome varchar(20),
  poligono geometry(POLYGON)
 );
 
 -- Inserir geometria (poligono invalido)
  INSERT INTO a02.poligono_inv (nome,poligono)
VALUES ('invalido',
ST_GeomFromText('POLYGON((2 0,0 0,1 1,1 -1, 2 0))')
);

-- Visualizar no Qgis

-- Criar tabela para armazenar multipontos

 CREATE TABLE a02.multipontos
 (id serial PRIMARY KEY, 
  nome varchar(20),
  pontos geometry(MULTIPOINT)
 );
 
-- Inserir dados geométricos
INSERT INTO a02.multipontos (nome,pontos)
VALUES (
'multipontos',
ST_GeomFromText('MULTIPOINT(-1 1, 0 0, 2 3)')
);
 
-- Visualizar no Qgis
 
-- Criar tabela para armazenar multipontos 3D
CREATE TABLE a02.multipontos3d
 (id serial PRIMARY KEY, 
  nome varchar(20),
  pontos3D geometry(MULTIPOINTZ)
 );
 
-- Inserir dados na tabela
    INSERT INTO a02.multipontos3d (nome,pontos3D)
VALUES (
'multipontos',
ST_GeomFromText('MULTIPOINT Z(-1 1 3, 0 0 1, 2 3 1)')
);
 
-- Visualizar no Qgis

-- Criar tabela para armazenar multilinestrings
  CREATE TABLE a02.multilinhas
 (id serial PRIMARY KEY, 
  nome varchar(20),
  linhas geometry(MULTILINESTRING)
 );

-- Inserir dados na tabela 
 INSERT INTO a02.multilinhas (nome,linhas)
VALUES (
'multilinhas',
ST_GeomFromText('MULTILINESTRING((0 0,0 1,1 1), (-1 1,-1 -1))')
);

-- Visualizar no Qgis

-- Criar tabela para armazenar multipoligonos
CREATE TABLE a02.multipoligonos
 (id serial PRIMARY KEY, 
  nome varchar(20),
  poligonos geometry(MULTIPOLYGON)
 );
 
-- Inserir dados na tabela
INSERT INTO a02.multipoligonos (nome,poligonos)
VALUES (
'multipoligono',
ST_GeomFromText('MULTIPOLYGON(((2.25 0,1.25 1,1.25 -1,2.25 0)), ((1 -1,1 1,0 0,1 -1)))')
);

-- Visualizar no Qgis

-- COLEÇÃO DE GEOMETRIAS
SELECT ST_AsText(ST_Collect(g))
FROM (
SELECT ST_GeomFromText('MULTIPOINT(-1 1, 0 0, 2 3)') As g
UNION ALL
SELECT ST_GeomFromText(
'MULTILINESTRING((0 0, 0 1, 1 1), (-1 1, -1 -1))'
) As g
UNION ALL
SELECT ST_GeomFromText(
'POLYGON(
(-0.25 -1.25, -0.25 1.25, 2.5 1.25, 2.5 -1.25, -0.25 -1.25),
(2.25 0, 1.25 1, 1.25 -1, 2.25 0),
(1 -1, 1 1, 0 0, 1 -1)
)'
) As g
) x;

-- visualizar o resultado da consulta no pgadmin

-- criar tabela com multigeometrias
CREATE TABLE a02.multigeometrias AS (
SELECT ST_AsText(ST_Collect(g))
FROM (
SELECT ST_GeomFromText('MULTIPOINT(-1 1, 0 0, 2 3)') As g
UNION ALL
SELECT ST_GeomFromText(
'MULTILINESTRING((0 0, 0 1, 1 1), (-1 1, -1 -1))'
) As g
UNION ALL
SELECT ST_GeomFromText(
'POLYGON(
(-0.25 -1.25, -0.25 1.25, 2.5 1.25, 2.5 -1.25, -0.25 -1.25),
(2.25 0, 1.25 1, 1.25 -1, 2.25 0),
(1 -1, 1 1, 0 0, 1 -1)
)'
) As g
) x);

-- Tentar visualizar no Qgis. Qual o resultado?

-- Adicionar chave primaria na tabela multigeometrias
 ALTER TABLE a02.multigeometrias ADD COLUMN id SERIAL PRIMARY KEY;
 
-- Tentar visualizar no Qgis. Qual o resultado?
 
 -- Criar tabela com uma linha para cada tipo de geometria
     CREATE TABLE a02.geometrias_sep
 (id serial PRIMARY KEY, 
  nome varchar(20),
  multipontos geometry(MULTIPOINT),
  multilinhas geometry(MULTILINESTRING),
  multipoligonos geometry(POLYGON)
 );
 
-- Inserir dados na tabela 
INSERT INTO a02.geometrias_sep (nome, multipontos, multilinhas, multipoligonos)
VALUES (
'registro1',
ST_GeomFromText('MULTIPOINT(-1 1, 0 0, 2 3)'),
ST_GeomFromText('MULTILINESTRING((0 0, 0 1, 1 1), (-1 1, -1 -1))'),
ST_GeomFromText('POLYGON((-0.25 -1.25, -0.25 1.25, 2.5 1.25, 2.5 -1.25, -0.25 -1.25),(2.25 0, 1.25 1, 1.25 -1, 2.25 0),(1 -1, 1 1, 0 0, 1 -1))')
);

-- Visualizar do Qgis. Qual o resultado?

-- Criar um poliedro
 CREATE TABLE a02.poliedro AS (
SELECT ST_GeomFromText(
'POLYHEDRALSURFACE Z (
((12 0 10, 8 8 10, 8 10 20, 12 2 20, 12 0 10)),
((8 8 10, 0 12 10, 0 14 20, 8 10 20, 8 8 10)),
((0 12 10, -8 8 10, -8 10 20, 0 14 20, 0 12 10))
)'
));

-- Adicionar chave primária na tabela poliedro
ALTER TABLE a02.poliedro ADD COLUMN id SERIAL PRIMARY KEY;

-- Visualizar no Qgis

-- Criar um Triangular Irregular Network (TIN)
CREATE TABLE a02.tin AS (
SELECT ST_GeomFromText(
'TIN Z (
((12 2 20, 8 8 10, 8 10 20, 12 2 20)),
((12 2 20, 12 0 10, 8 8 10, 12 2 20)),
((8 10 20, 0 12 10, 0 14 20, 8 10 20)),
((8 10 20, 8 8 10, 0 12 10, 8 10 20))
)'
));

-- Inserir chave primária
ALTER TABLE a02.tin ADD COLUMN id SERIAL PRIMARY KEY;

-- Visualizar no Qgis

-- Criar linhas circulares
CREATE TABLE a02.linha_circular (id serial NOT NULL PRIMARY KEY, tipo_linha varchar (20),
linha_circular geometry(CIRCULARSTRING))

-- Inserir dados na tabela
INSERT INTO a02.linha_circular (tipo_linha, linha_circular)
VALUES
('Circle',
ST_GeomFromText('CIRCULARSTRING(0 0, 2 0, 2 2, 0 2, 0 0)')),
('Half circle',
ST_GeomFromText('CIRCULARSTRING(2.5 2.5, 4.5 2.5, 4.5 4.5)')),
('Several arcs',
ST_GeomFromText('CIRCULARSTRING(5 5, 6 6, 4 8, 7 9, 9.5 9.5, 11 12, 12 12)'));

-- Tentar abrir no Qgis. O que aconteceu??

-- Dados geográficos e diferença com relação a dados geométricos

-- sin embargo los datos geometricos son la representacion de una figura geometrica

-- Criar tabela para armazenar dados do tipo geográfico
CREATE TABLE a02.pizza_geog (
id serial PRIMARY KEY,
nome varchar(20),
ponto geography(POINT)
);

-- Inserir dados geográficos na tabela
INSERT INTO a02.pizza_geog (nome, ponto)
VALUES
('Casa',ST_GeogFromText('POINT(0 0)')),
('Pizza 1',ST_GeogFromText('POINT(1 1)')),
('Pizza 2',ST_GeogFromText('POINT(1 -1)'));

-- Criar tabela para armazenar dados do tipo geométrico
CREATE TABLE a02.pizza_geom (
id serial PRIMARY KEY,
nome varchar(20),
ponto geometry(POINT)
);

-- Inserir dados geométricos na tabela
INSERT INTO a02.pizza_geom (nome, ponto)
VALUES
('Casa',ST_GeomFromText('POINT(0 0)')),
('Pizza 1',ST_GeomFromText('POINT(1 1)')),
('Pizza 2',ST_GeomFromText('POINT(1 -1)'));

-- Verificar a distância entre a casa e as pizzarias considerando dados geográficos
SELECT
h.nome As casa, p.nome As pizza,
ST_Distance(h.ponto, p.ponto) As dist
FROM
(SELECT nome, ponto FROM a02.pizza_geog WHERE nome = 'Casa') As h
CROSS JOIN
(SELECT nome, ponto FROM a02.pizza_geog WHERE nome LIKE 'Pizza%') As p;

-- Verificar a distância entre a casa e as pizzarias considerando dados geométricos
SELECT
h.nome As casa, p.nome As pizza,
ST_Distance(h.ponto, p.ponto) As dist
FROM
(SELECT nome, ponto FROM a02.pizza_geom WHERE nome = 'Casa') As h
CROSS JOIN
(SELECT nome, ponto FROM a02.pizza_geom WHERE nome LIKE 'Pizza%') As p;

-- Na linha do equador, um grau corresponde a aproximadamente 110.944 metros

-- Verificar a distância entre o mesmo ponto no globo terrestre usando dados do tipo geométrico e do tipo geográfico
SELECT ST_Distance(ST_Point(0,180)::geography, ST_Point(0,-180)::geography)
SELECT ST_Distance(ST_Point(0,180)::geometry, ST_Point(0,-180)::geometry)