#!/usr/bin/env bash
# Commit + push del repo privado de datos (checkpoint). Uso: guardar_datos.sh <dir> "<mensaje>"
set -u
DIR="$1"; MSG="$2"
cd "$DIR" || exit 1
git config user.name "github-actions[bot]"
git config user.email "github-actions[bot]@users.noreply.github.com"
git add -A
if git diff --staged --quiet; then
  echo "sin cambios en datos"; exit 0
fi
git commit -q -m "$MSG"
for i in 1 2 3 4; do
  if git push -q; then echo "datos guardados: $MSG"; exit 0; fi
  sleep $((i * 10))
  if ! git pull -q --rebase; then
    git rebase --abort 2>/dev/null
    # conflicto (otro proceso tocó el mismo archivo): conservar lo nuestro
    git pull -q --no-rebase -X ours || true
  fi
done
echo "::warning::no se pudo hacer push de los datos"; exit 1
