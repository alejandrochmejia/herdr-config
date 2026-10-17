#!/bin/sh
# herdr-config: instalador para macOS y Linux
# Uso:  curl -fsSL https://raw.githubusercontent.com/alejandrochmejia/herdr-config/main/install.sh | sh
#
# Descarga config.toml a ~/.config/herdr/config.toml (o a $HERDR_CONFIG_PATH),
# cambia los popups de PowerShell (terminal y yazi) por su versión Unix,
# respalda el config anterior si era distinto y recarga herdr si está corriendo.
set -eu

REPO_RAW="https://raw.githubusercontent.com/alejandrochmejia/herdr-config/main"
TARGET="${HERDR_CONFIG_PATH:-$HOME/.config/herdr/config.toml}"
TMP="$TARGET.download"

mkdir -p "$(dirname "$TARGET")"
curl -fsSL "$REPO_RAW/config.toml" -o "$TMP.raw"
# En Unix herdr corre los comandos con /bin/sh -c, así que las variables se
# expanden ahí. HERDR_ACTIVE_PANE_CWD es la carpeta del panel activo.
sed -e 's|"powershell.exe -NoLogo"|"exec ${SHELL:-/bin/sh}"|' \
    -e 's|^command = ".*yazi-popup\.ps1"$|command = '\''cd "${HERDR_ACTIVE_PANE_CWD:-.}" 2>/dev/null; exec yazi'\''|' \
    "$TMP.raw" > "$TMP"
rm -f "$TMP.raw"

if [ -f "$TARGET" ] && cmp -s "$TARGET" "$TMP"; then
  rm -f "$TMP"
  echo "Sin cambios: $TARGET ya estaba al día."
else
  if [ -f "$TARGET" ]; then
    BAK="$TARGET.bak-$(date +%Y%m%d-%H%M%S)"
    cp -p "$TARGET" "$BAK"
    echo "Respaldo del config anterior: $BAK"
  fi
  mv -f "$TMP" "$TARGET"
  echo "Config instalada en $TARGET"
fi

if command -v herdr >/dev/null 2>&1; then
  herdr config check || true
  if herdr server reload-config >/dev/null 2>&1; then
    echo "herdr recargó la config."
  else
    echo "herdr no está corriendo; la config se aplica al abrirlo."
  fi
else
  echo "herdr no está instalado todavía; la config queda lista para cuando lo instales."
fi
