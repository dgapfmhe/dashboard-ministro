import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[2]))

import plotly.express as px
import streamlit as st

from streamlit_app.app import cargar_serie, listar_variables  # type: ignore


st.title("Sector Eléctrico (MEM)")

vars_ = listar_variables(modulo="Eléctrico")
if vars_.empty:
    st.info("Aún no hay variables cargadas para este módulo.")
    st.stop()


# Submódulos derivados del prefijo del ID corto:
#   el_gen_*       -> Generación
#   el_cmg_*       -> Costos marginales
#   el_p_*         -> Precios combustibles
#   el_peaje_*     -> Peaje transmisión
#   el_tc          -> TC mensual MEM
#   el_dist_*      -> Distribuidoras (consolidado)
#   el_edenorte_*  -> Edenorte
#   el_edesur_*    -> Edesur
#   el_edeeste_*   -> Edeeste
#   el_def_*       -> Resultados financieros (anuales)
def _submodulo(var_id: str) -> str:
    if var_id.startswith("el_gen_"):
        return "Generación"
    if var_id.startswith("el_cmg_"):
        return "Costos marginales"
    if var_id.startswith("el_p_"):
        return "Precios combustibles"
    if var_id.startswith("el_peaje"):
        return "Peaje transmisión"
    if var_id == "el_tc":
        return "TC MEM"
    if var_id.startswith("el_def_"):
        return "Resultados financieros (anual)"
    if var_id.startswith("el_edenorte"):
        return "Edenorte"
    if var_id.startswith("el_edesur"):
        return "Edesur"
    if var_id.startswith("el_edeeste"):
        return "Edeeste"
    if var_id.startswith("el_dist"):
        return "Distribuidoras (consol.)"
    return "Otros"


vars_ = vars_.copy()
vars_["submodulo"] = vars_["id"].map(_submodulo)
submodulos = sorted(vars_["submodulo"].unique().tolist())
sub = st.selectbox("Submódulo", submodulos)
candidatas = vars_[vars_["submodulo"] == sub]

sel = st.multiselect(
    "Series",
    options=candidatas["id"].tolist(),
    default=candidatas["id"].head(2).tolist(),
    format_func=lambda i: candidatas.set_index("id").loc[i, "nombre"],
)

for var_id in sel:
    df = cargar_serie(var_id, desde="2020-01-01")
    if df.empty:
        st.warning(f"{var_id}: sin datos")
        continue
    meta = candidatas.set_index("id").loc[var_id]
    st.subheader(f"{meta['nombre']}  ·  {meta['unidad']}")
    fig = px.line(df, x="fecha", y="valor", markers=True)
    fig.update_layout(height=340, margin=dict(l=10, r=10, t=30, b=10))
    st.plotly_chart(fig, use_container_width=True)
