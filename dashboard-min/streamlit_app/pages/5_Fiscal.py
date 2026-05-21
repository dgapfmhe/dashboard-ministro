import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[2]))

from streamlit_app._modulo import render_modulo  # type: ignore

render_modulo(
    modulo="Fiscal",
    titulo="Fiscal (ingresos, gasto, resultados)",
)
