/*
1. ¿Hubo pacientes a los que les subio la temperatura durante la internación?
*/
-- Creo una tabla apareando cada registro con el siguiente
WITH numeradas AS (
    SELECT ROW_NUMBER() OVER() AS orden, t.*
    FROM temperaturas t
    ORDER BY id_paciente, dia
)
-- Apareo cada registro con el día siguiente
SELECT 
    v1.*,
    v2.temp temp_sig
FROM 
    numeradas v1
LEFT JOIN 
    numeradas v2
ON v1.orden = v2.orden-1
ORDER BY v1.id_paciente, v1.dia;

/*
Creo una tabla apareando cada registro con el siguiente
del mismo paciente
*/
WITH numeradas AS (
    SELECT ROW_COUNT() OVER() AS orden, t.*
    FROM temperaturas t
    ORDER BY id_paciente, dia
);
apareo AS (
    SELECT v1.*, v2.temp temp_sig
    FROM 
        numeradas v1
    LEFT JOIN 
        numeradas v2
    ON v1.orden = v2.orden - 1
    AND v1.id_paciente = v2.id_paciente - 1
    ORDER BY v1.id_paciente, v1.dia
)
SELECT *
FROM apareo
WHERE temp < temp_sig;

-- ¿ Y con función de ventana?
SELECT 
    t.*,
    LEAD(temp) OVER (PARTITION BY id_paiente ORDER BY id_paciente, dia temp)
FROM temperaturas
ORDER BY id_paciente, dia
/*
La función de ventana LEAD(campo) devuelve el valor del campo indicado en el registro SIGUIENTE dentro
de la ventana

Si no hubiera PARTITION BY la ventana sería global = toda la tabla (y en este ejemplo nos daría la tabla 
que mezclaba temperaturas de distintos pacientes)

El ORDER BY de la vntana ordena los elementos de la ventana para que la función los vea en ese orden
El ORDER BY final ordena los elementos de la salida para mostrarlos
*/

/*
Otros parámetros:

    LEAD(col, offset, valor_default) OVER (PARTITION BY col, ... ORDER BY col, ...)

donde offset -> cuántos registros se desplaza (Default = 1)

*/

SELECT id_paciente, temp
FROM temperaturas
WHERE LEAD(temp) OVER (ORDER BY id_paciente, dia) = 0;

SELECT id_paciente, temp
FROM (
    SELECT 
        t.*, 
        LEAD(temp) OVER (ORDER BY id_paciente, dia)
        
);