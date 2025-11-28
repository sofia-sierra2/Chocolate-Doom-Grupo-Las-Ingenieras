-- Inicialmente creamos las tablas acorde a nuestro ER, sin embargo empleamos unas temporales
-- para cargar los datos a la tabla principal de telemetry_event

CREATE TABLE "User" (
    user_id SERIAL PRIMARY KEY, --SERIAL crea una columna auto-incremental inicia en 1
    name VARCHAR(50),
    gender VARCHAR(10),
    age INT,
    experience_level VARCHAR(30)
);

CREATE TABLE Player (
    player_id SERIAL PRIMARY KEY,
    name VARCHAR(50),
    role VARCHAR(50),
    user_id INT REFERENCES "User"(user_id)
);

CREATE TABLE Game (
    game_id SERIAL PRIMARY KEY,
    player_name VARCHAR(50)
);

CREATE TABLE Map (
    map_code INT PRIMARY KEY,
    map_name VARCHAR(100) NOT NULL
);

CREATE TABLE Sector (
    sector_id SERIAL PRIMARY KEY,
    map_code INT REFERENCES Map(map_code),
    sector_index INT NOT NULL
);

CREATE TABLE Telemetry_event ( --esta es nuestra trabla principal que almacena todo
    telemetry_id SERIAL PRIMARY KEY,
    pos_x FLOAT,
    pos_y FLOAT,
    pos_z FLOAT,
    momentum_x FLOAT,
    momentum_y FLOAT,
    created_at TIMESTAMP,
    game_id INT REFERENCES Game(game_id),
    player_id INT REFERENCES Player(player_id),
    episode_id INT
);

CREATE TABLE staging_raw_lines ( --tabla temporal donde cargamos el archivo y esta lee linea a linea
    raw_line TEXT
);

CREATE TABLE staging_telemetry_event ( --tabla temporal donde pasamos los datos organizados y tabulados
										--con respecto a su tipo
    timestamp TEXT,
    tic TEXT,
    x TEXT,
    y TEXT,
    z TEXT,
    angle TEXT,
    momx TEXT,
    momy TEXT
);


-- Ahora insertamos los usuarios, juegos y jugadoras a las tablas 

INSERT INTO "User" (name, gender, age, experience_level) VALUES
('Valentina', 'Female', 22, 'Intermediate'),
('Natalia', 'Female', 21, 'Intermediate'),
('Vanesa', 'Female', 23, 'Beginner'),
('Sofia', 'Female', 22, 'Advanced');

INSERT INTO Game (player_name) VALUES
('Valentina'), ('Natalia'), ('Vanesa'), ('Sofia');

INSERT INTO Player (name, role, user_id) VALUES
('Valentina', 'Player', 1),
('Natalia', 'Player', 2),
('Vanesa', 'Player', 3),
('Sofia', 'Player', 4);

--Para iniciar cargamos los datos de cada jugadora dependiendo de su id que ya tenemos predeterminado
--
--CARGAR DATOS VALENTINA (Game ID = 1)
TRUNCATE staging_raw_lines; --TRUNCATE borra todo el contenido de la tabla de forma rápida 
TRUNCATE staging_telemetry_event;--(más rápida que DELETE), útil para limpiar antes de cargar un archivo nuevo.

-- 1. INSERT INTO staging_telemetry_event (Paso que cargamos los datos del archivo aquí)
--transformar cada raw_line (una línea de texto del archivo) en columnas separadas
--split_part(raw_line, E'\t', n): función que divide el texto por el carácter de tabulación (\t)
--y devuelve la n-ésima parte.
--::int, ::float: type casts — convierten la cadena a entero o float. Si la cadena no es válida
--para el tipo, dará error. El E'\t' significa TAB
INSERT INTO staging_telemetry_event (timestamp, tic, x, y, z, angle, momx, momy)
SELECT
    split_part(raw_line, E'\t', 1),
    split_part(raw_line, E'\t', 2)::int,
    split_part(raw_line, E'\t', 3)::float,
    split_part(raw_line, E'\t', 4)::float,
    split_part(raw_line, E'\t', 5)::float,
    split_part(raw_line, E'\t', 6)::float,
    split_part(raw_line, E'\t', 7)::float,
    split_part(raw_line, E'\t', 8)::float
FROM staging_raw_lines;



-- 2. INSERT INTO Telemetry_event (El ETL final, con las nuevas columnas)
--TRIM(x) quita espacios al inicio/fin
--NULLIF(..., '') convierte la cadena vacía a NULL (evita cast fails).
--::FLOAT convierte el resultado a número. Si es NULL, se inserta NULL
--to_timestamp(TRIM(timestamp), 'YYYY-MM-DD HH24:MI:SS'): Convierte la cadena con formato de fecha/hora a tipo TIMESTAMP
INSERT INTO telemetry_event (
    pos_x, pos_y, pos_z,
    momentum_x, momentum_y,
    created_at,
    game_id, player_id, episode_id
)
SELECT
    NULLIF(TRIM(x), '')::FLOAT, 
    NULLIF(TRIM(y), '')::FLOAT, 
    NULLIF(TRIM(z), '')::FLOAT, 
    NULLIF(TRIM(momx), '')::FLOAT,
    NULLIF(TRIM(momy), '')::FLOAT,
    to_timestamp(TRIM(timestamp), 'YYYY-MM-DD HH24:MI:SS'),
    1,  -- game_id fijo
    (
-- en esta subconsulta se encontra automáticamente el player_id que corresponde al juego (game_id = 1) para insertarlo en Telemetry_event.
        SELECT p.player_id
        FROM game g 
        JOIN player p ON g.player_name = p.name
        WHERE g.game_id = 1
        LIMIT 1
    ),
    1   -- episode_id fijo
FROM staging_telemetry_event
WHERE TRIM(x) <> ''  --Evita filas vacías
  AND TRIM(y) <> '' --TRIM(x) quita espacios al inicio/fin
  AND TRIM(z) <> ''
  AND TRIM(momx) <> ''
  AND TRIM(momy) <> '';

--comprobaciones rapidas de que los datos quedaron guardados  
SELECT COUNT(*) FROM Telemetry_event; 
SELECT * FROM Telemetry_event WHERE game_id = 1;


--CARGAR DATOS NATALIA
TRUNCATE staging_raw_lines;
TRUNCATE staging_telemetry_event;

INSERT INTO staging_telemetry_event (timestamp, tic, x, y, z, angle, momx, momy)
SELECT
    split_part(raw_line, E'\t', 1),
    split_part(raw_line, E'\t', 2)::int,
    split_part(raw_line, E'\t', 3)::float,
    split_part(raw_line, E'\t', 4)::float,
    split_part(raw_line, E'\t', 5)::float,
    split_part(raw_line, E'\t', 6)::float,
    split_part(raw_line, E'\t', 7)::float,
    split_part(raw_line, E'\t', 8)::float
FROM staging_raw_lines;

INSERT INTO telemetry_event (
    pos_x, pos_y, pos_z,
    momentum_x, momentum_y,
    created_at,
    game_id, player_id, episode_id
)
SELECT
    NULLIF(TRIM(x), '')::FLOAT,
    NULLIF(TRIM(y), '')::FLOAT,
    NULLIF(TRIM(z), '')::FLOAT,
    NULLIF(TRIM(momx), '')::FLOAT,
    NULLIF(TRIM(momy), '')::FLOAT,
    to_timestamp(TRIM(timestamp), 'YYYY-MM-DD HH24:MI:SS'),
    2,  -- game_id fijo
    (
        SELECT p.player_id
        FROM game g 
        JOIN player p ON g.player_name = p.name
        WHERE g.game_id = 2
        LIMIT 1
    ),
    1   -- episode_id fijo
FROM staging_telemetry_event
WHERE TRIM(x) <> ''
  AND TRIM(y) <> ''
  AND TRIM(z) <> ''
  AND TRIM(momx) <> ''
  AND TRIM(momy) <> '';


SELECT COUNT(*) FROM Telemetry_event;
SELECT COUNT (*) FROM Telemetry_event WHERE game_id = 2;


--CARGAR DATOS VANESA
TRUNCATE staging_raw_lines;
TRUNCATE staging_telemetry_event;

INSERT INTO staging_telemetry_event (timestamp, tic, x, y, z, angle, momx, momy)
SELECT
    split_part(raw_line, E'\t', 1),
    split_part(raw_line, E'\t', 2)::int,
    split_part(raw_line, E'\t', 3)::float,
    split_part(raw_line, E'\t', 4)::float,
    split_part(raw_line, E'\t', 5)::float,
    split_part(raw_line, E'\t', 6)::float,
    split_part(raw_line, E'\t', 7)::float,
    split_part(raw_line, E'\t', 8)::float
FROM staging_raw_lines;

INSERT INTO telemetry_event (
    pos_x, pos_y, pos_z,
    momentum_x, momentum_y,
    created_at,
    game_id, player_id, episode_id
)
SELECT
    NULLIF(TRIM(x), '')::FLOAT,
    NULLIF(TRIM(y), '')::FLOAT,
    NULLIF(TRIM(z), '')::FLOAT,
    NULLIF(TRIM(momx), '')::FLOAT,
    NULLIF(TRIM(momy), '')::FLOAT,
    to_timestamp(TRIM(timestamp), 'YYYY-MM-DD HH24:MI:SS'),
    3,  -- game_id fijo
    (
        SELECT p.player_id
        FROM game g 
        JOIN player p ON g.player_name = p.name
        WHERE g.game_id = 3
        LIMIT 1
    ),
    1   -- episode_id fijo
FROM staging_telemetry_event
WHERE TRIM(x) <> ''
  AND TRIM(y) <> ''
  AND TRIM(z) <> ''
  AND TRIM(momx) <> ''
  AND TRIM(momy) <> '';

SELECT COUNT(*) FROM Telemetry_event;
SELECT COUNT (*) FROM Telemetry_event WHERE game_id = 3;

--CARGAR DATOS SOFIA
TRUNCATE staging_raw_lines;
TRUNCATE staging_telemetry_event;

INSERT INTO staging_telemetry_event (timestamp, tic, x, y, z, angle, momx, momy)
SELECT
    NULLIF(split_part(raw_line, E'\t', 1), ''),               
    NULLIF(split_part(raw_line, E'\t', 2), '')::int,         
    NULLIF(split_part(raw_line, E'\t', 3), '')::float,
    NULLIF(split_part(raw_line, E'\t', 4), '')::float,
    NULLIF(split_part(raw_line, E'\t', 5), '')::float,
    NULLIF(split_part(raw_line, E'\t', 6), '')::float,
    NULLIF(split_part(raw_line, E'\t', 7), '')::float,
    NULLIF(split_part(raw_line, E'\t', 8), '')::float
FROM staging_raw_lines;

INSERT INTO telemetry_event (
    pos_x, pos_y, pos_z,
    momentum_x, momentum_y,
    created_at,
    game_id, player_id, episode_id
)
SELECT
    NULLIF(TRIM(x), '')::FLOAT,
    NULLIF(TRIM(y), '')::FLOAT,
    NULLIF(TRIM(z), '')::FLOAT,
    NULLIF(TRIM(momx), '')::FLOAT,
    NULLIF(TRIM(momy), '')::FLOAT,
    to_timestamp(TRIM(timestamp), 'YYYY-MM-DD HH24:MI:SS'),
    4,  -- game_id fijo
    (
        SELECT p.player_id
        FROM game g 
        JOIN player p ON g.player_name = p.name
        WHERE g.game_id = 4
        LIMIT 1
    ),
    1   -- episode_id fijo
FROM staging_telemetry_event
WHERE TRIM(x) <> ''
  AND TRIM(y) <> ''
  AND TRIM(z) <> ''
  AND TRIM(momx) <> ''
  AND TRIM(momy) <> '';

SELECT COUNT(*) FROM Telemetry_event;
SELECT COUNT (*) FROM Telemetry_event WHERE game_id = 4;


--Pruebas para ver si los datos quedaron bien guardados
SELECT g.player_name, COUNT(t.telemetry_id) AS total_eventos
FROM Game g
LEFT JOIN Telemetry_event t ON g.game_id = t.game_id
GROUP BY g.player_name;

SELECT * FROM Game;

-- Encuestas
-- Crear tablas necesarias 


CREATE TABLE UX_instrument (
    instrument_id SERIAL PRIMARY KEY,
    code VARCHAR(50),
    title VARCHAR(100),
    description TEXT
);

CREATE TABLE UX_item (
    item_id SERIAL PRIMARY KEY,
    item_text TEXT,
    item_index INT,
    instrument_id INT REFERENCES UX_instrument(instrument_id)
);

CREATE TABLE UX_response (
    UX_response_id SERIAL PRIMARY KEY,
    completed_at TIMESTAMP DEFAULT NOW(),
    value INT CHECK (value BETWEEN 1 AND 7),
    user_id INT REFERENCES "User"(user_id),
    instrument_id INT REFERENCES UX_instrument(instrument_id),
    game_id INT REFERENCES Game(game_id),
    item_id INT REFERENCES UX_item(item_id)
);

-- Instrumento GUESS
INSERT INTO UX_instrument (code, title, description)
VALUES ('GUESS-18', 'Game User Experience Satisfaction Scale',
        'Instrumento de 18 ítems con escala Likert 1-7 para medir satisfacción de experiencia de juego.');

-- Ítems del instrumento
INSERT INTO UX_item (item_text, item_index, instrument_id) VALUES
('I find the controls of the game to be straightforward.', 1, 1),
('I find the game''s interface to be easy to navigate.', 2, 1),
('I am captivated by the game''s story from the beginning.', 3, 1),
('I enjoy the fantasy or story provided by the game.', 4, 1),
('I feel detached from the outside world while playing the game.', 5, 1),
('I think the game is fun.', 6, 1),
('I feel bored while playing the game.', 7, 1),
('I feel the game allows me to be imaginative.', 8, 1),
('I feel creative while playing the game.', 9, 1),
('I enjoy the sound effects in the game.', 10, 1),
('I feel the game''s audio enhances my gaming experience.', 11, 1),
('I am very focused on my performance while playing the game.', 12, 1),
('I want to do as well as possible during the game.', 13, 1),
('I find the game supports social interaction between players.', 14, 1),
('I like to play this game with other players.', 15, 1),
('I enjoy the game''s graphics.', 16, 1),
('I think the game is visually appealing.', 17, 1),
('Overall, I am satisfied with my experience in the game.', 18, 1);

-- Respuestas (ingresadas a mano)
-- Valentina (user_id = 1)
INSERT INTO UX_response (value, user_id, instrument_id, game_id, item_id) VALUES
(6,1,1,1,1),(3,1,1,1,2),(4,1,1,1,3),(5,1,1,1,4),(5,1,1,1,5),(5,1,1,1,6),
(6,1,1,1,7),(3,1,1,1,8),(6,1,1,1,9),(5,1,1,1,10),(4,1,1,1,11),(4,1,1,1,12),
(5,1,1,1,13),(6,1,1,1,14),(6,1,1,1,15),(6,1,1,1,16),(3,1,1,1,17),(6,1,1,1,18);

-- Natalia (user_id = 2)
INSERT INTO UX_response (value, user_id, instrument_id, game_id, item_id) VALUES
(5,2,1,1,1),(6,2,1,1,2),(5,2,1,1,3),(7,2,1,1,4),(6,2,1,1,5),(3,2,1,1,6),
(6,2,1,1,7),(3,2,1,1,8),(4,2,1,1,9),(4,2,1,1,10),(4,2,1,1,11),(4,2,1,1,12),
(7,2,1,1,13),(7,2,1,1,14),(2,2,1,1,15),(4,2,1,1,16),(5,2,1,1,17),(6,2,1,1,18);

-- Vanesa (user_id = 3)
INSERT INTO UX_response (value, user_id, instrument_id, game_id, item_id) VALUES
(4,3,1,1,1),(5,3,1,1,2),(6,3,1,1,3),(5,3,1,1,4),(5,3,1,1,5),(3,3,1,1,6),
(6,3,1,1,7),(1,3,1,1,8),(4,3,1,1,9),(4,3,1,1,10),(2,3,1,1,11),(2,3,1,1,12),
(4,3,1,1,13),(4,3,1,1,14),(1,3,1,1,15),(1,3,1,1,16),(1,3,1,1,17),(2,3,1,1,18);

-- Sofía (user_id = 4)
INSERT INTO UX_response (value, user_id, instrument_id, game_id, item_id) VALUES
(7,4,1,1,1),(6,4,1,1,2),(7,4,1,1,3),(6,4,1,1,4),(5,4,1,1,5),(4,4,1,1,6),
(7,4,1,1,7),(2,4,1,1,8),(3,4,1,1,9),(4,4,1,1,10),(4,4,1,1,11),(4,4,1,1,12),
(7,4,1,1,13),(7,4,1,1,14),(3,4,1,1,15),(1,4,1,1,16),(5,4,1,1,17),(6,4,1,1,18);

-- Verificar que los datos se guardaron
SELECT * FROM "User";
SELECT * FROM Player;
SELECT * FROM UX_instrument;
SELECT * FROM UX_item;
SELECT * FROM UX_response;










---QUERIES ENTREGA 3

-- 2. Players with the highest average proximity.
--Analizar proximidad entre todas las parejas posibles de jugadores
--EXPLAIN ANALYZE dejamos comentado para luego evaluar con el índice
WITH ParejasProximidad AS (
    SELECT 
        p1.player_id AS jugador1_id,
        p2.player_id AS jugador2_id,
        p1.name AS nombre_jugador1,
        p2.name AS nombre_jugador2
    FROM Player p1
    CROSS JOIN Player p2 -- Crea todas las combinaciones posibles entre jugadores
    WHERE p1.player_id < p2.player_id --Evita duplicados (A-B vs B-A) y evita comparar un jugador consigo mismo
),
AnalisisProximidad AS (  --calculamos métricas de proximidad entre cada par de jugadores
    SELECT 
        pp.nombre_jugador1,  -- nombre del primer jugador en la pareja
        pp.nombre_jugador2,  -- nombre del segundo jugador en la pareja
        COUNT(*) AS total_mediciones,  -- número total de pares de mediciones tomadas (producto cartesiano filtrado)
        ROUND(AVG(  -- distancia promedio entre los pares de eventos considerados
            SQRT(
                POWER(t1.pos_x - t2.pos_x, 2) +  -- diferencia X al cuadrado
                POWER(t1.pos_y - t2.pos_y, 2) +  -- diferencia Y al cuadrado
                POWER(t1.pos_z - t2.pos_z, 2)    -- diferencia Z al cuadrado
            )
        )::numeric, 2) AS distancia_promedio,  -- redondea la media a 2 decimales
        ROUND(MIN(  -- distancia mínima observada entre los pares
            SQRT(
                POWER(t1.pos_x - t2.pos_x, 2) +
                POWER(t1.pos_y - t2.pos_y, 2) +
                POWER(t1.pos_z - t2.pos_z, 2)
            )
        )::numeric, 2) AS distancia_minima,  -- redondea la mínima a 2 decimales
        COUNT(CASE WHEN  -- cuenta cuántas mediciones están por debajo o igual al umbral (encuentros cercanos)
            SQRT(
                POWER(t1.pos_x - t2.pos_x, 2) +
                POWER(t1.pos_y - t2.pos_y, 2) +
                POWER(t1.pos_z - t2.pos_z, 2)
            ) <= 1500 THEN 1 END) AS encuentros_cercanos_count,  -- número de encuentros cercanos
        ROUND((COUNT(CASE WHEN  -- porcentaje de encuentros cercanos respecto al total
            SQRT(
                POWER(t1.pos_x - t2.pos_x, 2) +
                POWER(t1.pos_y - t2.pos_y, 2) +
                POWER(t1.pos_z - t2.pos_z, 2)
            ) <= 1500 THEN 1 END) * 100.0 / COUNT(*))::numeric, 2) AS porcentaje_encuentros_cercanos  -- porcentaje redondeado
    FROM ParejasProximidad pp  -- tabla con todas las parejas de jugadores (producto cartesiano filtrado)
    JOIN Telemetry_event t1 ON pp.jugador1_id = t1.player_id -- toma eventos del jugador 1
    JOIN Telemetry_event t2 ON pp.jugador2_id = t2.player_id -- toma eventos del jugador 2
    WHERE t1.pos_x IS NOT NULL AND t1.pos_y IS NOT NULL AND t1.pos_z IS NOT NULL  -- filtra eventos válidos (jugador1)
      AND t2.pos_x IS NOT NULL AND t2.pos_y IS NOT NULL AND t2.pos_z IS NOT NULL  -- filtra eventos válidos (jugador2)
      AND ABS(EXTRACT(EPOCH FROM (t1.created_at - t2.created_at))) <= 2.0  -- empareja solo eventos con diferencia temporal <= 2s
    GROUP BY pp.nombre_jugador1, pp.nombre_jugador2  -- agrupa por la pareja de nombres para calcular las métricas
)
SELECT 
    nombre_jugador1 || ' - ' || nombre_jugador2 AS par_jugadores,  -- concatena los dos nombres para mostrar el par
    total_mediciones,  -- muestra el total de mediciones consideradas
    distancia_promedio,  -- muestra la distancia promedio calculada
    distancia_minima,  -- muestra la distancia mínima observada
    encuentros_cercanos_count,  -- muestra cuántos encuentros cercanos hubo
    porcentaje_encuentros_cercanos || '%' AS porcentaje_encuentros_cercanos,  -- muestra el porcentaje con símbolo %
    CASE  -- clasifica la pareja según la cantidad/porcentaje de encuentros cercanos
        WHEN encuentros_cercanos_count = 0 THEN 'sin encuentros'  -- ninguna medición cercana
        WHEN porcentaje_encuentros_cercanos < 10 THEN 'pocos encuentros'  -- menos del 10%
        WHEN porcentaje_encuentros_cercanos < 50 THEN 'algunos encuentros'  -- entre 10% y 50%
        ELSE 'muchos encuentros'  -- 50% o más
    END AS categoria_proximidad
FROM AnalisisProximidad  -- usa las métricas calculadas en la CTE anterior
WHERE total_mediciones >= 1  -- filtra para incluir solo pares que tengan al menos una medición
ORDER BY encuentros_cercanos_count DESC, porcentaje_encuentros_cercanos DESC, distancia_minima ASC;  -- ordena resultados por prioridad: más encuentros, mayor % y menor distancia mínima

--indice de la consulta
CREATE INDEX idx_telemetry_player_created_at
ON Telemetry_event (player_id, created_at);




--3.Shortest and longest trajectory distances per player.
SELECT
    u.name AS player_name,                 -- Nombre de la jugadora
    MIN(g.total_distance) AS shortest_trajectory,  -- Trayectoria mínima entre sus games
    MAX(g.total_distance) AS longest_trajectory    -- Trayectoria máxima entre sus games
FROM (
    -- Subconsulta g: calcula la longitud total de la trayectoria por (player_id, game_id)
    SELECT
        t.player_id,
        t.game_id,
        SUM(
            CASE
                -- En el primer tic no hay posición anterior → distancia 0
                WHEN t.prev_x IS NULL OR t.prev_y IS NULL OR t.prev_z IS NULL THEN 0
                -- Distancia euclidiana 3D entre tic actual y tic anterior
                ELSE sqrt(
                    power(t.pos_x - t.prev_x, 2) +
                    power(t.pos_y - t.prev_y, 2) +
                    power(t.pos_z - t.prev_z, 2)
                )
            END
        ) AS total_distance          -- Longitud total de la trayectoria en ese game
    FROM (
        -- Subconsulta t: usa FUNCIÓN DE VENTANA LAG() sobre el TIC que construimos.
        -- Para cada (game_id, player_id) ordenado por tic, trae la posición del tic anterior.
        SELECT
            te.telemetry_id,
            te.game_id,
            te.player_id,
            te.pos_x,
            te.pos_y,
            te.pos_z,
            te.tic,   -- tic reconstruido en telemetry_event (0,1,2,...) por game y player
            LAG(te.pos_x) OVER (
                PARTITION BY te.game_id, te.player_id
                ORDER BY te.tic
            ) AS prev_x,    -- pos_x del tic anterior
            LAG(te.pos_y) OVER (
                PARTITION BY te.game_id, te.player_id
                ORDER BY te.tic
            ) AS prev_y,    -- pos_y del tic anterior
            LAG(te.pos_z) OVER (
                PARTITION BY te.game_id, te.player_id
                ORDER BY te.tic
            ) AS prev_z     -- pos_z del tic anterior
        FROM telemetry_event te      -- Tabla de eventos de telemetría con columna tic
    ) t
    GROUP BY t.player_id, t.game_id  -- Trayectoria total por cada game de cada jugadora
) g
JOIN player p ON p.player_id = g.player_id   -- Vincula player_id con la tabla Player
JOIN "User" u ON u.user_id = p.user_id      -- Obtiene el nombre de la jugadora
GROUP BY u.name
ORDER BY u.name;

--VIEW 
CREATE OR REPLACE VIEW vista_trayectorias_por_juego AS
WITH DistanciasPorGame AS (
    -- Calcula la longitud total de la trayectoria por (player_id, game_id)
    SELECT
        t.player_id,
        t.game_id,
        SUM(
            CASE
                -- En el primer tic no hay posición anterior → distancia 0
                WHEN t.prev_x IS NULL OR t.prev_y IS NULL OR t.prev_z IS NULL THEN 0
                -- Distancia euclidiana 3D entre tic actual y tic anterior
                ELSE sqrt(
                    power(t.pos_x - t.prev_x, 2) +
                    power(t.pos_y - t.prev_y, 2) +
                    power(t.pos_z - t.prev_z, 2)
                )
            END
        ) AS total_distance
    FROM (
        -- Usa LAG() sobre TIC para obtener la posición del tic anterior
        SELECT
            te.telemetry_id,
            te.game_id,
            te.player_id,
            te.pos_x,
            te.pos_y,
            te.pos_z,
            te.tic,   -- tic reconstruido por (game, player)
            LAG(te.pos_x) OVER (
                PARTITION BY te.game_id, te.player_id
                ORDER BY te.tic
            ) AS prev_x,
            LAG(te.pos_y) OVER (
                PARTITION BY te.game_id, te.player_id
                ORDER BY te.tic
            ) AS prev_y,
            LAG(te.pos_z) OVER (
                PARTITION BY te.game_id, te.player_id
                ORDER BY te.tic
            ) AS prev_z
        FROM telemetry_event te
    ) t
    GROUP BY t.player_id, t.game_id
),
ResumenPorPlayer AS (
    -- Por cada jugadora, encuentra su trayecto más corto y más largo
    SELECT
        d.player_id,
        MIN(d.total_distance) AS shortest_trajectory,
        MAX(d.total_distance) AS longest_trajectory
    FROM DistanciasPorGame d
    GROUP BY d.player_id
)
SELECT
    u.name        AS player_name,          -- nombre de la jugadora
    p.player_id,
    d.game_id,
    ROUND(d.total_distance::numeric, 2) AS total_distance,  -- distancia en ese game
    ROUND(r.shortest_trajectory::numeric, 2) AS shortest_trajectory, -- mínima para esa jugadora
    ROUND(r.longest_trajectory::numeric, 2) AS longest_trajectory,   -- máxima para esa jugadora
    CASE
        WHEN d.total_distance = r.shortest_trajectory THEN 'Trayectoria más corta'
        WHEN d.total_distance = r.longest_trajectory THEN 'Trayectoria más larga'
        ELSE 'Trayectoria intermedia'
    END AS categoria_trayectoria,
    RANK() OVER (
        PARTITION BY p.player_id
        ORDER BY d.total_distance ASC
    ) AS rank_por_distancia -- 1 = más corta, mayor = más larga
FROM DistanciasPorGame d
JOIN ResumenPorPlayer r ON r.player_id = d.player_id
JOIN Player p           ON p.player_id = d.player_id
JOIN "User" u           ON u.user_id = p.user_id;







--4. List UX survey responses for players with above-average trajectories duration.
--MAX(t.created_at) - MIN(t.created_at): Diferencia entre primer y último evento
--EXTRACT(EPOCH FROM ...): Convierte a segundos
WITH PlayerDurations AS (
    SELECT 
        t.player_id,
        p.name AS player_name,
        EXTRACT(EPOCH FROM (MAX(t.created_at) - MIN(t.created_at))) AS duration_seconds, 
        COUNT(t.telemetry_id) AS total_events -- COUNT(t.telemetry_id): Cuántos eventos tuvo cada jugador
    FROM Telemetry_event t
    JOIN Player p ON t.player_id = p.player_id
    WHERE t.created_at IS NOT NULL
    GROUP BY t.player_id, p.name
),
GlobalAverage AS (
--Calcula el promedio de duración de todos los jugadores
    SELECT AVG(duration_seconds) AS avg_duration_seconds
    FROM PlayerDurations
    WHERE duration_seconds > 0 --Se excluye jugadores con tiempo cero para no afectar el promedio
),
AboveAveragePlayers AS (
    SELECT 
        pd.player_id,
        pd.player_name,
        pd.duration_seconds,
        ROUND(pd.duration_seconds::numeric, 2) AS formatted_duration,
        ROUND((pd.duration_seconds / ga.avg_duration_seconds * 100)::numeric, 2) AS percentage_of_average --Cuánto porcentaje por encima del promedio están
    FROM PlayerDurations pd
    CROSS JOIN GlobalAverage ga --Combina cada jugador con el promedio
    WHERE pd.duration_seconds > ga.avg_duration_seconds --solo jugadores que superan el promedio
)
SELECT 
--Tomamos los jugadores above-average y une con sus respuestas UX
    aap.player_name,
    aap.formatted_duration AS duration_seconds,
    ROUND((SELECT avg_duration_seconds FROM GlobalAverage)::numeric, 2) AS global_avg_seconds,
    aap.percentage_of_average || '%' AS above_avg_by,
    uxi_main.code AS survey_instrument,
    uxi_main.title AS survey_title,
    uxi.item_text AS survey_question,
    uxr.value AS response_value,
    CASE uxr.value --Conviertimos los números (1-7) a la clasificacion
        WHEN 1 THEN 'Strongly Disagree'
        WHEN 2 THEN 'Disagree' 
        WHEN 3 THEN 'Somewhat Disagree'
        WHEN 4 THEN 'Neutral'
        WHEN 5 THEN 'Somewhat Agree'
        WHEN 6 THEN 'Agree'
        WHEN 7 THEN 'Strongly Agree'
    END AS response_label
FROM AboveAveragePlayers aap
JOIN UX_response uxr ON aap.player_id = uxr.user_id -- Obtiene respuestas de encuesta
JOIN UX_item uxi ON uxr.item_id = uxi.item_id -- Obtiene el texto de cada pregunta
JOIN UX_instrument uxi_main ON uxr.instrument_id = uxi_main.instrument_id  --Obtiene información del instrumento (GUESS-18)
ORDER BY aap.player_name, uxi.item_index;

--index b-tree
CREATE INDEX idx_te_player_created 
ON Telemetry_event (player_id, created_at);
--materialized view
CREATE MATERIALIZED VIEW mv_player_durations AS
SELECT 
    t.player_id,
    p.name AS player_name,
    EXTRACT(EPOCH FROM (MAX(t.created_at) - MIN(t.created_at))) AS duration_seconds,
    COUNT(t.telemetry_id) AS total_events
FROM Telemetry_event t
JOIN Player p ON t.player_id = p.player_id
WHERE t.created_at IS NOT NULL
GROUP BY t.player_id, p.name;

--query luego de la vista
WITH GlobalAverage AS (
    SELECT AVG(duration_seconds) AS avg_duration_seconds
    FROM mv_player_durations
    WHERE duration_seconds > 0
),
AboveAveragePlayers AS (
    SELECT 
        pd.player_id,
        pd.player_name,
        pd.duration_seconds,
        ROUND(pd.duration_seconds::numeric, 2) AS formatted_duration,
        ROUND((pd.duration_seconds / ga.avg_duration_seconds * 100)::numeric, 2) AS percentage_of_average
    FROM mv_player_durations pd
    CROSS JOIN GlobalAverage ga
    WHERE pd.duration_seconds > ga.avg_duration_seconds
)
SELECT 
    aap.player_name,
    aap.formatted_duration AS duration_seconds,
    ROUND((SELECT avg_duration_seconds FROM GlobalAverage)::numeric, 2) AS global_avg_seconds,
    aap.percentage_of_average || '%' AS above_avg_by,
    uxi_main.code AS survey_instrument,
    uxi_main.title AS survey_title,
    uxi.item_text AS survey_question,
    uxr.value AS response_value,
    CASE uxr.value
        WHEN 1 THEN 'Strongly Disagree'
        WHEN 2 THEN 'Disagree' 
        WHEN 3 THEN 'Somewhat Disagree'
        WHEN 4 THEN 'Neutral'
        WHEN 5 THEN 'Somewhat Agree'
        WHEN 6 THEN 'Agree'
        WHEN 7 THEN 'Strongly Agree'
    END AS response_label
FROM AboveAveragePlayers aap
JOIN UX_response uxr ON aap.player_id = uxr.user_id
JOIN UX_item uxi ON uxr.item_id = uxi.item_id
JOIN UX_instrument uxi_main ON uxr.instrument_id = uxi_main.instrument_id
ORDER BY aap.player_name, uxi.item_index;






-- 7.Average UX Score for Players with the Shortest Trajectory per Episode.

--EXPLAIN ANALYZE dejamos comentado para luego evaluar con el índice
WITH SegmentosDistancia AS (                                          -- calcula distancias entre puntos consecutivos de cada jugador
    SELECT 
        player_id,                                                    -- identificador del jugador
        SQRT(                                                         -- calcula la distancia euclidiana 3D entre dos puntos consecutivos
            POWER(pos_x - LAG(pos_x) OVER (PARTITION BY player_id 
                                           ORDER BY created_at), 2) + -- diferencia en X respecto al evento anterior
            POWER(pos_y - LAG(pos_y) OVER (PARTITION BY player_id 
                                           ORDER BY created_at), 2) + -- diferencia en Y
            POWER(pos_z - LAG(pos_z) OVER (PARTITION BY player_id 
                                           ORDER BY created_at), 2)   -- diferencia en Z
        ) AS distancia_segmento                                       -- resultado: distancia de ese tramo
    FROM Telemetry_event
    WHERE pos_x IS NOT NULL AND pos_y IS NOT NULL AND pos_z IS NOT NULL -- filtramos datos válidos
      AND episode_id = 1                                              -- solo analizamos episodio 1 porque es el unico
),
DistanciasPorJugador AS (                                             -- suma todas las distancias por jugador
    SELECT 
        player_id,
        SUM(distancia_segmento) AS distancia_total                    -- distancia recorrida total del jugador
    FROM SegmentosDistancia
    WHERE distancia_segmento IS NOT NULL                              -- ignorar filas donde no hay LAG
    GROUP BY player_id
),
PuntajesUX AS (                                                        -- calcula promedio UX por usuario
    SELECT 
        user_id,
        ROUND(AVG(value)::numeric, 2) AS promedio_ux,                 -- promedio UX con redondeo a 2 decimales
        COUNT(*) AS total_respuestas                                  -- cuántas respuestas UX dio cada usuario
    FROM UX_response
    GROUP BY user_id
)
SELECT 
    p.name AS jugador,                                                -- nombre del jugador
    ROUND(dpj.distancia_total::numeric, 2) AS distancia_trayectoria,  -- distancia total recorrida
    pux.promedio_ux AS puntaje_ux_promedio,                           -- promedio UX del usuario
    pux.total_respuestas,                                             -- cuántas respuestas UX dio
    CASE 
        WHEN dpj.distancia_total = (SELECT MIN(distancia_total) 
                                    FROM DistanciasPorJugador)        -- comparo con la distancia más baja
        THEN 'Trayectoria más corta'                                  -- jugador con recorrido más corto
        ELSE 'Otra trayectoria'                                       -- no es el que recorrió menos
    END AS categoria,
    RANK() OVER (ORDER BY dpj.distancia_total ASC) AS ranking_trayectoria -- ranking según distancia (menor = mejor)
FROM DistanciasPorJugador dpj
JOIN Player p ON dpj.player_id = p.player_id                          -- asocia el id del jugador con su nombre
JOIN PuntajesUX pux ON dpj.player_id = pux.user_id                    -- asocia jugador con su UX
WHERE dpj.distancia_total > 0                                         -- excluye jugadores sin movimiento
ORDER BY dpj.distancia_total ASC;                                     -- ordena de menor a mayor distancia

CREATE INDEX idx_telemetry_brin_createdat                             -- crea un índice BRIN (muy liviano)
ON Telemetry_event 
USING BRIN (created_at);                                              -- acelera consultas que ordenan/filtran por tiempo

SELECT 
    indexname,                                                        -- nombre del índice
    indexdef                                                          -- definición del índice
FROM pg_indexes 
WHERE indexname = 'idx_telemetry_brin_createdat';                     -- busca el índice recién creado



---VIEW
-- Creamos la view con todas las métricas
CREATE OR REPLACE VIEW vista_trayectorias_ux AS
WITH SegmentosDistancia AS (
    SELECT 
        player_id,
        SQRT(
            POWER(pos_x - LAG(pos_x) OVER (PARTITION BY player_id ORDER BY created_at), 2) +
            POWER(pos_y - LAG(pos_y) OVER (PARTITION BY player_id ORDER BY created_at), 2) +
            POWER(pos_z - LAG(pos_z) OVER (PARTITION BY player_id ORDER BY created_at), 2)
        ) AS distancia_segmento
    FROM Telemetry_event
    WHERE pos_x IS NOT NULL 
      AND pos_y IS NOT NULL 
      AND pos_z IS NOT NULL
      AND episode_id = 1
),
DistanciasPorJugador AS (
    SELECT 
        player_id,
        SUM(distancia_segmento) AS distancia_total,
        COUNT(distancia_segmento) AS segmentos_calculados
    FROM SegmentosDistancia
    WHERE distancia_segmento IS NOT NULL
    GROUP BY player_id
),
PuntajesUX AS (
    SELECT 
        user_id,
        ROUND(AVG(value)::numeric, 2) AS promedio_ux,
        COUNT(*) AS total_respuestas,
        MIN(value) AS puntaje_minimo,
        MAX(value) AS puntaje_maximo
    FROM UX_response
    GROUP BY user_id
)
SELECT 
    p.name AS jugador,
    ROUND(dpj.distancia_total::numeric, 2) AS distancia_trayectoria,
    dpj.segmentos_calculados,
    pux.promedio_ux AS puntaje_ux_promedio,
    pux.puntaje_minimo,
    pux.puntaje_maximo,
    pux.total_respuestas,
    CASE 
        WHEN dpj.distancia_total = (SELECT MIN(distancia_total) FROM DistanciasPorJugador) 
        THEN 'Trayectoria más corta'
        ELSE 'Otra trayectoria'
    END AS categoria,
    RANK() OVER (ORDER BY dpj.distancia_total ASC) AS ranking_trayectoria,
    ROUND((dpj.distancia_total / (SELECT AVG(distancia_total) FROM DistanciasPorJugador))::numeric, 2) AS porcentaje_promedio
FROM DistanciasPorJugador dpj
JOIN Player p ON dpj.player_id = p.player_id
JOIN PuntajesUX pux ON dpj.player_id = pux.user_id
WHERE dpj.distancia_total > 0;

-- Verificamos que la view se creó correctamente
SELECT table_name, view_definition 
FROM information_schema.views 
WHERE table_name = 'vista_trayectorias_ux';

-- Consulta básica para verificar la vista
SELECT * FROM vista_trayectorias_ux ORDER BY ranking_trayectoria;

-- Consulta específica: solo el jugador con trayectoria más corta
SELECT * FROM vista_trayectorias_ux WHERE categoria = 'Trayectoria más corta';

--índice 
CREATE INDEX idx_telemetry_brin_createdat
ON Telemetry_event
USING BRIN (created_at);



--8.Total Distance Traveled and Average Speed per Player, Analyzing All Games for a Player
--EXPLAIN ANALYZE para el index
SELECT
    u.name AS player_name,          -- Nombre de la jugadora
    a.total_distance,               -- Distancia total recorrida (unidades de mapa del juego)
    a.total_tics,                   -- Duración total en tics
    CASE
        WHEN a.total_tics > 0
            THEN a.total_distance / a.total_tics::FLOAT
        ELSE NULL
    END AS avg_speed_units_per_tic  -- Velocidad promedio: unidades de mapa / tic
FROM (
    -- Subconsulta a: agregación por jugadora (suma sobre TODAS sus partidas)
    SELECT
        t.player_id,
        SUM(
            CASE
                -- Primer tic de la serie: sin posición anterior → distancia 0
                WHEN t.prev_x IS NULL OR t.prev_y IS NULL OR t.prev_z IS NULL THEN 0
                -- Distancia euclidiana 3D entre la posición actual y la anterior
                ELSE sqrt(
                    power(t.pos_x - t.prev_x, 2) +
                    power(t.pos_y - t.prev_y, 2) +
                    power(t.pos_z - t.prev_z, 2)
                )
            END
        ) AS total_distance,
        SUM(
            CASE
                -- Primer tic de la serie: no hay diferencia de tic → 0
                WHEN t.prev_tic IS NULL THEN 0
                -- Diferencia de tics consecutivos = duración de ese paso
                ELSE (t.tic - t.prev_tic)
            END
        ) AS total_tics
    FROM (
        -- Subconsulta t: usa FUNCIÓN DE VENTANA LAG() sobre TIC y posiciones.
        -- Trabaja por (game_id, player_id) para respetar cada sesión del jugador.
        SELECT
            te.telemetry_id,
            te.game_id,
            te.player_id,
            te.pos_x,
            te.pos_y,
            te.pos_z,
            te.tic,   -- tic reconstruido a partir de created_at
            LAG(te.pos_x) OVER (
                PARTITION BY te.game_id, te.player_id
                ORDER BY te.tic
            ) AS prev_x,   -- pos_x en el tic anterior
            LAG(te.pos_y) OVER (
                PARTITION BY te.game_id, te.player_id
                ORDER BY te.tic
            ) AS prev_y,   -- pos_y en el tic anterior
            LAG(te.pos_z) OVER (
                PARTITION BY te.game_id, te.player_id
                ORDER BY te.tic
            ) AS prev_z,   -- pos_z en el tic anterior
            LAG(te.tic) OVER (
                PARTITION BY te.game_id, te.player_id
                ORDER BY te.tic
            ) AS prev_tic  -- tic anterior (para duración en tics)
        FROM telemetry_event te
    ) t
    GROUP BY t.player_id            -- Se agrupa sólo por la identidad de la jugadora
) a
JOIN player p ON p.player_id = a.player_id  -- Vincula con Player para llegar a User
JOIN "User" u ON u.user_id = p.user_id
ORDER BY u.name;

--index 
CREATE INDEX idx_telemetry_game_player_tic
ON telemetry_event (game_id, player_id, tic);

