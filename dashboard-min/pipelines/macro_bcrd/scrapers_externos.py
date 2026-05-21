"""Scrapers de fuentes externas referidos por `gestion_datos22.R`.

En el R original se scrapeaba investing.com, markets.businessinsider.com,
prices.lbma.org.uk. Estos sitios a menudo bloquean bots; por eso aquí
preferimos alternativas estables vía Yahoo Finance / FRED / LBMA JSON
y dejamos los scrapers HTML como *fallback* opcional.
"""
from __future__ import annotations

from datetime import datetime, timedelta, date

import pandas as pd

from core.logging_utils import get_logger

log = get_logger(__name__)


# ---------------------------------------------------------------------------
# Yahoo Finance (reemplaza quantmod::getSymbols)
# ---------------------------------------------------------------------------
def serie_yahoo(ticker: str, variable_id: str,
                desde: str = "2015-01-01") -> pd.DataFrame:
    """Descarga cierre ajustado desde Yahoo Finance (reemplazo de quantmod)."""
    try:
        import yfinance as yf
    except ImportError as e:  # noqa: BLE001
        log.warning("yfinance no instalado: %s", e)
        return pd.DataFrame()

    log.info("Yahoo: %s", ticker)
    hist = yf.download(ticker, start=desde, progress=False, auto_adjust=False)
    if hist.empty:
        return pd.DataFrame()
    s = hist["Close"].dropna()
    # yfinance a veces devuelve MultiIndex; aplanar
    if isinstance(s, pd.DataFrame):
        s = s.iloc[:, 0]
    return pd.DataFrame({
        "variable_id": variable_id,
        "fecha": s.index.date,
        "valor": s.values.astype(float),
    })


TICKERS_YAHOO: list[tuple[str, str]] = [
    ("CL=F",  "petroleo_wti"),
    ("NG=F",  "gas_natural"),
    ("MTF=F", "carbon_aus"),
    ("GC=F",  "oro"),
    ("^GSPC", "sp500"),
    ("^DJI",  "dow_jones"),
    ("^VIX",  "vix"),
]


def descargar_mercados() -> pd.DataFrame:
    out = []
    for ticker, var_id in TICKERS_YAHOO:
        try:
            out.append(serie_yahoo(ticker, var_id))
        except Exception as e:  # noqa: BLE001
            log.warning("Yahoo fallo %s: %s", ticker, e)
    return pd.concat(out, ignore_index=True) if out else pd.DataFrame()


# ---------------------------------------------------------------------------
# FRED (reemplaza fredr)
# ---------------------------------------------------------------------------
FRED_SERIES = [
    # (serie_id_FRED, variable_id, frecuencia)
    ("CPIAUCSL",    "cpi_usa",       "m"),
    ("CPIAUCSL",    "ipc_eeuu",      "m"),    # alias R
    ("INDPRO",      "indpro_usa",    "m"),
    ("IPMAN",       "indproMan_usa", "m"),
    ("DGS10",       "ust_10y",       "d"),
    ("FEDFUNDS",    "ti_fond_fed",   "m"),
    ("UNRATE",      "ur_sa_usa",     "m"),
    ("UNRATENSA",   "ur_usa",        "m"),
    ("USEPUINDXM",  "epu_eeuu",      "m"),
    ("GEPUCURRENT", "epu_global",    "m"),
    ("GDPC1",       "pib_eeuu",      "q"),
]


def descargar_fred(api_key: str | None) -> pd.DataFrame:
    if not api_key:
        log.warning("FRED_API_KEY ausente; omitiendo FRED")
        return pd.DataFrame()
    try:
        from fredapi import Fred
    except ImportError as e:  # noqa: BLE001
        log.warning("fredapi no instalado: %s", e)
        return pd.DataFrame()

    fred = Fred(api_key=api_key)
    frames = []
    for serie_id, var_id, _freq in FRED_SERIES:
        try:
            s = fred.get_series(serie_id)
            frames.append(pd.DataFrame({
                "variable_id": var_id,
                "fecha": s.index.date,
                "valor": s.values.astype(float),
            }))
            log.info("FRED %s → %s: %d filas", serie_id, var_id, len(s))
        except Exception as e:  # noqa: BLE001
            log.warning("FRED fallo %s: %s", serie_id, e)
    return pd.concat(frames, ignore_index=True) if frames else pd.DataFrame()


# ---------------------------------------------------------------------------
# World Bank Commodity Prices (Pink Sheet) — URL 2026 desde Data_dgapf_gg1.R
# ---------------------------------------------------------------------------
WB_CMO_URL = (
    "https://thedocs.worldbank.org/en/doc/"
    "74e8be41ceb20fa0da750cda2f6b9e4e-0050012026/related/"
    "CMO-Historical-Data-Monthly.xlsx"
)


def _conv_fecha_wb(v):
    """Convierte '2020M01' → date(2020, 1, 1)."""
    s = str(v).strip()
    if "M" in s and len(s) >= 6:
        try:
            y, m = s.split("M")
            return date(int(y), int(m), 1)
        except Exception:
            return None
    return None


def descargar_worldbank_cmo() -> pd.DataFrame:
    """Pink Sheet mensual del Banco Mundial. Extrae:
      - Precios spot:  Crude oil WTI, Natural gas US, Gold (hoja 'Monthly Prices', skip=4)
      - Índices:       Energy, Non-energy, Food, Metals, Precious metals,
                       Agriculture (hoja 'Monthly Indices', skip=8)
    Mapeo a IDs catálogo_r.
    """
    from core.http_utils import download_to
    from core.config import ensure_output_dir

    dest = ensure_output_dir().parent / "raw" / "worldbank" / "cmo.xlsx"
    try:
        download_to(WB_CMO_URL, dest)
    except Exception as e:  # noqa: BLE001
        log.warning("WB CMO no descargable: %s", e)
        return pd.DataFrame()

    frames: list[pd.DataFrame] = []

    # --- Hoja 'Monthly Prices' (precios spot) ---
    try:
        prices = pd.read_excel(dest, sheet_name="Monthly Prices", header=4)
        col_fecha = prices.columns[0]
        prices[col_fecha] = prices[col_fecha].map(_conv_fecha_wb)
        prices = prices.dropna(subset=[col_fecha])

        def _find_col(df, *keywords):
            for c in df.columns:
                lc = str(c).lower()
                if all(k.lower() in lc for k in keywords):
                    return c
            return None

        mapping_prices = [
            ("p_petroleo",  _find_col(prices, "crude oil", "wti")),
            ("p_gas_nat",   _find_col(prices, "natural gas", "us")),
            ("p_oro",       _find_col(prices, "gold")),
        ]
        for var_id, col in mapping_prices:
            if col is None:
                log.warning("WB CMO Prices: columna no encontrada para %s", var_id)
                continue
            s = pd.to_numeric(prices[col], errors="coerce")
            df = pd.DataFrame({
                "variable_id": var_id,
                "fecha": prices[col_fecha].tolist(),
                "valor": s.values.astype(float),
            }).dropna()
            frames.append(df)
            log.info("WB CMO Prices: %s → %d filas", var_id, len(df))
    except Exception as e:
        log.warning("WB CMO 'Monthly Prices' parse falló: %s", e)

    # --- Hoja 'Monthly Indices' (índices, header=8) ---
    # Las columnas tienen nombres irregulares ('Unnamed', ' ', ' .1', etc.),
    # así que usamos índices posicionales del R script (0-based):
    #   col 2 = Energy, col 3 = Non-Energy, col 4 = Agriculture,
    #   col 6 = Food, col 14 = Metals, col 16 = Precious metals
    try:
        indices = pd.read_excel(dest, sheet_name="Monthly Indices", header=8,
                                 dtype=object)
        col_fecha_i = indices.columns[0]
        indices[col_fecha_i] = indices[col_fecha_i].map(_conv_fecha_wb)
        indices = indices.dropna(subset=[col_fecha_i])

        mapping_idx_pos = [
            ("ener_ind",        2),
            ("non_ener_ind",    3),
            ("ind_p_AyB",       4),
            ("food_ind",        6),
            ("metals_ind",     14),
            ("prec_metal_ind", 16),
        ]
        for var_id, col_idx in mapping_idx_pos:
            if col_idx >= indices.shape[1]:
                log.warning("WB CMO: col %d fuera de rango para %s", col_idx, var_id)
                continue
            s = pd.to_numeric(indices.iloc[:, col_idx], errors="coerce")
            df = pd.DataFrame({
                "variable_id": var_id,
                "fecha": indices[col_fecha_i].tolist(),
                "valor": s.values.astype(float),
            }).dropna()
            frames.append(df)
            log.info("WB CMO Indices: %s → %d filas", var_id, len(df))
    except Exception as e:
        log.warning("WB CMO 'Monthly Indices' parse falló: %s", e)

    if not frames:
        return pd.DataFrame()
    return pd.concat(frames, ignore_index=True)
