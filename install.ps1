# herdr-config: instalador para Windows
# Uso:  irm https://raw.githubusercontent.com/alejandrochmejia/herdr-config/main/install.ps1 | iex
#
# Descarga config.toml a %APPDATA%\herdr\config.toml (o a $env:HERDR_CONFIG_PATH)
# y yazi-popup.ps1 a %APPDATA%\herdr\, respalda el config anterior si era
# distinto, define YAZI_FILE_ONE si hace falta y recarga herdr si esta corriendo.
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

  # El popup de yazi (prefix+y) llama a %APPDATA%\herdr\yazi-popup.ps1
  $herdrDir = Join-Path $env:APPDATA 'herdr'
  New-Item -ItemType Directory -Force -Path $herdrDir | Out-Null
  Invoke-WebRequest -UseBasicParsing -Uri "$repoRaw/yazi-popup.ps1" -OutFile (Join-Path $herdrDir 'yazi-popup.ps1') -ErrorAction Stop

  # yazi en Windows necesita el file.exe de Git para detectar tipos de archivo
  if (-not [Environment]::GetEnvironmentVariable('YAZI_FILE_ONE', 'User')) {
    $git = Get-Command git -ErrorAction SilentlyContinue
    $fileExe = if ($git) { Join-Path (Split-Path (Split-Path $git.Source)) 'usr\bin\file.exe' }
    if ($fileExe -and (Test-Path $fileExe)) {
      [Environment]::SetEnvironmentVariable('YAZI_FILE_ONE', $fileExe, 'User')
      Write-Host "YAZI_FILE_ONE = $fileExe"
    } else {
      Write-Host 'Aviso: no encontre el file.exe de Git; yazi lo necesita (instala Git for Windows).'
    }
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
