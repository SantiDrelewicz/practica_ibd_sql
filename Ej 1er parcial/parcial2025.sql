/*
1. Obtener todos los datos de las playlist para las cuales TODOS sus tracks han sido vendidos por lo menos una vez.
*/
SELECT p.name
FROM playlist p
WHERE 
	p.playlist_id NOT IN ( -- una de las playlist que tiene un track que no está asociado a ningun invoice_line
		SELECT DISTINCT(pt.playlist_id)
		FROM playlist_track pt
		LEFT JOIN invoice_line il
			ON il.track_id = pt.track_id
		WHERE il.invoice_line_id IS NULL
	) AND EXISTS ( -- obviamente tiene tracks asociados
		SELECT 1
		FROM playlist_track pt
		WHERE pt.playlist_id = p.playlist_id
	);
	
/*
2. Mostrar los empleados contratados después de Nancy Edwards. Se pide deolver id del empleado, nombre y 
   apellido unificados en un solo campo separados por '-' la fecha de contratación y las primeras 3 letras de la ciudad
   de residencia
*/
SELECT
	employee_id AS ID,
	first_name || ' - ' || last_name AS nombre_completo,
	CAST(hire_date AS DATE) AS fecha_contratacion,
	SUBSTRING(city, 1, 3) AS ciudad
FROM employee
WHERE hire_date > (
	SELECT hire_date
	FROM employee
	WHERE 
		LOWER(TRIM(first_name)) = 'nancy' AND 
		LOWER(TRIM(last_name))  = 'edwards'	
);

/*
3. Obtener todos los datos de customer, para aquellos customers que tengan como representante de venta a un
   empleado de su mismo pais y además su nombre tenga una longitud mayor a 5 caracteres
*/
SELECT c.*
FROM customer c
JOIN employee e
    ON e.employee_id = c.support_rep_id
WHERE c.country = e.country
    AND LENGTH(c.first_name) > 5;

/*
4. Devolver, si es que lo hubiera el nombre del género que no fue comprado por ningun cliente
*/
-- Me fijo los generos sin invoice line asociados
SELECT g.name AS generos_no_comprados
FROM invoice_line il
INNER JOIN track t
    ON il.track_id = t.track_id
RIGHT JOIN genre g
    ON g.genre_id = t.genre_id
WHERE il.invoice_id IS NULL;