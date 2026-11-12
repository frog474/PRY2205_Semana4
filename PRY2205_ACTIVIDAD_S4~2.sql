
-- ============================================================
-- CASO 1: LISTADO DE TRABAJADORES
-- ============================================================

SELECT
    UPPER(
        T.nombre || ' ' ||
        T.appaterno || ' ' ||
        NVL(T.apmaterno, '')
    ) AS "Nombre Completo Trabajador",

    TO_CHAR(T.numrut, 'FM99G999G999') || '-' || T.dvrut
        AS "RUT Trabajador",

    UPPER(TT.desc_categoria) AS "Tipo Trabajador",

    UPPER(CC.nombre_ciudad) AS "Ciudad Trabajador",

    TO_CHAR(T.sueldo_base, 'FM$999G999G999')
        AS "Sueldo Base"

FROM TRABAJADOR T
INNER JOIN TIPO_TRABAJADOR TT
    ON T.id_categoria_t = TT.id_categoria
INNER JOIN COMUNA_CIUDAD CC
    ON T.id_ciudad = CC.id_ciudad

WHERE T.sueldo_base BETWEEN 650000 AND 3000000

ORDER BY
    CC.nombre_ciudad DESC,
    T.sueldo_base ASC;

-- ============================================================
-- CASO 2: LISTADO DE CAJEROS
-- ============================================================

SELECT
    TO_CHAR(T.numrut, 'FM99G999G999') || '-' || T.dvrut
        AS "RUT",

    UPPER(
        T.nombre || ' ' ||
        T.appaterno || ' ' ||
        NVL(T.apmaterno, '')
    ) AS "Nombre Trabajador",

    COUNT(TC.nro_ticket) AS "Total Tickets",

    TO_CHAR(SUM(TC.monto_ticket), 'FM$999G999G999')
        AS "Total Vendido",

    TO_CHAR(NVL(SUM(CT.valor_comision), 0), 'FM$999G999G999')
        AS "Comision Total",

    UPPER(TT.desc_categoria) AS "Tipo Trabajador",

    UPPER(CC.nombre_ciudad) AS "Ciudad Trabajador"

FROM TRABAJADOR T

INNER JOIN TIPO_TRABAJADOR TT
    ON T.id_categoria_t = TT.id_categoria

INNER JOIN COMUNA_CIUDAD CC
    ON T.id_ciudad = CC.id_ciudad

INNER JOIN TICKETS_CONCIERTO TC
    ON T.numrut = TC.numrut_t

INNER JOIN COMISIONES_TICKET CT
    ON TC.nro_ticket = CT.nro_ticket

WHERE UPPER(TT.desc_categoria) = 'CAJERO'

GROUP BY
    T.numrut,
    T.dvrut,
    T.nombre,
    T.appaterno,
    T.apmaterno,
    TT.desc_categoria,
    CC.nombre_ciudad

HAVING SUM(TC.monto_ticket) > 50000

ORDER BY SUM(TC.monto_ticket) DESC;


-- ============================================================
-- CASO 3: LISTADO DE BONIFICACIONES
-- ============================================================

SELECT
    TO_CHAR(T.numrut, 'FM99G999G999') || '-' || T.dvrut
        AS "RUT",

    UPPER(
        T.nombre || ' ' ||
        T.appaterno || ' ' ||
        NVL(T.apmaterno, '')
    ) AS "Trabajador Nombre",

    TO_CHAR(T.fecing, 'YYYY') AS "Anio Ingreso",

    TRUNC(MONTHS_BETWEEN(SYSDATE, T.fecing) / 12)
        AS "Anos Antiguedad",

    COUNT(DISTINCT AF.numrut_carga)
        AS "Num. Cargas Familiares",

    UPPER(I.nombre_isapre) AS "Nombre Isapre",

    TO_CHAR(T.sueldo_base, 'FM$999G999G999')
        AS "Sueldo Base",

    TO_CHAR(
        CASE
            WHEN UPPER(I.nombre_isapre) = 'FONASA'
            THEN ROUND(T.sueldo_base * 0.01)
            ELSE 0
        END,
        'FM$999G999G999'
    ) AS "Bono Fonasa",

    TO_CHAR(
        CASE
            WHEN TRUNC(MONTHS_BETWEEN(SYSDATE, T.fecing) / 12) <= 10
            THEN ROUND(T.sueldo_base * 0.10)
            ELSE ROUND(T.sueldo_base * 0.15)
        END,
        'FM$999G999G999'
    ) AS "Bono Antiguedad",

    UPPER(A.nombre_afp) AS "Nombre AFP",

    UPPER(ECV.desc_estcivil) AS "Estado Civil"

FROM TRABAJADOR T

INNER JOIN ISAPRE I
    ON T.cod_isapre = I.cod_isapre

INNER JOIN AFP A
    ON T.cod_afp = A.cod_afp

INNER JOIN EST_CIVIL EC
    ON T.numrut = EC.numrut_t

INNER JOIN ESTADO_CIVIL ECV
    ON EC.id_estcivil_est = ECV.id_estcivil

LEFT JOIN ASIGNACION_FAMILIAR AF
    ON T.numrut = AF.numrut_t

WHERE EC.fecter_estcivil IS NULL
   OR EC.fecter_estcivil > SYSDATE

GROUP BY
    T.numrut,
    T.dvrut,
    T.nombre,
    T.appaterno,
    T.apmaterno,
    T.fecing,
    T.sueldo_base,
    I.nombre_isapre,
    A.nombre_afp,
    ECV.desc_estcivil

ORDER BY T.numrut ASC;

