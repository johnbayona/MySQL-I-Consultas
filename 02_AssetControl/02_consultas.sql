-- ============================================================
-- ASSETCONTROL | ESTUDIANTES - ESPACIOS PARA RESOLVER
-- Archivo 02/02 - 20 ejercicios DQL
-- Base de datos: assetcontrol
-- Instrucciones: ejecutar primero el archivo 01_base_datos.sql.
-- Consultas 18, 19 y 20: obligatoriamente con subconsultas.
-- No modificar los datos semilla durante esta evaluacion.
-- Alias y etiquetas visibles al cliente pueden estar en espanol.
-- ============================================================

USE assetcontrol;

-- EJEMPLO DE CLASE (no calificable)
SELECT
    a.id AS codigo_activo,
    a.brand AS marca,
    a.model AS modelo,
    a.status AS estado
FROM assets AS a;


-- ------------------------------------------------------------
-- 01. Mostrar el código, marca, modelo y estado de todos los activos, como se trabajó en clase.
-- Escribe tu SELECT aqui:
SELECT
    id AS codigo_activo,
    brand AS marca,
    model AS modelo,
    status AS estado
FROM assets
ORDER BY id;




-- ------------------------------------------------------------
-- 02. Mostrar cada equipo junto con el nombre de su tipo. Usar alias a y at y un JOIN.
-- Escribe tu SELECT aqui:
SELECT
    a.id AS codigo_activo,
    a.brand AS marca,
    a.model AS modelo,
    at.name AS tipo
FROM assets AS a
JOIN asset_types AS at ON a.asset_type_id = at.id;




-- ------------------------------------------------------------
-- 03. Filtrar los equipos DISPONIBLES que sean de tipo Portátil o Proyector.
-- Escribe tu SELECT aqui:

SELECT
    a.id AS codigo_activo,
    a.brand AS marca,
    a.model AS modelo,
    at.name AS tipo,
    a.status AS estado
FROM assets AS a
JOIN asset_types AS at ON a.asset_type_id = at.id
WHERE a.status = 'DISPONIBLE' AND (at.name = 'Portátil' OR at.name = 'Proyector')
ORDER BY a.id;



-- ------------------------------------------------------------
-- 04. Listar los empleados ACTIVOS del departamento Tecnología, con el nombre del departamento. Ordenar por empleado descendente.
-- Escribe tu SELECT aqui:
SELECT
    e.id AS codigo_empleado,
    e.name AS nombre,
    d.name AS departamento,
    e.status AS estado
FROM employees AS e
JOIN departments AS d ON e.department_id = d.id
WHERE e.status = 'ACTIVO' AND d.name = 'Tecnología'
ORDER BY e.name DESC, e.id;




-- ------------------------------------------------------------
-- 05. Listar los equipos comprados entre el 1 de enero de 2025 y el 31 de diciembre de 2025.
-- Escribe tu SELECT aqui:
SELECT
    id AS codigo_activo,
    brand AS marca,
    model AS modelo,
    purchase_date AS fecha_compra
FROM assets
WHERE purchase_date BETWEEN '2025-01-01' AND '2025-12-31'
ORDER BY purchase_date;




-- ------------------------------------------------------------
-- 06. Mostrar cada equipo junto a la sede y ciudad a las que pertenece.
-- Escribe tu SELECT aqui:
SELECT
    a.id AS codigo_activo,
    a.brand AS marca,
    a.model AS modelo,
    s.name AS sede,
    s.city AS ciudad
FROM assets AS a
JOIN sites AS s ON a.site_id = s.id;




-- ------------------------------------------------------------
-- 07. Mostrar los equipos que tienen una asignación vigente y el nombre del empleado que los tiene.
-- Escribe tu SELECT aqui:
SELECT
    a.id AS codigo_activo,
    a.brand AS marca,
    a.model AS modelo,
    m.ended_at AS fecha_fin_asignacion,
    e.name AS empleado
FROM assets AS a
JOIN assignments AS asg ON a.id = asg.asset_id
JOIN employees AS e ON asg.employee_id = e.id
JOIN maintenance AS m ON a.id = m.asset_id
ORDER BY a.id;



-- ------------------------------------------------------------
-- 08. Mostrar cada mantenimiento junto con el activo intervenido, el tipo y su costo.
-- Escribe tu SELECT aqui:
SELECT
    m.id AS codigo_mantenimiento,
    a.brand AS marca,
    a.model AS modelo,
    at.name AS tipo,
    m.cost AS costo
FROM maintenance AS m
JOIN assets AS a ON m.asset_id = a.id
JOIN asset_types AS at ON a.asset_type_id = at.id;




-- ------------------------------------------------------------
-- 09. Contar los equipos por estado, ordenados de mayor a menor cantidad.
-- Escribe tu SELECT aqui:
SELECT
    status AS estado,
    COUNT(*) AS total_equipos
FROM assets
GROUP BY status
ORDER BY total_equipos DESC, status;




-- ------------------------------------------------------------
-- 10. Contar los equipos registrados por sede, incluyendo sedes sin equipos. Usar LEFT JOIN.
-- Escribe tu SELECT aqui:
SELECT
    s.name AS sede,
    COUNT(a.id) AS total_equipos
FROM sites AS s
LEFT JOIN assets AS a ON s.id = a.site_id
GROUP BY s.name
ORDER BY total_equipos DESC, s.name;




-- ------------------------------------------------------------
-- 11. Calcular el costo total de mantenimientos por activo. Mostrar solo activos con mantenimiento.
-- Escribe tu SELECT aqui:
SELECT
    a.id AS codigo_activo,
    a.brand AS marca,
    a.model AS modelo,
    SUM(m.cost) AS costo_total_mantenimientos
FROM assets AS a
JOIN maintenance AS m ON a.id = m.asset_id
GROUP BY a.id, a.brand, a.model
ORDER BY costo_total_mantenimientos DESC, a.id; 




-- ------------------------------------------------------------
-- 12. Contar cuántos equipos vigentes tiene cada empleado, incluyendo los que no tienen ninguno.
-- Escribe tu SELECT aqui:
SELECT
    e.id AS codigo_empleado,
    e.name AS nombre,
    COUNT(asg.asset_id) AS total_equipos_vigentes
FROM employees AS e
LEFT JOIN assignments AS asg 
    ON e.id = asg.employee_id 
    AND asg.return_date IS NULL
GROUP BY e.id, e.name
ORDER BY total_equipos_vigentes DESC, e.name;




-- ------------------------------------------------------------
-- 13. Encontrar los tipos de equipo que tengan dos o más activos. Usar HAVING.
-- Escribe tu SELECT aqui:

SELECT
    at.name AS tipo,
    COUNT(a.id) AS total_activos
FROM asset_types AS at
JOIN assets AS a ON at.id = a.asset_type_id
GROUP BY at.name
HAVING COUNT(a.id) >= 2
ORDER BY total_activos DESC, at.name;



-- ------------------------------------------------------------
-- 14. Calcular el costo promedio de mantenimiento por tipo: PREVENTIVO o CORRECTIVO.
-- Escribe tu SELECT aqui:

SELECT
    m.type AS tipo_mantenimiento,
    AVG(m.cost) AS costo_promedio
FROM maintenance AS m
GROUP BY m.type
ORDER BY costo_promedio DESC, m.type;   



-- ------------------------------------------------------------
-- 15. Mostrar los tres mantenimientos más costosos, con su descripción y costo.
-- Escribe tu SELECT aqui:
SELECT
    id AS codigo_mantenimiento,
    description AS descripcion,
    cost AS costo
FROM maintenance
ORDER BY cost DESC
LIMIT 3;




-- ------------------------------------------------------------
-- 16. Consultar el nombre y departamento de quienes tienen equipos asignados actualmente.
-- Escribe tu SELECT aqui:
SELECT
    e.name AS nombre_empleado,
    d.name AS departamento
FROM employees AS e
JOIN departments AS d ON e.department_id = d.id
JOIN assignments AS asg ON e.id = asg.employee_id
WHERE asg.return_date IS NULL
GROUP BY e.name, d.name
ORDER BY e.name, d.name;




-- ------------------------------------------------------------
-- 17. Mostrar los activos que actualmente no tienen ninguna asignación abierta, usando LEFT JOIN e IS NULL.
-- Escribe tu SELECT aqui:
SELECT
    a.id AS codigo_activo,
    a.brand AS marca,
    a.model AS modelo
FROM assets AS a
LEFT JOIN assignments AS asg ON a.id = asg.asset_id AND asg.return_date IS NULL
WHERE asg.asset_id IS NULL
ORDER BY a.id, a.brand, a.model;




-- ------------------------------------------------------------
-- 18 | SUBCONSULTA. SUBCONSULTA: mostrar mantenimientos con costo superior al costo promedio de todos los mantenimientos.
-- Escribe tu SELECT aqui:
SELECT
    id AS codigo_mantenimiento,
    description AS descripcion,
    cost AS costo
FROM maintenance
WHERE cost > (SELECT AVG(cost) FROM maintenance)
ORDER BY cost DESC, id; 




-- ------------------------------------------------------------
-- 19 | SUBCONSULTA. SUBCONSULTA: buscar empleados que figuren en asignaciones vigentes mediante IN.
-- Escribe tu SELECT aqui:
SELECT
    e.id AS codigo_empleado,
    e.name AS nombre,
    d.name AS departamento
FROM employees AS e
JOIN departments AS d ON e.department_id = d.id
WHERE e.id IN (SELECT employee_id FROM assignments WHERE return_date IS NULL)
ORDER BY e.name, d.name;    




-- ------------------------------------------------------------
-- 20 | SUBCONSULTA. SUBCONSULTA: encontrar activos que nunca han tenido un mantenimiento mediante NOT EXISTS.
-- Escribe tu SELECT aqui:
SELECT
    a.id AS codigo_activo,
    a.brand AS marca,
    a.model AS modelo
FROM assets AS a    
WHERE NOT EXISTS (SELECT 1 FROM maintenance AS m WHERE m.asset_id = a.id)
ORDER BY a.id, a.brand, a.model;    


