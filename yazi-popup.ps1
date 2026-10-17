# Popup de yazi para herdr (prefix+y en config.toml).
# Sin acentos a proposito: Windows PowerShell 5.1 lee los .ps1 sin BOM como ANSI.
#
# El servidor de herdr conserva el entorno de cuando arranco: releer PATH y
# YAZI_FILE_ONE del registro hace que yazi (y fd, rg, fzf, jq) funcionen aunque
# se hayan instalado con herdr ya abierto.
$env:Path = [Environment]::GetEnvironmentVariable('Path', 'Machine') + ';' + [Environment]::GetEnvironmentVariable('Path', 'User')
$fileOne = [Environment]::GetEnvironmentVariable('YAZI_FILE_ONE', 'User')
if ($fileOne) { $env:YAZI_FILE_ONE = $fileOne }

# herdr pasa la carpeta del panel activo a los comandos personalizados.
$dir = $env:HERDR_ACTIVE_PANE_CWD
if (-not $dir -or -not (Test-Path -LiteralPath $dir)) { $dir = (Get-Location).Path }

yazi $dir
