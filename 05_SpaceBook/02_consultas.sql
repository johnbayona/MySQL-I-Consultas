-- ============================================================
-- SPACEBOOK | ESTUDIANTES - ESPACIOS PARA RESOLVER
-- Archivo 02/02 - 20 ejercicios DQL
-- Base de datos: spacebook
-- Instrucciones: ejecutar primero el archivo 01_base_datos.sql.
-- Consultas 18, 19 y 20: obligatoriamente con subconsultas.
-- No modificar los datos semilla durante esta evaluacion.
-- Alias y etiquetas visibles al cliente pueden estar en espanol.
-- ============================================================

USE spacebook;

-- EJEMPLO DE CLASE (no calificable)
SELECT
    r.id AS codigo_sala,
    r.name AS sala,
    r.capacity AS capacidad
FROM rooms AS r;


-- ------------------------------------------------------------
-- 01. Mostrar código, nombre, capacidad y estado de todas las salas.
-- Escribe tu SELECT aqui:
SELECT
    id AS Codigo_sala,
    name AS Sala,
    capacity AS Capacidad,
    status AS Estado
FROM rooms;


-- ------------------------------------------------------------
-- 02. Buscar salas ACTIVAS con capacidad entre 6 y 12 personas.
-- Escribe tu SELECT aqui:
SELECT
    id AS Codigo_sala,
    name AS Sala,
    capacity AS Capacidad,
    status AS Estado
FROM rooms
WHERE status = 'ACTIVA'
    AND capacity BETWEEN 6 AND 12;


-- ------------------------------------------------------------
-- 03. Mostrar los recursos DISPONIBLES de tipo PROYECTOR o AUDIO. Usar IN.
-- Escribe tu SELECT aqui:
SELECT
    code AS Codigo_recurso,
    name AS Recurso,
    type AS Tipo,
    status AS Estado
FROM resources
WHERE status = 'DISPONIBLE'
    AND type IN ('PROYECTOR', 'AUDIO');


-- ------------------------------------------------------------
-- 04. Mostrar las tres reservas que comienzan primero según la fecha y hora de inicio.
-- Escribe tu SELECT aqui:
SELECT
    id AS Codigo_reserva,
    started_at AS Fecha_inicio,
    ended_at AS Fecha_fin,
    reason AS Motivo,
    status AS Estado
FROM reservations
ORDER BY started_at, id
LIMIT 3;


-- ------------------------------------------------------------
-- 05. Buscar salas cuyo nombre contenga Sur o Ágora. Usar LIKE y OR.
-- Escribe tu SELECT aqui:
SELECT
    id AS Codigo_sala,
    name AS Sala
FROM rooms
WHERE name LIKE '%Sur%' OR name LIKE '%Ágora%';


-- ------------------------------------------------------------
-- 06. Mostrar cada sala con su sede y ciudad.
-- Escribe tu SELECT aqui:
SELECT
    r.id AS Codigo_sala,
    r.name AS Sala,
    s.name AS Sede,
    s.city AS Ciudad
FROM rooms AS r
JOIN sites AS s ON r.site_id = s.id;


-- ------------------------------------------------------------
-- 07. Mostrar cada reserva con el nombre de la sala y del organizador.
-- Escribe tu SELECT aqui:
SELECT
    re.id AS Codigo_reserva,
    r.name AS Sala,
    e.name AS Organizador
FROM reservations AS re
JOIN rooms AS r ON re.room_id = r.id
JOIN employees AS e ON re.organizer_id = e.id;


-- ------------------------------------------------------------
-- 08. Contar reservas por sala, incluyendo salas sin ninguna reserva. Usar LEFT JOIN.
-- Escribe tu SELECT aqui:
SELECT
    r.id AS Codigo_sala,
    r.name AS Sala,
    COUNT(re.id) AS Cantidad_reservas
FROM rooms AS r
LEFT JOIN reservations AS re ON r.id = re.room_id
GROUP BY r.id, r.name
ORDER BY r.id;


-- ------------------------------------------------------------
-- 09. Contar las reservas por estado.
-- Escribe tu SELECT aqui:
SELECT
    status AS Estado,
    COUNT(*) AS Cantidad_reservas
FROM reservations
GROUP BY status;


-- ------------------------------------------------------------
-- 10. Encontrar salas que tengan al menos dos reservas registradas. Usar HAVING.
-- Escribe tu SELECT aqui:
SELECT
    r.id AS Codigo_sala,
    r.name AS Sala,
    COUNT(re.id) AS Cantidad_reservas
FROM rooms AS r
JOIN reservations AS re ON r.id = re.room_id
GROUP BY r.id, r.name
HAVING COUNT(re.id) >= 2
ORDER BY r.id;


-- ------------------------------------------------------------
-- 11. Mostrar el número de reservas CONFIRMADAS por sala, sin incluir los demás estados.
-- Escribe tu SELECT aqui:
SELECT
    r.id AS Codigo_sala,
    r.name AS Sala,
    COUNT(re.id) AS Cantidad_confirmadas
FROM rooms AS r
JOIN reservations AS re ON r.id = re.room_id
WHERE re.status = 'CONFIRMADA'
GROUP BY r.id, r.name
ORDER BY r.id;


-- ------------------------------------------------------------
-- 12. Mostrar los empleados invitados a cada reserva, indicando motivo y respuesta.
-- Escribe tu SELECT aqui:
SELECT
    re.id AS Codigo_reserva,
    e.name AS Empleado,
    re.reason AS Motivo,
    rp.response AS Respuesta
FROM reservation_participants AS rp
JOIN reservations AS re ON rp.reservation_id = re.id
JOIN employees AS e ON rp.employee_id = e.id
ORDER BY re.id, e.id;


-- ------------------------------------------------------------
-- 13. Listar reservas CONFIRMADAS del 3 de noviembre de 2026. Usar BETWEEN.
-- Escribe tu SELECT aqui:
SELECT
    id AS Codigo_reserva,
    room_id AS Codigo_sala,
    started_at AS Fecha_inicio,
    ended_at AS Fecha_fin,
    reason AS Motivo,
    status AS Estado
FROM reservations
WHERE status = 'CONFIRMADA'
    AND started_at BETWEEN '2026-11-03 00:00:00' AND '2026-11-03 23:59:59'
ORDER BY started_at, id;


-- ------------------------------------------------------------
-- 14. Mostrar recursos asociados a reservas, indicando el organizador de la reserva.
-- Escribe tu SELECT aqui:
SELECT
    re.id AS Codigo_reserva,
    r.code AS Codigo_recurso,
    r.name AS Recurso,
    e.name AS Organizador
FROM reservation_resources AS rr
JOIN resources AS r ON rr.resource_id = r.id
JOIN reservations AS re ON rr.reservation_id = re.id
JOIN employees AS e ON re.organizer_id = e.id
ORDER BY re.id, r.id;


-- ------------------------------------------------------------
-- 15. Contar participantes invitados por reserva, incluyendo reservas sin participantes.
-- Escribe tu SELECT aqui:
SELECT
    re.id AS Codigo_reserva,
    re.reason AS Motivo,
    COUNT(rp.employee_id) AS Cantidad_invitados
FROM reservations AS re
LEFT JOIN reservation_participants AS rp ON re.id = rp.reservation_id
GROUP BY re.id, re.reason
ORDER BY re.id;


-- ------------------------------------------------------------
-- 16. Mostrar los bloqueos de salas junto con la sede donde ocurren.
-- Escribe tu SELECT aqui:
SELECT
    rb.id AS Codigo_bloqueo,
    r.name AS Sala,
    s.name AS Sede,
    rb.started_at AS Fecha_inicio,
    rb.ended_at AS Fecha_fin,
    rb.reason AS Motivo
FROM room_blocks AS rb
JOIN rooms AS r ON rb.room_id = r.id
JOIN sites AS s ON r.site_id = s.id
ORDER BY rb.id;


-- ------------------------------------------------------------
-- 17. Encontrar empleados con dos o más invitaciones ACEPTADA. Usar HAVING.
-- Escribe tu SELECT aqui:
SELECT
    e.code AS Codigo_empleado,
    e.name AS Empleado,
    COUNT(*) AS Cantidad_aceptadas
FROM employees AS e
JOIN reservation_participants AS rp ON e.id = rp.employee_id
WHERE rp.response = 'ACEPTADA'
GROUP BY e.id, e.code, e.name
HAVING COUNT(*) >= 2
ORDER BY e.id;


-- ------------------------------------------------------------
-- 18 | SUBCONSULTA. SUBCONSULTA: encontrar empleados que nunca han organizado una reserva. Usar NOT EXISTS.
-- Escribe tu SELECT aqui:
SELECT
    e.code AS Codigo_empleado,
    e.name AS Empleado
FROM employees AS e
WHERE NOT EXISTS (
    SELECT 1
    FROM reservations AS re
    WHERE re.organizer_id = e.id
);


-- ------------------------------------------------------------
-- 19 | SUBCONSULTA. SUBCONSULTA: mostrar salas cuya capacidad sea mayor al promedio de capacidades de todas las salas.
-- Escribe tu SELECT aqui:
SELECT
    r.id AS Codigo_sala,
    r.name AS Sala,
    r.capacity AS Capacidad
FROM rooms AS r
WHERE r.capacity > (
    SELECT AVG(capacity)
    FROM rooms
);


-- ------------------------------------------------------------
-- 20 | SUBCONSULTA. SUBCONSULTA: listar recursos nunca solicitados en una reserva CONFIRMADA. Usar NOT EXISTS.
-- Escribe tu SELECT aqui:
SELECT
    r.code AS Codigo_recurso,
    r.name AS Recurso,
    r.type AS Tipo,
    r.status AS Estado
FROM resources AS r
WHERE NOT EXISTS (
    SELECT 1
    FROM reservation_resources AS rr
    JOIN reservations AS re ON rr.reservation_id = re.id
    WHERE rr.resource_id = r.id
        AND re.status = 'CONFIRMADA'
);