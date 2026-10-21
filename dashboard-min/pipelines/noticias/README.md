# Noticias · sentimiento de prensa (ISEC / ISEP)

Scraper autónomo de Google News → almacén Parquet (repo privado
`dgapfmhe/dashboard-noticias`) → sentimiento con modelos intercambiables →
índices en Supabase → pestaña **Sentimiento de Prensa** del dashboard.

## Flujo diario (GitHub Actions, `noticias.yml`, 06:00 RD)

1. `scraper diario`: día t-1 con las 130 búsquedas de la investigación + re-barrido
   de t-3 (lo publicado/indexado tarde) + barrido general por medio (`site:dominio`,
   partido por secciones si Google satura en 100).
2. `scraper categorias-nuevas`: backfill semana a semana de las categorías agregadas.
3. `scraper textos`: decodifica el enlace de Google News → URL del medio → texto
   completo (trafilatura). Se guarda ÍNTEGRO (cada modelo trunca con su tokenizer).
4. `sentimiento`: puntúa con cada modelo activo (`config/modelos.yaml`).
5. `indices`: etiquetado, agregados, ISEP (Kalman) y Markov → Supabase.

`noticias-textos.yml` corre 2 veces más al día solo para avanzar la cola de
textos del histórico (93k noticias migradas de `isec_news.db`).

**Ritmo con Google** (prioridad: no ser bloqueados): 6 s + U(0,4) s entre
búsquedas, 4 s + U(0,3) s entre peticiones de decodificación, espera de 1/3/7 min
ante 429/captcha y corte de la corrida tras 3 bloqueos seguidos (lo pendiente queda
para la siguiente). Ajustable en `gnews.py` (`Ritmo`).

## Configuración

| archivo | qué |
|---|---|
| `config/categorias.yaml` | 19 sectores + 125 subcategorías de la investigación (congeladas) + las de usuario |
| `config/medios.yaml` | medios del barrido general y sus secciones |
| `config/modelos.yaml` | modelos de sentimiento (pysentimiento, HuggingFace, local) |

**Agregar una categoría:** botón "+ Agregar categoría" en la pestaña (abre el
formulario de issue). El workflow `noticias-categoria.yml` la agrega al YAML si
quien la pide es dueño/colaborador. Desde el día siguiente: se sigue desde t, se
re-etiqueta la historia por palabras clave y se hace backfill si se pidió.

**Cambiar/agregar modelo:** añadir un bloque en `modelos.yaml` con `activo: true`.
Puntúa todo el histórico sin borrar los demás modelos. Validarlo con
`python -m pipelines.noticias.herramientas.validar_modelos --modelo <id>`.

## Universos

- **query**: noticias traídas por las búsquedas de la categoría (comparable con el paper).
- **amplio**: query ∪ notas de cualquier origen (incl. barrido) con las palabras clave.

Se excluye solo lo claramente extranjero (medio no RD + texto sin ancla RD + menciona otro país).

## Comandos locales

```bash
set NOTICIAS_DIR=C:/Users/patri/Desktop/dashboard-noticias
python -m pipelines.noticias.scraper estado
python -m pipelines.noticias.scraper diario --dia 2026-10-20
python -m pipelines.noticias.sentimiento --minutos 30
python -m pipelines.noticias.indices --sin-subir
```
