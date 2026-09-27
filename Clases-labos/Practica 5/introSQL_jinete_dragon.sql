SELECT * FROM jinete_dragon;

/*
1. Mostrar el nombre del jinete, la fecha desde la que comenzó a
   montar su dragón y la cantidad de días transcurridos desde esa fecha
   hasta hoy.
*/
SELECT 
    nombre_jinete,
    fecha_desde,
    CURRENT_DATE - fecha_desde AS cant_dias_transcurridos
FROM jinete_dragon
WHERE es_jinete_actual;

/*
2. Mostrar el nombre del jinete, la casa y una descripción de su
   experiencia según la cantidad de batallas. (Menos de 5 batallas ->
   Novato, Entre 5 y 10 -> Experimentado, Más de 10 -> Veterano)
*/
SELECT
    INITCAP(TRIM(nombre_jinete)) AS nombre_jinete,
    INITCAP(TRIM(casa)) AS casa,
    SUM(cantidad_batallas) AS cantidad_batallas,
    CASE
        WHEN SUM(cantidad_batallas) < 5 THEN 'Novato'
        WHEN SUM(cantidad_batallas) BETWEEN 5 AND 10 THEN 'Experimentado'
        ELSE 'Veterano'
    END AS experiencia
FROM jinete_dragon
GROUP BY
    INITCAP(TRIM(nombre_jinete)),
    INITCAP(TRIM(casa));

/*
3. Mostrar el nombre del jinete, los kilómetros recorridos, la cantidad
   de batallas y calcular cuántos kilómetros recorrió en promedio por batalla.
*/
SELECT
    INITCAP(TRIM(nombre_jinete)) AS nombre_jinete,
    SUM(kilometros_recorridos) AS kilometros_recorridos,
    SUM(cantidad_batallas) AS cantidad_batallas,
    SUM(kilometros_recorridos) / NULLIF(SUM(cantidad_batallas), 0)
        AS kilometros_promedio_por_batalla
FROM jinete_dragon
GROUP BY INITCAP(TRIM(nombre_jinete));


