-- ===================================
-- Familiarización con el set de Datos
-- ===================================

SELECT COUNT(*) registros
FROM temperaturas; -- 14 registros
SELECT COUNT(DISTINCT id_paciente) pacientes -- 4 pacientes 
FROM temperaturas;

-- Ejercicio 0

-- Hay un único registro de temperatura de cada paciente para cada día de internación.
SELECT COUNT(DISTINCT (id_paciente, dia))
FROM temperaturas;

-- 1. Todos los pacientes tienen día de ingreso
SELECT COUNT(*) AS ingresos
FROM temperaturas
WHERE dia = 1;

-- 2. No puede haber más de un registro para el mismo paciente y día
SELECT
    id_paciente,
    dia,
    COUNT(*) AS cantidad
FROM temperaturas
GROUP BY id_paciente, dia
HAVING COUNT(*) > 1; -- devuelve 0 registros -> OK

-- 3. Los días de cada paciente deben ser consecutivos
SELECT t1.id_paciente, t1.dia
FROM temperaturas t1
/* 
Esto significa:
- existe algún registro posterior para ese paciente;
- pero no existe el día inmediatamente siguiente.
*/
WHERE EXISTS (
    SELECT 1
    FROM temperaturas t2
    WHERE t2.id_paciente = t1.id_paciente
      AND t2.dia > t1.dia
)
AND NOT EXISTS (
    SELECT 1
    FROM temperaturas t3
    WHERE t3.id_paciente = t1.id_paciente
      AND t3.dia = t1.dia + 1
);

-- 4. Ningún día puede ser menor que 1
SELECT *
FROM temperaturas
WHERE dia < 1

-- 5. Todos los pacientes deben ingresar con temperatura mayor a 37
SELECT *
FROM temperaturas
WHERE dia = 1 AND temp <= 37;

-- 6. temp = 0 solo puede aparecer como último registro del paciente
SELECT *
FROM temperaturas t1
WHERE
    temp = 0
    AND t1.dia <> (
        SELECT MAX(dia)
        FROM temperaturas t2
        WHERE t2.id_paciente = t1.id_paciente
    );

-- 7. Si hay un alta, el día anterior debe tener temperatura <= 37.
SELECT t1.*
FROM temperaturas t1
WHERE 
    t1.dia + 1 = (
        SELECT t2.dia
        FROM temperaturas t2
        WHERE 
            t2.id_paciente = t1.id_paciente AND
            t2.temp = 0
    ) AND t1.temp > 37;

-- ============================================ 
-- Para resolver SIN y CON funciones de ventana
-- ============================================ 
/*
Ejercicio 1: se quiere analizar si a algún paciente le subió la temperatura durante su internación en la sala.
Para esto (y otras cosas) se le quiere agregar a los datos una columna con la temperatura del paciente al 
día siguiente (llamada temp_sig).
*/
-- 1-a) Resolver el ejercicio sin usar funciones de ventana.
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
AND v1.id_paciente = v2.id_paciente
ORDER BY v1.id_paciente, v1.dia;
-- 1-b) Resolver el ejercicio usando funciones de ventana.
SELECT 
    *,
    LEAD(temp) OVER (PARTITION BY id_paciente ORDER BY id_paciente, dia) temp_sig
FROM temperaturas
ORDER BY id_paciente, dia;

-- ======================================
-- Para resolver CON funciones de ventana
-- ======================================

-- Ejercicio 2: ¿Cuál es la última temperatura registrada para los pacientes que se dieron de alta?
SELECT id_paciente, temp temperatura_alta
FROM (
    SELECT 
        t.*,
        LEAD(temp) OVER (
            PARTITION BY id_paciente ORDER BY id_paciente, dia
        ) temp_sig
    FROM temperaturas t
)
WHERE temp_sig = 0;

/*
Ejercicio 3: agregar a la tabla anterior un campo con el total de días de internación hasta ahora 
registrados para el paciente (llamada dias).
Y mostrar la lista de pacientes externados con su temperatura inicial y su cantidad de días totales de 
internación.
*/
SELECT 
    *,
    LEAD(temp) OVER (PARTITION BY id_paciente ORDER BY id_paciente, dia) temp_sig,
    COUNT(*) OVER (PARTITION BY id_paciente) dias
FROM temperaturas
ORDER BY id_paciente, dia;
SELECT
    id_paciente,
    temp,
    dias 
FROM (
    SELECT 
        *,
        LEAD(temp) OVER (PARTITION BY id_paciente ORDER BY id_paciente, dia) temp_sig,
        COUNT(*) OVER (PARTITION BY id_paciente) dias
    FROM temperaturas
)
WHERE dia + 1 = dias AND temp <= 37;

/*
Ejercicio 4 ¿Con qué temperatura entró cada paciente?
Nota: No vale preguntar por día 1, ya que podría estar registrada la fecha de ingreso.
*/
-- Busco el primer registro de cada paciente con temp > 37
WITH ingresos AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY id_paciente
            ORDER BY dia
        ) AS rn
    FROM temperaturas
)
SELECT
    id_paciente,
    temp AS temp_ingreso
FROM ingresos
WHERE rn = 1
ORDER BY id_paciente;

/*
Ejercicio 5 ¿Cuál fue la mayor baja diaria de temperatura registrada entre los pacientes confiebre?
*/
WITH historial AS (
    SELECT 
        *,
        LEAD(temp) OVER (PARTITION BY id_paciente ORDER BY id_paciente, dia) temp_sig,
        COUNT(*) OVER (PARTITION BY id_paciente) dias
    FROM temperaturas
)
SELECT MAX(ABS(temp - temp_sig)) mayor_baja_temp_diaria
FROM historial
WHERE 
    temp > 37 -- con fiebre
    AND temp_sig > 0;

WITH historial AS (
    SELECT 
        *,
        LEAD(temp) OVER (PARTITION BY id_paciente ORDER BY id_paciente, dia) temp_sig,
        COUNT(*) OVER (PARTITION BY id_paciente) dias
    FROM temperaturas
)
SELECT MAX(ABS(temp - temp_sig)) mayor_baja_temp_diaria
FROM historial
WHERE temp_sig > 0;


-- Ejercicio 7 A partir de la tabla 3 (la que tiene el campo dias):
-- 7- a) Rankee a los pacientes de manera descendiente según cantidad de días de internación. 
WITH historial AS (
    SELECT *,
        LEAD(temp) OVER (PARTITION BY id_paciente ORDER BY id_paciente, dia) temp_sig,
        COUNT(*) OVER (PARTITION BY id_paciente) dias
    FROM temperaturas
),
dias_x_paciente AS (
    SELECT DISTINCT 
        id_paciente, dias as dias_int
    FROM historial 
)
SELECT 
    *,
    RANK() OVER (
        ORDER BY dias_int DESC
    ) AS ranking
FROM dias_x_paciente;
-- 7- b) Utilice la función ROW_NUMBER() en lugar de RANK() y analice las diferencias.
WITH historial AS (
    SELECT *,
        LEAD(temp) OVER (PARTITION BY id_paciente ORDER BY id_paciente, dia) temp_sig,
        COUNT(*) OVER (PARTITION BY id_paciente) dias
    FROM temperaturas
),
dias_x_paciente AS (
    SELECT DISTINCT 
        id_paciente, dias as dias_int
    FROM historial 
)
SELECT 
    *,
    ROW_NUMBER() OVER (
        ORDER BY dias_int DESC
    ) AS ranking
FROM dias_x_paciente;
-- La diferencia con RANK() aparece cuando hay empates.

/*
Ejercicio 8 ¿Qué días alcanzaron los pacientes su máxima temperatura? (devolver el númerode orden 
del día)
*/
WITH temp_nro_dia AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY id_paciente ORDER BY id_paciente, dia
        ) nro_dia
    FROM temperaturas
)
SELECT t1.nro_dia, t1.id_paciente, t1.temp
FROM temp_nro_dia t1
WHERE temp = (
    SELECT MAX(t2.temp)
    FROM temperaturas t2
    WHERE t2.id_paciente = t1.id_paciente
)
ORDER BY nro_dia, temp;