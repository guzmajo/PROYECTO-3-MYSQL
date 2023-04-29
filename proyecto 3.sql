-- -----------------------------------------------------------------------------------------------------------------------
-- ----------- Limpieza de datos  -----------------------------------------------------
-- -----------------------------------------------------------------------------------------------------------------------

# 1. Crear tabla linkedin_ofertas

CREATE TABLE linkedin_ofertas (
  id_oferta INT PRIMARY KEY,
  fecha_actualizacion datetime,
  nombre_empresa varchar(200) ,
  fecha_busqueda_oferta_linkedin datetime ,
  fecha_publicacion_oferta date ,
  ubicacion_oferta varchar(200),
  search_id_oferta int ,
  titulo_oferta varchar(200),
  fecha_actualizacion_sp datetime
);

# 2. Modificar las restricciones de la fecha ejecutuando la siguiente sentencia:

SET @@SESSION.sql_mode='ALLOW_INVALID_DATES';

# Tambien yendo a MYSQL Preferences -> MYSQL
# en SQL_MODE to be used in generated scripts: quitar las opciones de ZERO_DATES

# 3. Definir la query que va a dejar los datos como queremos.

INSERT INTO linkedin_data.linkedin_ofertas

SELECT 
id as id_oferta,
_fivetran_synced as fecha_actualizacion,
company_name as nombre_empresa,
DATE_FORMAT(STR_TO_DATE(date,"%Y-%m-%d %H:%i:%s"),'%Y-%m-%d %H:%i:%s') as fecha_busqueda_oferta_linkedin,
date_published as fecha_publicacion_oferta,
location as ubicacion_oferta,
searches as search_id_oferta,
title as titulo_oferta,
NOW() AS fecha_actualizacion_sp
FROM linkedin_data.raw_linkedin_results
WHERE _fivetran_synced is not null;

# 4. Creamos SP con la query

#DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `update_table_linkedin_ofertas`()
BEGIN       
   INSERT INTO linkedin_data.linkedin_ofertas (id_oferta,fecha_actualizacion, nombre_empresa, fecha_busqueda_oferta_linkedin,fecha_publicacion_oferta,pais_oferta,search_id_oferta,titulo_oferta,fecha_actuailzacion_sp)
	SELECT 
		id as id_oferta,
		DATE_FORMAT(STR_TO_DATE(_fivetran_synced,"%Y-%m-%d %H:%i:%s"),'%Y-%m-%d %H:%i:%s') as fecha_actualizacion,
		company_name as nombre_empresa,
		DATE_FORMAT(STR_TO_DATE(date,"%Y-%m-%d %H:%i:%s"),'%Y-%m-%d %H:%i:%s') as fecha_busqueda_oferta_linkedin,
		date_published as fecha_publicacion_oferta,
		location as pais_oferta,
		searches as search_id_oferta,
		title as titulo_oferta
		FROM linkedin_data.raw_linkedin_results 
        WHERE id not in (SELECT id_oferta FROM linkedin_data.linkedin_ofertas); #OPCION 1
END
//
# 5. Creamos un evento para ejecutar el SP de forma diaria 

CREATE 
EVENT `update_table_linkedin_ofertas`
ON SCHEDULE EVERY 1 DAY 
STARTS TIMESTAMP(NOW() + INTERVAL 1 MINUTE) 
DO CALL update_table_linkedin_ofertas();

# 6. Ver eventos

SHOW EVENTS
;
# 7.Ver código del evento
SHOW CREATE EVENT update_table_linkedin_ofertas

 # Recursos : https://dev.mysql.com/doc/refman/8.0/en/alter-event.html
;
##------PARTE II - Crear busquedas

# 1. Crear tabla linkedin_busquedas

CREATE TABLE linkedin_busquedas (
  id_busqueda  INT PRIMARY KEY,
  fecha_busqueda datetime ,
  fecha_actualizacion datetime,
  keyword_busqueda varchar(200) ,
  pais_busqueda varchar(200),
  n_resultados_busqueda int,
  fecha_actualizacion_sp datetime 
);

# 2. Modificar las restricciones de la fecha ejecutuando la siguiente sentencia:

SET @@SESSION.sql_mode='ALLOW_INVALID_DATES';

# Tambien yendo a MYSQL Preferences -> MYSQL
# en SQL_MODE to be used in generated scripts: quitar las opciones de ZERO_DATES

# 3. Definir la query que va a dejar los datos como queremos.

SELECT    
	id as id_busqueda,
	timestamp(STR_TO_DATE(date,"%Y-%m-%d %H:%i:%s")) as fecha_busqueda_1, -- posible solucion
	DATE_FORMAT(STR_TO_DATE(date,"%Y-%m-%d %H:%i:%s"),'%Y-%m-%d %H:%i:%s') as fecha_busqueda,
	DATE_FORMAT(STR_TO_DATE(_fivetran_synced,"%Y-%m-%d %H:%i:%s"),'%Y-%m-%d %H:%i:%s') as fecha_actualizacion,   
	keyword as keyword_busqueda,   location as pais_busqueda, 
   cast(REPLACE(REPLACE(n_results,",",""),"+","") as UNSIGNED) as n_resultados_busqueda  
	FROM linkedin_data.raw_linkedin_searches
      WHERE _fivetran_synced is not null AND id not in (SELECT id_busqueda FROM linkedin_data.linkedin_busquedas);

# 4. Creamos SP con la query

#DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `update_table_linkedin_busquedas`()
BEGIN       
INSERT INTO linkedin_data.linkedin_busquedas (id_busqueda, fecha_busqueda, fecha_actualizacion, keyword_busqueda, pais_busqueda, n_resultados_busqueda)  
	SELECT    
	id as id_busqueda,
	DATE_FORMAT(STR_TO_DATE(date,"%Y-%m-%d %H:%i:%s"),'%Y-%m-%d %H:%i:%s') as fecha_busqueda,
	DATE_FORMAT(STR_TO_DATE(_fivetran_synced,"%Y-%m-%d %H:%i:%s"),'%Y-%m-%d %H:%i:%s') as fecha_actualizacion,   
	keyword as keyword_busqueda,   location as pais_busqueda,   
	cast(REPLACE(REPLACE(n_results,",",""),"+","") as UNSIGNED) as n_resultados_busqueda   
	FROM linkedin_data.raw_linkedin_searches         
	WHERE _fivetran_synced is not null AND id not in (SELECT id_busqueda FROM linkedin_data.linkedin_busquedas);

END;

# 5. Creamos un evento para ejecutar el SP

# CREAMOS UN EJECUTADOR DEL SP CON EVENTOS
CREATE 
EVENT `update_table_linkedin_busquedas`
ON SCHEDULE EVERY 1 DAY 
STARTS TIMESTAMP(NOW() + INTERVAL 1 MINUTE) 
DO CALL update_table_linkedin_busquedas();

# 6. Ver eventos
SHOW EVENTS

# 7. Ver el codigo de ese evento que creamos
# Ver código del evento
SHOW CREATE EVENT update_table_linkedin_busquedas

 # Recursos : https://dev.mysql.com/doc/refman/8.0/en/alter-event.html

-- -----------------------------------------------------------------------------------------------------------------------
-- -----------  Análisis exploratorio - validacion de datos  -----------------------------------------------------
-- -----------------------------------------------------------------------------------------------------------------------

# Para validar datos siempre debemos contrarrestrarlos con. la fuente original.
# Para eso vamos a linkedin y chequeamos

# 1. Chequeo que podemos hacer es ver cantidad de ofertas por día si tiene un sentido
SELECT
fecha_publicacion_oferta,
count(*)
FROM linkedin_data.linkedin_ofertas r
GROUP BY fecha_publicacion_oferta
ORDER BY fecha_publicacion_oferta DESC;

-- -----------------------------------------------------------------------------------------------------------------------
-- -----------  Análisis Linkedin data  -----------------------------------------------------
-- -----------------------------------------------------------------------------------------------------------------------
# 1. ¿Cúales son las empresas con mayor cantidad de ofertas?

SELECT
nombre_empresa,
count(*) AS cantidad_ofertas
FROM linkedin_data.linkedin_ofertas
GROUP BY nombre_empresa
ORDER BY count(*) DESC;

# 2. ¿Que cantidad de ofertas tenemos en la tabla por ubicación?

SELECT
ubicacion_oferta,
count(*) AS cantidad_ofertas
FROM linkedin_data.linkedin_ofertas
GROUP BY ubicacion_oferta
ORDER BY count(*) DESC;

# 3. ¿Que cantidad de ofertas tenemos por día publicados?
SELECT
fecha_publicacion_oferta,
count(*) AS cantidad_ofertas
FROM linkedin_data.linkedin_ofertas
GROUP BY fecha_publicacion_oferta
ORDER BY count(*) DESC;

## 4. ¿Cúales son los top 10 títulos de roles que se usan para publicar ofertas?

SELECT 
titulo_oferta,
count(*) AS cantidad_ofertas
FROM linkedin_data.linkedin_ofertas
GROUP BY titulo_oferta
ORDER BY count(*) DESC
LIMIT 10;


# 5. ¿Cúales con las 5 ubicaciones con mayor cantidad de ofertas?

SELECT 
ubicacion_oferta,
COUNT(*) as cantidad_ofertas
FROM linkedin_data.linkedin_ofertas
GROUP BY ubicacion_oferta
ORDER BY count(*) DESC
LIMIT 5;

# 6. ¿Cuantas ofertas de trabajo hay combinando keyowrd con título oferta?
# ¿Puedes devolver la cantidad agregando por ambos campos?

SELECT
	b.keyword_busqueda,
	o.titulo_oferta,
	count(*) as cantidad_ofertas
FROM linkedin_data.linkedin_busquedas b
LEFT JOIN linkedin_data.linkedin_ofertas o on search_id_oferta = id_busqueda
GROUP BY 
	keyword_busqueda,
	titulo_oferta
ORDER BY cantidad_ofertas desc;

# 7. ¿Cuantos puestos tenemos como junior, puedes traer la cantidad por título

SELECT 
titulo_oferta,
count(*)
FROM linkedin_data.linkedin_ofertas o 
LEFT JOIN linkedin_data.linkedin_busquedas b on o.search_id_oferta = b.id_busqueda
WHERE 
titulo_oferta LIKE  '%Junior%' 
OR titulo_oferta LIKE '%Jr%'
OR titulo_oferta LIKE '%Intern%'
OR titulo_oferta LIKE '%Entry-Level%'
OR titulo_oferta LIKE '%Entry%'
GROUP BY titulo_oferta
order by count(*) DESC;

# 8. ¿ Puedes ahora devolver la cantidad de ofertas con el título junior, pero por país? 

SELECT 
ubicacion_oferta,
count(*)
FROM linkedin_data.linkedin_ofertas o 
LEFT JOIN linkedin_data.linkedin_busquedas b on o.search_id_oferta = b.id_busqueda
WHERE 
titulo_oferta LIKE  '%Junior%' 
OR titulo_oferta LIKE '%Jr%'
OR titulo_oferta LIKE '%Intern%'
OR titulo_oferta LIKE '%Entry-Level%'
OR titulo_oferta LIKE '%Entry%'
GROUP BY ubicacion_oferta
order by count(*) DESC;

# 9. Podemos saber la cantidad de ofertas publicadas por mes y keyword?
# ¿ Que meses son mas top y con que keywords?

SELECT 
month(fecha_publicacion_oferta) AS mes_oferta,
b.keyword_busqueda,
count(*) as cantidad_de_ofertas
FROM linkedin_data.linkedin_ofertas o 
LEFT JOIN linkedin_data.linkedin_busquedas b on o.search_id_oferta = b.id_busqueda
GROUP BY mes_oferta,b.keyword_busqueda
order by mes_oferta,count(*) DESC;