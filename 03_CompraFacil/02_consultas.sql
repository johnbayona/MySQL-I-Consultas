-- ============================================================
-- COMPRAFÁCIL | ESTUDIANTES - ESPACIOS PARA RESOLVER
-- Archivo 02/02 - 20 ejercicios DQL
-- Base de datos: comprafacil
-- Instrucciones: ejecutar primero el archivo 01_base_datos.sql.
-- Consultas 18, 19 y 20: obligatoriamente con subconsultas.
-- No modificar los datos semilla durante esta evaluacion.
-- Alias y etiquetas visibles al cliente pueden estar en espanol.
-- ============================================================

USE comprafacil;

-- EJEMPLO DE CLASE (no calificable)
SELECT
    p.id AS codigo_producto,
    p.name AS producto,
    p.active AS activo
FROM products AS p;


-- ------------------------------------------------------------
-- 01. Mostrar el código, nombre y correo de los empleados que pueden solicitar compras.
-- Escribe tu SELECT aqui:
SELECT
    e.id AS codigo_empleado,
    e.name AS nombre_empleado,
    e.email AS correo_empleado
FROM employees AS e;




-- ------------------------------------------------------------
-- 02. Mostrar los productos activos y su unidad de medida. Usar WHERE.
-- Escribe tu SELECT aqui:
SELECT
    p.id AS codigo_producto,
    p.name AS nombre_producto,
    p.unit_of_measure AS unidad_medida
FROM products AS p
WHERE p.active = 1;




-- ------------------------------------------------------------
-- 03. Listar órdenes con estado PARCIAL o EMITIDA. Usar OR.
-- Escribe tu SELECT aqui:
SELECT
    o.id AS codigo_orden,
    o.status AS estado_orden,
    o.issued_at AS fecha_creacion
FROM purchase_orders AS o
WHERE o.status = 'PARCIAL' OR o.status = 'EMITIDA';


-- ------------------------------------------------------------
-- 04. Mostrar las solicitudes creadas entre el 1 y el 5 de septiembre de 2026. Usar BETWEEN.
-- Escribe tu SELECT aqui:
SELECT
    r.id AS codigo_solicitud,
    r.created_at AS fecha_creacion,
    r.status AS estado_solicitud
FROM requests AS r
WHERE r.created_at BETWEEN '2026-09-01' AND '2026-09-05';




-- ------------------------------------------------------------
-- 05. Buscar productos cuyo nombre contenga Cable o Teclado. Usar LIKE.
-- Escribe tu SELECT aqui:
SELECT
    p.id AS codigo_producto,
    p.name AS nombre_producto,
    p.unit_of_measure AS unidad_medida
FROM products AS p
WHERE p.name LIKE '%Cable%' OR p.name LIKE '%Teclado%';



-- ------------------------------------------------------------
-- 06. Mostrar cada solicitud con el empleado que la creó, su fecha y estado.
-- Escribe tu SELECT aqui:

SELECT
    r.id AS codigo_solicitud,
    e.name AS nombre_empleado,
    r.created_at AS fecha_creacion,
    r.status AS estado_solicitud
FROM requests AS r
JOIN employees AS e ON r.employee_id = e.id;    



-- ------------------------------------------------------------
-- 07. Mostrar cada orden de compra junto con el proveedor y la justificación de la solicitud que originó la orden.
-- Escribe tu SELECT aqui:
SELECT
    po.id AS Codigo_orden,
    s.company_name AS Proveedor,
    r.justification AS Justificacion
FROM purchase_orders AS po
JOIN suppliers AS s ON po.supplier_id = s.id
JOIN requests AS r ON po.request_id = r.id
ORDER BY po.id;

-- ------------------------------------------------------------
-- 08. Mostrar productos y cantidades requeridas de cada solicitud. Usar JOIN.
SELECT
    ri.request_id AS Codigo_solicitud,
    p.name AS Producto,
    ri.requested_quantity AS Cantidad_requerida
FROM request_items AS ri
JOIN products AS p ON ri.product_id = p.id
ORDER BY ri.request_id, ri.id;

-- ------------------------------------------------------------
-- 09. Contar las solicitudes por estado.
SELECT status AS Estado, COUNT(*) AS Cantidad_solicitudes
FROM requests
GROUP BY status
ORDER BY status;

-- ------------------------------------------------------------
-- 10. Calcular el valor total de cada orden sumando cantidad ordenada multiplicada por precio unitario.
SELECT
    po.id AS Codigo_orden,
    COALESCE(SUM(oi.ordered_quantity * oi.unit_price), 0) AS Valor_total
FROM purchase_orders AS po
LEFT JOIN order_items AS oi ON po.id = oi.order_id
GROUP BY po.id
ORDER BY po.id;

-- ------------------------------------------------------------
-- 11. Mostrar cada recepción con su número de remisión y proveedor.
SELECT
    r.id AS Codigo_recepcion,
    r.delivery_note AS Remision,
    s.company_name AS Proveedor
FROM receipts AS r
JOIN purchase_orders AS po ON r.order_id = po.id
JOIN suppliers AS s ON po.supplier_id = s.id
ORDER BY r.id;

-- ------------------------------------------------------------
-- 12. Mostrar los productos recibidos, su cantidad recibida y la remisión correspondiente.
SELECT
    p.name AS Producto,
    rci.received_quantity AS Cantidad_recibida,
    r.delivery_note AS Remision
FROM receipt_items AS rci
JOIN receipts AS r ON rci.receipt_id = r.id
JOIN order_items AS oi ON rci.order_item_id = oi.id
JOIN request_items AS ri ON oi.request_item_id = ri.id
JOIN products AS p ON ri.product_id = p.id
ORDER BY rci.id;

-- ------------------------------------------------------------
-- 13. Calcular la cantidad pendiente por renglón de orden: cantidad ordenada menos lo recibido. Mostrar también los renglones sin recepción.
SELECT
    oi.order_id AS Codigo_orden,
    oi.id AS Codigo_renglon,
    p.name AS Producto,
    oi.ordered_quantity AS Cantidad_ordenada,
    COALESCE(SUM(rci.received_quantity), 0) AS Cantidad_recibida,
    oi.ordered_quantity - COALESCE(SUM(rci.received_quantity), 0) AS Cantidad_pendiente
FROM order_items AS oi
JOIN request_items AS ri ON oi.request_item_id = ri.id
JOIN products AS p ON ri.product_id = p.id
LEFT JOIN receipt_items AS rci ON oi.id = rci.order_item_id
GROUP BY oi.order_id, oi.id, p.id, p.name, oi.ordered_quantity
ORDER BY oi.order_id, oi.id;

-- ------------------------------------------------------------
-- 14. Contar las órdenes por proveedor, incluyendo proveedores que todavía no tienen órdenes.
SELECT
    s.id AS Codigo_proveedor,
    s.company_name AS Proveedor,
    COUNT(po.id) AS Cantidad_ordenes
FROM suppliers AS s
LEFT JOIN purchase_orders AS po ON s.id = po.supplier_id
GROUP BY s.id, s.company_name
ORDER BY s.id;

-- ------------------------------------------------------------
-- 15. Mostrar empleados que hayan realizado dos o más solicitudes. Usar HAVING.
SELECT
    e.code AS Codigo_empleado,
    e.name AS Empleado,
    COUNT(r.id) AS Cantidad_solicitudes
FROM employees AS e
JOIN requests AS r ON e.id = r.employee_id
GROUP BY e.id, e.code, e.name
HAVING COUNT(r.id) >= 2
ORDER BY e.id;

-- ------------------------------------------------------------
-- 16. Mostrar productos presentes en dos o más renglones de órdenes de compra.
SELECT
    p.id AS Codigo_producto,
    p.name AS Producto,
    COUNT(oi.id) AS Cantidad_renglones
FROM products AS p
JOIN request_items AS ri ON p.id = ri.product_id
JOIN order_items AS oi ON ri.id = oi.request_item_id
GROUP BY p.id, p.name
HAVING COUNT(oi.id) >= 2
ORDER BY p.id;

-- ------------------------------------------------------------
-- 17. Mostrar los tres renglones de órdenes con mayor valor total (cantidad por precio). Usar LIMIT.
SELECT
    oi.id AS Codigo_renglon,
    oi.order_id AS Codigo_orden,
    p.name AS Producto,
    oi.ordered_quantity AS Cantidad,
    oi.unit_price AS Precio_unitario,
    oi.ordered_quantity * oi.unit_price AS Valor_total
FROM order_items AS oi
JOIN request_items AS ri ON oi.request_item_id = ri.id
JOIN products AS p ON ri.product_id = p.id
ORDER BY Valor_total DESC, oi.id
LIMIT 3;

-- ------------------------------------------------------------
-- 18. SUBCONSULTA: encontrar renglones cuyo precio unitario sea superior al precio unitario promedio.
SELECT
    oi.id AS Codigo_renglon,
    oi.order_id AS Codigo_orden,
    oi.unit_price AS Precio_unitario
FROM order_items AS oi
WHERE oi.unit_price > (
    SELECT AVG(unit_price)
    FROM order_items
)
ORDER BY oi.id;

-- ------------------------------------------------------------
-- 19. SUBCONSULTA: listar productos que nunca han aparecido en una orden de compra. Usar NOT EXISTS.
SELECT
    p.id AS Codigo_producto,
    p.name AS Producto
FROM products AS p
WHERE NOT EXISTS (
    SELECT 1
    FROM request_items AS ri
    JOIN order_items AS oi ON ri.id = oi.request_item_id
    WHERE ri.product_id = p.id
)
ORDER BY p.id;

-- ------------------------------------------------------------
-- 20. SUBCONSULTA: listar proveedores que tengan al menos una orden PARCIAL. Usar IN.
SELECT
    s.id AS Codigo_proveedor,
    s.company_name AS Proveedor
FROM suppliers AS s
WHERE s.id IN (
    SELECT po.supplier_id
    FROM purchase_orders AS po
    WHERE po.status = 'PARCIAL'
)
ORDER BY s.id;


