/*
1. Listar todos los campos de la tabla Emploeyee
*/
SELECT * FROM employee;

/*
2. Listar todas las BillingCity de la tabla Invoice sin repetir
*/
SELECT DISTINCT INITCAP(TRIM(billing_city)) AS BillingCity
FROM invoice
ORDER BY BillingCity;

/*
3. Listar los nombres, apellidos y el estado de los empleados tal que vivan en la ciudaddeCalgary.
*/
SELECT 
    first_name,
    last_name,
    state
FROM employee
WHERE city = 'Calgary';

/*
4.  Listar los nombres, la duración y Bytes de los tracks cuya duración sea mayor a 500segundos.
*/
SELECT
    name,
    (milliseconds/1000) AS duracion_segs,
    bytes
FROM track
WHERE milliseconds > 500*1000
ORDER BY duracion_segs DESC;

/*
5. Listar todos los campos de la tabla Invoice, tales que el país de facturación sea Alemania, Francia 
   o Italia ordenados en forma ascendente por el nombre de la ciudad de facturación.
*/
SELECT *
FROM invoice
WHERE billing_country IN ('Germany', 'France', 'Italy')
ORDER BY billing_city ASC;

/*
6. Listar todas las BillingCity, que comiencen con la letra ‘B’ de la tabla Invoice ordenadas
   descendentemente.
*/
SELECT billing_city
FROM invoice
WHERE billing_city LIKE 'B%';

/*
7. Seleccionar el nombre, albumId y el compositor de los tracks y además el género del mismo. 
   HINT: La información está repartida entre la tabla "Track" y la tabla "Genre"
*/
SELECT 
    t.name AS track, 
    t.album_id, 
    t.composer AS compositor, 
    g.name AS genero
FROM track t
INNER JOIN genre g
    ON t.genre_id = g.genre_id;

/*
8. A la consulta anterior, agregar el nombre del MediaType de cada track
*/
SELECT 
    t.name AS track, 
    t.album_id, 
    t.composer AS compositor, 
    g.name AS genero,
    mt.name AS media_type
FROM track t
INNER JOIN genre g
    ON t.genre_id = g.genre_id
INNER JOIN media_type mt
    ON t.media_type_id = mt.media_type_id;

/*
9. Listar la cantidad de tracks que tiene cada género y el nombre del género.
*/
SELECT 
    COUNT(*) AS cant_tracks,
    g.name
FROM track t
INNER JOIN genre g
    ON t.genre_id = g.genre_id
GROUP BY g.genre_id;

/*
10. Obtener los artistas que no tienen álbumes
*/
SELECT ar.name
FROM artist ar
LEFT JOIN album al
    ON ar.artist_id = al.artist_id
WHERE al.album_id IS NULL;
-- Otra forma:
SELECT ar.name
FROM artist ar
WHERE NOT EXISTS (
    SELECT 1
    FROM album al
    WHERE al.artist_id = ar.artist_id
);

/*
11. Listar todos los nombres de los artistas que comienzan con la letra 'M' y la cantidad de tracks, de 
    esos artistas, con más de 25 tracks, ordenado por cantidad de tracks de forma descendente.
*/
SELECT 
    ar.name AS artist_name, 
    COUNT(*) AS cant_tracks
FROM artist ar
INNER JOIN album al
    ON al.artist_id = ar.artist_id
INNER JOIN track t
    ON t.album_id = al.album_id
WHERE ar.name LIKE 'M%'
GROUP BY ar.artist_id
HAVING COUNT(*) > 25
ORDER BY cant_tracks DESC;

/*
12. Listar todos los artistas, y para el caso en que corresponda los álbumes asociados quetengan.
*/
SELECT 
    ar.name AS artista,
    STRING_AGG(al.title, ' - ') AS álbumes
FROM artist ar
LEFT JOIN album al
    ON ar.artist_id = al.artist_id
GROUP BY ar.artist_id;

/*
13. Listar todos los álbumes, y para el caso en que corresponda los artistas asociados quetengan
*/
SELECT 
    al.name AS album,
    STRING_AGG(ar.name, ' - ') AS artistas
FROM artist al
LEFT JOIN artist ar
    ON ar.artist_id = al.artist_id
GROUP BY al.artist_id;

/*
14. CTE: Obtener las playlists más caras. 
    Hint: primero obtener el ‘precio’ de cada playlist.
*/
WITH precio_playlist AS (
    SELECT 
        pt.playlist_id AS playlist_id, 
        SUM(t.unit_price) AS precio
    FROM playlist_track pt
    JOIN track t
        ON t.track_id = pt.track_id
    GROUP BY pt.playlist_id
)
SELECT
    p.playlist_id, p.name AS playlist, pp.precio AS precio
FROM precio_playlist pp
JOIN playlist p
    ON pp.playlist_id = p.playlist_id
WHERE pp.precio = (
    SELECT MAX(precio)
    FROM precio_playlist
);

/*
15. CTE: ¿Cuál es el promedio de álbumes por PlayList?
    Hint: Se debe devolver un valor numérico.
*/
WITH albumes_x_playlist AS (
    SELECT
        p.playlist_id,
        COUNT(DISTINCT t.album_id) AS cant_albumes
    FROM playlist p
    LEFT JOIN playlist_track pt -- puede haber playlists sin tracks
        ON pt.playlist_id = p.playlist_id
    LEFT JOIN track t
        ON t.track_id = pt.track_id
    GROUP BY p.playlist_id
)
SELECT AVG(cant_albumes) AS albumes_prom_x_playlist
FROM albumes_x_playlist;

/*
16. Obtener los datos de todos los tracks del álbum 'Led Zeppelin I'. 
    Hint: Utilizar consultas anidadas.
*/
SELECT *
FROM track
WHERE album_id IN (
    SELECT album_id
    FROM album
    WHERE title = 'Led Zeppelin I'
);

/*
17. Obtener los nombres, en mayúscula, de los tracks que se llaman igual que el álbumal quepertenecen. 
    Hint: Utilizar consultas anidadas
*/
SELECT UPPER(t.name)
FROM track t
WHERE t.name = (
    SELECT title
    FROM album a
    WHERE t.album_id =  a.album_id
);
-- Otra forma:
SELECT UPPER(t.name)
FROM track t
WHERE EXISTS (
    SELECT 1
    FROM album a
    WHERE a.album_id = t.album_id
      AND a.title = t.name
);

/*
18. Obtener los playlist que no contengan ningún track de los álbumes de los artistas “AC/DC” o 
    “Audioslave” o "Chris Cornell".
*/
SELECT p.*
FROM playlist p
WHERE NOT EXISTS (
    SELECT 1
    FROM playlist_track pt
    JOIN track t
        ON t.track_id = pt.track_id
    JOIN album al
        ON al.album_id = t.album_id
    JOIN artist ar
        ON ar.artist_id = al.artist_id
    WHERE
        pt.playlist_id = p.playlist_id
        AND ar.name IN ('AC/DC', 'Audioslave', 'Chris Cornell')
)
ORDER BY p.playlist_id ASC;

/*
19. Ordenar los géneros según la cantidad de facturas generadas
*/
SELECT 
    g.name AS genero, 
    COUNT(DISTINCT il.invoice_id) AS cant_facturas
FROM genre g
JOIN track t
    ON t.genre_id = g.genre_id
JOIN invoice_line il
    ON il.track_id = t.track_id
GROUP BY g.name
ORDER BY COUNT(DISTINCT il.invoice_id) DESC;

/*
20. Seleccione nombre y composer de los tracks que nunca fueron facturados. 
    HINT: Pensarlo con NOT IN
*/
SELECT name, composer
FROM track t
WHERE t.track_id NOT IN (
    SELECT track_id
    FROM invoice_line
);

/*
21. Seleccione nombre y composer de los tracks que nunca fueron facturados. 
    HINT: Pensarlo con EXCEPT 
*/
SELECT name, composer
    FROM track
EXCEPT
    SELECT t.name, t.composer
        FROM track t
        JOIN invoice_line il
            ON il.track_id = t.track_id;

/*
22. Devolver el id del track, nombre del artista, título del álbum y nombre del track, tal que este sea el 
    más largo en cantidad de caracteres, de todos los tracks. 
    HINT: CTE + funciones auxiliares de strings
*/
WITH largo_nombre_track AS (
    SELECT 
        t.track_id,
        ar.name AS artista,
        al.title AS titulo_album,
        t.name AS nombre_track,
        LENGTH(t.name) AS largo
    FROM track t
    JOIN album al
        ON al.album_id = t.album_id
    JOIN artist ar
        ON ar.artist_id = al.artist_id
)
SELECT
    track_id,
    artista,
    titulo_album,
    nombre_track
FROM largo_nombre_track
WHERE largo = (
    SELECT MAX(largo)
    FROM largo_nombre_track
);