"""Helper para construir una página de Streamlit por módulo.

Uso:

    from streamlit_app._modulo import render_modulo
    render_modulo(modulo="Real", titulo="Sector Real")
"""
from __future__ import annotations

import plotly.express as px
import streamlit as st

from streamlit_app.app import cargar_serie, listar_variables  # type: ignore


def render_modulo(modulo: str, titulo: str | None = None,
                  desde_default: str = "2015-01-01") -> None:
    st.title(titulo or modulo)

    vars_ = listar_variables(modulo=modulo)
    if vars_.empty:
        st.info("Aún no hay variables cargadas para este módulo.")
        return

    # Filtros
    col1, col2 = st.columns([3, 1])
    frecs = sorted(vars_["frecuencia"].dropna().unique().tolist())
    if len(frecs) > 1:
        freq = col2.selectbox("Frecuencia", ["(todas)"] + frecs)
        if freq != "(todas)":
            vars_ = vars_[vars_["frecuencia"] == freq]

    if "tipo" in vars_.columns:
        tipos_disp = sorted(vars_["tipo"].dropna().unique().tolist())
        if len(tipos_disp) > 1:
            tipo_sel = col2.selectbox("Tipo", ["(todos)"] + tipos_disp)
            if tipo_sel != "(todos)":
                vars_ = vars_[vars_["tipo"] == tipo_sel]

    sel = col1.multiselect(
        "Series",
        options=vars_["id"].tolist(),
        default=vars_["id"].head(3).tolist(),
        format_func=lambda i: vars_.set_index("id").loc[i, "nombre"],
    )

    desde = st.date_input("Desde", value=None)
    desde_str = desde.isoformat() if desde else desde_default

    for var_id in sel:
        df = cargar_serie(var_id, desde=desde_str)
        if df.empty:
            st.warning(f"{var_id}: sin datos")
            continue
        meta = vars_.set_index("id").loc[var_id]
        sub = f"{meta['nombre']}  ·  {meta.get('unidad','')}"
        if meta.get("escala") and meta["escala"] != "Unidad":
            sub += f"  ({meta['escala']})"
        if meta.get("tipo") == "derivada" and meta.get("formula"):
            sub += f"   _[{meta['formula']}]_"
        st.subheader(sub)
        fig = px.line(df, x="fecha", y="valor", markers=True)
        fig.update_layout(height=340, margin=dict(l=10, r=10, t=30, b=10))
        st.plotly_chart(fig, use_container_width=True)
