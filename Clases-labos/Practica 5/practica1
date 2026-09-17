SELECT * FROM jinete_dragon;

/* 
1. Mostrar el nombre del jinete, la fecha desde la que comenzó a 
   montar su dragón y la cantidad de días transcurridos desde esa fecha 
   hasta hoy.
*/    
SELECT nombre_jinete, 
	   fecha_desde, 
	   CURRENT_DATE - fecha_desde AS  "dias"
FROM jinete_dragon 
WHERE fecha_desde IS NOT NULL;

/* 
2. Mostrar el nombre del jinete, la casa y una descripcion de su 
   experiencia según de su experiencia según la cantidad de batallas. (Menos de 5 batallas ->
   Novato, Entre 5 y 10 -> Experimentado, Más de 10 -> Veterano)
*/
SELECT nombre_jinete,
	   casa,
       cantidad_batallas,
CASE 
	WHEN cantidad_batallas < 5 THEN 'Novato'
	WHEN cantidad_batallas <= 10 THEN 'Experimentado'
    ELSE 'Veterano'   
END AS experiencia
FROM jinete_dragon
WHERE cantidad_batallas IS NOT NULL;

/*
3. Mostrar el nombre del jinete, los kilómetros recorridos, la cantidad 
   de batallas y calcular cuántos kilómetros recorrió en promedio
   por batalla
*/
SELECT nombre_jinete,
	   kilometros_recorridos,
	   cantidad_batallas,
	   kilometros_recorridos / cantidad_batallas AS km_por_batalla
FROM jinete_dragon
WHERE kilometros_recorridos IS NOT NULL 
	AND cantidad_batallas > 0;

/*
4. Buscar todos los registros correspondientes a la casa Targaryen,
   independientemente de que el valor almacenado esté escrito con
   mayúsculas, minúsculas oespacios innecesarios.
*/
SELECT
	nombre_jinete,
	casa
FROM jinete_dragon
WHERE LOWER(TRIM(casa)) = 'targaryen';

/*
¿Cuál es la cantidad mínima, máxima y promedio de 
*/
SELECT
	MIN kilometros_recorridos AS minimo_km,
	MAX kilometros_recorridos AS maximo_km,
	ROUND(AVG kilometros_recorridos, 2) AS promedio_km
FROM jinete_dragon;

/*
6. ¿Cuántos registros no tienen informado un dragón?
*/
SELECT COUNT(*) - COUNT(nombre_dragon) AS registros_sin_dragon 
FROM jinete_dragon;
--WHERE nombre_dragon IS NULL;

/*
7. Determinar cuántos jinetes están actualmente asociados a un dragón.
*/
SELECT COUNT(*) as jinetes_actuales
FROM jinete_dragon
WHERE es_jinete_actual = TRUE;

/*
8. Calcular la cantidad total de kilómetros recorridos por todos los jinetes registrados
*/
SELECT 
	SUM(kilometros_recorridos) AS total_km
FROM jinete_dragon;

/*
9. ¿Cuántos kilómentros recorrieron los jinetes de cada casa?
*/
SELECT 
	LOWER(TRIM(casa)) AS casa, 
	SUM(kilometros_recorridos) AS total_km
FROM jinete_dragon
WHERE kilometros_recorridos IS NOT NULL
GROUP BY LOWER(TRIM(casa))
ORDER BY total_km DESC;



