-- ============================================================================
-- Pronósticos oficiales (laboratorio) — historial de aciertos
-- Pegar en Supabase → SQL Editor → Run. Idempotente.
-- ============================================================================

-- Pronóstico vigente (se reescribe cada día): nowcast del próximo dato a publicar.
create table if not exists pred_nowcast (
  spec_id        text not null,
  modelo_id      text not null,
  modelo_nombre  text,
  objetivo       text,
  descripcion    text,
  fecha_objetivo date not null,
  emitido        timestamptz not null default now(),
  media          double precision,
  li95           double precision,
  ls95           double precision,
  interanual     double precision,
  real           double precision,
  real_interanual double precision,
  primary key (spec_id, modelo_id)
);

-- Pronóstico CONGELADO: el primero emitido después de cerrar el mes objetivo
-- (sentimiento completo) y antes de que salga el dato oficial. Nunca se reescribe;
-- cuando el dato real se publica se completa la columna `real`.
create table if not exists pred_vintage (
  spec_id        text not null,
  modelo_id      text not null,
  modelo_nombre  text,
  objetivo       text,
  descripcion    text,
  fecha_objetivo date not null,
  emitido        timestamptz not null default now(),
  media          double precision,
  li95           double precision,
  ls95           double precision,
  interanual     double precision,
  real           double precision,
  real_interanual double precision,
  primary key (spec_id, modelo_id, fecha_objetivo)
);

-- Métricas del backtest (fuera de muestra) de cada especificación oficial.
create table if not exists pred_metricas (
  spec_id        text not null,
  modelo_id      text not null,
  modelo_nombre  text,
  descripcion    text,
  n              int,
  rmse           double precision,
  rrmse_ar       double precision,
  p_dm_ar        double precision,
  acierto_dir    double precision,
  actualizado    timestamptz default now(),
  primary key (spec_id, modelo_id)
);

do $$
declare t text;
begin
  foreach t in array array['pred_nowcast','pred_vintage','pred_metricas']
  loop
    execute format('alter table %I enable row level security', t);
    execute format('drop policy if exists lectura_publica on %I', t);
    execute format('create policy lectura_publica on %I for select using (true)', t);
  end loop;
end $$;
