# Examen práctico final — Análisis de información con MySQL 8.x

## Descripción del proyecto

Este proyecto corresponde al desarrollo del examen práctico final de MySQL 8.x, cuyo propósito es aplicar consultas SQL para analizar información y resolver diferentes necesidades de negocio mediante bases de datos relacionales.

Se desarrollaron diez ejercicios utilizando las bases de datos construidas durante los talleres, aplicando operaciones de consulta, relaciones entre tablas, agrupaciones, filtros y cálculos.

## Objetivo

Fortalecer las habilidades en consultas SQL mediante el análisis de información, la interpretación de requerimientos y la construcción de consultas que permitan obtener resultados precisos, organizados y útiles para la toma de decisiones.

## Bases de datos utilizadas

| Base de datos | Área de aplicación |
|---|---|
| `helpdesk_pro` | Gestión de soporte técnico y mesa de ayuda. |
| `assetcontrol` | Administración de inventario tecnológico y mantenimiento. |
| `comprafacil` | Gestión de solicitudes, órdenes y compras. |
| `talenttrack` | Formación corporativa y certificaciones. |
| `spacebook` | Administración de salas, reservas y recursos. |

## Desarrollo de los ejercicios

| Punto | Ejercicio | Operaciones principales |
|---|---|---|
| 01 | Identificación de clientes que requieren atención prioritaria. | JOIN, CASE, SUM, COUNT, GROUP BY y HAVING. |
| 02 | Identificación de técnicos que no han respondido a sus tickets. | JOIN, NOT EXISTS y filtros condicionales. |
| 03 | Análisis de costos de mantenimiento por sede. | LEFT JOIN, SUM, COUNT DISTINCT y ROUND. |
| 04 | Identificación de equipos asignados a colaboradores de otras sedes. | INNER JOIN y comparación de sedes. |
| 05 | Cálculo del dinero comprometido y pendiente de recibir en órdenes de compra. | WITH, SUM, LEFT JOIN y COALESCE. |
| 06 | Identificación de productos solicitados recurrentemente y pendientes por ordenar. | COUNT DISTINCT, SUM, WITH y GROUP BY. |
| 07 | Evaluación de matrículas y condiciones para certificación. | CASE WHEN, LEFT JOIN, EXISTS y cálculos porcentuales. |
| 08 | Comparación de resultados de certificación por empresa. | COUNT DISTINCT, JOIN, GROUP BY y HAVING. |
| 09 | Identificación de salas disponibles en un intervalo de tiempo. | NOT EXISTS y validación de cruces de fechas. |
| 10 | Análisis de participantes, recursos y porcentaje de ocupación de salas. | WITH, COUNT DISTINCT, CASE WHEN y ROUND. |

## Tecnologías y conceptos aplicados

- **Motor de base de datos:** MySQL 8.x.
- **Herramienta de trabajo:** MySQL Workbench.
- Consultas SQL y manipulación de resultados mediante `SELECT`.
- Relaciones entre tablas mediante `INNER JOIN` y `LEFT JOIN`.
- Agrupación y agregación mediante `GROUP BY`, `HAVING`, `COUNT` y `SUM`.
- Consultas condicionales mediante `CASE WHEN`, `EXISTS` y `NOT EXISTS`.
- Consultas temporales mediante CTE (`WITH`).
- Tratamiento de valores nulos mediante `COALESCE`.
- Cálculos porcentuales y redondeo mediante `ROUND`.
- Control de duplicados mediante `DISTINCT`.

## Ejecución

1. Instalar MySQL 8.x y disponer de MySQL Workbench.
2. Ejecutar el archivo `01_base_datos.sql` de la versión V2 de cada proyecto.
3. Verificar que las cinco bases de datos estén creadas correctamente.
4. Abrir el archivo `examen_mysql_bayona_john.sql`.
5. Ejecutar las diez consultas en orden y verificar los resultados.

**Importante:** los ejercicios se desarrollan utilizando los datos semilla proporcionados. No es necesario insertar registros adicionales ni modificar la información existente.

## Resultado del proyecto

Se desarrollaron diez consultas SQL orientadas a resolver escenarios reales de análisis de información empresarial. El trabajo permitió integrar conocimientos sobre modelado relacional, consultas multitabla, funciones de agregación, subconsultas, validaciones y cálculos.

Este ejercicio representa una aplicación práctica de MySQL como herramienta para la gestión, consulta y análisis de datos, fortaleciendo el razonamiento lógico y la capacidad de transformar requerimientos funcionales en soluciones SQL.

---

**Proyecto académico:** Examen práctico final de MySQL 8.x.

**Enfoque:** Análisis de información y resolución de requerimientos mediante SQL.