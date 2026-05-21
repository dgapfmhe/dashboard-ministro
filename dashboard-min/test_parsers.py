"""Quick smoke-test for all new parsers."""
from pathlib import Path
from pipelines.macro_bcrd.parsers_bcrd import (
    parser_ipc_sub, parser_rin, parser_pib_gasto,
    parser_ti_intb, parser_ti_activa, parser_ti_pasiva,
    parser_credito_sect, parser_agregados, PARSER_REGISTRY,
)

RAW = Path("data/raw/bcrd")

tests = [
    ("ipc_sub",      RAW / "ipc_sub.xlsx",       parser_ipc_sub),
    ("rin",          RAW / "rin.xlsx",            parser_rin),
    ("pib_gasto",    RAW / "pib_gasto.xlsx",      parser_pib_gasto),
    ("ti_intb",      RAW / "ti_intb.xls",         parser_ti_intb),
    ("ti_activa",    RAW / "ti_activa.xlsx",       parser_ti_activa),
    ("ti_pasiva",    RAW / "ti_pasiva.xlsx",       parser_ti_pasiva),
    ("credito_sect", RAW / "credito_sect.xlsx",   parser_credito_sect),
    ("agregados",    RAW / "agregados.xlsx",       parser_agregados),
]

# Also test bug-fixed parsers
fixed = [
    ("encaje (encaje_mn)",   RAW / "encaje.xlsx",    PARSER_REGISTRY["encaje"]),
    ("tc_ent_fin (tcn_m)",   RAW / "tc_ent_fin.xls", PARSER_REGISTRY["tc_ent_fin"]),
]

print("=" * 60)
print("PARSER SMOKE TESTS")
print("=" * 60)

for name, path, fn in tests + fixed:
    if not path.exists():
        print(f"  SKIP {name}: archivo no encontrado")
        continue
    df = fn(path)
    if df.empty:
        print(f"  FAIL {name}: DataFrame vacío")
    else:
        vars_found = df["variable_id"].unique().tolist()
        print(f"  OK   {name}: {len(df):,} filas | vars={vars_found} | "
              f"fechas {df['fecha'].min()} a {df['fecha'].max()}")
