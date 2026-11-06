# Examen práctico final — Análisis de información con MySQL

**Duración:** 3 horas (180 minutos)  
**Modalidad:** individual, con las cinco bases de datos de los talleres  
**Valor:** 100 puntos (10 puntos por consulta)  
**Herramienta:** MySQL 8.x

## Contexto del examen

Durante las clases construimos y consultamos las bases de datos `helpdesk_pro`, `assetcontrol`, `comprafacil`, `talenttrack` y `spacebook`. Ahora actuarás como analista de datos: recibirás solicitudes de distintas áreas de negocio y deberás convertir cada necesidad en **una consulta SQL que proporcione la información correcta**.

Las situaciones no indican qué instrucciones SQL debes utilizar. Debes interpretar el problema, identificar las tablas necesarias y decidir cómo relacionar, filtrar, agrupar y ordenar la información.

**Antes de comenzar:** ejecuta el archivo `01_base_datos.sql` de la versión V2 de cada proyecto, con sus datos semilla. **No necesitas insertar registros adicionales para este examen.** No ejecutes los ejemplos opcionales de `UPDATE`, `DELETE` ni `TRUNCATE`, ni modifiques los datos para conseguir resultados.

Escribe tus respuestas en un archivo llamado `examen_mysql_apellido_nombre.sql`, numeradas del `01` al `10`, con el `USE` correspondiente antes de cada consulta. Debe ser posible ejecutar las diez respuestas en orden. Conserva los identificadores de las bases, tablas y atributos en **inglés, minúsculas y `snake_case`**. Los alias que presentes al usuario pueden estar en español, también en minúsculas y `snake_case`. Si dos tablas generan múltiples registros relacionados, comprueba que los totales no se dupliquen.

**Criterio general:** cuando una cifra sea monetaria, un promedio o un porcentaje, preséntala con dos decimales. Las fechas de referencia son las de los casos, no la fecha actual del sistema. Se califica el resultado y el razonamiento, no una única manera de escribir SQL.

---

## Caso 1. HelpDesk Pro — Mesa de ayuda empresarial

### 01. ¿Qué clientes requieren atención prioritaria? — 10 puntos

La gerencia de HelpDesk Pro observa que algunos clientes generan numerosos reportes y quiere decidir a cuáles asignará primero recursos de soporte. Para su reunión de seguimiento solo le interesan los **clientes activos** que hayan registrado **al menos dos tickets** y todavía tengan **algún ticket sin resolver**. Para este análisis, considera pendientes los casos en estado `ABIERTO` o `EN_PROCESO`.

Prepara un informe de una fila por cliente. La gerencia necesita ver su nombre comercial, el número total de tickets de cualquier estado, el número de pendientes, cuántos de estos pendientes son de prioridad `CRITICA` y la fecha en que ese cliente abrió su ticket más reciente, incluso si ya fue cerrado. Los clientes con más pendientes deben aparecer primero; cuando exista empate, ordénalos alfabéticamente.

**Columnas que debe recibir la gerencia, en este orden:** `cliente`, `total_tickets`, `tickets_pendientes`, `criticos_pendientes`, `ultima_apertura`.

```sql
USE helpdesk_pro;

-- 01. Tu consulta
SELECT
    c.company_name AS cliente,

    COUNT(t.id) AS total_tickets,

    SUM(
        CASE
            WHEN t.status IN ('ABIERTO', 'EN_PROCESO')
            THEN 1
            ELSE 0
        END
    ) AS tickets_pendientes,

    SUM(
        CASE
            WHEN t.status IN ('ABIERTO', 'EN_PROCESO')
             AND t.priority = 'CRITICA'
            THEN 1
            ELSE 0
        END
    ) AS criticos_pendientes,

    MAX(t.opened_at) AS ultima_apertura

FROM clients c

INNER JOIN contacts co
    ON c.id = co.client_id

INNER JOIN tickets t
    ON co.id = t.contact_id

WHERE c.status = 'ACTIVO'

GROUP BY
    c.id,
    c.company_name

HAVING
    COUNT(t.id) >= 2

    AND SUM(
        CASE
            WHEN t.status IN ('ABIERTO', 'EN_PROCESO')
            THEN 1
            ELSE 0
        END
    ) > 0

ORDER BY
    tickets_pendientes DESC,
    cliente ASC;


```

### 02. ¿Qué responsables no han respondido a sus tickets? — 10 puntos

El coordinador de soporte detectó que algunos incidentes están asignados, pero su responsable actual aún no ha escrito una respuesta. Quiere enviarles un recordatorio sin responsabilizar a técnicos que ya terminaron su asignación ni confundir los comentarios de un cliente o de otro técnico con los del responsable vigente.

Entrégale los tickets que sigan `ABIERTO` o `EN_PROCESO`, tengan una asignación **sin fecha de finalización** y no registren **ningún comentario escrito por el técnico de esa asignación en ese mismo ticket**. Para cada caso deben aparecer el código del ticket, asunto, empresa cliente, técnico responsable, prioridad y fecha de inicio de la asignación. Presenta primero los tickets abiertos hace más tiempo y utiliza su código para desempatar.

**Columnas esperadas:** `codigo_ticket`, `asunto`, `cliente`, `tecnico`, `prioridad`, `asignado_desde`.

```sql
USE helpdesk_pro;

-- 02. Tu consulta _ que responsables no han respondido a sus tickets


SELECT
    tickets.id AS codigo_ticket,
    tickets.subject AS asunto,
    clients.company_name AS cliente,
    technicians.name AS tecnico,
    tickets.priority AS prioridad,
    assignments.started_at AS asignado_desde

FROM tickets

INNER JOIN assignments
    ON tickets.id = assignments.ticket_id

INNER JOIN technicians
    ON assignments.technician_id = technicians.id

INNER JOIN contacts
    ON tickets.contact_id = contacts.id

INNER JOIN clients
    ON contacts.client_id = clients.id

WHERE
    (tickets.status = 'ABIERTO'
     OR tickets.status = 'EN_PROCESO')

    AND assignments.ended_at IS NULL

    AND NOT EXISTS (
        SELECT 1
        FROM comments
        WHERE comments.ticket_id = tickets.id
          AND comments.technician_id = assignments.technician_id
    )

ORDER BY
    tickets.opened_at ASC,
    tickets.id ASC;


```

---

## Caso 2. AssetControl — Inventario tecnológico

### 03. ¿En qué sedes se está invirtiendo más en mantenimiento? — 10 puntos

La dirección de tecnología debe distribuir su presupuesto del próximo trimestre. Antes de hacerlo necesita comparar las sedes que tienen **dos o más equipos en inventario**, incluidos los disponibles, asignados o dados de baja. También quiere distinguir entre tener muchos equipos y tener muchos mantenimientos sobre un mismo equipo.

El informe debe contener una fila por sede con su nombre y ciudad, cuántos **equipos distintos** tiene registrados, cuántos de ellos han recibido alguna intervención, cuánto suman los costos de **todos** sus mantenimientos y cuál es el costo promedio por equipo de inventario. Este último indicador se calcula dividiendo el gasto acumulado entre todos los equipos registrados en la sede, no entre los mantenimientos realizados. Si no existe ningún mantenimiento, el gasto y el promedio deberán mostrarse como cero. Organiza las sedes por gasto total descendente y usa el nombre como desempate.

**Columnas esperadas:** `sede`, `ciudad`, `total_equipos`, `equipos_intervenidos`, `costo_total`, `promedio_por_equipo`.

```sql
USE assetcontrol;

-- 03. Tu consulta


SELECT
    sites.name AS sede,
    sites.city AS ciudad,

    COUNT(DISTINCT assets.id) AS total_equipos,

    COUNT(DISTINCT maintenance.asset_id) AS equipos_intervenidos,

    ROUND(
        COALESCE(SUM(maintenance.cost), 0), 2
    ) AS costo_total,

    ROUND(
        COALESCE(SUM(maintenance.cost), 0)
        / COUNT(DISTINCT assets.id), 2
    ) AS promedio_por_equipo

FROM sites

INNER JOIN assets
    ON sites.id = assets.site_id

LEFT JOIN maintenance
    ON assets.id = maintenance.asset_id

GROUP BY
    sites.id,
    sites.name,
    sites.city

HAVING
    COUNT(DISTINCT assets.id) >= 2

ORDER BY
    costo_total DESC,
    sede ASC;


```

### 04. ¿Qué equipos están bajo custodia de otra sede? — 10 puntos

Durante una auditoría, el área administrativa descubrió que algunos activos pueden estar asignados a colaboradores cuyo departamento pertenece a una sede diferente de la sede responsable del inventario. Esto no es necesariamente un error, pero debe revisarse porque puede afectar los controles de custodia.

Identifica exclusivamente las asignaciones **que todavía no tienen fecha de devolución** y en las que las dos sedes no coincidan. Auditoría necesita el identificador patrimonial, la marca del equipo, el nombre del colaborador, su departamento, el nombre de la sede responsable del activo, el nombre de la sede a la que pertenece el departamento y la fecha de asignación. Presenta los equipos ordenados por su identificador patrimonial.

**Columnas esperadas:** `codigo_activo`, `marca`, `empleado`, `departamento`, `sede_inventario`, `sede_departamento`, `fecha_asignacion`.

```sql
USE assetcontrol;

-- 04. Tu consulta

SELECT
    assets.patrimonial_identifier AS codigo_activo,
    assets.brand AS marca,
    employees.name AS empleado,
    departments.name AS departamento,
    sede_inventario.name AS sede_inventario,
    sede_departamento.name AS sede_departamento,
    assignments.started_at AS fecha_asignacion

FROM assignments

INNER JOIN assets
    ON assignments.asset_id = assets.id

INNER JOIN employees
    ON assignments.employee_id = employees.id

INNER JOIN departments
    ON employees.department_id = departments.id

INNER JOIN sites AS sede_inventario
    ON assets.site_id = sede_inventario.id

INNER JOIN sites AS sede_departamento
    ON departments.site_id = sede_departamento.id

WHERE
    assignments.return_date IS NULL

    AND sede_inventario.id <> sede_departamento.id

ORDER BY
    assets.patrimonial_identifier ASC;


```

---

## Caso 3. CompraFácil — Gestión de compras

### 05. ¿Cuánto dinero comprometido falta por recibir? — 10 puntos

El departamento financiero revisará las órdenes de compra para saber cuánto dinero se comprometió con los proveedores y qué parte de los productos ya fue recibida. Algunas órdenes contienen varios renglones; otras tienen entregas parciales y un mismo renglón puede aparecer en varias recepciones. También existen órdenes que aún no han recibido nada.

Construye un estado por **cada orden que no esté `ANULADA`**, incluidas las que no registran recepciones. El valor ordenado es la suma de las cantidades compradas multiplicadas por sus precios unitarios acordados; el valor recibido se obtiene de las cantidades efectivamente recibidas en todas las entregas, valoradas a esos mismos precios. La diferencia corresponde al saldo pendiente. Una entrega parcial no debe hacer que se cuente dos veces el valor original de la orden. Las órdenes con mayor saldo pendiente aparecerán primero; resuelve los empates por código de orden.

**Columnas esperadas:** `codigo_orden`, `proveedor`, `estado`, `valor_ordenado`, `valor_recibido`, `saldo_pendiente`.

```sql
USE comprafacil;

-- 05. Tu consulta


WITH valores_ordenados AS (

    SELECT
        order_items.order_id,

        SUM(
            order_items.ordered_quantity *
            order_items.unit_price
        ) AS valor_ordenado

    FROM order_items

    GROUP BY order_items.order_id

),

valores_recibidos AS (

    SELECT
        receipts.order_id,

        SUM(
            receipt_items.received_quantity *
            order_items.unit_price
        ) AS valor_recibido

    FROM receipts

    INNER JOIN receipt_items
        ON receipts.id = receipt_items.receipt_id

    INNER JOIN order_items
        ON receipt_items.order_item_id = order_items.id

    GROUP BY receipts.order_id

)

SELECT
    purchase_orders.id AS codigo_orden,

    suppliers.company_name AS proveedor,

    purchase_orders.status AS estado,

    ROUND(
        COALESCE(valores_ordenados.valor_ordenado, 0),
        2
    ) AS valor_ordenado,

    ROUND(
        COALESCE(valores_recibidos.valor_recibido, 0),
        2
    ) AS valor_recibido,

    ROUND(
        COALESCE(valores_ordenados.valor_ordenado, 0) -
        COALESCE(valores_recibidos.valor_recibido, 0),
        2
    ) AS saldo_pendiente

FROM purchase_orders

INNER JOIN suppliers
    ON purchase_orders.supplier_id = suppliers.id

LEFT JOIN valores_ordenados
    ON purchase_orders.id = valores_ordenados.order_id

LEFT JOIN valores_recibidos
    ON purchase_orders.id = valores_recibidos.order_id

WHERE purchase_orders.status <> 'ANULADA'

ORDER BY
    saldo_pendiente DESC,
    codigo_orden ASC;


```

### 06. ¿Qué productos se piden reiteradamente y aún no se compran en su totalidad? — 10 puntos

Compras sospecha que hay productos que aparecen de manera recurrente en las solicitudes internas, pero que siguen pendientes de ordenar. Para determinarlo, revisará **todas las solicitudes registradas**, independientemente de su estado, y prestará especial atención a productos presentes en **dos o más solicitudes diferentes**.

Para cada producto que cumpla esa condición, compara el total solicitado con el total efectivamente incluido en los renglones de las órdenes de compra vinculadas a esas solicitudes. Cuando una solicitud todavía no tenga orden, debe seguir contando como cantidad solicitada y aportar cero a la cantidad ordenada. El área solo quiere conocer los productos cuya cantidad solicitada **supere** a la ordenada. Incluye su SKU, nombre, número de solicitudes distintas, cantidades solicitadas y ordenadas, y cantidad restante por ordenar. Muestra primero el mayor faltante y usa el SKU para desempatar.

**Columnas esperadas:** `sku`, `producto`, `solicitudes`, `cantidad_solicitada`, `cantidad_ordenada`, `cantidad_no_ordenada`.

```sql
USE comprafacil;

-- 06. Tu consulta

WITH datos_solicitados AS (

    SELECT
        request_items.product_id,

        COUNT(DISTINCT request_items.request_id) AS solicitudes,

        SUM(request_items.requested_quantity) AS cantidad_solicitada

    FROM request_items

    GROUP BY request_items.product_id

),

datos_ordenados AS (

    SELECT
        request_items.product_id,

        SUM(order_items.ordered_quantity) AS cantidad_ordenada

    FROM request_items

    INNER JOIN purchase_orders
        ON request_items.request_id = purchase_orders.request_id

    INNER JOIN order_items
        ON purchase_orders.id = order_items.order_id
        AND request_items.id = order_items.request_item_id

    GROUP BY request_items.product_id

),

resumen_productos AS (

    SELECT
        products.sku,
        products.name AS producto,

        datos_solicitados.solicitudes,

        datos_solicitados.cantidad_solicitada,

        COALESCE(datos_ordenados.cantidad_ordenada, 0)
            AS cantidad_ordenada,

        datos_solicitados.cantidad_solicitada -
        COALESCE(datos_ordenados.cantidad_ordenada, 0)
            AS cantidad_no_ordenada

    FROM products

    INNER JOIN datos_solicitados
        ON products.id = datos_solicitados.product_id

    LEFT JOIN datos_ordenados
        ON products.id = datos_ordenados.product_id

)

SELECT
    sku,
    producto,
    solicitudes,
    cantidad_solicitada,
    cantidad_ordenada,
    cantidad_no_ordenada

FROM resumen_productos

WHERE
    solicitudes >= 2
    AND cantidad_solicitada > cantidad_ordenada

ORDER BY
    cantidad_no_ordenada DESC,
    sku ASC;


```

---

## Caso 4. TalentTrack — Formación corporativa

### 07. ¿Quiénes reúnen las condiciones para certificarse? — 10 puntos

La coordinación académica va a auditar la emisión de certificados. Quiere revisar **todas las matrículas**, incluso aquellas cuyos estudiantes aún no tienen asistencias registradas. Para este ejercicio, una matrícula es **apta para certificarse** únicamente cuando su edición está `FINALIZADA`, existe un registro de asistencia para **cada sesión programada de esa misma edición** y se asistió en estado `PRESENTE` a por lo menos el **80 %** de esas sesiones. Tener un certificado registrado no reemplaza estas condiciones.

Construye un reporte que muestre el código de cada matrícula, el colaborador, el código de edición, cuántas sesiones están programadas, en cuántas se registró asistencia y cuántas figuran como `PRESENTE`. Calcula el porcentaje de presencias sobre las sesiones programadas. Añade una respuesta `SI` o `NO` para señalar si es apta y otra para señalar si **ya tiene certificado emitido**. Una matrícula sin presencias debe mostrar cero por ciento cuando tenga sesiones programadas. Ordena por código de edición y nombre del colaborador.

**Columnas esperadas:** `codigo_matricula`, `colaborador`, `edicion`, `sesiones_programadas`, `asistencias_registradas`, `presencias`, `porcentaje_asistencia`, `apto_para_certificado`, `certificado_emitido`.

```sql
USE talenttrack;

-- 07. Tu consulta


WITH sesiones_por_edicion AS (

    SELECT
        sessions.edition_id,

        COUNT(sessions.id) AS sesiones_programadas

    FROM sessions

    GROUP BY sessions.edition_id

),

asistencias_por_matricula AS (

    SELECT
        attendance.enrollment_id,

        COUNT(DISTINCT attendance.session_id)
            AS asistencias_registradas,

        COUNT(
            DISTINCT CASE
                WHEN attendance.status = 'PRESENTE'
                THEN attendance.session_id
            END
        ) AS presencias

    FROM attendance

    INNER JOIN sessions
        ON attendance.session_id = sessions.id

    INNER JOIN enrollments
        ON attendance.enrollment_id = enrollments.id
        AND sessions.edition_id = enrollments.edition_id

    GROUP BY attendance.enrollment_id

),

resumen_matriculas AS (

    SELECT
        enrollments.id AS codigo_matricula,

        collaborators.name AS colaborador,

        editions.code AS edicion,

        editions.status AS estado_edicion,

        COALESCE(
            sesiones_por_edicion.sesiones_programadas, 0
        ) AS sesiones_programadas,

        COALESCE(
            asistencias_por_matricula.asistencias_registradas, 0
        ) AS asistencias_registradas,

        COALESCE(
            asistencias_por_matricula.presencias, 0
        ) AS presencias,

        CASE
            WHEN COALESCE(
                sesiones_por_edicion.sesiones_programadas, 0
            ) > 0
            THEN ROUND(
                COALESCE(asistencias_por_matricula.presencias, 0)
                * 100.0 /
                sesiones_por_edicion.sesiones_programadas,
                2
            )
            ELSE 0.00
        END AS porcentaje_asistencia,

        CASE
            WHEN EXISTS (
                SELECT 1
                FROM certificates
                WHERE certificates.enrollment_id = enrollments.id
            )
            THEN 'SI'
            ELSE 'NO'
        END AS certificado_emitido

    FROM enrollments

    INNER JOIN collaborators
        ON enrollments.collaborator_id = collaborators.id

    INNER JOIN editions
        ON enrollments.edition_id = editions.id

    LEFT JOIN sesiones_por_edicion
        ON editions.id = sesiones_por_edicion.edition_id

    LEFT JOIN asistencias_por_matricula
        ON enrollments.id = asistencias_por_matricula.enrollment_id

)

SELECT
    codigo_matricula,
    colaborador,
    edicion,
    sesiones_programadas,
    asistencias_registradas,
    presencias,
    porcentaje_asistencia,

    CASE
        WHEN estado_edicion = 'FINALIZADA'
         AND sesiones_programadas > 0
         AND asistencias_registradas = sesiones_programadas
         AND presencias >= sesiones_programadas * 0.80
        THEN 'SI'
        ELSE 'NO'
    END AS apto_para_certificado,

    certificado_emitido

FROM resumen_matriculas

ORDER BY
    edicion ASC,
    colaborador ASC;


```

### 08. ¿Qué empresas obtienen mejores resultados de certificación? — 10 puntos

La dirección comercial desea comparar la efectividad de su oferta de formación entre las empresas clientes **activas** que hayan acumulado **dos o más matrículas**. Una misma persona puede matricularse en varias ediciones; en ese caso, representa un solo colaborador, pero varias matrículas. Igualmente, dos ediciones de un mismo curso representan un solo curso distinto.

Para cada empresa incluida en el análisis, informa cuántos colaboradores diferentes se han matriculado, el total de matrículas, la cantidad de cursos distintos cursados, el total de certificados efectivamente emitidos y la tasa de certificación calculada como **certificados emitidos dividido entre matrículas, multiplicado por 100**. Presenta primero las empresas con la tasa más alta; en caso de empate, utiliza el nombre de la empresa en orden alfabético.

**Columnas esperadas:** `empresa`, `colaboradores_matriculados`, `total_matriculas`, `cursos_distintos`, `certificados_emitidos`, `tasa_certificacion`.

```sql
USE talenttrack;

-- 08. Tu consulta


SELECT
    companies.company_name AS empresa,

    COUNT(DISTINCT collaborators.id)
        AS colaboradores_matriculados,

    COUNT(DISTINCT enrollments.id)
        AS total_matriculas,

    COUNT(DISTINCT editions.course_id)
        AS cursos_distintos,

    COUNT(
        DISTINCT CASE
            WHEN certificates.issued_at IS NOT NULL
            THEN certificates.id
        END
    ) AS certificados_emitidos,

    ROUND(
        COUNT(
            DISTINCT CASE
                WHEN certificates.issued_at IS NOT NULL
                THEN certificates.id
            END
        ) * 100.0 /
        COUNT(DISTINCT enrollments.id),
        2
    ) AS tasa_certificacion

FROM companies

INNER JOIN collaborators
    ON companies.id = collaborators.company_id

INNER JOIN enrollments
    ON collaborators.id = enrollments.collaborator_id

INNER JOIN editions
    ON enrollments.edition_id = editions.id

INNER JOIN courses
    ON editions.course_id = courses.id

LEFT JOIN certificates
    ON enrollments.id = certificates.enrollment_id

WHERE
    companies.status = 'ACTIVO'

GROUP BY
    companies.id,
    companies.company_name

HAVING
    COUNT(DISTINCT enrollments.id) >= 2

ORDER BY
    tasa_certificacion DESC,
    empresa ASC;


```

---

## Caso 5. SpaceBook — Reservas de salas

### 09. ¿Qué salas se pueden reservar en el horario solicitado? — 10 puntos

Un empleado necesita una sala para una reunión el **3 de noviembre de 2026**, desde las **8:30 a. m. hasta las 9:30 a. m.** Puede desplazarse a cualquiera de las sedes y desea conocer todas las salas activas realmente disponibles.

Para considerar una sala disponible, no debe existir ninguna reserva en estado `CONFIRMADA` que ocupe **alguna parte** de ese intervalo, ni un bloqueo de sala por mantenimiento o limpieza que se cruce con él. Las reservas `SOLICITADA`, `CANCELADA` o `FINALIZADA` no deben impedir la selección. Si una ocupación termina exactamente al comenzar la reunión, o empieza exactamente cuando esta termina, no representa un conflicto. Prepara la relación de salas disponibles con su código, nombre, sede, ciudad y capacidad. Ordénalas alfabéticamente por sede y después por sala.

**Columnas esperadas:** `codigo_sala`, `sala`, `sede`, `ciudad`, `capacidad`.

```sql
USE spacebook;

-- 09. Tu consulta

SELECT
    rooms.code AS codigo_sala,
    rooms.name AS sala,
    sites.name AS sede,
    sites.city AS ciudad,
    rooms.capacity AS capacidad

FROM rooms

INNER JOIN sites
    ON rooms.site_id = sites.id

WHERE
    rooms.status = 'ACTIVO'

    AND NOT EXISTS (

        SELECT 1
        FROM reservations

        WHERE reservations.room_id = rooms.id

          AND reservations.status = 'CONFIRMADA'

          AND reservations.started_at < '2026-11-03 09:30:00'

          AND reservations.ended_at > '2026-11-03 08:30:00'

    )

    AND NOT EXISTS (

        SELECT 1
        FROM room_blocks

        WHERE room_blocks.room_id = rooms.id

          AND room_blocks.started_at < '2026-11-03 09:30:00'

          AND room_blocks.ended_at > '2026-11-03 08:30:00'

    )

ORDER BY
    sites.name ASC,
    rooms.name ASC;


```

### 10. ¿Cómo se está utilizando el aforo de las reuniones confirmadas? — 10 puntos

La administración necesita comparar las reuniones en estado `CONFIRMADA` para conocer sus participantes y recursos reservados. En una reunión puede haber varios invitados y también varios recursos, por lo que no debe repetirse una persona o un dispositivo al calcular los totales.

Por cada reserva confirmada, presenta el código, la sala, el organizador y la capacidad. Indica cuántas personas fueron invitadas en total, cuántas respondieron `ACEPTADA`, cuántas `RECHAZADA` y cuántos recursos diferentes están asociados a la reunión. Para este informe, el número de asistentes confirmados será **el organizador más todos los invitados que aceptaron**; cuenta al organizador como una persona adicional, conforme a la regla del examen. Calcula qué porcentaje de la capacidad representa ese número. Organiza las reuniones de mayor a menor porcentaje de aforo, con el código de reserva como desempate.

**Columnas esperadas:** `codigo_reserva`, `sala`, `organizador`, `capacidad`, `invitados`, `aceptados`, `rechazados`, `recursos`, `asistentes_confirmados`, `porcentaje_aforo`.

```sql
USE spacebook;

-- 10. Tu consulta

WITH datos_participantes AS (

    SELECT
        reservation_participants.reservation_id,

        COUNT(
            DISTINCT reservation_participants.employee_id
        ) AS invitados,

        COUNT(
            DISTINCT CASE
                WHEN reservation_participants.response = 'ACEPTADA'
                THEN reservation_participants.employee_id
            END
        ) AS aceptados,

        COUNT(
            DISTINCT CASE
                WHEN reservation_participants.response = 'RECHAZADA'
                THEN reservation_participants.employee_id
            END
        ) AS rechazados

    FROM reservation_participants

    GROUP BY reservation_participants.reservation_id

),

datos_recursos AS (

    SELECT
        reservation_resources.reservation_id,

        COUNT(
            DISTINCT reservation_resources.resource_id
        ) AS recursos

    FROM reservation_resources

    GROUP BY reservation_resources.reservation_id

)

SELECT
    reservations.id AS codigo_reserva,

    rooms.name AS sala,

    employees.name AS organizador,

    rooms.capacity AS capacidad,

    COALESCE(datos_participantes.invitados, 0)
        AS invitados,

    COALESCE(datos_participantes.aceptados, 0)
        AS aceptados,

    COALESCE(datos_participantes.rechazados, 0)
        AS rechazados,

    COALESCE(datos_recursos.recursos, 0)
        AS recursos,

    1 + COALESCE(datos_participantes.aceptados, 0)
        AS asistentes_confirmados,

    CASE
        WHEN rooms.capacity > 0
        THEN ROUND(
            (
                1 + COALESCE(datos_participantes.aceptados, 0)
            ) * 100.0 / rooms.capacity,
            2
        )
        ELSE 0.00
    END AS porcentaje_aforo

FROM reservations

INNER JOIN rooms
    ON reservations.room_id = rooms.id

INNER JOIN employees
    ON reservations.organizer_id = employees.id

LEFT JOIN datos_participantes
    ON reservations.id = datos_participantes.reservation_id

LEFT JOIN datos_recursos
    ON reservations.id = datos_recursos.reservation_id

WHERE reservations.status = 'CONFIRMADA'

ORDER BY
    porcentaje_aforo DESC,
    codigo_reserva ASC;


```

---

## Evaluación

Cada situación vale **10 puntos**: interpretación de las reglas del negocio (4), relaciones correctas entre tablas (3), exactitud de resultados y ausencia de duplicados (2), presentación de campos y orden solicitado (1).

**Antes de entregar:** verifica que todas las consultas puedan ejecutarse después de cargar las cinco bases originales, sin cambios a los datos; que los conteos de elementos distintos sean correctos y que los casos sin registros relacionados se manejen de acuerdo con cada situación.

**Fin del examen.**


