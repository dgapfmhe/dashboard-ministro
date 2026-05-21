-- ============================================================================
-- SETUP COMPLETO — Ejecutar una sola vez en Supabase SQL Editor
-- ============================================================================

-- CATÁLOGO DE VARIABLES
CREATE TABLE IF NOT EXISTS variables (
    id              TEXT PRIMARY KEY,
    nombre          TEXT NOT NULL,
    descripcion     TEXT,
    modulo          TEXT NOT NULL,
    submodulo       TEXT,
    frecuencia      TEXT NOT NULL CHECK (frecuencia IN ('diaria','semanal','mensual','trimestral','anual')),
    unidad          TEXT NOT NULL,
    escala          TEXT NOT NULL DEFAULT 'Unidad' CHECK (escala IN ('Unidad','Miles','Millones','Miles de millones')),
    fuente          TEXT NOT NULL,
    fuente_url      TEXT,
    tipo            TEXT NOT NULL DEFAULT 'directa' CHECK (tipo IN ('directa','derivada')),
    formula         TEXT,
    transformacion  TEXT,
    activo          BOOLEAN NOT NULL DEFAULT TRUE,
    creado_en       TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    actualizado_en  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_variables_modulo     ON variables(modulo);
CREATE INDEX IF NOT EXISTS idx_variables_fuente     ON variables(fuente);
CREATE INDEX IF NOT EXISTS idx_variables_frecuencia ON variables(frecuencia);
CREATE INDEX IF NOT EXISTS idx_variables_tipo       ON variables(tipo);

ALTER TABLE variables ADD COLUMN IF NOT EXISTS escala  TEXT NOT NULL DEFAULT 'Unidad';
ALTER TABLE variables ADD COLUMN IF NOT EXISTS tipo    TEXT NOT NULL DEFAULT 'directa';
ALTER TABLE variables ADD COLUMN IF NOT EXISTS formula TEXT;

-- SERIE DE TIEMPO (HECHOS)
CREATE TABLE IF NOT EXISTS series_datos (
    variable_id     TEXT NOT NULL REFERENCES variables(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    fecha           DATE NOT NULL,
    valor           DOUBLE PRECISION,
    flag            TEXT,
    fuente_raw      TEXT,
    ingesta_id      BIGINT,
    actualizado_en  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    PRIMARY KEY (variable_id, fecha)
);

CREATE INDEX IF NOT EXISTS idx_series_fecha           ON series_datos(fecha);
CREATE INDEX IF NOT EXISTS idx_series_variable        ON series_datos(variable_id);
CREATE INDEX IF NOT EXISTS idx_series_variable_fecha  ON series_datos(variable_id, fecha DESC);

-- BITÁCORA DE INGESTAS
CREATE TABLE IF NOT EXISTS ingestas (
    id                  BIGSERIAL PRIMARY KEY,
    pipeline            TEXT NOT NULL,
    ejecutado_en        TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    duracion_seg        INTEGER,
    filas_insertadas    INTEGER,
    filas_actualizadas  INTEGER,
    estado              TEXT NOT NULL CHECK (estado IN ('ok','warning','error')),
    mensaje             TEXT,
    run_url             TEXT
);

CREATE INDEX IF NOT EXISTS idx_ingestas_pipeline ON ingestas(pipeline, ejecutado_en DESC);

-- HISTÓRICO TPM
CREATE TABLE IF NOT EXISTS tpm_historico (
    fecha_anuncio  DATE PRIMARY KEY,
    tpm_pct        DOUBLE PRECISION NOT NULL,
    cambio_pb      DOUBLE PRECISION,
    nota           TEXT,
    fuente_url     TEXT
);

-- VISTA CONVENIENTE
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

-- ============================================================================
-- RLS: Lectura pública (sin autenticación) para el dashboard
-- ============================================================================
ALTER TABLE variables    ENABLE ROW LEVEL SECURITY;
ALTER TABLE series_datos ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "lectura_publica_variables"    ON variables;
DROP POLICY IF EXISTS "lectura_publica_series_datos" ON series_datos;

CREATE POLICY "lectura_publica_variables"
    ON variables FOR SELECT
    USING (true);

CREATE POLICY "lectura_publica_series_datos"
    ON series_datos FOR SELECT
    USING (true);
