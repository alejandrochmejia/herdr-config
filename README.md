# herdr-config

Mi configuración de [herdr](https://herdr.dev) (multiplexor de terminal para agentes de código), compartida entre Windows, macOS y Linux.

## Instalar o actualizar

Windows (PowerShell):

```powershell
irm https://raw.githubusercontent.com/alejandrochmejia/herdr-config/main/install.ps1 | iex
```

macOS / Linux:

```sh
curl -fsSL https://raw.githubusercontent.com/alejandrochmejia/herdr-config/main/install.sh | sh
```

El instalador:

1. Descarga `config.toml` a `%APPDATA%\herdr\config.toml` (Windows) o `~/.config/herdr/config.toml` (macOS/Linux). Si tienes `HERDR_CONFIG_PATH` definido, usa esa ruta.
2. Si ya había un config distinto, lo respalda como `config.toml.bak-<fecha>`.
3. En macOS/Linux cambia el popup de terminal de PowerShell a tu `$SHELL`.
4. Valida con `herdr config check` y, si herdr está corriendo, aplica los cambios con `herdr server reload-config`.

Para actualizar un equipo después de cambiar el repo, vuelve a correr el mismo comando.

## Qué incluye

| Sección | Qué hace |
|---|---|
| `[theme]` | Catppuccin; cambia solo entre `catppuccin-latte` (claro) y `catppuccin` (oscuro) según la terminal. |
| `[ui]` | Estados por forma (`symbols`), título de ventana `{hostname}: {workspace}`, y zoom, equipo y hora a la derecha de la barra de pestañas. |
| `[ui.toast]` | Notificación del sistema cuando un agente termina o espera respuesta; clic para saltar al panel. |
| `[ui.sidebar.agents.rows_by_agent]` | Filas de Claude Code en la barra lateral: estado, título y ubicación. |
| `[keys]` | Redimensionar con `Ctrl+Shift+Alt+flechas`, sin prefijo. |
| `[[keys.command]]` | `prefijo + t`: terminal flotante. `prefijo + Alt+G`: lazygit flotante. |

El shell de los paneles no está fijo a propósito. herdr usa `pwsh.exe` si existe y si no `powershell.exe` en Windows, y `$SHELL` en macOS/Linux.

## Atajos

Prefijo: `Ctrl+B`. Presiónalo, suéltalo y luego la tecla.

| Tecla | Acción |
|---|---|
| `?` / `s` | Ayuda / ajustes |
| `v` / `-` | Dividir vertical / horizontal |
| `h` `j` `k` `l` | Moverse entre paneles |
| `z` / `x` | Zoom / cerrar panel |
| `c`, `n`, `p`, `1`…`9` | Nueva pestaña, siguiente, anterior, ir a una |
| `w` / `Shift+N` | Elegir workspace / nuevo workspace |
| `b` | Mostrar u ocultar la barra lateral |
| `q` | Desconectarse sin cerrar nada |
| `Shift+R` | Recargar el config |
| `t` / `Alt+G` | Terminal flotante / lazygit |

## Extras recomendados en cada equipo

- **lazygit** para el popup `prefijo + Alt+G`: `winget install JesseDuffield.lazygit`, `brew install lazygit` o el gestor de paquetes de tu distro. Si lo instalas con herdr abierto, reinicia herdr: el servidor conserva el `PATH` de cuando arrancó.
- **Integración con Claude Code** para que herdr pueda retomar las sesiones de Claude tras reiniciarse: `herdr integration install claude`.

## Notas

- Las notificaciones del sistema están probadas en Windows. En macOS herdr usa `terminal-notifier` si está instalado y si no `osascript`. En Linux no lo he probado.
- Los atajos con `Alt` pueden depender de la terminal. En macOS, configura la tecla Option como Meta/Alt.
