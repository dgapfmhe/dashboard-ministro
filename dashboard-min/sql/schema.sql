-- ============================================================================
-- Dashboard Macroeconómico DGAPF - Esquema Supabase (formato LARGO)
-- Ministerio de Hacienda - República Dominicana
-- ============================================================================
-- Idea:
--   * `variables`    : catálogo (una fila por serie). Define ID, nombre,
--                      módulo, frecuencia, unidad, fuente, transformación.
--   * `series_datos` : hechos (una fila por variable_id + fecha).
--   * `ingestas`    : bitácora de corridas (para auditoría GitHub Actions).
--   * `tasa_politica_monetaria_historico` : historial de cambios TPM (meta).
--
-- Todas las tablas usan RLS-ready diseño: filas pequeñas, PK compuestas,
-- índices por fecha y módulo para dashboards Streamlit.
-- ============================================================================

-- Borra el esquema anterior si se re-inicializa (CUIDADO en prod)
-- DROP TABLE IF EXISTS series_datos CASCADE;
-- DROP TABLE IF EXISTS variables CASCADE;
-- DROP TABLE IF EXISTS ingestas CASCADE;
-- DROP TABLE IF EXISTS tpm_historico CASCADE;

-- ----------------------------------------------------------------------------
-- CATÁLOGO DE VARIABLES
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS variables (
    id              TEXT PRIMARY KEY,               -- ID corto: 'ipc_rd', 'tcn_compra', 'el_gen_total'
    nombre          TEXT NOT NULL,                  -- nombre descriptivo
    descripcion     TEXT,                           -- detalle largo (de metadata_data_*)
    modulo          TEXT NOT NULL,                  -- 'Real','Precios','Mercado Cambiario','Externo','Fiscal','Monetario','Financiero','Eléctrico'
    submodulo       TEXT,                           -- libre: 'ipc','edes','cdeee', etc.
    frecuencia      TEXT NOT NULL CHECK (frecuencia IN ('diaria','semanal','mensual','trimestral','anual')),
    unidad          TEXT NOT NULL,                  -- 'RD$/US$','índice','%','US$', etc.
    escala          TEXT NOT NULL DEFAULT 'Unidad' CHECK (escala IN ('Unidad','Miles','Millones','Miles de millones')),
    fuente          TEXT NOT NULL,                  -- 'BCRD','FRED','MEM','SIPEN','Hacienda', etc.
    fuente_url      TEXT,
    tipo            TEXT NOT NULL DEFAULT 'directa' CHECK (tipo IN ('directa','derivada')),
    formula         TEXT,                           -- solo si tipo='derivada' (ej: 'ipc_rd / lag(ipc_rd, 12) - 1')
    transformacion  TEXT,                           -- legado: 'nivel','yoy','mom','ytd','acum_12m'
    activo          BOOLEAN NOT NULL DEFAULT TRUE,
    creado_en       TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    actualizado_en  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_variables_modulo      ON variables(modulo);
CREATE INDEX IF NOT EXISTS idx_variables_fuente      ON variables(fuente);
CREATE INDEX IF NOT EXISTS idx_variables_frecuencia  ON variables(frecuencia);
CREATE INDEX IF NOT EXISTS idx_variables_tipo        ON variables(tipo);

-- Migraciones idempotentes: agregar columnas si la tabla ya existía con el esquema viejo
ALTER TABLE variables ADD COLUMN IF NOT EXISTS escala  TEXT NOT NULL DEFAULT 'Unidad';
ALTER TABLE variables ADD COLUMN IF NOT EXISTS tipo    TEXT NOT NULL DEFAULT 'directa';
ALTER TABLE variables ADD COLUMN IF NOT EXISTS formula TEXT;

-- ----------------------------------------------------------------------------
-- HECHOS: SERIE DE TIEMPO EN FORMATO LARGO
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS series_datos (
    variable_id   TEXT NOT NULL REFERENCES variables(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    fecha         DATE NOT NULL,
    valor         DOUBLE PRECISION,                 -- NULL si no se publicó ese período
    flag          TEXT,                             -- 'preliminar','revisado','proyeccion','derivada', NULL si final
    fuente_raw    TEXT,                             -- URL/archivo exacto de esa corrida
    ingesta_id    BIGINT,                           -- FK opcional a ingestas.id
    actualizado_en TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    PRIMARY KEY (variable_id, fecha)
);

CREATE INDEX IF NOT EXISTS idx_series_fecha        ON series_datos(fecha);
CREATE INDEX IF NOT EXISTS idx_series_variable     ON series_datos(variable_id);
CREATE INDEX IF NOT EXISTS idx_series_variable_fecha ON series_datos(variable_id, fecha DESC);

-- ----------------------------------------------------------------------------
-- BITÁCORA DE INGESTAS (GitHub Actions)
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS ingestas (
    id              BIGSERIAL PRIMARY KEY,
    pipeline        TEXT NOT NULL,                  -- 'sector_electrico','macro_bcrd','forecasting'
    ejecutado_en    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    duracion_seg    INTEGER,
    filas_insertadas INTEGER,
    filas_actualizadas INTEGER,
    estado          TEXT NOT NULL CHECK (estado IN ('ok','warning','error')),
    mensaje         TEXT,
    run_url         TEXT                            -- URL del run de GitHub Actions
);

CREATE INDEX IF NOT EXISTS idx_ingestas_pipeline   ON ingestas(pipeline, ejecutado_en DESC);

-- ----------------------------------------------------------------------------
-- HISTÓRICO TPM (equivalente a `Resumen_TPM` del script R)
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS tpm_historico (
    fecha_anuncio   DATE PRIMARY KEY,
    tpm_pct         DOUBLE PRECISION NOT NULL,
    cambio_pb       DOUBLE PRECISION,               -- puntos básicos vs decisión previa
    nota            TEXT,
    fuente_url      TEXT
);

-- ----------------------------------------------------------------------------
-- VISTA CONVENIENTE: serie larga + metadata (para debug / Streamlit)
-- ----------------------------------------------------------------------------
CREATE OR REPLACE VIEW v_series_con_meta AS
SELECT
    sd.variable_id,
    v.nombre,
    v.modulo,
    v.frecuencia,
    v.unidad,
    v.escala,
    v.fuente,
    v.tipo,
    v.formula,
    sd.fecha,
    sd.valor,
    sd.flag
FROM series_datos sd
JOIN variables v ON v.id = sd.variable_id;

-- Ejemplo de consulta dashboard Streamlit:
--   SELECT fecha, valor
--   FROM series_datos
--   WHERE variable_id = 'ipc_rd'
--     AND fecha >= '2020-01-01'
--   ORDER BY fecha;
--
-- O con metadata:
--   SELECT fecha, valor, nombre, unidad
--   FROM v_series_con_meta
--   WHERE variable_id = 'imae'
--     AND fecha >= '2020-01-01'
--   ORDER BY fecha;
