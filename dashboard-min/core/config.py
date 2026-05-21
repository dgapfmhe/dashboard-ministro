"""Configuración central: secretos vía variables de entorno (GitHub Secrets o .env local)."""
from __future__ import annotations

import os
from functools import lru_cache
from pathlib import Path

from dotenv import load_dotenv
from pydantic_settings import BaseSettings, SettingsConfigDict


# Permite ejecutar desde cualquier carpeta si hay un .env junto al repo
_REPO_ROOT = Path(__file__).resolve().parents[1]
load_dotenv(_REPO_ROOT / ".env", override=False)


class Settings(BaseSettings):
    """Todos los valores vienen de env. NO guardar secretos en el repo."""

    # Supabase
    supabase_url: str | None = None
    supabase_service_key: str | None = None

    # FRED
    fred_api_key: str | None = None

    # SQL Server DGA (solo runner interno)
    dga_sql_server: str | None = None
    dga_sql_uid: str | None = None
    dga_sql_pwd: str | None = None
    dga_sql_db: str | None = None

    # Rutas
    excel_output_dir: Path = _REPO_ROOT / "data" / "excel_output"

    # User agent para scraping
    user_agent: str = (
        "Mozilla/5.0 (compatible; DGAPF-Dashboard/1.0; "
        "+https://hacienda.gob.do)"
    )

    model_config = SettingsConfigDict(env_file=".env", env_file_encoding="utf-8", extra="ignore")


@lru_cache(maxsize=1)
def get_settings() -> Settings:
    return Settings()


def ensure_output_dir() -> Path:
    path = get_settings().excel_output_dir
    path.mkdir(parents=True, exist_ok=True)
    return path
