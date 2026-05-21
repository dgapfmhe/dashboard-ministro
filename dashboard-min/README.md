# Dashboard Macroeconómico DGAPF

Pipelines Python + Supabase + GitHub Actions + Streamlit para el Dashboard
Macroeconómico de la Dirección General de Análisis y Política Fiscal (DGAPF),
Ministerio de Hacienda — República Dominicana.

Convertido desde los 3 scripts R del equipo:
- `data1.R` → `pipelines/sector_electrico/` (Módulo 8)
- `gestion_datos22.R` → `pipelines/macro_bcrd/` (Módulos 1–5)
- `Data_dgapf 2.R` → `pipelines/forecasting/` (Módulos 6–7 + agregaciones)

## Estructura

```
dashboard-macro/
├── core/
│   ├── catalog.py          # catálogo canónico (IDs cortos snake_case)
│   ├── catalog_loader.py   # fusión catálogo Python ∪ metadata_data_* del Excel
│   ├── derived.py          # evaluador de fórmulas para variables derivadas
│   ├── config.py · supabase_io.py · excel_io.py · dates.py · bcrd.py
├── pipelines/
│   ├── sector_electrico/  # scraping MEM + parsing Anexo (`el_*`)
│   ├── macro_bcrd/        # descargas BCRD + FRED + Yahoo + WB + cálculo de derivadas
│   └── forecasting/       # EIA STEO (`*_proy`) + Hacienda EO + SIPEN + DGA SQL + agregaciones M→T
├── sql/schema.sql         # esquema Supabase (largo) con `tipo`, `formula`, `escala`
├── streamlit_app/         # dashboard UI (8 páginas, una por módulo)
├── .github/workflows/     # daily, weekly, monthly
└── data/excel_output/     # respaldos xlsx (gitignored)
```

## Catálogo: IDs cortos + variables derivadas

Las variables tienen IDs cortos (`ipc_rd`, `tcn_compra`, `imae`, `el_gen_total`)
alineados con las hojas `metadata_data_mensual` y `metadata_data_trimestral`
del libro `dataDGAPF.xlsx` que mantiene el equipo. Para agregar una variable
nueva tienes 2 caminos:

1. **Editar Python**: agregar una entrada a `core/catalog.py` (lista
   `MENSUALES`, `TRIMESTRALES`, `DIARIAS`, `ELECTRICO` o `PROYECCIONES`).
2. **Editar Excel**: agregar una fila al `metadata_data_*` del libro y
   apuntar al pipeline a ese archivo (`--excel-metadata`). El loader fusiona
   ambos catálogos y los IDs nuevos del Excel se inyectan automáticamente.

Las variables **derivadas** (ej: `ipc_yoy`, `balanza_com`, `pond_cpr`,
`tcn_spread`) se definen con `tipo='derivada'` y un campo `formula`. El
evaluador `core.derived.calcular_derivadas()` las computa después de cargar
las series directas y soporta `lag(x, n)`, `diff(x, n)`, `pct(x, n)`,
`log(x)`, aritmética (`+ - * /`) y constantes. Ejemplos en uso:

| ID            | Fórmula                              |
|---------------|--------------------------------------|
| `tcn_spread`  | `tcn_venta - tcn_compra`             |
| `ipc_yoy`     | `ipc_rd / lag(ipc_rd, 12) - 1`       |
| `ipc_mom`     | `ipc_rd / lag(ipc_rd, 1) - 1`        |
| `balanza_com` | `export - import`                    |
| `pond_cpr`    | `cpr_nom / pib_nom`                  |

## Puesta en marcha

### 1. Supabase

Crea un proyecto Supabase y aplica el esquema:

```bash
psql "$SUPABASE_DB_URL" -f sql/schema.sql
```

o pegando `sql/schema.sql` en el SQL Editor.

### 2. Variables de entorno

Copia `.env.example` a `.env` y completa. En GitHub, configura estos **Secrets** en
Settings → Secrets and variables → Actions:

| Secret                  | Uso                                   |
|-------------------------|---------------------------------------|
| `SUPABASE_URL`          | URL del proyecto Supabase             |
| `SUPABASE_SERVICE_KEY`  | Service role key (solo backend)       |
| `FRED_API_KEY`          | [FRED API](https://fred.stlouisfed.org/docs/api/api_key.html) |
| `DGA_SQL_SERVER/UID/PWD/DB` | Solo si hay self-hosted runner en red interna |

> ⚠️ **Importante**: Las credenciales hardcodeadas en los scripts R originales
> (FRED API key y usuario SQL Server) **NO** se reutilizan. Generen un API key
> nuevo de FRED y roten la password del SQL Server.

### 3. Instalar dependencias

```bash
python -m venv .venv
source .venv/bin/activate   # Windows: .venv\Scripts\activate
pip install -r requirements.txt
```

### 4. Correr un pipeline localmente

```bash
# Solo prueba: no escribe a Supabase, solo genera el xlsx
python -m pipelines.sector_electrico.run --dry-run
python -m pipelines.macro_bcrd.run --dry-run --solo-bcrd
python -m pipelines.forecasting.run --dry-run
```

### 5. Correr el dashboard

```bash
streamlit run streamlit_app/app.py
```

## Cadencias automatizadas

| Workflow        | Cron (UTC)        | Qué hace                                           |
|-----------------|-------------------|----------------------------------------------------|
| `daily.yml`     | `0 12 * * 1-5`    | Yahoo (mercados) + FRED (CPI, DGS10)               |
| `weekly.yml`    | `0 14 * * 1`      | Pipeline macro BCRD completo                       |
| `monthly.yml`   | `0 13 1,15 * *`   | Sector eléctrico (MEM) + Forecasting (EIA STEO)   |

Todos los workflows son **idempotentes** gracias al `ON CONFLICT (variable_id, fecha) DO UPDATE`
en Supabase — correr dos veces el mismo día no duplica datos.

## Notas de migración R → Python

| R                             | Python                                    |
|-------------------------------|-------------------------------------------|
| `openxlsx::read.xlsx`         | `pandas.read_excel`                       |
| `rvest::html_nodes/html_attr` | `bs4.BeautifulSoup`                       |
| `quantmod::getSymbols`        | `yfinance.download`                       |
| `fredr::fredr`                | `fredapi.Fred`                            |
| `RODBC::odbcDriverConnect`    | `pyodbc.connect`                          |
| `aggregate.ts(..., FUN=...)`  | `core.dates.monthly_to_quarterly`         |
| `as.Date(serial, origin=...)` | `core.dates.excel_serial_to_date`         |
| `excels_importados()` custom  | `core.excel_io.leer_rango_detectado`      |
| `write.xlsx`                  | `core.excel_io.escribir_excel_por_frecuencia` |

## Pendientes conocidos

1. **Parsers BCRD**: los archivos BCRD cambian URL con cierta frecuencia;
   confirmar los paths reales ejecutando el pipeline con `--dry-run` y
   ajustando `core/bcrd.BCRD_FILES`.
2. **Hacienda EO / SIPEN**: URLs dependen de publicación en `hacienda.gob.do`;
   agregar parser específico cuando se confirme el layout.
3. **DGA SQL Server**: solo accesible desde red interna
   (`172.16.2.91`). Para GitHub Actions se requiere un **self-hosted runner**
   o una réplica en cloud.
4. **Variables nuevas**: están las que vienen de los 3 scripts R + las que
   ya existían en las hojas `metadata_data_*` (~185 totales). Si quieren
   agregar más basta con editar el Excel o `core/catalog.py`.

## Licencia

Uso interno del Ministerio de Hacienda — República Dominicana.
