-- ============================================================================
-- Catálogo de Variables — generado desde core/catalog_r.py
-- Total: 478 variables
-- ============================================================================
-- Idempotente: re-correr no rompe nada; actualiza nombre/módulo/etc.
BEGIN;

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('tcn_compra', 'Tipo de Cambio Compra (diaria)', NULL, 'Mercado Cambiario', NULL, 'diaria', 'RD$/US$', 'Unidad', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('tcn_venta', 'Tipo de Cambio Venta (diaria)', NULL, 'Mercado Cambiario', NULL, 'diaria', 'RD$/US$', 'Unidad', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('tcn_venta_eur', 'Tipo de Cambio Venta EUR (diaria)', NULL, 'Mercado Cambiario', NULL, 'diaria', 'RD$/EUR', 'Unidad', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('tcn_usa_spread', 'Spread Venta - Compra', NULL, 'Mercado Cambiario', NULL, 'diaria', 'RD$/US$', 'Unidad', 'Derivada', NULL, 'derivada', 'tcn_venta - tcn_compra', TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('embi', 'EMBI RD diario', NULL, 'Financiero', NULL, 'diaria', 'pbs', 'Unidad', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('p_petroleo_d', 'Petróleo WTI (diario)', NULL, 'Externo', NULL, 'diaria', 'US$/barril', 'Unidad', 'Yahoo', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('p_oro_d', 'Oro (diario)', NULL, 'Externo', NULL, 'diaria', 'US$/oz', 'Unidad', 'Yahoo', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('p_gas_nat_d', 'Gas Natural (diario)', NULL, 'Externo', NULL, 'diaria', 'US$/MMBtu', 'Unidad', 'Yahoo', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('carb_aus_d', 'Carbón Australiano (diario)', NULL, 'Externo', NULL, 'diaria', 'US$/ton', 'Unidad', 'Yahoo', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('sp500_d', 'S&P 500 (diario)', NULL, 'Financiero', NULL, 'diaria', 'índice', 'Unidad', 'Yahoo', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('dow_jones_d', 'Dow Jones (diario)', NULL, 'Financiero', NULL, 'diaria', 'índice', 'Unidad', 'Yahoo', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('vix_d', 'VIX (diario)', NULL, 'Financiero', NULL, 'diaria', 'índice', 'Unidad', 'Yahoo', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('dgs10_d', 'Tasa Tesoro EE.UU. 10 años (DGS10)', NULL, 'Financiero', NULL, 'diaria', '%', 'Unidad', 'FRED', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('tap_rd', 'Tasa Activa Promedio RD (diaria)', NULL, 'Financiero', NULL, 'diaria', '%', 'Unidad', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('tpp_rd', 'Tasa Pasiva Promedio RD (diaria)', NULL, 'Financiero', NULL, 'diaria', '%', 'Unidad', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('tap_us', 'Tasa Activa Promedio US$ (diaria)', NULL, 'Financiero', NULL, 'diaria', '%', 'Unidad', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('tpp_us', 'Tasa Pasiva Promedio US$ (diaria)', NULL, 'Financiero', NULL, 'diaria', '%', 'Unidad', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('imae', 'IMAE - Indice Mensual de Actividad Económica', NULL, 'Real', NULL, 'mensual', 'índice', 'Unidad', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('pib_real', 'PIB real mensual (interanual)', NULL, 'Real', NULL, 'mensual', '%', 'Unidad', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('inf_rd', 'Inflación interanual RD', NULL, 'Precios', NULL, 'mensual', '%', 'Unidad', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('inf_sub', 'Inflación subyacente interanual', NULL, 'Precios', NULL, 'mensual', '%', 'Unidad', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('inf_trans', 'Inflación transables', NULL, 'Precios', NULL, 'mensual', '%', 'Unidad', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('inf_no_trans', 'Inflación no transables', NULL, 'Precios', NULL, 'mensual', '%', 'Unidad', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('inf_AyBNA', 'Inflación Alimentos y Bebidas No Alcohólicas', NULL, 'Precios', NULL, 'mensual', '%', 'Unidad', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('inf_BAyT', 'Inflación Bebidas Alcohólicas y Tabaco', NULL, 'Precios', NULL, 'mensual', '%', 'Unidad', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('inf_vestir', 'Inflación Vestir y Calzado', NULL, 'Precios', NULL, 'mensual', '%', 'Unidad', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('inf_viv', 'Inflación Vivienda', NULL, 'Precios', NULL, 'mensual', '%', 'Unidad', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('inf_mue', 'Inflación Muebles', NULL, 'Precios', NULL, 'mensual', '%', 'Unidad', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('inf_sal', 'Inflación Salud', NULL, 'Precios', NULL, 'mensual', '%', 'Unidad', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('inf_transport', 'Inflación Transporte', NULL, 'Precios', NULL, 'mensual', '%', 'Unidad', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('inf_com', 'Inflación Comunicación', NULL, 'Precios', NULL, 'mensual', '%', 'Unidad', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('inf_Ryc', 'Inflación Recreación y Cultura', NULL, 'Precios', NULL, 'mensual', '%', 'Unidad', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('inf_edu', 'Inflación Educación', NULL, 'Precios', NULL, 'mensual', '%', 'Unidad', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('inf_RyH', 'Inflación Restaurantes y Hoteles', NULL, 'Precios', NULL, 'mensual', '%', 'Unidad', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('inf_BySD', 'Inflación Bienes y Servicios Diversos', NULL, 'Precios', NULL, 'mensual', '%', 'Unidad', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('ICI', 'Índice de Confianza al Consumidor', NULL, 'Real', NULL, 'mensual', 'índice', 'Unidad', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('tcn_compra_m', 'Tipo de Cambio Compra (mensual)', NULL, 'Mercado Cambiario', NULL, 'mensual', 'RD$/US$', 'Unidad', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('tcn_venta_m', 'Tipo de Cambio Venta (mensual)', NULL, 'Mercado Cambiario', NULL, 'mensual', 'RD$/US$', 'Unidad', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('tcn_eur_m', 'Tipo de Cambio Venta EUR (mensual)', NULL, 'Mercado Cambiario', NULL, 'mensual', 'RD$/EUR', 'Unidad', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('tcr_rd', 'Tipo de Cambio Real RD', NULL, 'Mercado Cambiario', NULL, 'mensual', 'índice', 'Unidad', 'Derivada', NULL, 'derivada', '(tcn_venta_m/1.358727436 * ipc_eeuu/218.076*100)/inf_rd', TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('tcn_usa_spread_m', 'Spread Venta-Compra (mensual)', NULL, 'Mercado Cambiario', NULL, 'mensual', 'RD$/US$', 'Unidad', 'Derivada', NULL, 'derivada', 'tcn_venta_m - tcn_compra_m', TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('imp_pd_va', 'Importaciones petroleras (valor)', NULL, 'Externo', NULL, 'mensual', 'US$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('m_pqoil_rd', 'Importaciones petroleras (cantidad)', NULL, 'Externo', NULL, 'mensual', 'MM barriles', 'Unidad', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('rem_fam', 'Remesas familiares', NULL, 'Externo', NULL, 'mensual', 'US$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('se_cc_numtur', 'Llegada de Turistas', NULL, 'Externo', NULL, 'mensual', 'personas', 'Unidad', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('export', 'Exportaciones (DGA)', NULL, 'Externo', NULL, 'mensual', 'US$', 'Millones', 'DGA', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('import', 'Importaciones (DGA)', NULL, 'Externo', NULL, 'mensual', 'US$', 'Millones', 'DGA', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('rin', 'Reservas Internacionales Netas', NULL, 'Externo', NULL, 'mensual', 'US$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('embi_rd', 'EMBI RD (mensual)', NULL, 'Financiero', NULL, 'mensual', 'pbs', 'Unidad', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('bmr_rd', 'Base Monetaria Restringida', NULL, 'Monetario', NULL, 'mensual', 'RD$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('M1', 'Medio Circulante M1', NULL, 'Monetario', NULL, 'mensual', 'RD$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('M2', 'Medio Circulante M2', NULL, 'Monetario', NULL, 'mensual', 'RD$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('M3', 'Medio Circulante M3', NULL, 'Monetario', NULL, 'mensual', 'RD$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('encajemn_d_q', 'Encaje legal MN (disponible vs requerido)', NULL, 'Monetario', NULL, 'mensual', '%', 'Unidad', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('encajeme_d_q', 'Encaje legal ME (disponible vs requerido)', NULL, 'Monetario', NULL, 'mensual', '%', 'Unidad', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('compra_fx_tot', 'Compra total US$ (Operaciones)', NULL, 'Mercado Cambiario', NULL, 'mensual', 'US$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('sm_bcrd_vc', 'Valores en circulación BCRD', NULL, 'Monetario', NULL, 'mensual', 'RD$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('prest_tot', 'Préstamos al Sector Privado (consolidado)', NULL, 'Financiero', 'credito', 'mensual', 'RD$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('prest_agr', 'Préstamos Agricultura, Silvicultura y Pesca', NULL, 'Financiero', 'credito', 'mensual', 'RD$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('prest_ind', 'Préstamos Industrias Manufactureras', NULL, 'Financiero', 'credito', 'mensual', 'RD$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('prest_con', 'Préstamos Construcción', NULL, 'Financiero', 'credito', 'mensual', 'RD$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('prest_com', 'Préstamos Comercio', NULL, 'Financiero', 'credito', 'mensual', 'RD$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('prest_viv', 'Préstamos Adquisición de Viviendas', NULL, 'Financiero', 'credito', 'mensual', 'RD$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('prest_cons', 'Préstamos de Consumo', NULL, 'Financiero', 'credito', 'mensual', 'RD$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('prest_tar', 'Préstamos Tarjetas de Crédito', NULL, 'Financiero', 'credito', 'mensual', 'RD$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('pvcred_nc_rd', 'Crédito Sector Privado M/N', NULL, 'Financiero', NULL, 'mensual', 'RD$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('pbcred_nc_rd', 'Crédito Sector Público M/N', NULL, 'Financiero', NULL, 'mensual', 'RD$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('tia_prom_pond_rd', 'Tasa Interés Activa Promedio Ponderada', NULL, 'Financiero', NULL, 'mensual', '%', 'Unidad', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('tip_prom_pond', 'Tasa Interés Pasiva Promedio Ponderada', NULL, 'Financiero', NULL, 'mensual', '%', 'Unidad', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('tia_90', 'Tasa Activa 0-90 días', NULL, 'Financiero', NULL, 'mensual', '%', 'Unidad', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('tia_5yr', 'Tasa Activa 2-5 años', NULL, 'Financiero', NULL, 'mensual', '%', 'Unidad', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('tib_rd', 'Tasa Interbancaria RD', NULL, 'Financiero', NULL, 'mensual', '%', 'Unidad', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('tpm', 'Tasa de Política Monetaria', NULL, 'Monetario', NULL, 'mensual', '%', 'Unidad', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('DEPOS', 'Tasa de depósito de facilidad permanente', NULL, 'Monetario', NULL, 'mensual', '%', 'Unidad', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('REPOS', 'Tasa Repos overnight', NULL, 'Monetario', NULL, 'mensual', '%', 'Unidad', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('vol_tip', 'Volatilidad tasa pasiva (* 2.33)', NULL, 'Financiero', NULL, 'mensual', '%', 'Unidad', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('sd_tip', 'Desv. típica tasa pasiva', NULL, 'Financiero', NULL, 'mensual', '%', 'Unidad', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('p_petroleo', 'Petróleo WTI (mensual, WB)', NULL, 'Externo', NULL, 'mensual', 'US$/barril', 'Unidad', 'BancoMundial', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('p_gas_nat', 'Gas Natural (mensual, WB)', NULL, 'Externo', NULL, 'mensual', 'US$/MMBtu', 'Unidad', 'BancoMundial', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('p_oro', 'Oro (mensual, WB)', NULL, 'Externo', NULL, 'mensual', 'US$/oz', 'Unidad', 'BancoMundial', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('ind_p_AyB', 'Índice precios Alimentos y Bebidas (WB)', NULL, 'Externo', NULL, 'mensual', 'índice', 'Unidad', 'BancoMundial', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('ener_ind', 'Índice precios Energía (WB)', NULL, 'Externo', NULL, 'mensual', 'índice', 'Unidad', 'BancoMundial', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('non_ener_ind', 'Índice precios No Energía (WB)', NULL, 'Externo', NULL, 'mensual', 'índice', 'Unidad', 'BancoMundial', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('food_ind', 'Índice precios Alimentos (WB)', NULL, 'Externo', NULL, 'mensual', 'índice', 'Unidad', 'BancoMundial', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('metals_ind', 'Índice precios Metales (WB)', NULL, 'Externo', NULL, 'mensual', 'índice', 'Unidad', 'BancoMundial', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('prec_metal_ind', 'Índice precios Metales Preciosos (WB)', NULL, 'Externo', NULL, 'mensual', 'índice', 'Unidad', 'BancoMundial', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('vix', 'VIX (mensual)', NULL, 'Financiero', NULL, 'mensual', 'índice', 'Unidad', 'Yahoo', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('bolsa_DowJones', 'Dow Jones (mensual)', NULL, 'Financiero', NULL, 'mensual', 'índice', 'Unidad', 'Yahoo', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('ipc_eeuu', 'IPC EE.UU. (CPIAUCSL)', NULL, 'Externo', NULL, 'mensual', 'índice', 'Unidad', 'FRED', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('indpro_usa', 'Producción Industrial EE.UU. (INDPRO)', NULL, 'Externo', NULL, 'mensual', 'índice', 'Unidad', 'FRED', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('indproMan_usa', 'Producción Industrial Manufactura EE.UU.', NULL, 'Externo', NULL, 'mensual', 'índice', 'Unidad', 'FRED', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('epu_eeuu', 'Índice de Incertidumbre Política EE.UU.', NULL, 'Externo', NULL, 'mensual', 'índice', 'Unidad', 'FRED', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('epu_global', 'Índice de Incertidumbre Política Global', NULL, 'Externo', NULL, 'mensual', 'índice', 'Unidad', 'FRED', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('ti_fond_fed', 'Fed Funds Rate', NULL, 'Externo', NULL, 'mensual', '%', 'Unidad', 'FRED', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('ur_usa', 'Desempleo EE.UU. (no ajust.)', NULL, 'Externo', NULL, 'mensual', '%', 'Unidad', 'FRED', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('ur_sa_usa', 'Desempleo EE.UU. (ajustado)', NULL, 'Externo', NULL, 'mensual', '%', 'Unidad', 'FRED', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('ing_trib', 'Ingresos Tributarios (Hacienda EO)', NULL, 'Fiscal', NULL, 'mensual', 'RD$', 'Millones', 'Hacienda', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('gk', 'Gasto de Capital (Hacienda EO)', NULL, 'Fiscal', NULL, 'mensual', 'RD$', 'Millones', 'Hacienda', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('ventas_dgii_rd', 'Ventas Totales DGII (ITBIS)', NULL, 'Fiscal', NULL, 'mensual', 'RD$', 'Millones', 'DGII', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('ventas_const', 'Ventas DGII - Construcción', NULL, 'Fiscal', NULL, 'mensual', 'RD$', 'Millones', 'DGII', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('ventas_mineria', 'Ventas DGII - Minería', NULL, 'Fiscal', NULL, 'mensual', 'RD$', 'Millones', 'DGII', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('ventas_manuf', 'Ventas DGII - Manufactura', NULL, 'Fiscal', NULL, 'mensual', 'RD$', 'Millones', 'DGII', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('ventas_comercio', 'Ventas DGII - Comercio', NULL, 'Fiscal', NULL, 'mensual', 'RD$', 'Millones', 'DGII', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('ventas_hoteles', 'Ventas DGII - Hoteles, Bares, Restaurantes', NULL, 'Fiscal', NULL, 'mensual', 'RD$', 'Millones', 'DGII', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('ventas_transp', 'Ventas DGII - Transporte', NULL, 'Fiscal', NULL, 'mensual', 'RD$', 'Millones', 'DGII', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('ventas_otros', 'Ventas DGII - Otros (residual)', NULL, 'Fiscal', NULL, 'mensual', 'RD$', 'Millones', 'Derivada', NULL, 'derivada', 'ventas_dgii_rd - (ventas_const+ventas_mineria+ventas_manuf+ventas_comercio+ventas_hoteles+ventas_transp)', TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('Hidro_av', 'Recaudo Hidrocarburos Ad Valorem', NULL, 'Fiscal', NULL, 'mensual', 'RD$', 'Millones', 'DGII', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('Hidro_esp', 'Recaudo Hidrocarburos Específico', NULL, 'Fiscal', NULL, 'mensual', 'RD$', 'Millones', 'DGII', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('itbis_ret_ca', 'Retención ITBIS Comprobantes (CA)', NULL, 'Fiscal', NULL, 'mensual', 'RD$', 'Millones', 'DGII', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('imp_cheq', 'Impuesto al Cheque', NULL, 'Fiscal', NULL, 'mensual', 'RD$', 'Millones', 'DGII', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('salario', 'Salario promedio (SIPEN)', NULL, 'Real', NULL, 'mensual', 'RD$', 'Unidad', 'SIPEN', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('cot_tss', 'Cotizantes al SDSS', NULL, 'Real', NULL, 'mensual', 'personas', 'Unidad', 'SIPEN', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('pib_nom', 'PIB Nominal', NULL, 'Real', NULL, 'trimestral', 'RD$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('ct_nom', 'Consumo Total Nominal', NULL, 'Real', NULL, 'trimestral', 'RD$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('cpr_nom', 'Consumo Privado Nominal', NULL, 'Real', NULL, 'trimestral', 'RD$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('cpu_nom', 'Consumo Público Nominal', NULL, 'Real', NULL, 'trimestral', 'RD$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('fbkt', 'Formación Bruta Capital Total', NULL, 'Real', NULL, 'trimestral', 'RD$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('fbkf_nom', 'FBKF Nominal', NULL, 'Real', NULL, 'trimestral', 'RD$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('ve', 'Variación de Existencias', NULL, 'Real', NULL, 'trimestral', 'RD$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('exp_nom', 'Exportaciones Nominal', NULL, 'Real', NULL, 'trimestral', 'RD$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('imp_nom', 'Importaciones Nominal', NULL, 'Real', NULL, 'trimestral', 'RD$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('ct_real', 'Consumo Total Real', NULL, 'Real', NULL, 'trimestral', 'RD$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('cpr_real', 'Consumo Privado Real', NULL, 'Real', NULL, 'trimestral', 'RD$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('cpu_real', 'Consumo Público Real', NULL, 'Real', NULL, 'trimestral', 'RD$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('fbkf_real', 'FBKF Real', NULL, 'Real', NULL, 'trimestral', 'RD$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('exp_real', 'Exportaciones Real', NULL, 'Real', NULL, 'trimestral', 'RD$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('imp_real', 'Importaciones Real', NULL, 'Real', NULL, 'trimestral', 'RD$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('pib_real_trim', 'PIB Real (trimestral)', NULL, 'Real', NULL, 'trimestral', 'RD$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('defl_pib', 'Deflactor del PIB', NULL, 'Real', NULL, 'trimestral', 'índice', 'Unidad', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('inc_con', 'Incidencia Consumo en PIB', NULL, 'Real', NULL, 'trimestral', 'pp', 'Unidad', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('inc_fbkf', 'Incidencia FBKF en PIB', NULL, 'Real', NULL, 'trimestral', 'pp', 'Unidad', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('inc_exp', 'Incidencia Exportaciones en PIB', NULL, 'Real', NULL, 'trimestral', 'pp', 'Unidad', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('inc_imp', 'Incidencia Importaciones en PIB', NULL, 'Real', NULL, 'trimestral', 'pp', 'Unidad', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('pond_cpr', 'Ponderación Consumo Privado', NULL, 'Real', NULL, 'trimestral', '%', 'Unidad', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('pond_cpu', 'Ponderación Consumo Público', NULL, 'Real', NULL, 'trimestral', '%', 'Unidad', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('pond_fbkf', 'Ponderación FBKF', NULL, 'Real', NULL, 'trimestral', '%', 'Unidad', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('pond_exp', 'Ponderación Exportaciones', NULL, 'Real', NULL, 'trimestral', '%', 'Unidad', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('pond_imp', 'Ponderación Importaciones', NULL, 'Real', NULL, 'trimestral', '%', 'Unidad', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('inc_agr', 'Incidencia Agropecuario en PIB', NULL, 'Real', NULL, 'trimestral', 'pp', 'Unidad', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('inc_ind', 'Incidencia Industria en PIB', NULL, 'Real', NULL, 'trimestral', 'pp', 'Unidad', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('inc_ser', 'Incidencia Servicios en PIB', NULL, 'Real', NULL, 'trimestral', 'pp', 'Unidad', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('agro_real', 'PIB Agropecuario Real', NULL, 'Real', NULL, 'trimestral', 'RD$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('minas_real', 'PIB Minería Real', NULL, 'Real', NULL, 'trimestral', 'RD$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('manzf_real', 'PIB Manufactura Zonas Francas Real', NULL, 'Real', NULL, 'trimestral', 'RD$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('cons_real', 'PIB Construcción Real', NULL, 'Real', NULL, 'trimestral', 'RD$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('serv_real', 'PIB Servicios Real', NULL, 'Real', NULL, 'trimestral', 'RD$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('com_real', 'PIB Comercio Real', NULL, 'Real', NULL, 'trimestral', 'RD$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('HByR_real', 'PIB Hoteles, Bares y Restaurantes Real', NULL, 'Real', NULL, 'trimestral', 'RD$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('trans_real', 'PIB Transporte Real', NULL, 'Real', NULL, 'trimestral', 'RD$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('intfin_real', 'PIB Intermediación Financiera Real', NULL, 'Real', NULL, 'trimestral', 'RD$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('viv_real', 'PIB Vivienda Real', NULL, 'Real', NULL, 'trimestral', 'RD$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('otros_real', 'PIB Otros sectores Real', NULL, 'Real', NULL, 'trimestral', 'RD$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('adminpub_real', 'PIB Administración Pública Real', NULL, 'Real', NULL, 'trimestral', 'RD$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('l_enftc_empalmado', 'Ocupados (ENFT empalmada)', NULL, 'Real', NULL, 'trimestral', 'personas', 'Unidad', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('wnom_enftc_empalmado', 'Ingreso laboral nominal/hora (ENFT)', NULL, 'Real', NULL, 'trimestral', 'RD$', 'Unidad', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('hrs_enftc_empalmado', 'Horas trabajadas (ENFT)', NULL, 'Real', NULL, 'trimestral', 'horas', 'Unidad', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('pib_eeuu', 'PIB EE.UU. real (GDPC1)', NULL, 'Externo', NULL, 'trimestral', 'US$', 'Miles de millones', 'FRED', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('x_ncnl', 'Exportaciones nacionales', NULL, 'Externo', 'bop', 'trimestral', 'US$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('x_zf', 'Exportaciones zonas francas', NULL, 'Externo', 'bop', 'trimestral', 'US$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('m_ncnl', 'Importaciones nacionales', NULL, 'Externo', 'bop', 'trimestral', 'US$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('m_zf', 'Importaciones zonas francas', NULL, 'Externo', 'bop', 'trimestral', 'US$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('viajes', 'Servicios - Viajes', NULL, 'Externo', 'bop', 'trimestral', 'US$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('serv_mifpt', 'Servicios - Manufactura int. e info., telecomunicaciones', NULL, 'Externo', 'bop', 'trimestral', 'US$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('otros_serv_cred', 'Otros servicios (crédito)', NULL, 'Externo', 'bop', 'trimestral', 'US$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('fletes', 'Servicios - Fletes', NULL, 'Externo', 'bop', 'trimestral', 'US$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('otros_serv_deb', 'Otros servicios (débito)', NULL, 'Externo', 'bop', 'trimestral', 'US$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('remu_empl', 'Remuneración empleados', NULL, 'Externo', 'bop', 'trimestral', 'US$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('ied', 'Inversión extranjera directa', NULL, 'Externo', 'bop', 'trimestral', 'US$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('idc', 'Inversión directa cartera', NULL, 'Externo', 'bop', 'trimestral', 'US$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('otra_i', 'Otra inversión', NULL, 'Externo', 'bop', 'trimestral', 'US$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('adr', 'Activos de reserva (cambio)', NULL, 'Externo', 'bop', 'trimestral', 'US$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('rem_fam_cred', 'Remesas familiares (crédito)', NULL, 'Externo', 'bop', 'trimestral', 'US$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('otras_transf_cred', 'Otras transferencias (crédito)', NULL, 'Externo', 'bop', 'trimestral', 'US$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('rem_fam_deb', 'Remesas familiares (débito)', NULL, 'Externo', 'bop', 'trimestral', 'US$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('otras_transf_deb', 'Otras transferencias (débito)', NULL, 'Externo', 'bop', 'trimestral', 'US$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('cuenta_cap', 'Cuenta de capital', NULL, 'Externo', 'bop', 'trimestral', 'US$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('id', 'Inversión directa', NULL, 'Externo', 'bop', 'trimestral', 'US$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('inv_cart', 'Inversión de cartera', NULL, 'Externo', 'bop', 'trimestral', 'US$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('dpp_mlp', 'Deuda pasiva pública MLP', NULL, 'Externo', 'bop', 'trimestral', 'US$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('dpp_cp', 'Deuda pasiva pública CP', NULL, 'Externo', 'bop', 'trimestral', 'US$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('myd', 'Moneda y depósitos', NULL, 'Externo', 'bop', 'trimestral', 'US$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('otros_cf', 'Otros capital financiero', NULL, 'Externo', 'bop', 'trimestral', 'US$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('saldo', 'Saldo balanza de pagos', NULL, 'Externo', 'bop', 'trimestral', 'US$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('eyo', 'Errores y omisiones', NULL, 'Externo', 'bop', 'trimestral', 'US$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('adr_financ', 'ADR financieros', NULL, 'Externo', 'bop', 'trimestral', 'US$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('u_cpfmi', 'Uso crédito FMI', NULL, 'Externo', 'bop', 'trimestral', 'US$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('transf_financ', 'Transferencias financieras', NULL, 'Externo', 'bop', 'trimestral', 'US$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('otra_inv_pas', 'Otra inversión pasivos', NULL, 'Externo', 'bop', 'trimestral', 'US$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('a_pc_ide', 'Activos PC IDE', NULL, 'Externo', 'pii', 'trimestral', 'US$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('a_pc_eid', 'Activos PC EID', NULL, 'Externo', 'pii', 'trimestral', 'US$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('a_pc_eee', 'Activos PC EEE', NULL, 'Externo', 'pii', 'trimestral', 'US$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('a_inst_ide', 'Activos Instituciones IDE', NULL, 'Externo', 'pii', 'trimestral', 'US$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('a_inst_eid', 'Activos Instituciones EID', NULL, 'Externo', 'pii', 'trimestral', 'US$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('a_inst_eee', 'Activos Instituciones EEE', NULL, 'Externo', 'pii', 'trimestral', 'US$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('a_bc_pcf', 'Activos BC PCF', NULL, 'Externo', 'pii', 'trimestral', 'US$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('a_sd_pcf', 'Activos SD PCF', NULL, 'Externo', 'pii', 'trimestral', 'US$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('a_gg_pcf', 'Activos GG PCF', NULL, 'Externo', 'pii', 'trimestral', 'US$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('a_osf_pcf', 'Activos OSF PCF', NULL, 'Externo', 'pii', 'trimestral', 'US$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('a_snfhsfl_pcf', 'Activos SNFHSFL PCF', NULL, 'Externo', 'pii', 'trimestral', 'US$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('a_bc_td', 'Activos BC TD', NULL, 'Externo', 'pii', 'trimestral', 'US$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('a_sd_td', 'Activos SD TD', NULL, 'Externo', 'pii', 'trimestral', 'US$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('a_gg_td', 'Activos GG TD', NULL, 'Externo', 'pii', 'trimestral', 'US$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('a_osf_td', 'Activos OSF TD', NULL, 'Externo', 'pii', 'trimestral', 'US$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('a_snfhsfl_td', 'Activos SNFHSFL TD', NULL, 'Externo', 'pii', 'trimestral', 'US$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('a_dfoc', 'Activos DFOC', NULL, 'Externo', 'pii', 'trimestral', 'US$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('a_opc', 'Activos OPC', NULL, 'Externo', 'pii', 'trimestral', 'US$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('a_bc_md', 'Activos BC MD', NULL, 'Externo', 'pii', 'trimestral', 'US$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('a_sd_md', 'Activos SD MD', NULL, 'Externo', 'pii', 'trimestral', 'US$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('a_gg_md', 'Activos GG MD', NULL, 'Externo', 'pii', 'trimestral', 'US$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('a_osf_md', 'Activos OSF MD', NULL, 'Externo', 'pii', 'trimestral', 'US$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('a_snfhsfl_md', 'Activos SNFHSFL MD', NULL, 'Externo', 'pii', 'trimestral', 'US$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('a_bc_pms', 'Activos BC PMS', NULL, 'Externo', 'pii', 'trimestral', 'US$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('a_sd_pms', 'Activos SD PMS', NULL, 'Externo', 'pii', 'trimestral', 'US$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('a_gg_pms', 'Activos GG PMS', NULL, 'Externo', 'pii', 'trimestral', 'US$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('a_osf_pms', 'Activos OSF PMS', NULL, 'Externo', 'pii', 'trimestral', 'US$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('a_snfhsfl_pms', 'Activos SNFHSFL PMS', NULL, 'Externo', 'pii', 'trimestral', 'US$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('a_segpen', 'Activos Seguros y Pensiones', NULL, 'Externo', 'pii', 'trimestral', 'US$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('a_bc_cac', 'Activos BC CAC', NULL, 'Externo', 'pii', 'trimestral', 'US$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('a_sd_cac', 'Activos SD CAC', NULL, 'Externo', 'pii', 'trimestral', 'US$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('a_gg_cac', 'Activos GG CAC', NULL, 'Externo', 'pii', 'trimestral', 'US$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('a_osf_cac', 'Activos OSF CAC', NULL, 'Externo', 'pii', 'trimestral', 'US$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('a_snfhsfl_cac', 'Activos SNFHSFL CAC', NULL, 'Externo', 'pii', 'trimestral', 'US$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('a_bc_ocpc', 'Activos BC OCPC', NULL, 'Externo', 'pii', 'trimestral', 'US$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('a_sd_ocpc', 'Activos SD OCPC', NULL, 'Externo', 'pii', 'trimestral', 'US$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('a_gg_ocpc', 'Activos GG OCPC', NULL, 'Externo', 'pii', 'trimestral', 'US$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('a_osf_ocpc', 'Activos OSF OCPC', NULL, 'Externo', 'pii', 'trimestral', 'US$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('a_snfhsfl_ocpc', 'Activos SNFHSFL OCPC', NULL, 'Externo', 'pii', 'trimestral', 'US$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('a_lingoro', 'Activos Lingotes de Oro', NULL, 'Externo', 'pii', 'trimestral', 'US$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('a_coro_nasg', 'Activos Otros Oro NASG', NULL, 'Externo', 'pii', 'trimestral', 'US$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('a_dereg', 'Activos DEG', NULL, 'Externo', 'pii', 'trimestral', 'US$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('a_pres_fmi', 'Activos Préstamos FMI', NULL, 'Externo', 'pii', 'trimestral', 'US$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('a_deraam', 'Activos DERAAM', NULL, 'Externo', 'pii', 'trimestral', 'US$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('a_deraoe', 'Activos DERAOE', NULL, 'Externo', 'pii', 'trimestral', 'US$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('a_td_tv', 'Activos TD TV', NULL, 'Externo', 'pii', 'trimestral', 'US$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('a_pcf_tv', 'Activos PCF TV', NULL, 'Externo', 'pii', 'trimestral', 'US$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('a_drvfin', 'Activos Derivados Financieros', NULL, 'Externo', 'pii', 'trimestral', 'US$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('a_oda', 'Activos ODA', NULL, 'Externo', 'pii', 'trimestral', 'US$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('p_pc_ide', 'Pasivos PC IDE', NULL, 'Externo', 'pii', 'trimestral', 'US$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('p_pc_eid', 'Pasivos PC EID', NULL, 'Externo', 'pii', 'trimestral', 'US$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('p_pc_eee', 'Pasivos PC EEE', NULL, 'Externo', 'pii', 'trimestral', 'US$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('p_inst_ide', 'Pasivos Instituciones IDE', NULL, 'Externo', 'pii', 'trimestral', 'US$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('p_inst_eid', 'Pasivos Instituciones EID', NULL, 'Externo', 'pii', 'trimestral', 'US$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('p_inst_eee', 'Pasivos Instituciones EEE', NULL, 'Externo', 'pii', 'trimestral', 'US$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('p_bc_pcf', 'Pasivos BC PCF', NULL, 'Externo', 'pii', 'trimestral', 'US$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('p_sd_pcf', 'Pasivos SD PCF', NULL, 'Externo', 'pii', 'trimestral', 'US$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('p_gg_pcf', 'Pasivos GG PCF', NULL, 'Externo', 'pii', 'trimestral', 'US$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('p_osf_pcf', 'Pasivos OSF PCF', NULL, 'Externo', 'pii', 'trimestral', 'US$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('p_snfhsfl_pcf', 'Pasivos SNFHSFL PCF', NULL, 'Externo', 'pii', 'trimestral', 'US$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('p_bc_td', 'Pasivos BC TD', NULL, 'Externo', 'pii', 'trimestral', 'US$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('p_sd_td', 'Pasivos SD TD', NULL, 'Externo', 'pii', 'trimestral', 'US$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('p_gg_td', 'Pasivos GG TD', NULL, 'Externo', 'pii', 'trimestral', 'US$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('p_osf_td', 'Pasivos OSF TD', NULL, 'Externo', 'pii', 'trimestral', 'US$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('p_snfhsfl_td', 'Pasivos SNFHSFL TD', NULL, 'Externo', 'pii', 'trimestral', 'US$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('p_dfoc', 'Pasivos DFOC', NULL, 'Externo', 'pii', 'trimestral', 'US$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('p_opc', 'Pasivos OPC', NULL, 'Externo', 'pii', 'trimestral', 'US$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('p_bc_md', 'Pasivos BC MD', NULL, 'Externo', 'pii', 'trimestral', 'US$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('p_sd_md', 'Pasivos SD MD', NULL, 'Externo', 'pii', 'trimestral', 'US$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('p_gg_md', 'Pasivos GG MD', NULL, 'Externo', 'pii', 'trimestral', 'US$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('p_osf_md', 'Pasivos OSF MD', NULL, 'Externo', 'pii', 'trimestral', 'US$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('p_snfhsfl_md', 'Pasivos SNFHSFL MD', NULL, 'Externo', 'pii', 'trimestral', 'US$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('p_bc_pms', 'Pasivos BC PMS', NULL, 'Externo', 'pii', 'trimestral', 'US$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('p_sd_pms', 'Pasivos SD PMS', NULL, 'Externo', 'pii', 'trimestral', 'US$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('p_gg_pms', 'Pasivos GG PMS', NULL, 'Externo', 'pii', 'trimestral', 'US$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('p_osf_pms', 'Pasivos OSF PMS', NULL, 'Externo', 'pii', 'trimestral', 'US$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('p_snfhsfl_pms', 'Pasivos SNFHSFL PMS', NULL, 'Externo', 'pii', 'trimestral', 'US$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('p_segpen', 'Pasivos Seguros y Pensiones', NULL, 'Externo', 'pii', 'trimestral', 'US$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('p_bc_cac', 'Pasivos BC CAC', NULL, 'Externo', 'pii', 'trimestral', 'US$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('p_sd_cac', 'Pasivos SD CAC', NULL, 'Externo', 'pii', 'trimestral', 'US$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('p_gg_cac', 'Pasivos GG CAC', NULL, 'Externo', 'pii', 'trimestral', 'US$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('p_osf_cac', 'Pasivos OSF CAC', NULL, 'Externo', 'pii', 'trimestral', 'US$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('p_snfhsfl_cac', 'Pasivos SNFHSFL CAC', NULL, 'Externo', 'pii', 'trimestral', 'US$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('p_bc_ocpc', 'Pasivos BC OCPC', NULL, 'Externo', 'pii', 'trimestral', 'US$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('p_sd_ocpc', 'Pasivos SD OCPC', NULL, 'Externo', 'pii', 'trimestral', 'US$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('p_gg_ocpc', 'Pasivos GG OCPC', NULL, 'Externo', 'pii', 'trimestral', 'US$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('p_osf_ocpc', 'Pasivos OSF OCPC', NULL, 'Externo', 'pii', 'trimestral', 'US$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('p_snfhsfl_ocpc', 'Pasivos SNFHSFL OCPC', NULL, 'Externo', 'pii', 'trimestral', 'US$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('p_dereg', 'Pasivos DEG', NULL, 'Externo', 'pii', 'trimestral', 'US$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('p_pii', 'PII NETA', NULL, 'Externo', 'pii', 'trimestral', 'US$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('dpc_ext', 'Deuda Pública Consolidada Externa', NULL, 'Fiscal', 'deuda', 'trimestral', 'US$', 'Millones', 'DGAPF', 'https://www.creditopublico.gob.do/Content/estadisticas/consolidada/trimestral/04Deuda Pública Consolidada por Sector Institucional Trimestral.xlsx', 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('dpc_int', 'Deuda Pública Consolidada Interna', NULL, 'Fiscal', 'deuda', 'trimestral', 'US$', 'Millones', 'DGAPF', 'https://www.creditopublico.gob.do/Content/estadisticas/consolidada/trimestral/04Deuda Pública Consolidada por Sector Institucional Trimestral.xlsx', 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('d_ext_spnf_gc', 'Deuda Ext. SPNF Gobierno Central', NULL, 'Fiscal', 'deuda', 'trimestral', 'US$', 'Millones', 'DGAPF', 'https://www.creditopublico.gob.do/Content/estadisticas/consolidada/trimestral/04Deuda Pública Consolidada por Sector Institucional Trimestral.xlsx', 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('d_int_spnf_gc', 'Deuda Int. SPNF Gobierno Central', NULL, 'Fiscal', 'deuda', 'trimestral', 'US$', 'Millones', 'DGAPF', 'https://www.creditopublico.gob.do/Content/estadisticas/consolidada/trimestral/04Deuda Pública Consolidada por Sector Institucional Trimestral.xlsx', 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('d_ext_spnf_r', 'Deuda Ext. SPNF Resto', NULL, 'Fiscal', 'deuda', 'trimestral', 'US$', 'Millones', 'DGAPF', 'https://www.creditopublico.gob.do/Content/estadisticas/consolidada/trimestral/04Deuda Pública Consolidada por Sector Institucional Trimestral.xlsx', 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('d_int_spnf_r', 'Deuda Int. SPNF Resto', NULL, 'Fiscal', 'deuda', 'trimestral', 'US$', 'Millones', 'DGAPF', 'https://www.creditopublico.gob.do/Content/estadisticas/consolidada/trimestral/04Deuda Pública Consolidada por Sector Institucional Trimestral.xlsx', 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('d_ext_spf', 'Deuda Ext. Sector Público Financiero', NULL, 'Fiscal', 'deuda', 'trimestral', 'US$', 'Millones', 'DGAPF', 'https://www.creditopublico.gob.do/Content/estadisticas/consolidada/trimestral/04Deuda Pública Consolidada por Sector Institucional Trimestral.xlsx', 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('d_int_spf', 'Deuda Int. Sector Público Financiero', NULL, 'Fiscal', 'deuda', 'trimestral', 'US$', 'Millones', 'DGAPF', 'https://www.creditopublico.gob.do/Content/estadisticas/consolidada/trimestral/04Deuda Pública Consolidada por Sector Institucional Trimestral.xlsx', 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('isr_pf', 'ISR Personas Físicas', NULL, 'Fiscal', 'eo', 'mensual', 'RD$', 'Millones', 'Hacienda', 'https://www.hacienda.gob.do/estadisticas-fiscales/', 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('isr_se', 'ISR Sociedades y otras empresas', NULL, 'Fiscal', 'eo', 'mensual', 'RD$', 'Millones', 'Hacienda', 'https://www.hacienda.gob.do/estadisticas-fiscales/', 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('isp', 'Impuestos sobre la propiedad', NULL, 'Fiscal', 'eo', 'mensual', 'RD$', 'Millones', 'Hacienda', 'https://www.hacienda.gob.do/estadisticas-fiscales/', 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('iva', 'ITBIS (impuestos al valor agregado)', NULL, 'Fiscal', 'eo', 'mensual', 'RD$', 'Millones', 'Hacienda', 'https://www.hacienda.gob.do/estadisticas-fiscales/', 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('ist_fc', 'Impuestos sobre transacciones financieras y de capital', NULL, 'Fiscal', 'eo', 'mensual', 'RD$', 'Millones', 'Hacienda', 'https://www.hacienda.gob.do/estadisticas-fiscales/', 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('i_sel', 'Impuestos selectivos', NULL, 'Fiscal', 'eo', 'mensual', 'RD$', 'Millones', 'Hacienda', 'https://www.hacienda.gob.do/estadisticas-fiscales/', 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('isse', 'Impuestos sobre servicios específicos', NULL, 'Fiscal', 'eo', 'mensual', 'RD$', 'Millones', 'Hacienda', 'https://www.hacienda.gob.do/estadisticas-fiscales/', 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('isb', 'Impuestos sobre uso de bienes y permisos', NULL, 'Fiscal', 'eo', 'mensual', 'RD$', 'Millones', 'Hacienda', 'https://www.hacienda.gob.do/estadisticas-fiscales/', 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('isct', 'Impuestos sobre comercio y transacciones internacionales', NULL, 'Fiscal', 'eo', 'mensual', 'RD$', 'Millones', 'Hacienda', 'https://www.hacienda.gob.do/estadisticas-fiscales/', 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('otros_imp', 'Otros impuestos', NULL, 'Fiscal', 'eo', 'mensual', 'RD$', 'Millones', 'Hacienda', 'https://www.hacienda.gob.do/estadisticas-fiscales/', 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('cs_ing', 'Contribuciones sociales (ingreso)', NULL, 'Fiscal', 'eo', 'mensual', 'RD$', 'Millones', 'Hacienda', 'https://www.hacienda.gob.do/estadisticas-fiscales/', 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('don', 'Donaciones (ingreso)', NULL, 'Fiscal', 'eo', 'mensual', 'RD$', 'Millones', 'Hacienda', 'https://www.hacienda.gob.do/estadisticas-fiscales/', 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('otros_ing', 'Otros ingresos', NULL, 'Fiscal', 'eo', 'mensual', 'RD$', 'Millones', 'Hacienda', 'https://www.hacienda.gob.do/estadisticas-fiscales/', 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('ss', 'Sueldos y salarios', NULL, 'Fiscal', 'eo', 'mensual', 'RD$', 'Millones', 'Hacienda', 'https://www.hacienda.gob.do/estadisticas-fiscales/', 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('cs_gasto', 'Contribuciones sociales (gasto)', NULL, 'Fiscal', 'eo', 'mensual', 'RD$', 'Millones', 'Hacienda', 'https://www.hacienda.gob.do/estadisticas-fiscales/', 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('u_bys', 'Uso de bienes y servicios', NULL, 'Fiscal', 'eo', 'mensual', 'RD$', 'Millones', 'Hacienda', 'https://www.hacienda.gob.do/estadisticas-fiscales/', 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('inter_nr', 'Intereses a no residentes', NULL, 'Fiscal', 'eo', 'mensual', 'RD$', 'Millones', 'Hacienda', 'https://www.hacienda.gob.do/estadisticas-fiscales/', 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('inter_r', 'Intereses a residentes', NULL, 'Fiscal', 'eo', 'mensual', 'RD$', 'Millones', 'Hacienda', 'https://www.hacienda.gob.do/estadisticas-fiscales/', 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('subs_sp', 'Subsidios a sociedades públicas', NULL, 'Fiscal', 'eo', 'mensual', 'RD$', 'Millones', 'Hacienda', 'https://www.hacienda.gob.do/estadisticas-fiscales/', 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('subs_ep', 'Subsidios a empresas privadas', NULL, 'Fiscal', 'eo', 'mensual', 'RD$', 'Millones', 'Hacienda', 'https://www.hacienda.gob.do/estadisticas-fiscales/', 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('don_ge', 'Donaciones a gobiernos extranjeros', NULL, 'Fiscal', 'eo', 'mensual', 'RD$', 'Millones', 'Hacienda', 'https://www.hacienda.gob.do/estadisticas-fiscales/', 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('don_ogint', 'Donaciones a organismos internacionales', NULL, 'Fiscal', 'eo', 'mensual', 'RD$', 'Millones', 'Hacienda', 'https://www.hacienda.gob.do/estadisticas-fiscales/', 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('don_gg_corr', 'Donaciones GG corrientes', NULL, 'Fiscal', 'eo', 'mensual', 'RD$', 'Millones', 'Hacienda', 'https://www.hacienda.gob.do/estadisticas-fiscales/', 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('don_gg_cap', 'Donaciones GG capital', NULL, 'Fiscal', 'eo', 'mensual', 'RD$', 'Millones', 'Hacienda', 'https://www.hacienda.gob.do/estadisticas-fiscales/', 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('prest_soc', 'Prestaciones sociales', NULL, 'Fiscal', 'eo', 'mensual', 'RD$', 'Millones', 'Hacienda', 'https://www.hacienda.gob.do/estadisticas-fiscales/', 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('transf_corr_ncop', 'Transferencias corrientes no clasificadas', NULL, 'Fiscal', 'eo', 'mensual', 'RD$', 'Millones', 'Hacienda', 'https://www.hacienda.gob.do/estadisticas-fiscales/', 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('transf_cap_ncop', 'Transferencias de capital no clasificadas', NULL, 'Fiscal', 'eo', 'mensual', 'RD$', 'Millones', 'Hacienda', 'https://www.hacienda.gob.do/estadisticas-fiscales/', 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('act_f', 'Activos fijos', NULL, 'Fiscal', 'eo', 'mensual', 'RD$', 'Millones', 'Hacienda', 'https://www.hacienda.gob.do/estadisticas-fiscales/', 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('obj_val', 'Objetos de valor', NULL, 'Fiscal', 'eo', 'mensual', 'RD$', 'Millones', 'Hacienda', 'https://www.hacienda.gob.do/estadisticas-fiscales/', 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('act_np', 'Activos no producidos', NULL, 'Fiscal', 'eo', 'mensual', 'RD$', 'Millones', 'Hacienda', 'https://www.hacienda.gob.do/estadisticas-fiscales/', 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('din_ld', 'Dinero legal y depósitos', NULL, 'Fiscal', 'eo', 'mensual', 'RD$', 'Millones', 'Hacienda', 'https://www.hacienda.gob.do/estadisticas-fiscales/', 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('part_cap_di', 'Participaciones de capital y FDI', NULL, 'Fiscal', 'eo', 'mensual', 'RD$', 'Millones', 'Hacienda', 'https://www.hacienda.gob.do/estadisticas-fiscales/', 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('otras_cpc', 'Otras cuentas por cobrar', NULL, 'Fiscal', 'eo', 'mensual', 'RD$', 'Millones', 'Hacienda', 'https://www.hacienda.gob.do/estadisticas-fiscales/', 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('emis_ai', 'Emisiones (activos internos)', NULL, 'Fiscal', 'eo', 'mensual', 'RD$', 'Millones', 'Hacienda', 'https://www.hacienda.gob.do/estadisticas-fiscales/', 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('amort_ai', 'Amortizaciones (activos internos)', NULL, 'Fiscal', 'eo', 'mensual', 'RD$', 'Millones', 'Hacienda', 'https://www.hacienda.gob.do/estadisticas-fiscales/', 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('resto_ai', 'Resto activos internos', NULL, 'Fiscal', 'eo', 'mensual', 'RD$', 'Millones', 'Hacienda', 'https://www.hacienda.gob.do/estadisticas-fiscales/', 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('loan_sb_ai', 'Préstamos sector bancario AI', NULL, 'Fiscal', 'eo', 'mensual', 'RD$', 'Millones', 'Hacienda', 'https://www.hacienda.gob.do/estadisticas-fiscales/', 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('loan_snb_ai', 'Préstamos sector no bancario AI', NULL, 'Fiscal', 'eo', 'mensual', 'RD$', 'Millones', 'Hacienda', 'https://www.hacienda.gob.do/estadisticas-fiscales/', 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('otros_pas_ai', 'Otros pasivos AI', NULL, 'Fiscal', 'eo', 'mensual', 'RD$', 'Millones', 'Hacienda', 'https://www.hacienda.gob.do/estadisticas-fiscales/', 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('emis_ae', 'Emisiones (activos externos)', NULL, 'Fiscal', 'eo', 'mensual', 'RD$', 'Millones', 'Hacienda', 'https://www.hacienda.gob.do/estadisticas-fiscales/', 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('amort_ae', 'Amortizaciones (activos externos)', NULL, 'Fiscal', 'eo', 'mensual', 'RD$', 'Millones', 'Hacienda', 'https://www.hacienda.gob.do/estadisticas-fiscales/', 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('resto_ae', 'Resto activos externos', NULL, 'Fiscal', 'eo', 'mensual', 'RD$', 'Millones', 'Hacienda', 'https://www.hacienda.gob.do/estadisticas-fiscales/', 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('desemb_loan_ae', 'Desembolsos préstamos AE', NULL, 'Fiscal', 'eo', 'mensual', 'RD$', 'Millones', 'Hacienda', 'https://www.hacienda.gob.do/estadisticas-fiscales/', 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('amort_loan_ae', 'Amortizaciones préstamos AE', NULL, 'Fiscal', 'eo', 'mensual', 'RD$', 'Millones', 'Hacienda', 'https://www.hacienda.gob.do/estadisticas-fiscales/', 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('resto_loan_ae', 'Resto préstamos AE', NULL, 'Fiscal', 'eo', 'mensual', 'RD$', 'Millones', 'Hacienda', 'https://www.hacienda.gob.do/estadisticas-fiscales/', 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('din_ld_rspnf', 'Dinero legal y depósitos RSPNF', NULL, 'Fiscal', 'eo', 'mensual', 'RD$', 'Millones', 'Hacienda', 'https://www.hacienda.gob.do/estadisticas-fiscales/', 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('tdd_rspnf', 'Títulos de deuda RSPNF', NULL, 'Fiscal', 'eo', 'mensual', 'RD$', 'Millones', 'Hacienda', 'https://www.hacienda.gob.do/estadisticas-fiscales/', 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('cpc_rspnf', 'Cuentas por cobrar RSPNF', NULL, 'Fiscal', 'eo', 'mensual', 'RD$', 'Millones', 'Hacienda', 'https://www.hacienda.gob.do/estadisticas-fiscales/', 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('de_rspnf', 'Deudores externos RSPNF', NULL, 'Fiscal', 'eo', 'mensual', 'RD$', 'Millones', 'Hacienda', 'https://www.hacienda.gob.do/estadisticas-fiscales/', 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('pas_tdd_ai', 'Pasivos títulos de deuda AI', NULL, 'Fiscal', 'eo', 'mensual', 'RD$', 'Millones', 'Hacienda', 'https://www.hacienda.gob.do/estadisticas-fiscales/', 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('loan_rspnf', 'Préstamos RSPNF', NULL, 'Fiscal', 'eo', 'mensual', 'RD$', 'Millones', 'Hacienda', 'https://www.hacienda.gob.do/estadisticas-fiscales/', 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('otros_pas_rspnf', 'Otros pasivos RSPNF', NULL, 'Fiscal', 'eo', 'mensual', 'RD$', 'Millones', 'Hacienda', 'https://www.hacienda.gob.do/estadisticas-fiscales/', 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('ae_rspnf', 'Acreedores externos RSPNF', NULL, 'Fiscal', 'eo', 'mensual', 'RD$', 'Millones', 'Hacienda', 'https://www.hacienda.gob.do/estadisticas-fiscales/', 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('a_in_b', 'Activos internos brutos', NULL, 'Monetario', 'monetario_t', 'trimestral', 'RD$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('rib', 'Reservas Internacionales Brutas', NULL, 'Monetario', 'monetario_t', 'trimestral', 'RD$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('rin_t', 'Reservas Internacionales Netas (trim.)', NULL, 'Monetario', 'monetario_t', 'trimestral', 'RD$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('a_fgc', 'Activos frente al GC', NULL, 'Monetario', 'monetario_t', 'trimestral', 'RD$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('a_fsp', 'Activos frente al SP', NULL, 'Monetario', 'monetario_t', 'trimestral', 'RD$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('cred_osd', 'Crédito a OSD', NULL, 'Monetario', 'monetario_t', 'trimestral', 'RD$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('val_circ', 'Valores en circulación', NULL, 'Monetario', 'monetario_t', 'trimestral', 'RD$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('desc_vem', 'Descuento de valores emitidos por BCRD', NULL, 'Monetario', 'monetario_t', 'trimestral', 'RD$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('deprem_cp', 'Depósitos remunerados CP', NULL, 'Monetario', 'monetario_t', 'trimestral', 'RD$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('bm_em_bmr', 'Base monetaria emisión BMR', NULL, 'Monetario', 'monetario_t', 'trimestral', 'RD$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('el_sc_osd_bmr', 'El sector consolidado OSD - BMR', NULL, 'Monetario', 'monetario_t', 'trimestral', 'RD$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('valbc_pososd_bmr', 'Valores BCRD posición OSD BMR', NULL, 'Monetario', 'monetario_t', 'trimestral', 'RD$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('bmr', 'Base Monetaria Restringida', NULL, 'Monetario', 'monetario_t', 'trimestral', 'RD$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('el_sc_osd_bma', 'Sector consolidado OSD - BMA', NULL, 'Monetario', 'monetario_t', 'trimestral', 'RD$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('deprem_cp_me', 'Depósitos remunerados CP - ME', NULL, 'Monetario', 'monetario_t', 'trimestral', 'RD$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('ovn', 'Overnight', NULL, 'Monetario', 'monetario_t', 'trimestral', 'RD$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('od_osd_bc', 'Operaciones de descuento OSD - BC', NULL, 'Monetario', 'monetario_t', 'trimestral', 'RD$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('valcp_embc_osd', 'Valores CP emitidos BCRD - OSD', NULL, 'Monetario', 'monetario_t', 'trimestral', 'RD$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('bm_pp', 'Base monetaria papel privado', NULL, 'Monetario', 'monetario_t', 'trimestral', 'RD$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('dt_mn', 'Depósitos transferibles MN', NULL, 'Monetario', 'monetario_t', 'trimestral', 'RD$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('m1', 'M1 (trim.)', NULL, 'Monetario', 'monetario_t', 'trimestral', 'RD$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('od_mn', 'Otros depósitos MN', NULL, 'Monetario', 'monetario_t', 'trimestral', 'RD$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('valda_mn_emosd', 'Valores DA MN emitidos OSD', NULL, 'Monetario', 'monetario_t', 'trimestral', 'RD$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('valda_mn_embc', 'Valores DA MN emitidos BCRD', NULL, 'Monetario', 'monetario_t', 'trimestral', 'RD$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('m2', 'M2 (trim.)', NULL, 'Monetario', 'monetario_t', 'trimestral', 'RD$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('od_me', 'Otros depósitos ME', NULL, 'Monetario', 'monetario_t', 'trimestral', 'RD$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('valda_me', 'Valores DA ME', NULL, 'Monetario', 'monetario_t', 'trimestral', 'RD$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('k2_1', 'K2 - clase 1', NULL, 'Monetario', 'monetario_t', 'trimestral', 'RD$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('k2_2', 'K2 - clase 2', NULL, 'Monetario', 'monetario_t', 'trimestral', 'RD$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('k2_3', 'K2 - clase 3', NULL, 'Monetario', 'monetario_t', 'trimestral', 'RD$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('tc_t', 'Tipo de cambio (trim.)', NULL, 'Monetario', 'monetario_t', 'trimestral', 'RD$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('ae_ronr_bc', 'AE-RONR Banco Central', NULL, 'Monetario', 'panorama', 'trimestral', 'RD$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('ae_onr_bc', 'AE-ONR Banco Central', NULL, 'Monetario', 'panorama', 'trimestral', 'RD$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('p_cp_nr', 'Pasivos CP NR', NULL, 'Monetario', 'panorama', 'trimestral', 'RD$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('p_lp_nr', 'Pasivos LP NR', NULL, 'Monetario', 'panorama', 'trimestral', 'RD$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('rin_pm', 'RIN (Panorama monetario)', NULL, 'Monetario', 'panorama', 'trimestral', 'RD$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('ai_gc_bc', 'Activos internos GC - BC', NULL, 'Monetario', 'panorama', 'trimestral', 'RD$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('ai_snf_bc', 'Activos internos SNF - BC', NULL, 'Monetario', 'panorama', 'trimestral', 'RD$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('ai_osd_bc', 'Activos internos OSD - BC', NULL, 'Monetario', 'panorama', 'trimestral', 'RD$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('ai_os_bc', 'Activos internos OS - BC', NULL, 'Monetario', 'panorama', 'trimestral', 'RD$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('ai_op_bc', 'Activos internos OP - BC', NULL, 'Monetario', 'panorama', 'trimestral', 'RD$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('bm_circ', 'Base monetaria circulante', NULL, 'Monetario', 'panorama', 'trimestral', 'RD$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('dvp', 'Depósitos VP', NULL, 'Monetario', 'panorama', 'trimestral', 'RD$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('tc', 'Tipo de cambio panorama', NULL, 'Monetario', 'panorama', 'trimestral', 'RD$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('ae_nr_osd', 'AE-NR OSD', NULL, 'Monetario', 'panorama', 'trimestral', 'RD$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('p_nr_osd', 'Pasivos NR OSD', NULL, 'Monetario', 'panorama', 'trimestral', 'RD$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('ai_gc_osd', 'Activos internos GC - OSD', NULL, 'Monetario', 'panorama', 'trimestral', 'RD$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('ai_gel_osd', 'Activos internos GEL - OSD', NULL, 'Monetario', 'panorama', 'trimestral', 'RD$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('ai_snf_osd', 'Activos internos SNF - OSD', NULL, 'Monetario', 'panorama', 'trimestral', 'RD$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('ai_bcbm_osd', 'Activos internos BCBM - OSD', NULL, 'Monetario', 'panorama', 'trimestral', 'RD$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('ai_bcd_osd', 'Activos internos BCD - OSD', NULL, 'Monetario', 'panorama', 'trimestral', 'RD$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('ai_bcv_osd', 'Activos internos BCV - OSD', NULL, 'Monetario', 'panorama', 'trimestral', 'RD$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('ai_osf_osd', 'Activos internos OSF - OSD', NULL, 'Monetario', 'panorama', 'trimestral', 'RD$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('ai_osnf_osd', 'Activos internos OSNF - OSD', NULL, 'Monetario', 'panorama', 'trimestral', 'RD$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('ai_hsfl_osd', 'Activos internos HSFL - OSD', NULL, 'Monetario', 'panorama', 'trimestral', 'RD$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('ai_op_osd', 'Activos internos OP - OSD', NULL, 'Monetario', 'panorama', 'trimestral', 'RD$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('p_dsa_dt_osd', 'Pasivos DSA-DT OSD', NULL, 'Monetario', 'panorama', 'trimestral', 'RD$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('p_dsa_odv_osd', 'Pasivos DSA-ODV OSD', NULL, 'Monetario', 'panorama', 'trimestral', 'RD$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('a_vda_gc', 'Activos valores deuda GC', NULL, 'Monetario', 'panorama', 'trimestral', 'RD$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('a_vda_gel', 'Activos valores deuda GEL', NULL, 'Monetario', 'panorama', 'trimestral', 'RD$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('a_vda_snf', 'Activos valores deuda SNF', NULL, 'Monetario', 'panorama', 'trimestral', 'RD$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('a_prm_gc', 'Activos préstamos GC', NULL, 'Monetario', 'panorama', 'trimestral', 'RD$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('a_prm_gel', 'Activos préstamos GEL', NULL, 'Monetario', 'panorama', 'trimestral', 'RD$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('a_prm_snf', 'Activos préstamos SNF', NULL, 'Monetario', 'panorama', 'trimestral', 'RD$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('a_o', 'Otros activos', NULL, 'Monetario', 'panorama', 'trimestral', 'RD$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('p_dto_gc', 'Pasivos depósitos GC', NULL, 'Monetario', 'panorama', 'trimestral', 'RD$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('p_dto_gel', 'Pasivos depósitos GEL', NULL, 'Monetario', 'panorama', 'trimestral', 'RD$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('p_dto_snf', 'Pasivos depósitos SNF', NULL, 'Monetario', 'panorama', 'trimestral', 'RD$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('p_vto_gc', 'Pasivos valores GC', NULL, 'Monetario', 'panorama', 'trimestral', 'RD$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('p_vto_gel', 'Pasivos valores GEL', NULL, 'Monetario', 'panorama', 'trimestral', 'RD$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('p_vto_snf', 'Pasivos valores SNF', NULL, 'Monetario', 'panorama', 'trimestral', 'RD$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('p_o', 'Otros pasivos', NULL, 'Monetario', 'panorama', 'trimestral', 'RD$', 'Millones', 'BCRD', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('indpro_usa_f', 'Pron. Producción Industrial EE.UU.', NULL, 'Externo', 'proyeccion', 'mensual', 'índice', 'Unidad', 'EIA STEO', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('indproMan_usa_f', 'Pron. Producción Industrial Manufactura EE.UU.', NULL, 'Externo', 'proyeccion', 'mensual', 'índice', 'Unidad', 'EIA STEO', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('ipc_eeuu_f', 'Pron. IPC EE.UU.', NULL, 'Externo', 'proyeccion', 'mensual', 'índice', 'Unidad', 'EIA STEO', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('ur_sa_usa_f', 'Pron. Desempleo EE.UU.', NULL, 'Externo', 'proyeccion', 'mensual', 'índice', 'Unidad', 'EIA STEO', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('p_petroleo_f', 'Pron. Petróleo WTI', NULL, 'Externo', 'proyeccion', 'mensual', 'índice', 'Unidad', 'EIA STEO', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('p_gas_nat_f', 'Pron. Gas Natural', NULL, 'Externo', 'proyeccion', 'mensual', 'índice', 'Unidad', 'EIA STEO', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('pib_eeuu_f', 'Pron. PIB EE.UU.', NULL, 'Externo', 'proyeccion', 'trimestral', 'US$', 'Miles de millones', 'EIA STEO', NULL, 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('el_gen_total', 'Generación Total', NULL, 'Eléctrico', 'generacion', 'mensual', 'GWh', 'Unidad', 'MEM', 'https://mem.gob.do/category/sector-electrico/informe-de-desempeno/', 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('el_gen_carbon', 'Generación Carbón Mineral', NULL, 'Eléctrico', 'generacion', 'mensual', 'GWh', 'Unidad', 'MEM', 'https://mem.gob.do/category/sector-electrico/informe-de-desempeno/', 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('el_gen_gas_nat', 'Generación Gas Natural', NULL, 'Eléctrico', 'generacion', 'mensual', 'GWh', 'Unidad', 'MEM', 'https://mem.gob.do/category/sector-electrico/informe-de-desempeno/', 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('el_gen_fo2', 'Generación Fuel Oil No. 2', NULL, 'Eléctrico', 'generacion', 'mensual', 'GWh', 'Unidad', 'MEM', 'https://mem.gob.do/category/sector-electrico/informe-de-desempeno/', 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('el_gen_fo6', 'Generación Fuel Oil No. 6', NULL, 'Eléctrico', 'generacion', 'mensual', 'GWh', 'Unidad', 'MEM', 'https://mem.gob.do/category/sector-electrico/informe-de-desempeno/', 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('el_gen_fo26', 'Generación Fuel Oil No. 2 y No. 6', NULL, 'Eléctrico', 'generacion', 'mensual', 'GWh', 'Unidad', 'MEM', 'https://mem.gob.do/category/sector-electrico/informe-de-desempeno/', 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('el_gen_hidro', 'Generación Hidráulica', NULL, 'Eléctrico', 'generacion', 'mensual', 'GWh', 'Unidad', 'MEM', 'https://mem.gob.do/category/sector-electrico/informe-de-desempeno/', 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('el_gen_eolica', 'Generación Eólica', NULL, 'Eléctrico', 'generacion', 'mensual', 'GWh', 'Unidad', 'MEM', 'https://mem.gob.do/category/sector-electrico/informe-de-desempeno/', 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('el_gen_solar', 'Generación Solar Fotovoltaica', NULL, 'Eléctrico', 'generacion', 'mensual', 'GWh', 'Unidad', 'MEM', 'https://mem.gob.do/category/sector-electrico/informe-de-desempeno/', 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('el_gen_biomasa', 'Generación Biomasa', NULL, 'Eléctrico', 'generacion', 'mensual', 'GWh', 'Unidad', 'MEM', 'https://mem.gob.do/category/sector-electrico/informe-de-desempeno/', 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('el_cmg_energia', 'Costo Marginal de Energía', NULL, 'Eléctrico', 'costos', 'mensual', 'USCents/kWh', 'Unidad', 'MEM', 'https://mem.gob.do/category/sector-electrico/informe-de-desempeno/', 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('el_cmg_potencia', 'Costo Marginal de Potencia', NULL, 'Eléctrico', 'costos', 'mensual', 'US$/kW-mes', 'Unidad', 'MEM', 'https://mem.gob.do/category/sector-electrico/informe-de-desempeno/', 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('el_peaje_trans', 'Peaje de Transmisión', NULL, 'Eléctrico', 'costos', 'mensual', 'USCents/kWh', 'Unidad', 'MEM', 'https://mem.gob.do/category/sector-electrico/informe-de-desempeno/', 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('el_der_conex', 'Derecho de Conexión Unitario', NULL, 'Eléctrico', 'costos', 'mensual', 'US$/kW-mes', 'Unidad', 'MEM', 'https://mem.gob.do/category/sector-electrico/informe-de-desempeno/', 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('el_pcomb_fo2', 'Precio Fuel Oil No. 2', NULL, 'Eléctrico', 'precios_comb', 'mensual', 'US$/MMBTU', 'Unidad', 'MEM', 'https://mem.gob.do/category/sector-electrico/informe-de-desempeno/', 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('el_pcomb_fo6', 'Precio Fuel Oil No. 6', NULL, 'Eléctrico', 'precios_comb', 'mensual', 'US$/MMBTU', 'Unidad', 'MEM', 'https://mem.gob.do/category/sector-electrico/informe-de-desempeno/', 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('el_pcomb_gas', 'Precio Gas Natural', NULL, 'Eléctrico', 'precios_comb', 'mensual', 'US$/MMBTU', 'Unidad', 'MEM', 'https://mem.gob.do/category/sector-electrico/informe-de-desempeno/', 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('el_pcomb_gas_conv', 'Precio Gas Natural (Conv.)', NULL, 'Eléctrico', 'precios_comb', 'mensual', 'US$/MMBTU', 'Unidad', 'MEM', 'https://mem.gob.do/category/sector-electrico/informe-de-desempeno/', 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('el_pcomb_carbon', 'Precio Carbón Mineral', NULL, 'Eléctrico', 'precios_comb', 'mensual', 'US$/MMBTU', 'Unidad', 'MEM', 'https://mem.gob.do/category/sector-electrico/informe-de-desempeno/', 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('el_tc', 'Tasa de Cambio Sector Eléctrico', NULL, 'Eléctrico', 'precios_comb', 'mensual', 'RD$/US$', 'Unidad', 'MEM', 'https://mem.gob.do/category/sector-electrico/informe-de-desempeno/', 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('el_pventa_tot', 'Precio Venta Total', NULL, 'Eléctrico', 'precios_dist', 'mensual', 'USCents/kWh', 'Unidad', 'MEM', 'https://mem.gob.do/category/sector-electrico/informe-de-desempeno/', 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('el_pventa_edn', 'Precio Venta EDENORTE', NULL, 'Eléctrico', 'precios_dist', 'mensual', 'USCents/kWh', 'Unidad', 'MEM', 'https://mem.gob.do/category/sector-electrico/informe-de-desempeno/', 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('el_pventa_eds', 'Precio Venta EDESUR', NULL, 'Eléctrico', 'precios_dist', 'mensual', 'USCents/kWh', 'Unidad', 'MEM', 'https://mem.gob.do/category/sector-electrico/informe-de-desempeno/', 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('el_pventa_ede', 'Precio Venta EDEESTE', NULL, 'Eléctrico', 'precios_dist', 'mensual', 'USCents/kWh', 'Unidad', 'MEM', 'https://mem.gob.do/category/sector-electrico/informe-de-desempeno/', 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('el_pcomp_spot_tot', 'Precio Compra SPOT Total', NULL, 'Eléctrico', 'precios_dist', 'mensual', 'USCents/kWh', 'Unidad', 'MEM', 'https://mem.gob.do/category/sector-electrico/informe-de-desempeno/', 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('el_pcomp_spot_edn', 'Precio Compra SPOT EDENORTE', NULL, 'Eléctrico', 'precios_dist', 'mensual', 'USCents/kWh', 'Unidad', 'MEM', 'https://mem.gob.do/category/sector-electrico/informe-de-desempeno/', 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('el_pcomp_spot_eds', 'Precio Compra SPOT EDESUR', NULL, 'Eléctrico', 'precios_dist', 'mensual', 'USCents/kWh', 'Unidad', 'MEM', 'https://mem.gob.do/category/sector-electrico/informe-de-desempeno/', 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('el_pcomp_spot_ede', 'Precio Compra SPOT EDEESTE', NULL, 'Eléctrico', 'precios_dist', 'mensual', 'USCents/kWh', 'Unidad', 'MEM', 'https://mem.gob.do/category/sector-electrico/informe-de-desempeno/', 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('el_pcomp_cont_tot', 'Precio Compra CONTRATOS Total', NULL, 'Eléctrico', 'precios_dist', 'mensual', 'USCents/kWh', 'Unidad', 'MEM', 'https://mem.gob.do/category/sector-electrico/informe-de-desempeno/', 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('el_pcomp_cont_edn', 'Precio Compra CONTRATOS EDENORTE', NULL, 'Eléctrico', 'precios_dist', 'mensual', 'USCents/kWh', 'Unidad', 'MEM', 'https://mem.gob.do/category/sector-electrico/informe-de-desempeno/', 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('el_pcomp_cont_eds', 'Precio Compra CONTRATOS EDESUR', NULL, 'Eléctrico', 'precios_dist', 'mensual', 'USCents/kWh', 'Unidad', 'MEM', 'https://mem.gob.do/category/sector-electrico/informe-de-desempeno/', 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('el_pcomp_cont_ede', 'Precio Compra CONTRATOS EDEESTE', NULL, 'Eléctrico', 'precios_dist', 'mensual', 'USCents/kWh', 'Unidad', 'MEM', 'https://mem.gob.do/category/sector-electrico/informe-de-desempeno/', 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('el_cri_tot', 'CRI Total', NULL, 'Eléctrico', 'distribucion', 'mensual', '%', 'Unidad', 'MEM', 'https://mem.gob.do/category/sector-electrico/informe-de-desempeno/', 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('el_cri_edn', 'CRI EDENORTE', NULL, 'Eléctrico', 'distribucion', 'mensual', '%', 'Unidad', 'MEM', 'https://mem.gob.do/category/sector-electrico/informe-de-desempeno/', 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('el_cri_eds', 'CRI EDESUR', NULL, 'Eléctrico', 'distribucion', 'mensual', '%', 'Unidad', 'MEM', 'https://mem.gob.do/category/sector-electrico/informe-de-desempeno/', 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('el_cri_ede', 'CRI EDEESTE', NULL, 'Eléctrico', 'distribucion', 'mensual', '%', 'Unidad', 'MEM', 'https://mem.gob.do/category/sector-electrico/informe-de-desempeno/', 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('el_efact_tot', 'Energía Facturada Total', NULL, 'Eléctrico', 'distribucion', 'mensual', 'GWh', 'Unidad', 'MEM', 'https://mem.gob.do/category/sector-electrico/informe-de-desempeno/', 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('el_efact_edn', 'Energía Facturada EDENORTE', NULL, 'Eléctrico', 'distribucion', 'mensual', 'GWh', 'Unidad', 'MEM', 'https://mem.gob.do/category/sector-electrico/informe-de-desempeno/', 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('el_efact_eds', 'Energía Facturada EDESUR', NULL, 'Eléctrico', 'distribucion', 'mensual', 'GWh', 'Unidad', 'MEM', 'https://mem.gob.do/category/sector-electrico/informe-de-desempeno/', 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('el_efact_ede', 'Energía Facturada EDEESTE', NULL, 'Eléctrico', 'distribucion', 'mensual', 'GWh', 'Unidad', 'MEM', 'https://mem.gob.do/category/sector-electrico/informe-de-desempeno/', 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('el_perd_tot', 'Pérdidas Total', NULL, 'Eléctrico', 'distribucion', 'mensual', '%', 'Unidad', 'MEM', 'https://mem.gob.do/category/sector-electrico/informe-de-desempeno/', 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('el_perd_edn', 'Pérdidas EDENORTE', NULL, 'Eléctrico', 'distribucion', 'mensual', '%', 'Unidad', 'MEM', 'https://mem.gob.do/category/sector-electrico/informe-de-desempeno/', 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('el_perd_eds', 'Pérdidas EDESUR', NULL, 'Eléctrico', 'distribucion', 'mensual', '%', 'Unidad', 'MEM', 'https://mem.gob.do/category/sector-electrico/informe-de-desempeno/', 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('el_perd_ede', 'Pérdidas EDEESTE', NULL, 'Eléctrico', 'distribucion', 'mensual', '%', 'Unidad', 'MEM', 'https://mem.gob.do/category/sector-electrico/informe-de-desempeno/', 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('el_cobr_tot', 'Cobranzas Total', NULL, 'Eléctrico', 'distribucion', 'mensual', '%', 'Unidad', 'MEM', 'https://mem.gob.do/category/sector-electrico/informe-de-desempeno/', 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('el_cobr_edn', 'Cobranzas EDENORTE', NULL, 'Eléctrico', 'distribucion', 'mensual', '%', 'Unidad', 'MEM', 'https://mem.gob.do/category/sector-electrico/informe-de-desempeno/', 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('el_cobr_eds', 'Cobranzas EDESUR', NULL, 'Eléctrico', 'distribucion', 'mensual', '%', 'Unidad', 'MEM', 'https://mem.gob.do/category/sector-electrico/informe-de-desempeno/', 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('el_cobr_ede', 'Cobranzas EDEESTE', NULL, 'Eléctrico', 'distribucion', 'mensual', '%', 'Unidad', 'MEM', 'https://mem.gob.do/category/sector-electrico/informe-de-desempeno/', 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('el_def_op_tot', 'Balance Operacional Total', NULL, 'Eléctrico', 'financiero', 'anual', 'RD$', 'Unidad', 'MEM', 'https://mem.gob.do/category/sector-electrico/informe-de-desempeno/', 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('el_def_op_edn', 'Balance Operacional EDENORTE', NULL, 'Eléctrico', 'financiero', 'anual', 'RD$', 'Unidad', 'MEM', 'https://mem.gob.do/category/sector-electrico/informe-de-desempeno/', 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('el_def_op_eds', 'Balance Operacional EDESUR', NULL, 'Eléctrico', 'financiero', 'anual', 'RD$', 'Unidad', 'MEM', 'https://mem.gob.do/category/sector-electrico/informe-de-desempeno/', 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('el_def_op_ede', 'Balance Operacional EDEESTE', NULL, 'Eléctrico', 'financiero', 'anual', 'RD$', 'Unidad', 'MEM', 'https://mem.gob.do/category/sector-electrico/informe-de-desempeno/', 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('el_def_capex_tot', 'Balance con Inversiones Total', NULL, 'Eléctrico', 'financiero', 'anual', 'RD$', 'Unidad', 'MEM', 'https://mem.gob.do/category/sector-electrico/informe-de-desempeno/', 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('el_def_capex_edn', 'Balance con Inversiones EDENORTE', NULL, 'Eléctrico', 'financiero', 'anual', 'RD$', 'Unidad', 'MEM', 'https://mem.gob.do/category/sector-electrico/informe-de-desempeno/', 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('el_def_capex_eds', 'Balance con Inversiones EDESUR', NULL, 'Eléctrico', 'financiero', 'anual', 'RD$', 'Unidad', 'MEM', 'https://mem.gob.do/category/sector-electrico/informe-de-desempeno/', 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('el_def_capex_ede', 'Balance con Inversiones EDEESTE', NULL, 'Eléctrico', 'financiero', 'anual', 'RD$', 'Unidad', 'MEM', 'https://mem.gob.do/category/sector-electrico/informe-de-desempeno/', 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('el_def_fin_tot', 'Balance luego de Financiamiento Total', NULL, 'Eléctrico', 'financiero', 'anual', 'RD$', 'Unidad', 'MEM', 'https://mem.gob.do/category/sector-electrico/informe-de-desempeno/', 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('el_def_fin_edn', 'Balance luego de Financiamiento EDENORTE', NULL, 'Eléctrico', 'financiero', 'anual', 'RD$', 'Unidad', 'MEM', 'https://mem.gob.do/category/sector-electrico/informe-de-desempeno/', 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('el_def_fin_eds', 'Balance luego de Financiamiento EDESUR', NULL, 'Eléctrico', 'financiero', 'anual', 'RD$', 'Unidad', 'MEM', 'https://mem.gob.do/category/sector-electrico/informe-de-desempeno/', 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

INSERT INTO variables (id, nombre, descripcion, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url, tipo, formula, activo) VALUES ('el_def_fin_ede', 'Balance luego de Financiamiento EDEESTE', NULL, 'Eléctrico', 'financiero', 'anual', 'RD$', 'Unidad', 'MEM', 'https://mem.gob.do/category/sector-electrico/informe-de-desempeno/', 'directa', NULL, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    modulo = EXCLUDED.modulo,
    submodulo = EXCLUDED.submodulo,
    frecuencia = EXCLUDED.frecuencia,
    unidad = EXCLUDED.unidad,
    escala = EXCLUDED.escala,
    fuente = EXCLUDED.fuente,
    fuente_url = EXCLUDED.fuente_url,
    tipo = EXCLUDED.tipo,
    formula = EXCLUDED.formula,
    activo = EXCLUDED.activo,
    actualizado_en = NOW();

COMMIT;

-- Listo. 478 filas upserted.
