"""Conexión al SQL Server interno de la DGA (Dirección General de Aduanas).

En el script R:
  conn <- odbcDriverConnect("driver={SQL Server};server=172.16.2.91;
                            database=...;uid=usrplt;pwd=...")
  sqlQuery(conn, "SELECT ...")

Aquí usamos `pyodbc`. Si el runner no tiene acceso (GitHub Actions
público), la función hace short-circuit y retorna DataFrame vacío.
"""
from __future__ import annotations

import os
from contextlib import contextmanager

import pandas as pd

from core.config import get_settings
from core.logging_utils import get_logger

log = get_logger(__name__)


@contextmanager
def conectar():
    s = get_settings()
    if not (s.dga_sql_server and s.dga_sql_uid and s.dga_sql_pwd and s.dga_sql_db):
        log.info("Credenciales DGA no configuradas; omitiendo consulta")
        yield None
        return
    try:
        import pyodbc
    except ImportError as e:  # noqa: BLE001
        log.warning("pyodbc no instalado: %s", e)
        yield None
        return

    driver = os.getenv("DGA_SQL_DRIVER", "{ODBC Driver 17 for SQL Server}")
    cn_str = (
        f"DRIVER={driver};SERVER={s.dga_sql_server};DATABASE={s.dga_sql_db};"
        f"UID={s.dga_sql_uid};PWD={s.dga_sql_pwd};TrustServerCertificate=yes;"
    )
    conn = None
    try:
        conn = pyodbc.connect(cn_str, timeout=15)
        yield conn
    except Exception as e:  # noqa: BLE001
        log.warning("Conexión DGA falló: %s", e)
        yield None
    finally:
        if conn is not None:
            conn.close()


def query(sql: str) -> pd.DataFrame:
    """Ejecuta una consulta en la DGA. Retorna DataFrame vacío si no hay conexión."""
    with conectar() as conn:
        if conn is None:
            return pd.DataFrame()
        return pd.read_sql(sql, conn)
