"""Quick audit: list every variable_id in series_datos with its row count and date range."""
import os
from collections import Counter
from dotenv import load_dotenv
from supabase import create_client

load_dotenv()
client = create_client(os.environ["SUPABASE_URL"], os.environ["SUPABASE_SERVICE_KEY"])

# Catalog
vars_data = client.table("variables").select("id,nombre,modulo,frecuencia,unidad,fuente").execute().data
print(f"\nCATALOG: {len(vars_data)} variables\n")

# Series counts via RPC-like aggregation: page through and count
print("Loading all series_datos rows (paginated)...")
all_rows = []
page = 0
PAGE = 1000
while True:
    res = client.table("series_datos").select("variable_id,fecha").range(page * PAGE, (page + 1) * PAGE - 1).execute()
    if not res.data:
        break
    all_rows.extend(res.data)
    page += 1
    if len(res.data) < PAGE:
        break

print(f"TOTAL series_datos rows: {len(all_rows)}\n")

counts = Counter(r["variable_id"] for r in all_rows)
mins = {}
maxs = {}
for r in all_rows:
    v = r["variable_id"]; f = r["fecha"]
    if v not in mins or f < mins[v]: mins[v] = f
    if v not in maxs or f > maxs[v]: maxs[v] = f

# Sort by id
print(f"{'variable_id':<25} {'rows':>7}  {'min':<12}  {'max':<12}")
print("-" * 60)
for v in sorted(counts):
    print(f"{v:<25} {counts[v]:>7}  {mins[v]:<12}  {maxs[v]:<12}")

# Variables in catalog with NO data
no_data = [v["id"] for v in vars_data if v["id"] not in counts]
print(f"\n{len(no_data)} catalog variables with NO data:")
for v in sorted(no_data):
    print(f"  - {v}")

# Frontend expected IDs
fe_ids = {
    'SectorExterno': ['export', 'rem_fam', 'se_cc_numtur', 'rin', 'embi', 'embi_rd', 'pib_nom', 'tcn_venta_m'],
    'DepositosPrestamos': ['bmr_rd', 'prest_tot', 'sm_bcrd_vc', 'ipc_rd', 'prest_agr','prest_ind','prest_con','prest_com','prest_viv','prest_tar','prest_cons'],
    'SectorElectrico': ['res_global', 'pib_nom', 'ing_trib', 'tcn_venta_m'],
    'Tasas': ['tpm', 'tib_rd', 'ti_fond_fed', 'tia_prom_pond', 'tip_prom_pond', 'ipc_yoy', 'ipc_sub', 'ipc_rd', 'imae'],
    'TipoCambio': ['tcn_compra', 'tcn_venta', 'tcn_compra_m', 'tcn_venta_m', 'tcr_rd'],
}
print("\nFrontend-vs-Supabase coverage:")
for tab, ids in fe_ids.items():
    missing = [i for i in ids if i not in counts]
    print(f"  {tab}: {len(ids)-len(missing)}/{len(ids)} OK  | missing: {missing}")
