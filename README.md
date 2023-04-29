# Project3-mysql

1. [El cliente](#el-cliente)
2. [Linkedin](#linkedin)
3. [El problema](#el-problema)
4. [Los datos](#los-datos)
5. [La solución](#la-solución)
6. [El proceso](#el-proceso)
7. [Análisis exploratorio previo](#análisis-exploratorio-previo)
8. [Ejecución](#ejecución)

## El cliente: 

Somos analistas de datos y queremos analizar el mercado laboral en estos roles. Para eso estamos obteniendo datos de los puestos de trabajo que figuran en Linkedin en áreas de análisis de datos para distintos países. :satellite: 

## Linkedin: 

Es una red social profesional donde muchas empresas publican ofertas de trabajo. :computer: 

## El problema: 

Queremos sacar conclusiones del mercado laboral del mundo de los datos. Para eso tenemos información sobre una descarga de datos de webscrapping que hemos conseguido y tenemos que validar primero si los datos son correctos y luego llegar a determinadas conclusiones. :grey_question: 

## Los datos. 
:floppy_disk:  

## La solución. 
:wrench:  

El primer paso es limpiar los datos y crear nuevas tablas con los datos limpios. El segundo paso será automatizar esa limpieza con un SP que se ejecute de forma diaria y nos actualice la información en la nueva tabla. 

## El proceso. 
:gear:  

### Análisis exploratorio previo 

1. ¿Qué tipo de datos tenemos?
2. ¿Qué limpieza observamos que podríamos hacer?
3. ¿Cómo validamos datos?

## Ejecución 

### Parte I - Crear tabla linkedin_data + SP de recarga de datos 

1. Cargar la base de datos “linkedin_data”
2. Crear tabla linkedin_ofertas (con los siguientes campos: linkedin_ofertas (
  fecha_actualizacion datetime,
  nombre_empresa varchar(200) ,
  fecha_busqueda_oferta_linkedin datetime ,
  fecha_publicacion_oferta date ,
  pais_oferta varchar(200),
  search_id_oferta int ,
  titulo_oferta varchar(200) )
3. Modificar las restricciones de la fecha ejecutuando la siguiente sentencia: SET @@SESSION.sql_mode='ALLOW_INVALID_DATES';
4. Definir la consulta que va a dejar los datos como queremos. (limpiarlos)
5. Crear un stored procedure con la query de limpieza que inserte datos en la tabla.
6. Crear el evento que ejecute el SP de forma diaria

### Parte II - Crear tabla linkedin_busquedas + SP de recarga de datos 

1. Crear tabla linkedin_busquedas (linkedin_busquedas (
  id_busqueda  INT PRIMARY KEY,
  fecha_busqueda datetime ,
  fecha_actualizacion datetime,
  keyword_busqueda varchar(200) ,
  pais_busqueda varchar(200),
  n_resultados_busqueda int
)
2. Modificar las restricciones de la fecha ejecutuando la siguiente sentencia: SET @@SESSION.sql_mode='ALLOW_INVALID_DATES';
3. Definir la consulta que va a dejar los datos como queremos. (limpiarlos)
4. Crear un stored procedure con la query de limpieza que inserte datos en la tabla.
5. Crear el evento que ejecute el SP de forma diaria

### Parte III - Análisis de los datos de las tabla 

1. ¿Cuáles son las empresas con mayor cantidad de ofertas? 
2. ¿Qué cantidad de ofertas tenemos en la tabla por ubicación? 
3. ¿Qué cantidad de ofertas tenemos por día publicados? 
4. ¿Cuáles son los top 10 títulos de roles que se usan para publicar ofertas? 
5. ¿Cuáles con las 5 ubicaciones con mayor cantidad de ofertas? 
6. ¿Cuántas ofertas de trabajo hay combinando keyword con título oferta? ¿Puedes devolver la cantidad agregando por ambos campos? 
7. ¿Cuántos puestos tenemos como junior, puedes traer la cantidad por título de oferta? 
8. ¿Puedes ahora devolver la cantidad de ofertas con el título junior, pero por país? 
9. ¿Podemos saber la cantidad de ofertas publicadas por mes y keyword? ¿Qué meses son más top y con qué keywords? 
10. ¿Qué conclusiones podemos sacar del análisis? 

## Conclusión 
