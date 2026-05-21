"""Dashboard Macroeconómico DGAPF — página principal.

Ejecutar:
    streamlit run streamlit_app/app.py
"""
from __future__ import annotations

import os
import sys
from pathlib import Path

# Permite `from core.*` cuando Streamlit ejecuta el archivo directamente
sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

import pandas as pd
import plotly.express as px
import streamlit as st
from supabase import create_client


st.set_page_config(
    page_title="Dashboard DGAPF",
    page_icon="📊",
    layout="wide",
    initial_sidebar_state="expanded",
)


@st.cache_resource
def _client():
    url = os.getenv("SUPABASE_URL") or st.secrets.get("SUPABASE_URL", "")
    key = os.getenv("SUPABASE_SERVICE_KEY") or st.secrets.get("SUPABASE_SERVICE_KEY", "")
    if not url or not key:
        st.error("Configura SUPABASE_URL / SUPABASE_SERVICE_KEY en secrets.")
        st.stop()
    return create_client(url, key)


@st.cache_data(ttl=600)
def listar_variables(modulo: str | None = None) -> pd.DataFrame:
    q = _client().table("variables").select("*").eq("activo", True)
    if modulo:
        q = q.eq("modulo", modulo)
    res = q.execute()
    return pd.DataFrame(res.data or [])


@st.cache_data(ttl=600)
def cargar_serie(variable_id: str, desde: str = "2015-01-01") -> pd.DataFrame:
    res = (
        _client()
        .table("series_datos")
        .select("fecha,valor,flag")
        .eq("variable_id", variable_id)
        .gte("fecha", desde)
        .order("fecha")
        .execute()
    )
    df = pd.DataFrame(res.data or [])
    if not df.empty:
        df["fecha"] = pd.to_datetime(df["fecha"])
    return df


# ---------------------------------------------------------------------------
# Home
# ---------------------------------------------------------------------------
st.title("📊 Dashboard Macroeconómico DGAPF")
st.caption("Ministerio de Hacienda — Dirección General de Análisis y Política Fiscal")

st.markdown(
    """
    Selecciona un módulo en la barra lateral para explorar las variables.

    **Módulos disponibles**
    1. Precios (IPC, IPC subyacente, transables, meta)
    2. Sector Real (IMAE, PIB, ICI, IMAM, ventas DGII, salario)
    3. Mercado Cambiario (TCN compra/venta, TCR, spread USA)
    4. Externo (BoP, importaciones, exportaciones, remesas, turistas, commodities)
    5. Fiscal (ingresos, gasto, resultado primario y global)
    6. Monetario (BMR, M1, encajes, RIN, crédito por sector)
    7. Financiero (TPM, EMBI, tasas, mercados, calidad activos)
    8. Sector Eléctrico (generación, EDEs, resultados financieros MEM)
    """
)

cat = listar_variables()
if not cat.empty:
    col1, col2, col3 = st.columns(3)
    col1.metric("Variables activas", len(cat))
    col2.metric("Módulos", cat["modulo"].nunique())
    col3.metric("Fuentes", cat["fuente"].nunique())

    st.dataframe(
        cat[["id", "nombre", "modulo", "frecuencia", "unidad", "fuente"]],
        use_container_width=True,
        hide_index=True,
    )
