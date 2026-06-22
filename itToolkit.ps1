# ==========================================
#             IT TOOLKIT v1.0
# ==========================================

function Show-Banner {
    Clear-Host
    Write-Host @"
  _____           _     _ _    _ _   
 |_   _|__   ___ | | __| | | _(_) |_ 
   | |/ _ \ / _ \| |/ _` | |/ / | __|
   | | (_) | (_) | | (_| |   <| | |_ 
   |_|\___/ \___/|_|\__,_|_|\_\_|\__|
                                     

==========================================
            IT TOOLKIT v1.0
==========================================

[1] Limpieza del sistema
[2] Optimización Windows
[3] Herramientas de red
[4] Disco y almacenamiento
[5] Información del sistema
[6] Reparación Windows
[7] Herramientas rápidas
[0] Salir

"@
}

# ==========================================
# LIMPIEZA
# ==========================================

function Limpiar-Sistema {

    Write-Host "`nLimpiando archivos temporales..." -ForegroundColor Green

    Remove-Item "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item "C:\Windows\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue

    if (Test-Path "C:\Windows\Prefetch") {
        Remove-Item "C:\Windows\Prefetch\*" -Recurse -Force -ErrorAction SilentlyContinue
    }

    try {
        Clear-RecycleBin -Force -ErrorAction SilentlyContinue
    } catch {}

    ipconfig /flushdns | Out-Null

    Write-Host "`nLimpieza completada." -ForegroundColor Green
    Pause
}

# ==========================================
# OPTIMIZACION
# ==========================================

function Optimizar-Windows {

    Write-Host "`nAplicando optimizaciones..." -ForegroundColor Yellow

    powercfg /setactive SCHEME_MIN

    Write-Host "`nAbriendo opciones visuales..."
    Start-Process SystemPropertiesPerformance.exe

    Write-Host "`nOptimizacion aplicada."
    Pause
}

# ==========================================
# DISCO
# ==========================================

function Optimizar-Disco {

    Write-Host "`nOptimizando unidad C..." -ForegroundColor Cyan

    try {
        Optimize-Volume -DriveLetter C -Defrag -Verbose
    }
    catch {
        Write-Host "No fue posible optimizar la unidad."
    }

    Pause
}

function Programar-Defrag {

    schtasks /create `
        /tn "ITToolkitDefrag" `
        /tr "defrag C: /O" `
        /sc DAILY `
        /st 01:00 `
        /f

    Write-Host "`nProgramado correctamente."
    Pause
}

# ==========================================
# RED
# ==========================================

function Herramientas-Red {

    do {

        Clear-Host

        Write-Host @"

=========================
 HERRAMIENTAS DE RED
=========================

[1] Mostrar adaptadores
[2] Mostrar DNS
[3] Resolver dominio (nslookup)
[4] Liberar/Renovar IP
[5] Reiniciar adaptador
[6] Mantener puerto activo
[7] Prueba Internet
[0] Volver

"@

        $op = Read-Host "Seleccione"

        switch ($op) {

            "1" {
                Get-NetAdapter
                Pause
            }

            "2" {
                Get-DnsClientServerAddress
                Pause
            }

            "3" {
                $dominio = Read-Host "Dominio"
                nslookup $dominio
                Pause
            }

            "4" {
                ipconfig /release
                ipconfig /renew
                Pause
            }

            "5" {
                $adaptador = Read-Host "Nombre adaptador"
                Restart-NetAdapter -Name $adaptador
                Pause
            }

            "6" {
                Get-NetAdapter | ForEach-Object {
                    try {
                        Set-NetAdapterPowerManagement `
                            -Name $_.Name `
                            -AllowComputerToTurnOffDevice Disabled
                    }
                    catch {}
                }

                Write-Host "Configuracion aplicada."
                Pause
            }

            "7" {
                Test-NetConnection 8.8.8.8
                Pause
            }
        }

    } until ($op -eq "0")
}

# ==========================================
# INFORMACION SISTEMA
# ==========================================

function Mostrar-Info {

    Clear-Host

    Write-Host "=========== SISTEMA ===========" -ForegroundColor Green

    Write-Host "`nEquipo:"
    hostname

    Write-Host "`nSistema:"
    Get-CimInstance Win32_OperatingSystem |
        Select Caption, Version

    Write-Host "`nMemoria RAM:"
    Get-CimInstance Win32_ComputerSystem |
        Select TotalPhysicalMemory

    Write-Host "`nDiscos:"
    Get-PSDrive -PSProvider FileSystem

    Write-Host "`nIP:"
    ipconfig

    Pause
}

# ==========================================
# REPARACION
# ==========================================

function Reparar-Windows {

    do {

        Clear-Host

        Write-Host @"

=========================
 REPARACION WINDOWS
=========================

[1] SFC
[2] DISM
[3] Reiniciar Explorer
[0] Volver

"@

        $op = Read-Host "Seleccione"

        switch ($op) {

            "1" {
                sfc /scannow
                Pause
            }

            "2" {
                DISM /Online /Cleanup-Image /RestoreHealth
                Pause
            }

            "3" {
                Stop-Process -Name explorer -Force
                Start-Process explorer
                Pause
            }
        }

    } until ($op -eq "0")
}

# ==========================================
# HERRAMIENTAS RAPIDAS
# ==========================================

function Herramientas-Rapidas {

    do {

        Clear-Host

        Write-Host @"

=========================
 HERRAMIENTAS RAPIDAS
=========================

[1] Ver puertos abiertos
[2] Top procesos RAM
[3] Reporte sistema
[4] Serial equipo
[5] Usuarios conectados
[0] Volver

"@

        $op = Read-Host "Seleccione"

        switch ($op) {

            "1" {
                netstat -ano
                Pause
            }

            "2" {
                Get-Process |
                    Sort WS -Descending |
                    Select -First 15
                Pause
            }

            "3" {

                $archivo = "$env:USERPROFILE\Desktop\ReporteIT.txt"

                Get-ComputerInfo > $archivo

                Write-Host "`nReporte generado:"
                Write-Host $archivo -ForegroundColor Green

                Pause
            }

            "4" {
                wmic bios get serialnumber
                Pause
            }

            "5" {
                query user
                Pause
            }
        }

    } until ($op -eq "0")
}

# ==========================================
# MENU PRINCIPAL
# ==========================================

do {

    Show-Banner

    $opcion = Read-Host "Seleccione una opcion"

    switch ($opcion) {

        "1" { Limpiar-Sistema }

        "2" { Optimizar-Windows }

        "3" { Herramientas-Red }

        "4" {
            do {

                Clear-Host

                Write-Host @"

=========================
 DISCO
=========================

[1] Optimizar Disco
[2] Programar Defrag Diario
[0] Volver

"@

                $d = Read-Host "Seleccione"

                switch ($d) {

                    "1" { Optimizar-Disco }
                    "2" { Programar-Defrag }

                }

            } until ($d -eq "0")
        }

        "5" { Mostrar-Info }

        "6" { Reparar-Windows }

        "7" { Herramientas-Rapidas }

    }

} until ($opcion -eq "0")
