/* =====================================================================
   PRY2205 - Consulta de Bases de Datos
   Experiencia 1 - Semana 3 (Forma B)
   Caso: ASOCIADOS
   Usuario / conexion: PRY2205_S3 / PRY2205_ACTIVIDAD_S3
   ===================================================================== */

/* Coma decimal y punto de miles (como en las figuras) */
ALTER SESSION SET NLS_NUMERIC_CHARACTERS = ',.';

/* =====================================================================
   CASO 1: ANALISIS DE PROPIEDADES
   Resumen por tipo de propiedad cuyo total de gasto comun supera
   el monto ingresado (Figura 2: 100000)
   ===================================================================== */
SELECT
    id_tipo_propiedad                                         AS "TIPO",
    COUNT(*)                                                  AS "TOTAL_PROPIEDADES",
    TO_CHAR(MAX(valor_arriendo), '$9G999G999')                AS "MAX_ARRIENDO",
    TO_CHAR(ROUND(AVG(valor_arriendo)), '$9G999G999')         AS "PROMEDIO_ARRIENDO",
    TO_CHAR(MIN(valor_arriendo), '$9G999G999')                AS "MIN_ARRIENDO",
    CASE
        WHEN MAX(valor_arriendo) <= 1000000 THEN 'ESTÁNDAR'
        ELSE 'PREMIUM'
    END                                                       AS "CLASIFICACION",
    TO_CHAR(SUM(NVL(valor_gasto_comun, 0)), '$9G999G999')     AS "TOTAL_GASTOS_COMUNES"
FROM propiedad
GROUP BY id_tipo_propiedad
HAVING SUM(NVL(valor_gasto_comun, 0)) > &VALOR_TOTAL_GASTO_COMUN
ORDER BY SUM(NVL(valor_gasto_comun, 0)) DESC;

/* =====================================================================
   CASO 2: ANALISIS DE ANTIGUEDAD DE EMPLEADOS
   Ejecutivos de Arriendo (categoria 3) con mas de 5 anios en la empresa
   que no pertenecen a la sucursal ingresada (Figura 3: 30)
   ===================================================================== */
SELECT
    UPPER(nombre_emp || ' ' || appaterno_emp)                 AS "Nombre Empleado",
    TO_CHAR(sueldo_emp, '$9G999G999')                         AS "Sueldo con Formato",
    CASE
        WHEN sueldo_emp > 2000000 THEN 'ALTO'
        ELSE 'MEDIO'
    END                                                       AS "Clasificación Sueldo",
    TO_CHAR(TRUNC(MONTHS_BETWEEN(SYSDATE, fecing_emp) / 12))  AS "Años Antigüedad",
    CASE
        WHEN TRUNC(MONTHS_BETWEEN(SYSDATE, fecing_emp) / 12) <= 10
            THEN 'Corresponde bono  5%:' || TO_CHAR(ROUND(sueldo_emp * 0.05), '$99G999G999')
        WHEN TRUNC(MONTHS_BETWEEN(SYSDATE, fecing_emp) / 12) <= 20
            THEN 'Corresponde bono 10%:' || TO_CHAR(ROUND(sueldo_emp * 0.10), '$99G999G999')
        ELSE 'Corresponde bono 15%:' || TO_CHAR(ROUND(sueldo_emp * 0.15), '$99G999G999')
    END                                                       AS "BONO"
FROM empleado
WHERE NVL(id_categoria_emp, 0) = 3
  AND MONTHS_BETWEEN(SYSDATE, fecing_emp) / 12 > 5
  AND id_sucursal <> &CODIGO_SUCURSAL
ORDER BY sueldo_emp DESC;

/* =====================================================================
   CASO 3: LISTA DE CLIENTES
   Clientes agrupados por clasificacion de renta, solo grupos con
   renta promedio sobre 200000
   ===================================================================== */
SELECT
    CASE
        WHEN renta_cli >= 1000000 THEN 'PREMIUM'
        WHEN renta_cli >= 600000 THEN 'ALTA'
        WHEN renta_cli >= 300000 THEN 'MEDIA'
        ELSE 'BAJA'
    END                                                       AS "CLASIFICACION_RENTA",
    COUNT(*)                                                  AS "CANTIDAD_CLIENTES",
    TO_CHAR(ROUND(AVG(renta_cli)), '$9G999G999')              AS "RENTA_PROMEDIO",
    CASE
        WHEN SUM(NVL2(celular_cli, 1, 0)) = 0 THEN 'Clientes Sin Teléfono'
        ELSE 'Clientes con Teléfono'
    END                                                       AS "ESTADO_TELEFONO"
FROM cliente
GROUP BY CASE
             WHEN renta_cli >= 1000000 THEN 'PREMIUM'
             WHEN renta_cli >= 600000 THEN 'ALTA'
             WHEN renta_cli >= 300000 THEN 'MEDIA'
             ELSE 'BAJA'
         END
HAVING AVG(renta_cli) > 200000;
