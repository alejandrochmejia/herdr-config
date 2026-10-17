# herdr-config: instalador para Windows
# Uso:  irm https://raw.githubusercontent.com/alejandrochmejia/herdr-config/main/install.ps1 | iex
#
# Descarga config.toml a %APPDATA%\herdr\config.toml (o a $env:HERDR_CONFIG_PATH),
# respalda el anterior si era distinto y recarga herdr si esta corriendo.
# Sin acentos a proposito: Windows PowerShell 5.1 lee los .ps1 sin BOM como ANSI.

& {
  $repoRaw = 'https://raw.githubusercontent.com/alejandrochmejia/herdr-config/main'
  $target = if ($env:HERDR_CONFIG_PATH) { $env:HERDR_CONFIG_PATH } else { Join-Path $env:APPDATA 'herdr\config.toml' }
  $tmp = "$target.download"

  New-Item -ItemType Directory -Force -Path (Split-Path -Parent $target) -ErrorAction Stop | Out-Null
  # -OutFile guarda los bytes tal cual (UTF-8 sin BOM, que es lo que espera herdr)
  Invoke-WebRequest -UseBasicParsing -Uri "$repoRaw/config.toml" -OutFile $tmp -ErrorAction Stop

  if ((Test-Path $target) -and ((Get-FileHash $target).Hash -eq (Get-FileHash $tmp).Hash)) {
    Remove-Item $tmp
    Write-Host "Sin cambios: $target ya estaba al dia."
  } else {
    if (Test-Path $target) {
      $bak = "$target.bak-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
      Copy-Item $target $bak
      Write-Host "Respaldo del config anterior: $bak"
    }
    Move-Item -Force $tmp $target
    Write-Host "Config instalada en $target"
  }

  if (Get-Command herdr -ErrorAction SilentlyContinue) {
    herdr config check
    $status = (herdr status server | Out-String)
    if ($status -match 'status:\s*running') {
      herdr server reload-config | Out-Null
      Write-Host 'herdr recargo la config.'
    } else {
      Write-Host 'herdr no esta corriendo; la config se aplica al abrirlo.'
    }
  } else {
    Write-Host 'herdr no esta instalado todavia; la config queda lista para cuando lo instales.'
  }
}
