--- BD Chinook - Intro
	
/*
1. Devolver las primeras 10 filas
*/
SELECT *
FROM track
ORDER BY unit_price DESC --ordenar para que siempre de el mismo resultado
LIMIT 10;

/*
2. Saltar las primeras 10 filas
*/
SELECT *
FROM track
OFFSET 10;

/*
3. Buscar nombres que comienzan con "The"
*/
SELECT name
FROM artist
WHERE name LIKE 'The%';

/*
4. Buscar nombres de artistas de exactamente 5 caracteres que comiencen con A.
*/
SELECT name
FROM artist
WHERE name LIKE 'A____';
-- Importante: % cubre cualquier cantidad de caracteres; _ cubre exactamente uno.

/*
5. Seleccionar el nombre, albumId y el compositor de los tracks. 
   Además se quiere agregar el MediaType del track y el género de cada track.
   HINT: La información está repartida entre más de una tabla
*/
SELECT 
	t.name AS track_name, 
	t.album_id AS album_id, 
	t.composer AS composer, 
	g.name AS genre, 
	mt.name AS media_type
FROM track t
INNER JOIN genre g
	ON g.genre_id = t.genre_id
-- WHERE t.genre_id = g.genre_id
INNER JOIN media_type AS mt
	ON mt.media_type_id = t.media_type_id;

/*
6. Listar la cantidad de tracks que tiene cada genero y el nombre del género
HINT: GROUP BY
*/
SELECT 
	G.name AS genero,
	COUNT (*) AS cant_tracks
from track AS T
JOIN GENRE as G ON G.genre_id = T.genre_id
GROUP BY G.name;

/*
7. Agregar, para cada género, la lista con todos los tracks de ese género 
   con su duración en milisegundos.
*/
SELECT
	G.name AS nombre,
	COUNT(*) AS cant_tracks,
	STRING_AGG(T.name || ' - ' || T.milliseconds || ' ms', ', ') AS datos_tracks
FROM track AS T
JOIN genre AS G ON G.genre_id = T.genre_id
GROUP BY G.name;

/*
8. Obtener los artistas que no tienen álbumes.
   HINT: Búsqueda de opcionalidad con consultas anidadas.
*/
SELECT Ar.*
FROM artist Ar
WHERE Ar.artist_id NOT IN (
	SELECT DISTINCT Al.artist_id
	FROM album Al
);

/*
9. Ahora pensémoslo sin consultas anidadas
*/
SELECT Ar.*
FROM artist Ar
LEFT JOIN album Al
	ON Ar.artist_id = Al.artist_id
WHERE Al.album_id IS NULL;

/*
10. Obtener los tracks cuyo precio sea igual al precio máximo de su género.
*/
SELECT 
	T1.name, T1.unit_price 
FROM track T1
WHERE T1.unit_price = (
	SELECT MAX(T2.unit_price) AS max_price
	FROM track AS T2
	WHERE T2.genre_id = T1.genre_id
);

/*
11. Lstar todos los artistas y, para el caso en corresponda, 
	los álbumes asociados que tengan
*/


/*
12. Listar todos los álbumes, y para el caso que corresponda los artistas que tengan asociados
*/
SELECT 
	A.title AS album,
	Ar.name AS artist_name
FROM artist Ar
RIGHT JOIN album A
	ON Ar.artist_id = A.artist_id;

/*
13. Listar todos los nombres de los artistas que comienzan con la letra "M" 
	y la cantidad de tracks, de esos artistas con más de 25 tracks, 
	ordenando por cantida de tracks de forma descendente.
	HINT: HAVING
*/
SELECT 
	Ar.name,
	COUNT(*) AS track_count
FROM artist Ar
INNER JOIN album Al
	ON Al.artist_id = Ar.artist_id
INNER JOIN track T
	ON Al.album_id = T.album_id
WHERE Ar.name LIKE 'M%'
GROUP BY Ar.artist_id, Ar.name
HAVING COUNT(*) > 25
ORDER BY COUNT(*) DESC;


--Ejercitación consolidada.
/*
¿Cuántos paises tienen registrados los clientes de Chinook?
a) 59	b) 24	c) 59
*/
SELECT COUNT DISTINCT country 
FROM customer;

/*
¿Cuántas canciones pertenecen al género rock?
*/
SELECT COUNT(*) AS cant
FROM track
INNER JOIN genre
	ON track.genre_id = genre.genre_id
WHERE genre.name = 'Rock';

/*
¿Cuántas canciones tienen más de 30 caracteres y comienzan con la letra "T"?
*/
SELECT COUNT(*)
FROM track
WHERE length(trim(name)) > 30 AND UPPER(name) LIKE 'T%';

/*
Obtener los países que tienen más de 10 facturas, 
mostrando el país en mayúsculas, la cantidad de facturas 
y la cantidad de caracteres del país.
*/
SELECT upper(billing_country) AS pais, COUNT(*) AS cant_facturas, length(upper(billing_country)) AS caracteres_pais
FROM invoice
GROUP BY upper(billing_country)
ORDER BY cant_facturas DESC;

SELECT
	UPPER(C.country) AS pais,
	COUNT(*) AS cantidad_facturas,
	LENGTH(UPPER(C.country)) AS longitud
FROM customer AS C;


-- CTE (Common Table Expressions)

/*
14. CTE: Obtener las playlist más caras.
	HINT: Primero obtener el precio de cada playlist 
*/
WITH playlist_precio AS (
	SELECT 
		PT.playlist_id AS playlist_id, 
		SUM(T.unit_price) AS precio
	FROM playlist_track PT
	JOIN track T ON PT.track_id = T.track_id
	GROUP BY pt.playlist_id;
)
SELECT pl.*, pr.precio
FROM precios pr
JOIN playlist pl ON pr.playlist_id = pl.playlist_id
WHERE pr.precio = (SELECT MAX(p.precio) FROM precios p);


