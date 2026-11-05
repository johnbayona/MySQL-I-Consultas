# Orden lógico de ejecución de una consulta SELECT en MySQL

**Aplicación:** cinco prácticas empresariales de SQL · **Motor:** MySQL 8.0.16 o superior.

En SQL, el **orden de escritura** de una consulta es distinto del **orden lógico de evaluación** que utilizamos para explicar cómo se obtiene el resultado. El optimizador de MySQL puede ejecutar físicamente las operaciones en otra secuencia: los pasos siguientes son una guía para razonar, no una traza del motor.

## 1. Orden en el que escribimos la consulta

```sql
SELECT
    d.name AS departamento,
    COUNT(e.id) AS total_empleados
FROM departments AS d
JOIN employees AS e
    ON d.id = e.department_id
WHERE e.status = 'ACTIVO'
GROUP BY d.id, d.name
HAVING COUNT(e.id) >= 2
ORDER BY total_empleados DESC
LIMIT 3;
```

El ejemplo se puede ejecutar en **`assetcontrol`** después de cargar `01_base_datos.sql`. Los nombres de base, tablas y columnas están en inglés, minúsculas y `snake_case`. Los **datos comerciales** (`'ACTIVO'`, nombres de empleados, áreas) y los **alias de presentación** se muestran en español.

## 2. Orden lógico para interpretar el resultado

| Paso | Cláusula | ¿Qué hace? |
|---|---|---|
| 1 | `FROM` | Identifica la tabla o conjunto base. |
| 2 | `JOIN ... ON` | Relaciona las tablas utilizando sus claves (por ejemplo, `e.department_id = d.id`). |
| 3 | `WHERE` | Filtra **filas individuales** antes de agrupar. |
| 4 | `GROUP BY` | Crea grupos, por ejemplo, uno por departamento. |
| 5 | `HAVING` | Filtra **grupos** usando resultados agregados como `COUNT` o `SUM`. |
| 6 | `SELECT` | Define las columnas y expresiones que se devuelven al usuario. |
| 7 | `DISTINCT` | Si se escribió, elimina duplicados de las columnas seleccionadas. |
| 8 | `ORDER BY` | Ordena las filas del resultado. |
| 9 | `LIMIT` | Deja únicamente la cantidad de filas solicitada. |

**Regla práctica:** `WHERE` selecciona registros; `HAVING` selecciona grupos.

## 3. SELECT, FROM, JOIN y alias

```sql
USE assetcontrol;

SELECT
    a.id AS codigo_equipo,
    a.brand AS marca,
    at.name AS tipo_equipo,
    a.status AS estado
FROM assets AS a
JOIN asset_types AS at
    ON a.asset_type_id = at.id;
```

- `a` es un **alias de tabla** que representa `assets`.
- `at` representa `asset_types`.
- La condición `ON` conecta la clave foránea `assets.asset_type_id` con la clave primaria `asset_types.id`.
- `AS tipo_equipo` es un **alias de columna visible**. No cambia el nombre real de la columna en la base de datos.
- `JOIN` sin calificativo representa un `INNER JOIN`: solo conserva filas con coincidencia.

## 4. WHERE y operadores

```sql
SELECT a.id AS codigo_equipo, a.brand AS marca, a.status AS estado
FROM assets AS a
WHERE a.status = 'DISPONIBLE'
    AND (a.brand = 'HP' OR a.brand = 'Epson')
ORDER BY a.brand;
```

Otros ejemplos para practicar:

```sql
-- Comparación y rango
SELECT * FROM maintenance WHERE cost >= 100000;
SELECT * FROM assets WHERE purchase_date BETWEEN '2025-01-01' AND '2025-12-31';

-- Búsqueda parcial y lista
SELECT * FROM employees WHERE name LIKE '%Ana%';
SELECT * FROM assets WHERE status IN ('DISPONIBLE', 'MANTENIMIENTO');

-- Valores nulos
SELECT * FROM assignments WHERE return_date IS NULL;
SELECT * FROM assignments WHERE return_date IS NOT NULL;
```

`AND` tiene mayor precedencia que `OR`: utiliza paréntesis siempre que se combinen y pueda existir ambigüedad. `BETWEEN` incluye los dos extremos; para periodos `DATETIME`, especifica la hora del fin de día o prefiere un intervalo semiabierto (`started_at >= '2026-09-01' AND started_at < '2026-10-01'`). Nunca uses `= NULL` para encontrar ausencias de valor.

## 5. GROUP BY frente a HAVING

```sql
-- Contar todos los equipos, agrupados por estado.
SELECT status AS estado, COUNT(*) AS total_equipos
FROM assets
GROUP BY status;

-- Mantener solo tipos de equipo con dos o mas activos.
SELECT at.name AS tipo_equipo, COUNT(a.id) AS cantidad
FROM asset_types AS at
JOIN assets AS a ON at.id = a.asset_type_id
GROUP BY at.id, at.name
HAVING COUNT(a.id) >= 2
ORDER BY cantidad DESC;
```

Usa `WHERE` para filtrar valores antes de `GROUP BY`, pero `HAVING` para condiciones como `COUNT(*) >= 2`, `SUM(cost) > 100000` o `AVG(cost) > 200000` después de agrupar. No escribas `WHERE COUNT(*) > 2`.

En MySQL con `ONLY_FULL_GROUP_BY` activo, toda columna seleccionada que no esté dentro de una función de agregación debe aparecer en el agrupamiento o estar funcionalmente determinada por éste. En los solucionarios las columnas no agregadas se agrupan explícitamente.

## 6. LEFT JOIN y resultados sin coincidencia

```sql
-- Incluye empleados con CERO asignaciones vigentes.
SELECT e.name AS empleado, COUNT(a.id) AS equipos_vigentes
FROM employees AS e
LEFT JOIN assignments AS a
    ON e.id = a.employee_id
    AND a.return_date IS NULL
GROUP BY e.id, e.name
ORDER BY equipos_vigentes DESC;
```

La diferencia con `JOIN` es que `LEFT JOIN` conserva los registros de la izquierda incluso cuando no tienen una fila correspondiente a la derecha. Observa que el filtro de asignación vigente está en `ON`; desplazarlo sin analizarlo a `WHERE` puede cambiar el resultado para los empleados sin equipos vigentes.

## 7. ORDER BY, LIMIT y funciones de agregación

```sql
-- Los tres mantenimientos con mayor costo.
SELECT id AS codigo_mantenimiento, description AS descripcion, cost AS costo
FROM maintenance
ORDER BY cost DESC, id
LIMIT 3;
```

`ORDER BY cost DESC` ordena de mayor a menor. El segundo campo `id` sirve para que el orden sea estable cuando dos costos son iguales. Si usas `LIMIT` sin `ORDER BY`, **no queda garantizado** cuáles registros recibirás.

## 8. Subconsultas: tres patrones

```sql
-- Subconsulta escalar: costo superior al promedio.
SELECT id, cost
FROM maintenance
WHERE cost > (SELECT AVG(cost) FROM maintenance);

-- Subconsulta IN: empleados con alguna asignacion vigente.
SELECT id, name
FROM employees
WHERE id IN (
    SELECT employee_id
    FROM assignments
    WHERE return_date IS NULL
);

-- Subconsulta correlacionada NOT EXISTS: activos sin mantenimiento.
SELECT a.id, a.brand
FROM assets AS a
WHERE NOT EXISTS (
    SELECT 1
    FROM maintenance AS m
    WHERE m.asset_id = a.id
);
```

Una subconsulta tiene a su vez su propio `FROM`, `WHERE` y demás pasos lógicos. La tercera utiliza `a.id` de la consulta exterior y, por tanto, es una subconsulta **correlacionada**.

## 9. Errores frecuentes en el laboratorio

1. Escribir `JOIN` sin `ON`, formando relaciones equivocadas o productos cartesianos.
2. Confundir `WHERE` y `HAVING`.
3. Usar `= NULL` en lugar de `IS NULL`.
4. Mezclar `AND` y `OR` sin paréntesis.
5. Elegir columnas de tablas distintas sin prefijos cuando ambas tienen `id`, `name` o `status`.
6. Escribir un `LIMIT` sin un `ORDER BY` y esperar un conjunto de filas específico.
7. Modificar las semillas con los ejemplos opcionales de `DELETE` o `TRUNCATE` antes de validar el DQL.

**Secuencia de práctica recomendada:** primero resolver las consultas 01–05 (filtros), luego 06–08 (JOIN), 09–17 (agregaciones y combinaciones) y finalmente 18–20 (subconsultas).

**Fuentes técnicas oficiales:** [MySQL 8.4 — SELECT](https://dev.mysql.com/doc/refman/8.4/en/select.html), [MySQL 8.4 — GROUP BY](https://dev.mysql.com/doc/refman/8.4/en/group-by-handling.html) y [MySQL 8.4 — JOIN](https://dev.mysql.com/doc/refman/8.4/en/join.html).
