-- ============================================================
-- TALENTTRACK | ESTUDIANTES - ESPACIOS PARA RESOLVER
-- Archivo 02/02 - 20 ejercicios DQL
-- Base de datos: talenttrack
-- Instrucciones: ejecutar primero el archivo 01_base_datos.sql.
-- Consultas 18, 19 y 20: obligatoriamente con subconsultas.
-- No modificar los datos semilla durante esta evaluacion.
-- Alias y etiquetas visibles al cliente pueden estar en espanol.
-- ============================================================

USE talenttrack;

-- EJEMPLO DE CLASE (no calificable)
SELECT
    c.id AS codigo_curso,
    c.name AS curso,
    c.duration_hours AS horas
FROM courses AS c;


-- ------------------------------------------------------------
-- 01. Mostrar código, nombre y duración en horas de todos los cursos.
-- Escribe tu SELECT aqui:
SELECT
    code AS Codigo,
    name AS Curso,
    duration_hours AS Horas
FROM courses;


-- ------------------------------------------------------------
-- 02. Listar ediciones en estado ABIERTA o EN_CURSO cuya fecha de inicio sea desde septiembre de 2026.
-- Escribe tu SELECT aqui:
SELECT
    code AS Edicion,
    start_date AS Fecha_inicio,
    status AS Estado
FROM editions
WHERE (status = 'ABIERTA' OR status = 'EN_CURSO')
    AND start_date >= '2026-09-01';


-- ------------------------------------------------------------
-- 03. Mostrar colaboradores ACTIVO de empresas cuyo nombre contenga SAS. Usar JOIN y LIKE.
-- Escribe tu SELECT aqui:
SELECT
    c.id AS Codigo_colaborador,
    c.name AS Colaborador,
    co.company_name AS Empresa
FROM collaborators AS c
JOIN companies AS co ON c.company_id = co.id
WHERE c.status = 'ACTIVO'
    AND co.company_name LIKE '%SAS%';


-- ------------------------------------------------------------
-- 04. Mostrar las tres ediciones con fecha de inicio más reciente. Usar LIMIT.
-- Escribe tu SELECT aqui:
SELECT
    code AS Edicion,
    start_date AS Fecha_inicio
FROM editions
ORDER BY start_date DESC, id
LIMIT 3;


-- ------------------------------------------------------------
-- 05. Buscar cursos cuyo nombre incluya IA o datos. Usar LIKE y OR.
-- Escribe tu SELECT aqui:
SELECT
    code AS Codigo,
    name AS Curso
FROM courses
WHERE name LIKE '%IA%' OR name LIKE '%datos%';


-- ------------------------------------------------------------
-- 06. Mostrar cada edición junto con el nombre del curso y el instructor que la imparte.
-- Escribe tu SELECT aqui:
SELECT
    e.code AS Edicion,
    c.name AS Curso,
    i.name AS Instructor
FROM editions AS e
JOIN courses AS c ON e.course_id = c.id
JOIN instructors AS i ON e.instructor_id = i.id;


-- ------------------------------------------------------------
-- 07. Relacionar cada matrícula con colaborador, empresa y edición.
-- Escribe tu SELECT aqui:
SELECT
    en.id AS Codigo_matricula,
    c.name AS Colaborador,
    co.company_name AS Empresa,
    e.code AS Edicion
FROM enrollments AS en
JOIN collaborators AS c ON en.collaborator_id = c.id
JOIN companies AS co ON c.company_id = co.id
JOIN editions AS e ON en.edition_id = e.id;


-- ------------------------------------------------------------
-- 08. Contar los matriculados por edición, incluyendo ediciones sin inscritos. Usar LEFT JOIN.
-- Escribe tu SELECT aqui:
SELECT
    e.code AS Edicion,
    COUNT(en.id) AS Cantidad_matriculados
FROM editions AS e
LEFT JOIN enrollments AS en ON e.id = en.edition_id
GROUP BY e.id, e.code
ORDER BY e.id;


-- ------------------------------------------------------------
-- 09. Contar matrículas agrupadas por su estado.
-- Escribe tu SELECT aqui:
SELECT
    status AS Estado,
    COUNT(*) AS Cantidad_matriculas
FROM enrollments
GROUP BY status;


-- ------------------------------------------------------------
-- 10. Encontrar los cursos que se han ofrecido en dos o más ediciones. Usar HAVING.
-- Escribe tu SELECT aqui:
SELECT
    c.code AS Codigo_curso,
    c.name AS Curso,
    COUNT(e.id) AS Cantidad_ediciones
FROM courses AS c
JOIN editions AS e ON c.id = e.course_id
GROUP BY c.id, c.code, c.name
HAVING COUNT(e.id) >= 2;


-- ------------------------------------------------------------
-- 11. Contar las sesiones programadas en cada edición.
-- Escribe tu SELECT aqui:
SELECT
    e.code AS Edicion,
    COUNT(s.id) AS Cantidad_sesiones
FROM editions AS e
LEFT JOIN sessions AS s ON e.id = s.edition_id
GROUP BY e.id, e.code
ORDER BY e.id;


-- ------------------------------------------------------------
-- 12. Mostrar los certificados emitidos junto al nombre del colaborador y el curso.
-- Escribe tu SELECT aqui:
SELECT
    ce.code AS Certificado,
    ce.issued_at AS Fecha_emision,
    c.name AS Colaborador,
    cu.name AS Curso
FROM certificates AS ce
JOIN enrollments AS en ON ce.enrollment_id = en.id
JOIN collaborators AS c ON en.collaborator_id = c.id
JOIN editions AS e ON en.edition_id = e.id
JOIN courses AS cu ON e.course_id = cu.id;


-- ------------------------------------------------------------
-- 13. Mostrar las sesiones realizadas durante septiembre de 2026, junto a su edición.
-- Escribe tu SELECT aqui:
SELECT
    s.id AS Codigo_sesion,
    s.topic AS Tema,
    s.started_at AS Fecha_inicio,
    s.ended_at AS Fecha_fin,
    e.code AS Edicion
FROM sessions AS s
JOIN editions AS e ON s.edition_id = e.id
WHERE s.started_at >= '2026-09-01'
    AND s.started_at < '2026-10-01'
ORDER BY s.started_at, s.id;


-- ------------------------------------------------------------
-- 14. Mostrar todas las asistencias registradas con el colaborador, tema de la sesión y estado.
-- Escribe tu SELECT aqui:
SELECT
    a.id AS Codigo_asistencia,
    c.name AS Colaborador,
    s.topic AS Tema,
    a.status AS Estado
FROM attendance AS a
JOIN enrollments AS en ON a.enrollment_id = en.id
JOIN collaborators AS c ON en.collaborator_id = c.id
JOIN sessions AS s ON a.session_id = s.id
ORDER BY a.id;


-- ------------------------------------------------------------
-- 15. Contar cuántas asistencias PRESENTE registra cada matrícula con registros de asistencia.
-- Escribe tu SELECT aqui:
SELECT
    en.id AS Codigo_matricula,
    SUM(CASE WHEN a.status = 'PRESENTE' THEN 1 ELSE 0 END) AS Cantidad_presentes
FROM enrollments AS en
JOIN attendance AS a ON en.id = a.enrollment_id
GROUP BY en.id
ORDER BY en.id;


-- ------------------------------------------------------------
-- 16. Mostrar ediciones con al menos dos matriculados e indicar su capacidad. Usar HAVING.
-- Escribe tu SELECT aqui:
SELECT
    e.code AS Edicion,
    e.capacity AS Capacidad,
    COUNT(en.id) AS Cantidad_matriculados
FROM editions AS e
JOIN enrollments AS en ON e.id = en.edition_id
GROUP BY e.id, e.code, e.capacity
HAVING COUNT(en.id) >= 2
ORDER BY e.id;


-- ------------------------------------------------------------
-- 17. Mostrar matrículas cuya asistencia registrada tenga al menos 80% PRESENTE. Usar GROUP BY y HAVING.
-- Escribe tu SELECT aqui:
SELECT
    en.id AS Codigo_matricula,
    COUNT(a.id) AS Cantidad_registros,
    SUM(CASE WHEN a.status = 'PRESENTE' THEN 1 ELSE 0 END) AS Cantidad_presentes,
    100.0 * SUM(CASE WHEN a.status = 'PRESENTE' THEN 1 ELSE 0 END)
        / COUNT(a.id) AS Porcentaje_presente
FROM enrollments AS en
JOIN attendance AS a ON en.id = a.enrollment_id
GROUP BY en.id
HAVING 100.0 * SUM(CASE WHEN a.status = 'PRESENTE' THEN 1 ELSE 0 END)
        / COUNT(a.id) >= 80
ORDER BY en.id;


-- ------------------------------------------------------------
-- 18 | SUBCONSULTA. SUBCONSULTA: encontrar colaboradores que todavía no se han matriculado en ninguna edición. Usar NOT EXISTS.
-- Escribe tu SELECT aqui:
SELECT
    c.id AS Codigo_colaborador,
    c.name AS Colaborador
FROM collaborators AS c
WHERE NOT EXISTS (
    SELECT 1
    FROM enrollments AS en
    WHERE en.collaborator_id = c.id
);


-- ------------------------------------------------------------
-- 19 | SUBCONSULTA. SUBCONSULTA: mostrar ediciones cuya capacidad sea mayor al promedio de capacidades de las ediciones.
-- Escribe tu SELECT aqui:
SELECT
    e.code AS Edicion,
    e.capacity AS Capacidad
FROM editions AS e
WHERE e.capacity > (
    SELECT AVG(capacity)
    FROM editions
);


-- ------------------------------------------------------------
-- 20 | SUBCONSULTA. SUBCONSULTA: mostrar colaboradores que estén matriculados en alguna edición del curso con código CUR-IA. Usar IN.
-- Escribe tu SELECT aqui:
SELECT
    c.id AS Codigo_colaborador,
    c.name AS Colaborador
FROM collaborators AS c
WHERE c.id IN (
    SELECT en.collaborator_id
    FROM enrollments AS en
    JOIN editions AS e ON en.edition_id = e.id
    JOIN courses AS cu ON e.course_id = cu.id
    WHERE cu.code = 'CUR-IA'
);