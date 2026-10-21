-- ============================================================================
-- Sentimiento de prensa (ISEC / ISEP) — tablas para el Dashboard Macro
-- Pegar completo en Supabase → SQL Editor → Run. Idempotente.
-- El TEXTO de las noticias NO vive aquí (repo privado dashboard-noticias).
-- ============================================================================

create table if not exists sent_categorias (
  id            text primary key,
  nombre        text not null,
  nivel         smallint not null,          -- 0 todo · 1 sector · 2 subcategoría
  padre         text,
  origen        text,                       -- investigacion | usuario | sistema
  congelada     boolean default false,
  activa_desde  date,
  n_queries     int,
  palabras_clave text[],
  actualizado   timestamptz default now()
);

create table if not exists sent_modelos (
  id         text primary key,
  nombre     text,
  tipo       text,
  idiomas    text[],
  activo     boolean,
  principal  boolean,
  f1_oro     double precision,
  kappa_oro  double precision,
  n_oro      int,
  actualizado timestamptz default now()
);

-- Agregados: freq D/W/M para TODO y sectores; solo M para subcategorías.
-- W = semana que empieza el lunes. El ISEC se calcula en el navegador con estos conteos.
create table if not exists sent_agregado (
  freq          char(1) not null,
  fecha         date not null,
  categoria_id  text not null,
  modelo_id     text not null,
  universo      text not null,              -- query | amplio
  n             int not null,
  n_pos         int, n_neu int, n_neg int,
  suma_pol      double precision,
  suma_pol2     double precision,
  primary key (freq, fecha, categoria_id, modelo_id, universo)
);
create index if not exists sent_agregado_cat on sent_agregado (categoria_id, modelo_id, universo, freq, fecha);

-- ISEP: sentimiento latente (filtro/suavizador de Kalman)
create table if not exists sent_latente (
  freq          char(1) not null,           -- D | W | M
  fecha         date not null,
  categoria_id  text not null,
  modelo_id     text not null,
  universo      text not null,
  observado     double precision,           -- SPS observado (ISEP con ruido)
  n             int,
  filtrado      double precision,           -- en tiempo real (no mira el futuro)
  filtrado_se   double precision,
  suavizado     double precision,           -- usa toda la muestra (solo histórico)
  suavizado_se  double precision,
  primary key (freq, fecha, categoria_id, modelo_id, universo)
);
create index if not exists sent_latente_cat on sent_latente (categoria_id, modelo_id, universo, freq, fecha);

create table if not exists sent_latente_param (
  freq text not null, categoria_id text not null, modelo_id text not null, universo text not null,
  mu double precision, theta double precision, s2_eta double precision, s2_eps double precision,
  q double precision, pct_ruido double precision, n_obs int, n_mediana double precision,
  estimado_en text,
  primary key (freq, categoria_id, modelo_id, universo)
);

create table if not exists sent_markov (
  freq text not null, fecha date not null, categoria_id text not null,
  modelo_id text not null, universo text not null,
  p_estres double precision,
  primary key (freq, fecha, categoria_id, modelo_id, universo)
);

-- Últimas noticias (60 días): titular + medio + enlace + puntaje. SIN texto.
create table if not exists sent_noticias (
  id         text not null,
  modelo_id  text not null,
  fecha      date not null,
  titulo     text,
  medio      text,
  url        text,
  sectores   text[],
  polaridad  double precision,
  etiqueta   text,
  base       text,                          -- titulo | texto
  primary key (id, modelo_id)
);
create index if not exists sent_noticias_fecha on sent_noticias (fecha desc);

-- Lectura pública (el dashboard es público); escritura solo con service key.
do $$
declare t text;
begin
  foreach t in array array['sent_categorias','sent_modelos','sent_agregado','sent_latente',
                           'sent_latente_param','sent_markov','sent_noticias']
  loop
    execute format('alter table %I enable row level security', t);
    execute format('drop policy if exists lectura_publica on %I', t);
    execute format('create policy lectura_publica on %I for select using (true)', t);
  end loop;
end $$;
