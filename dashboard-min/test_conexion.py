"""
Corre esto primero para verificar que Supabase y FRED conectan bien:
    python test_conexion.py
"""
import os
from dotenv import load_dotenv

load_dotenv()

print("=" * 50)
print("TEST DE CONEXIÓN")
print("=" * 50)

# 1. Supabase
print("\n1. Supabase...")
try:
    from supabase import create_client
    url  = os.getenv("SUPABASE_URL", "")
    key  = os.getenv("SUPABASE_SERVICE_KEY", "")
    assert url and key, "SUPABASE_URL o SUPABASE_SERVICE_KEY vacíos en .env"
    client = create_client(url, key)

    # Verificar que las tablas existen
    r = client.table("variables").select("id", count="exact").limit(1).execute()
    print(f"   ✓ Tabla 'variables' OK — {r.count} filas")

    r2 = client.table("series_datos").select("variable_id", count="exact").limit(1).execute()
    print(f"   ✓ Tabla 'series_datos' OK — {r2.count} filas")

except AssertionError as e:
    print(f"   ✗ Config: {e}")
except Exception as e:
    msg = str(e)
    if "variables" in msg and "schema cache" in msg:
        print("   ✗ Tabla 'variables' NO EXISTE — Aplica sql/setup_completo.sql en Supabase SQL Editor")
    elif "series_datos" in msg and "schema cache" in msg:
        print("   ✗ Tabla 'series_datos' NO EXISTE — Aplica sql/setup_completo.sql en Supabase SQL Editor")
    else:
        print(f"   ✗ Error: {e}")

# 2. FRED
print("\n2. FRED API...")
try:
    from fredapi import Fred
    fred_key = os.getenv("FRED_API_KEY", "")
    assert fred_key, "FRED_API_KEY vacía en .env"
    fred = Fred(api_key=fred_key)
    serie = fred.get_series("FEDFUNDS", observation_start="2024-01-01")
    print(f"   ✓ FRED OK — Fed Funds último valor: {serie.iloc[-1]:.2f}%")
except AssertionError as e:
    print(f"   ✗ Config: {e}")
except Exception as e:
    print(f"   ✗ Error: {e}")

# 3. Yahoo Finance
print("\n3. Yahoo Finance...")
try:
    import yfinance as yf
    ticker = yf.Ticker("CL=F")
    hist = ticker.history(period="5d")
    precio = hist["Close"].iloc[-1]
    print(f"   ✓ Yahoo Finance OK — WTI último precio: ${precio:.2f}")
except Exception as e:
    print(f"   ✗ Error: {e}")

print("\n" + "=" * 50)
print("Si todo marcó ✓, corre el pipeline:")
print("  python -m pipelines.macro_bcrd.run")
print("=" * 50)
