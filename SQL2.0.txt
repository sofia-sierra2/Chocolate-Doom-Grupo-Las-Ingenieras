-- Telemetry events
-- 1. Crear las tablas

CREATE TABLE "User" (
    user_id SERIAL PRIMARY KEY,
    name VARCHAR(50),
    gender VARCHAR(10),
    age INT,
    experience_level VARCHAR(30)
);

CREATE TABLE Game (
    game_id SERIAL PRIMARY KEY,
    player_name VARCHAR(50)
);

CREATE TABLE Telemetry_event (
    telemetry_id SERIAL PRIMARY KEY,
    pos_x FLOAT,
    pos_y FLOAT,
    pos_z FLOAT,
    momentum_x FLOAT,
    momentum_y FLOAT,
    created_at TIMESTAMP,
    game_id INT REFERENCES Game(game_id)
);

CREATE TABLE staging_raw_lines (
    raw_line TEXT
);

CREATE TABLE staging_telemetry_event (
    timestamp TEXT,
    tic TEXT,
    x TEXT,
    y TEXT,
    z TEXT,
    angle TEXT,
    momx TEXT,
    momy TEXT
);


-- 2. Insertar usuarios y juegos

INSERT INTO "User" (alias, gender, age, experience_level) VALUES
('Valentina', 'Female', 22, 'Intermediate'),
('Natalia', 'Female', 21, 'Intermediate'),
('Vanesa', 'Female', 23, 'Beginner'),
('Sofia', 'Female', 22, 'Advanced');

INSERT INTO Game (player_name) VALUES
('Valentina'), ('Natalia'), ('Vanesa'), ('Sofia');

TRUNCATE telemetry_event;

--CARGAR DATOS VALENTINA
TRUNCATE staging_raw_lines;
TRUNCATE staging_telemetry_event;

INSERT INTO staging_telemetry_event (timestamp, tic, x, y, z, angle, momx, momy)
SELECT
  split_part(raw_line, E'\t', 1),
  split_part(raw_line, E'\t', 2),
  split_part(raw_line, E'\t', 3),
  split_part(raw_line, E'\t', 4),
  split_part(raw_line, E'\t', 5),
  split_part(raw_line, E'\t', 6),
  split_part(raw_line, E'\t', 7),
  split_part(raw_line, E'\t', 8)
FROM staging_raw_lines;

INSERT INTO Telemetry_event (pos_x, pos_y, pos_z, momentum_x, momentum_y, created_at, game_id)
SELECT
  NULLIF(TRIM(x), '')::FLOAT,
  NULLIF(TRIM(y), '')::FLOAT,
  NULLIF(TRIM(z), '')::FLOAT,
  NULLIF(TRIM(momx), '')::FLOAT,
  NULLIF(TRIM(momy), '')::FLOAT,
  to_timestamp(TRIM(timestamp), 'YYYY-MM-DD HH24:MI:SS'),
  1
FROM staging_telemetry_event
WHERE TRIM(x) <> ''
  AND TRIM(y) <> ''
  AND TRIM(z) <> ''
  AND TRIM(momx) <> ''
  AND TRIM(momy) <> '';

SELECT COUNT(*) FROM Telemetry_event;
SELECT COUNT (*) FROM Telemetry_event WHERE game_id = 1;

--CARGAR DATOS NATALIA
TRUNCATE staging_raw_lines;
TRUNCATE staging_telemetry_event;

INSERT INTO staging_telemetry_event (timestamp, tic, x, y, z, angle, momx, momy)
SELECT
  split_part(raw_line, E'\t', 1),
  split_part(raw_line, E'\t', 2),
  split_part(raw_line, E'\t', 3),
  split_part(raw_line, E'\t', 4),
  split_part(raw_line, E'\t', 5),
  split_part(raw_line, E'\t', 6),
  split_part(raw_line, E'\t', 7),
  split_part(raw_line, E'\t', 8)
FROM staging_raw_lines;

INSERT INTO Telemetry_event (pos_x, pos_y, pos_z, momentum_x, momentum_y, created_at, game_id)
SELECT
  NULLIF(TRIM(x), '')::FLOAT,
  NULLIF(TRIM(y), '')::FLOAT,
  NULLIF(TRIM(z), '')::FLOAT,
  NULLIF(TRIM(momx), '')::FLOAT,
  NULLIF(TRIM(momy), '')::FLOAT,
  to_timestamp(TRIM(timestamp), 'YYYY-MM-DD HH24:MI:SS'),
  2
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
  split_part(raw_line, E'\t', 2),
  split_part(raw_line, E'\t', 3),
  split_part(raw_line, E'\t', 4),
  split_part(raw_line, E'\t', 5),
  split_part(raw_line, E'\t', 6),
  split_part(raw_line, E'\t', 7),
  split_part(raw_line, E'\t', 8)
FROM staging_raw_lines;

INSERT INTO Telemetry_event (pos_x, pos_y, pos_z, momentum_x, momentum_y, created_at, game_id)
SELECT
  NULLIF(TRIM(x), '')::FLOAT,
  NULLIF(TRIM(y), '')::FLOAT,
  NULLIF(TRIM(z), '')::FLOAT,
  NULLIF(TRIM(momx), '')::FLOAT,
  NULLIF(TRIM(momy), '')::FLOAT,
  to_timestamp(TRIM(timestamp), 'YYYY-MM-DD HH24:MI:SS'),
  3
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
  split_part(raw_line, E'\t', 1),
  split_part(raw_line, E'\t', 2),
  split_part(raw_line, E'\t', 3),
  split_part(raw_line, E'\t', 4),
  split_part(raw_line, E'\t', 5),
  split_part(raw_line, E'\t', 6),
  split_part(raw_line, E'\t', 7),
  split_part(raw_line, E'\t', 8)
FROM staging_raw_lines;

INSERT INTO Telemetry_event (pos_x, pos_y, pos_z, momentum_x, momentum_y, created_at, game_id)
SELECT
  NULLIF(TRIM(x), '')::FLOAT,
  NULLIF(TRIM(y), '')::FLOAT,
  NULLIF(TRIM(z), '')::FLOAT,
  NULLIF(TRIM(momx), '')::FLOAT,
  NULLIF(TRIM(momy), '')::FLOAT,
  to_timestamp(TRIM(timestamp), 'YYYY-MM-DD HH24:MI:SS'),
  4
FROM staging_telemetry_event
WHERE TRIM(x) <> ''
  AND TRIM(y) <> ''
  AND TRIM(z) <> ''
  AND TRIM(momx) <> ''
  AND TRIM(momy) <> '';

SELECT COUNT(*) FROM Telemetry_event;
SELECT COUNT (*) FROM Telemetry_event WHERE game_id = 4;

--PRUEBAS
SELECT g.player_name, COUNT(t.telemetry_id) AS total_eventos
FROM Game g
LEFT JOIN Telemetry_event t ON g.game_id = t.game_id
GROUP BY g.player_name;

SELECT * FROM Game;

-- Encuestas
-- Crear tablas necesarias 

CREATE TABLE Player (
    player_id SERIAL PRIMARY KEY,
    alias VARCHAR(50),
    role VARCHAR(50),
    user_id INT REFERENCES "User"(user_id)
);

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
    game_id INT, -- se relacionaría con Game(game_id)
    item_id INT REFERENCES UX_item(item_id)
);

-- Insertar datos a las tablas

-- Usuarios
INSERT INTO "User" (gender, age, experience_level, consent)
VALUES
('Female', 22, 'Intermediate', TRUE),
('Female', 21, 'Intermediate', TRUE),
('Female', 23, 'Beginner', TRUE),
('Female', 22, 'Advanced', TRUE);

-- Jugadores
INSERT INTO Player (alias, role, user_id)
VALUES
('Valentina', 'Player', 1),
('Natalia', 'Player', 2),
('Vanesa', 'Player', 3),
('Sofia', 'Player', 4);

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


