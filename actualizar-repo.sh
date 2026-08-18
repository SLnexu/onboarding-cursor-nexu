#!/bin/bash
# Actualiza el clon local de prestemos_backend como maximo una vez al dia.
# Corre al abrir una sesion de Cursor y lanza el pull en segundo plano para
# no retrasar el arranque. Si algo falla, no interrumpe al usuario.
set -u

DIRECTORIO_HOOKS="$HOME/.cursor/hooks"
MARCA="$DIRECTORIO_HOOKS/.ultima-actualizacion-prestemos"
BITACORA="$DIRECTORIO_HOOKS/actualizar-repo-prestemos.log"
SEGUNDOS_EN_UN_DIA=86400

terminar() {
  echo '{}'
  exit 0
}

entrada=$(cat 2>/dev/null || true)

# Cursor reporta la carpeta abierta; si no se puede leer, se buscan las rutas
# donde el onboarding deja el clon.
repo=""
if command -v python3 >/dev/null 2>&1; then
  repo=$(printf '%s' "$entrada" | python3 -c '
import json, os, sys

try:
    datos = json.load(sys.stdin)
except Exception:
    sys.exit(0)

rutas = []

def recorrer(nodo):
    if isinstance(nodo, str):
        rutas.append(nodo)
    elif isinstance(nodo, list):
        for hijo in nodo:
            recorrer(hijo)
    elif isinstance(nodo, dict):
        for hijo in nodo.values():
            recorrer(hijo)

recorrer(datos)

for ruta in rutas:
    if ruta.startswith("/") and os.path.isdir(os.path.join(ruta, ".git")):
        print(ruta)
        break
' 2>/dev/null)
fi

if [ -z "$repo" ]; then
  for candidato in "$HOME/dev/prestemos_backend" "$HOME/prestemos_backend"; do
    if [ -d "$candidato/.git" ]; then
      repo="$candidato"
      break
    fi
  done
fi

[ -n "$repo" ] || terminar

origen=$(git -C "$repo" remote get-url origin 2>/dev/null || true)
case "$origen" in
  *prestemos_backend*) ;;
  *) terminar ;;
esac

# Una vez al dia: si la marca es mas reciente que 24 horas, no hace nada.
if [ -f "$MARCA" ]; then
  ahora=$(date +%s)
  ultima=$(stat -f %m "$MARCA" 2>/dev/null || echo 0)
  if [ $((ahora - ultima)) -lt $SEGUNDOS_EN_UN_DIA ]; then
    terminar
  fi
fi

touch "$MARCA"

# El pull corre aparte para que la sesion abra de inmediato. BatchMode evita
# que se quede esperando una contrasena si la llave no esta disponible.
(
  export GIT_TERMINAL_PROMPT=0
  export GIT_SSH_COMMAND="ssh -o BatchMode=yes -o StrictHostKeyChecking=accept-new"
  if git -C "$repo" pull --ff-only --quiet >>"$BITACORA" 2>&1; then
    echo "$(date '+%Y-%m-%d %H:%M') actualizado: $repo" >>"$BITACORA"
  else
    echo "$(date '+%Y-%m-%d %H:%M') fallo al actualizar: $repo" >>"$BITACORA"
    rm -f "$MARCA"
  fi
) >/dev/null 2>&1 &

terminar
