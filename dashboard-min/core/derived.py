"""Evaluador de fórmulas para variables derivadas.

Permite definir variables como ``tcn_spread = tcn_venta - tcn_compra``,
``ipc_yoy = ipc_rd / lag(ipc_rd, 12) - 1``, etc., y calcularlas a partir
de series ya cargadas.

Funciones soportadas
--------------------
* Aritmética: ``+ - * /`` y unario ``-``
* Constantes numéricas
* ``lag(var, n)``  → ``serie.shift(n)``
* ``diff(var, n)`` → ``serie.diff(n)``  (default n=1)
* ``log(var)``     → ``np.log(serie)``
* ``pct(var, n)``  → ``serie.pct_change(n)``  (default n=1)

Para frecuencia mensual, ``lag(x, 12)`` da el valor de hace 12 meses,
``lag(x, 1)`` el del mes anterior. Para trimestral, ``lag(x, 4)``
es el mismo trimestre del año pasado, etc.

Uso
---
>>> from core.derived import evaluar_formula, calcular_derivadas
>>> series = {
...     "tcn_compra": pd.Series([60.1, 60.2, 60.4], index=fechas),
...     "tcn_venta":  pd.Series([60.3, 60.5, 60.7], index=fechas),
... }
>>> evaluar_formula("tcn_venta - tcn_compra", series)
"""
from __future__ import annotations

import ast
import keyword
import logging
import re
from typing import Mapping

import numpy as np
import pandas as pd

log = logging.getLogger(__name__)

# IDs como `import`, `class`, `def`, `return` chocan con la sintaxis de Python.
# Los renombramos a `_var_<id>` antes de parsear y los volvemos a mapear al
# leerlos del diccionario de series.
_PREFIJO_RESERVADO = "_var_"


def _escapar_reservadas(formula: str) -> str:
    """Reemplaza identificadores que coinciden con keywords de Python."""
    def _sub(m):
        nombre = m.group(0)
        if keyword.iskeyword(nombre):
            return _PREFIJO_RESERVADO + nombre
        return nombre

    return re.sub(r"\b[A-Za-z_][A-Za-z0-9_]*\b", _sub, formula)


def _desescapar(nombre: str) -> str:
    if nombre.startswith(_PREFIJO_RESERVADO):
        return nombre[len(_PREFIJO_RESERVADO):]
    return nombre


# ---------------------------------------------------------------------------
# AST seguro
# ---------------------------------------------------------------------------

_BIN_OPS = {
    ast.Add: lambda a, b: a + b,
    ast.Sub: lambda a, b: a - b,
    ast.Mult: lambda a, b: a * b,
    ast.Div: lambda a, b: a / b,
    ast.Pow: lambda a, b: a ** b,
}

_FUNCS = {
    "lag": lambda s, n=1: s.shift(int(n)),
    "diff": lambda s, n=1: s.diff(int(n)),
    "log": lambda s: np.log(s),
    "pct": lambda s, n=1: s.pct_change(int(n)),
    "abs": lambda s: s.abs() if hasattr(s, "abs") else abs(s),
}


def _eval_nodo(node: ast.AST, series: Mapping[str, pd.Series]) -> pd.Series | float:
    if isinstance(node, ast.Expression):
        return _eval_nodo(node.body, series)
    if isinstance(node, ast.Constant):
        if isinstance(node.value, (int, float)):
            return node.value
        raise ValueError(f"Constante no numérica: {node.value!r}")
    if isinstance(node, ast.Name):
        nombre = _desescapar(node.id)
        if nombre not in series:
            raise KeyError(f"Serie '{nombre}' no disponible para evaluar la fórmula")
        return series[nombre]
    if isinstance(node, ast.UnaryOp):
        if isinstance(node.op, ast.USub):
            return -_eval_nodo(node.operand, series)
        if isinstance(node.op, ast.UAdd):
            return +_eval_nodo(node.operand, series)
        raise ValueError(f"Operador unario no soportado: {type(node.op).__name__}")
    if isinstance(node, ast.BinOp):
        op = _BIN_OPS.get(type(node.op))
        if op is None:
            raise ValueError(f"Operador binario no soportado: {type(node.op).__name__}")
        return op(_eval_nodo(node.left, series), _eval_nodo(node.right, series))
    if isinstance(node, ast.Call):
        if not isinstance(node.func, ast.Name):
            raise ValueError("Solo funciones por nombre")
        fn = _FUNCS.get(node.func.id)
        if fn is None:
            raise ValueError(f"Función no soportada: {node.func.id}")
        args = [_eval_nodo(a, series) for a in node.args]
        return fn(*args)
    raise ValueError(f"Nodo AST no soportado: {type(node).__name__}")


def evaluar_formula(formula: str, series: Mapping[str, pd.Series]) -> pd.Series:
    """Evalúa una fórmula contra un mapa de series y devuelve una pd.Series.

    Las series deben compartir índice (``fecha``) — la operación se hace
    elemento a elemento gracias a la alineación automática de pandas.
    """
    tree = ast.parse(_escapar_reservadas(formula), mode="eval")
    out = _eval_nodo(tree, series)
    if isinstance(out, (int, float)):
        # constante pura: devolver una serie vacía
        return pd.Series([out])
    return out


# ---------------------------------------------------------------------------
# helpers de orquestación
# ---------------------------------------------------------------------------

def referencias(formula: str) -> set[str]:
    """Devuelve los IDs de variable usados en la fórmula."""
    tree = ast.parse(_escapar_reservadas(formula), mode="eval")
    return {_desescapar(n.id) for n in ast.walk(tree)
            if isinstance(n, ast.Name) and _desescapar(n.id) not in _FUNCS}


def calcular_derivadas(
    derivadas: list[dict],
    series: Mapping[str, pd.Series],
    fail_silently: bool = True,
) -> dict[str, pd.Series]:
    """Calcula todas las variables derivadas posibles.

    Resuelve dependencias en orden topológico simple — pasadas iterativas
    hasta que no haya progreso. Si ``fail_silently`` es ``True`` (default)
    los errores se loguean y la variable se omite.
    """
    pendientes = {v["id"]: v for v in derivadas if v.get("formula")}
    resultados: dict[str, pd.Series] = {}
    disponibles = dict(series)

    while pendientes:
        progreso = False
        for vid in list(pendientes):
            v = pendientes[vid]
            refs = referencias(v["formula"])
            if not refs.issubset(disponibles):
                continue
            try:
                resultados[vid] = evaluar_formula(v["formula"], disponibles)
                disponibles[vid] = resultados[vid]
                del pendientes[vid]
                progreso = True
            except Exception as exc:  # noqa: BLE001
                msg = f"No se pudo calcular '{vid}' ({v['formula']!r}): {exc}"
                if fail_silently:
                    log.warning(msg)
                    del pendientes[vid]
                    progreso = True
                else:
                    raise

        if not progreso:
            for vid, v in pendientes.items():
                faltantes = referencias(v["formula"]) - disponibles.keys()
                log.warning("'%s' depende de variables ausentes: %s", vid, faltantes)
            break

    return resultados


def serie_larga_a_pivot(df_largo: pd.DataFrame) -> dict[str, pd.Series]:
    """Convierte un DataFrame largo (variable_id, fecha, valor) a un dict de series.

    Útil para alimentar ``calcular_derivadas`` con datos leídos de Supabase.
    """
    if df_largo.empty:
        return {}
    df_largo = df_largo.sort_values("fecha")
    out: dict[str, pd.Series] = {}
    for vid, grupo in df_largo.groupby("variable_id"):
        s = pd.Series(grupo["valor"].values, index=pd.to_datetime(grupo["fecha"]).values)
        out[vid] = s
    return out


def derivadas_a_largo(
    resultados: dict[str, pd.Series],
    flag: str = "derivada",
) -> pd.DataFrame:
    """Convierte el output de ``calcular_derivadas`` al formato largo
    listo para upsertear a Supabase: columnas ``variable_id, fecha, valor, flag``.
    """
    filas = []
    for vid, serie in resultados.items():
        for fecha, valor in serie.items():
            if pd.isna(valor):
                continue
            filas.append(
                {
                    "variable_id": vid,
                    "fecha": pd.Timestamp(fecha).date().isoformat(),
                    "valor": float(valor),
                    "flag": flag,
                }
            )
    return pd.DataFrame(filas)
