# Deployment — Vercel + GitHub Actions + Supabase

Guía paso a paso para poner el dashboard en producción.

```
┌──────────────┐    fetch data       ┌──────────────┐
│    Vercel    │ ──────────────────► │   Supabase   │
│ dashboard-web│                     │  (Postgres)  │
└──────┬───────┘                     └──────▲───────┘
       │                                    │ upsert
       │ git pull /public/                  │
       │ dashboard_completo.xlsx            │
       │                              ┌─────┴────────┐
       └──────────────────────────────┤GitHub Actions│
              auto-deploy on push     │ dashboard-min│
                                      └──────────────┘
```

---

## 1. Estructura del repo (monorepo)

Tu proyecto local actual:
```
Dashboard Ministro/
├── dashboard-web/        # Next.js (deploy a Vercel)
├── dashboard-min/        # Python pipeline (corre en GH Actions)
└── DEPLOYMENT.md
```

Subí TODO al mismo repo de GitHub (monorepo). Vercel se queda con `dashboard-web/` como Root Directory.

---

## 2. Subir el código a GitHub

```bash
cd "C:/Users/patri/Desktop/Dashboard Ministro"

# Crear .gitignore en la raíz
cat > .gitignore <<'EOF'
# Python
__pycache__/
*.py[cod]
.venv/
venv/
.env
*.log

# Node
node_modules/
.next/
.turbo/
out/

# Datos pesados (los regenera GH Actions)
dashboard-min/data/raw/
dashboard-min/data/excel_output/

# Editor
.vscode/
.idea/
.DS_Store

# Secrets
.env.local
.env*.local
EOF

git init
git add .
git commit -m "Initial commit: dashboard ministro"

# Crear repo en github.com (privado o público), luego:
git remote add origin https://github.com/TU_USUARIO/dashboard-ministro.git
git branch -M main
git push -u origin main
```

---

## 3. Deploy a Vercel

1. Andá a https://vercel.com/new
2. **Import Git Repository** → conectá tu cuenta GitHub
3. Seleccioná `dashboard-ministro`
4. **Configure Project**:
   - **Framework Preset**: Next.js (auto-detectado)
   - **Root Directory**: `dashboard-web` ← importante (monorepo)
   - **Build Command**: `npm run build` (default)
   - **Output Directory**: `.next` (default)
   - **Install Command**: `npm install` (default)

5. **Environment Variables** (click "Environment Variables"):
   ```
   NEXT_PUBLIC_SUPABASE_URL                = https://iorydgyaxhgnsflylemc.supabase.co
   NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY    = sb_publishable_8vL40oVh98DQriu2LXyvZw_yb5uz7Ta
   ```
   (Estos están en tu `.env.local` actual.)

6. **Deploy** → primer deploy toma ~2 min

URL final: `https://dashboard-ministro.vercel.app` (o el nombre que elijas)

---

## 4. Configurar GitHub Actions (datos automáticos)

### 4.1 Secrets del repo

GitHub → tu repo → **Settings** → **Secrets and variables** → **Actions** → **New repository secret**

| Secret | Valor |
|---|---|
| `SUPABASE_URL` | `https://iorydgyaxhgnsflylemc.supabase.co` |
| `SUPABASE_SERVICE_KEY` | service key (del `.env` de dashboard-min) |
| `FRED_API_KEY` | tu FRED API key |
| `VERCEL_DEPLOY_HOOK` | opcional (ver paso 4.3) |

### 4.2 Workflows ya configurados

En `dashboard-min/.github/workflows/`:
- `daily.yml` — lun-vie 12:00 UTC: Yahoo, FRED, BCRD diario
- `weekly.yml` — lunes 14:00 UTC: pipeline BCRD completo
- `monthly.yml` — días 1 y 15: MEM eléctrico + forecasting
- `catalog-sync.yml` — sync del catálogo cuando se edita `catalog_r.py`

### 4.3 Excel auto-commit (clave para Vercel)

El archivo `dashboard-web/public/dashboard_completo.xlsx` se sirve desde Vercel. Para que tenga datos actualizados, GH Actions debe:
1. Regenerar el Excel después de actualizar Supabase
2. Commitear el Excel al repo → Vercel auto-deploya

Ya tenés el workflow `weekly.yml` modificado para hacer esto (ver más abajo). El paso clave:

```yaml
- name: Regenerar Excel + commit
  run: |
    cd dashboard-min
    python scripts/build_dashboard_excel.py
    cd ..
    git config user.name "github-actions[bot]"
    git config user.email "github-actions[bot]@users.noreply.github.com"
    git add dashboard-web/public/dashboard_completo.xlsx
    git diff --staged --quiet || git commit -m "chore: update Excel data $(date -u +%Y-%m-%d)"
    git push
```

### 4.4 (Opcional) Vercel Deploy Hook directo

Si NO querés commit del Excel y preferís un re-deploy manual:

1. Vercel → tu proyecto → **Settings** → **Git** → **Deploy Hooks**
2. Crear hook con nombre `github-actions` para branch `main`
3. Copiá la URL (`https://api.vercel.com/v1/integrations/deploy/prj_XXX/YYY`)
4. Agregá como secret `VERCEL_DEPLOY_HOOK` en GitHub
5. Al final del workflow:
   ```yaml
   - name: Trigger Vercel redeploy
     if: env.VERCEL_DEPLOY_HOOK != ''
     env:
       HOOK: ${{ secrets.VERCEL_DEPLOY_HOOK }}
     run: curl -X POST "$HOOK"
   ```

---

## 5. Verificación post-deploy

Después del primer deploy:

1. Visitá `https://tu-proyecto.vercel.app` — debería cargar el dashboard
2. Andá a Sector Externo — debería mostrar los charts con datos
3. Click "Descargar Excel" — debería bajar `dashboard_completo.xlsx`
4. Esperá al próximo cron (o disparalo manual en GH Actions → "Run workflow")
5. Después de la corrida, mirá los commits del repo — deberías ver `chore: update Excel data YYYY-MM-DD`
6. Vercel hace auto-deploy del nuevo commit → en ~2 min el Excel se actualiza en el dashboard

---

## 6. Disparar workflows manualmente

GitHub → tu repo → **Actions** → seleccioná el workflow → **Run workflow** → branch `main` → **Run workflow**.

Útil para:
- Probar después de cambios en parsers
- Forzar refresh de datos sin esperar el cron
- Re-sincronizar el catálogo

---

## 7. Costos estimados

| Servicio | Plan | Costo | Uso del proyecto |
|---|---|---|---|
| Vercel | Hobby (free) | $0 | < 100 GB-h/mes (sobra) |
| Supabase | Free tier | $0 | < 500 MB DB, ~130k filas = 7MB |
| GitHub Actions | Free para repos públicos | $0 | < 2000 min/mes (privado free) |
| FRED API | Free | $0 | 120 calls/min límite |

**Total: $0/mes** mientras estés dentro de los free tiers.

---

## 8. Comandos útiles localmente

```bash
# Re-correr pipeline localmente
cd dashboard-min
python -m pipelines.macro_bcrd.run

# Regenerar Excel
python scripts/build_dashboard_excel.py

# Sync catálogo
python sql/upsert_catalogo_supabase.py

# Dev server del dashboard
cd dashboard-web
npm run dev
```

---

## 9. Troubleshooting

**Vercel: "Module not found"** — Verificá que el Root Directory sea `dashboard-web`.

**GH Actions falla con "module not found: supabase"** — Verificá que `requirements.txt` tenga `supabase>=2.4.0`.

**Excel no se actualiza en el dashboard** — Vercel debe haber recibido un push. Verificá los commits y los deploys de Vercel.

**Hydration error en producción** — Ya está arreglado con `mounted` pattern; si persiste, hard refresh.
