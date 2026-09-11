--DROP TABLE IF EXISTS "jinete_dragon";



CREATE TABLE jinete_dragon (
    registro_id SERIAL PRIMARY KEY,
    nombre_jinete VARCHAR(100) NOT NULL,
    casa VARCHAR(50) NOT NULL,
    titulo VARCHAR(100),
    fecha_nacimiento_jinete DATE,
    nombre_dragon VARCHAR(50),
    fecha_nacimiento_dragon DATE,
    color_dragon VARCHAR(50),
    fecha_desde DATE,
    fecha_hasta DATE,
    kilometros_recorridos NUMERIC(10,2),
    es_jinete_actual BOOLEAN,
    cantidad_batallas INTEGER,
    observaciones TEXT
);
