# ==========================================
#             IT TOOLKIT v2.0
# ==========================================

# ==========================================
# CONFIGURACION Y VARIABLES GLOBALES
# ==========================================

$script:LogFile = "$env:USERPROFILE\Desktop\ITToolkit_Log.txt"
$script:ColorVerde = "Green"
$script:ColorRojo = "Red"
$script:ColorAmarillo = "Yellow"
$script:ColorCyan = "Cyan"
$script:ColorMagenta = "Magenta"

# ==========================================
# FUNCIONES DE UTILIDAD
# ==========================================

function Write-Log {
    param(
        [string]$Mensaje,
        [string]$Nivel = "INFO"
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "[$timestamp] [$Nivel] $Mensaje"
    Add-Content -Path $script:LogFile -Value $logEntry
}

function Show-MenuHeader {
    param([string]$Titulo)
    Clear-Host
    Write-Host "`n" ("=" * 50) -ForegroundColor $script:ColorCyan
    Write-Host "  $Titulo" -ForegroundColor $script:ColorMagenta
    Write-Host ("=" * 50) -ForegroundColor $script:ColorCyan
}

function Show-ProgressBar {
    param(
        [string]$Mensaje,
        [int]$Duracion = 2
    )
    Write-Host "`n$Mensaje" -ForegroundColor $script:ColorAmarillo
    for ($i = 1; $i -le 20; $i++) {
        Write-Host "#" -NoNewline -ForegroundColor Green
        Start-Sleep -Milliseconds ($Duracion * 50)
    }
    Write-Host " COMPLETADO!" -ForegroundColor Green
}

function Confirm-Action {
    param(
        [string]$Mensaje = "¿Esta seguro de continuar?",
        [string]$OpcionSi = "s",
        [string]$OpcionNo = "n"
    )
    $respuesta = Read-Host "$Mensaje ($OpcionSi/$OpcionNo)"
    return ($respuesta -eq $OpcionSi)
}

function Get-ProcessList {
    param(
        [int]$Cantidad = 20,
        [string]$Ordenar = "WS"
    )
    $procesos = Get-Process | Sort $Ordenar -Descending | Select -First $Cantidad
    return $procesos
}

function Show-ProcessTable {
    param(
        [array]$Procesos
    )
    $Procesos | Format-Table Id, ProcessName, 
        @{N='RAM (MB)';E={[math]::Round($_.WS/1MB,2)}},
        @{N='CPU';E={[math]::Round($_.CPU,2)}},
        @{N='Threads';E={$_.Threads.Count}},
        @{N='Respondiendo';E={if($_.Responding){"Si"}else{"No"}}} -AutoSize
}

function Kill-ProcessByName {
    param([string]$Nombre)
    $procesos = Get-Process -Name $Nombre -ErrorAction SilentlyContinue
    if ($procesos) {
        try {
            $procesos | ForEach-Object {
                Stop-Process -Id $_.Id -Force -ErrorAction Stop
                Write-Host "Terminado: $($_.ProcessName) [PID: $($_.Id)]" -ForegroundColor Green
                Write-Log "Proceso terminado: $($_.ProcessName) (PID: $($_.Id))" "SUCCESS"
            }
            return $true
        }
        catch {
            Write-Host "No se pudo terminar el proceso. Ejecute como administrador." -ForegroundColor Red
            Write-Log "Error al terminar proceso: $Nombre" "ERROR"
            return $false
        }
    }
    else {
        Write-Host "No se encontraron procesos con el nombre '$Nombre'." -ForegroundColor Red
        return $false
    }
}

function Kill-ProcessByPID {
    param([int]$PID)
    $proceso = Get-Process -Id $PID -ErrorAction SilentlyContinue
    if ($proceso) {
        try {
            Stop-Process -Id $PID -Force -ErrorAction Stop
            Write-Host "Terminado: $($proceso.ProcessName) [PID: $PID]" -ForegroundColor Green
            Write-Log "Proceso terminado: $($proceso.ProcessName) (PID: $PID)" "SUCCESS"
            return $true
        }
        catch {
            Write-Host "No se pudo terminar el proceso. Ejecute como administrador." -ForegroundColor Red
            Write-Log "Error al terminar proceso PID: $PID" "ERROR"
            return $false
        }
    }
    else {
        Write-Host "No se encontró proceso con PID $PID." -ForegroundColor Red
        return $false
    }
}

# ==========================================
# BANNER PRINCIPAL
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
            IT TOOLKIT v2.0
==========================================

[1] Limpieza del sistema
[2] Optimizacion Windows
[3] Herramientas de red
[4] Disco y almacenamiento
[5] Informacion del sistema
[6] Reparacion Windows
[7] Herramientas rapidas
[8] Administracion de procesos
[9] Diagnostico del sistema
[0] Salir

"@
    Write-Host "`n[INFO] Log guardado en: $LogFile" -ForegroundColor Gray
}

# ==========================================
# LIMPIEZA
# ==========================================

function Limpiar-Sistema {
    Show-MenuHeader "LIMPIEZA DEL SISTEMA"
    Write-Log "Iniciando limpieza del sistema" "INFO"
    
    Write-Host "`nLimpiando archivos temporales..." -ForegroundColor $script:ColorVerde
    Show-ProgressBar "Eliminando temporales" 1
    
    $tempPaths = @(
        "$env:TEMP\*",
        "C:\Windows\Temp\*",
        "C:\Windows\Prefetch\*",
        "$env:USERPROFILE\AppData\Local\Temp\*",
        "$env:USERPROFILE\AppData\Local\Microsoft\Windows\INetCache\*"
    )
    
    foreach ($path in $tempPaths) {
        try {
            Remove-Item $path -Recurse -Force -ErrorAction SilentlyContinue
            Write-Host "  Eliminado: $path" -ForegroundColor Gray
        }
        catch {
            # Ignorar errores
        }
    }
    
    try {
        Clear-RecycleBin -Force -ErrorAction SilentlyContinue
        Write-Host "  Papelera vaciada" -ForegroundColor Gray
    } catch {}
    
    ipconfig /flushdns | Out-Null
    Write-Host "  DNS flusheado" -ForegroundColor Gray
    
    Write-Log "Limpieza completada" "SUCCESS"
    Write-Host "`nLimpieza completada exitosamente." -ForegroundColor $script:ColorVerde
    Pause
}

# ==========================================
# OPTIMIZACION
# ==========================================

function Optimizar-Windows {
    Show-MenuHeader "OPTIMIZACION WINDOWS"
    Write-Log "Iniciando optimizacion" "INFO"
    
    Write-Host "`nAplicando optimizaciones..." -ForegroundColor $script:ColorAmarillo
    
    # Plan de energia
    powercfg /setactive SCHEME_MIN
    Write-Host "  Plan de energia: Alto rendimiento" -ForegroundColor Gray
    
    # Desactivar efectos visuales innecesarios
    Write-Host "  Abriendo opciones visuales..." -ForegroundColor Gray
    Start-Process SystemPropertiesPerformance.exe
    
    # Limpiar memoria RAM (forzar garbage collection)
    [System.GC]::Collect()
    [System.GC]::WaitForPendingFinalizers()
    Write-Host "  Memoria RAM optimizada" -ForegroundColor Gray
    
    Write-Log "Optimizacion completada" "SUCCESS"
    Write-Host "`nOptimizacion aplicada." -ForegroundColor $script:ColorVerde
    Pause
}

# ==========================================
# DISCO
# ==========================================

function Optimizar-Disco {
    Show-MenuHeader "OPTIMIZACION DE DISCO"
    Write-Log "Iniciando optimizacion de disco" "INFO"
    
    Write-Host "`nOptimizando unidad C..." -ForegroundColor $script:ColorCyan
    Show-ProgressBar "Analizando disco" 2
    
    try {
        Optimize-Volume -DriveLetter C -Defrag -Verbose
        Write-Log "Disco optimizado" "SUCCESS"
    }
    catch {
        Write-Host "No fue posible optimizar la unidad." -ForegroundColor $script:ColorRojo
        Write-Log "Error en optimizacion de disco" "ERROR"
    }
    
    Pause
}

function Programar-Defrag {
    Show-MenuHeader "PROGRAMAR DEFRAGMENTACION"
    
    schtasks /create `
        /tn "ITToolkitDefrag" `
        /tr "defrag C: /O" `
        /sc DAILY `
        /st 01:00 `
        /f
    
    Write-Host "`nTarea programada correctamente para las 01:00 AM diarias." -ForegroundColor $script:ColorVerde
    Write-Log "Defrag programado" "SUCCESS"
    Pause
}

function Analizar-Disco {
    Show-MenuHeader "ANALISIS DE DISCO"
    Write-Log "Iniciando analisis de disco" "INFO"
    
    Write-Host "`nAnalizando espacio en disco..." -ForegroundColor $script:ColorCyan
    
    $discos = Get-WmiObject Win32_LogicalDisk -Filter "DriveType=3"
    
    foreach ($disco in $discos) {
        $total = [math]::Round($disco.Size / 1GB, 2)
        $libre = [math]::Round($disco.FreeSpace / 1GB, 2)
        $usado = [math]::Round(($disco.Size - $disco.FreeSpace) / 1GB, 2)
        $porcentaje = [math]::Round(($disco.FreeSpace / $disco.Size) * 100, 2)
        
        Write-Host "`nUnidad $($disco.DeviceID):" -ForegroundColor $script:ColorAmarillo
        Write-Host "  Total: $total GB"
        Write-Host "  Usado: $usado GB"
        Write-Host "  Libre: $libre GB ($porcentaje% libre)"
        
        if ($porcentaje -lt 10) {
            Write-Host "  ADVERTENCIA: Espacio critico!" -ForegroundColor $script:ColorRojo
        }
        elseif ($porcentaje -lt 20) {
            Write-Host "  ADVERTENCIA: Espacio bajo!" -ForegroundColor $script:ColorAmarillo
        }
    }
    
    Write-Log "Analisis de disco completado" "SUCCESS"
    Pause
}

# ==========================================
# RED
# ==========================================

function Herramientas-Red {
    do {
        Show-MenuHeader "HERRAMIENTAS DE RED"
        Write-Host @"
[1] Mostrar adaptadores
[2] Mostrar DNS
[3] Resolver dominio (nslookup)
[4] Liberar/Renovar IP
[5] Reiniciar adaptador
[6] Mantener puerto activo
[7] Prueba Internet
[8] Mostrar tabla de enrutamiento
[9] Realizar traceroute
[10] Escanear puertos locales
[11] Ver conexiones activas
[0] Volver

"@
        $op = Read-Host "Seleccione"
        
        switch ($op) {
            "1" { 
                Show-MenuHeader "ADAPTADORES DE RED"
                Get-NetAdapter | Format-Table Name, Status, LinkSpeed, MacAddress -AutoSize
                Pause 
            }
            "2" { 
                Show-MenuHeader "SERVIDORES DNS"
                Get-DnsClientServerAddress | Format-Table -AutoSize
                Pause 
            }
            "3" { 
                Show-MenuHeader "RESOLVER DOMINIO"
                $dominio = Read-Host "Dominio"
                nslookup $dominio
                Pause 
            }
            "4" { 
                Show-MenuHeader "RENOVAR IP"
                Write-Host "Liberando IP..." -ForegroundColor Yellow
                ipconfig /release
                Write-Host "Renovando IP..." -ForegroundColor Yellow
                ipconfig /renew
                Write-Host "IP renovada." -ForegroundColor Green
                Pause 
            }
            "5" { 
                Show-MenuHeader "REINICIAR ADAPTADOR"
                $adaptador = Read-Host "Nombre adaptador"
                Restart-NetAdapter -Name $adaptador
                Pause 
            }
            "6" { 
                Show-MenuHeader "MANTENER PUERTO ACTIVO"
                Get-NetAdapter | ForEach-Object {
                    try {
                        Set-NetAdapterPowerManagement -Name $_.Name -AllowComputerToTurnOffDevice Disabled
                    }
                    catch {}
                }
                Write-Host "Configuracion aplicada." -ForegroundColor Green
                Pause 
            }
            "7" { 
                Show-MenuHeader "PRUEBA DE CONEXION"
                Test-NetConnection 8.8.8.8
                Pause 
            }
            "8" { 
                Show-MenuHeader "TABLA DE ENRUTAMIENTO"
                route print
                Pause 
            }
            "9" { 
                Show-MenuHeader "TRACEROUTE"
                $destino = Read-Host "Ingrese direccion IP o dominio"
                Write-Host "`nRealizando traceroute a $destino..." -ForegroundColor Yellow
                tracert $destino
                Pause 
            }
            "10" { 
                Show-MenuHeader "PUERTOS ABIERTOS"
                $puertos = Read-Host "Puertos a escanear (ej: 80,443,8080 o 1-1000)"
                Write-Host "Escaneando puertos..." -ForegroundColor Yellow
                $puertosArray = $puertos.Split(',')
                foreach ($puerto in $puertosArray) {
                    if ($puerto -match '-') {
                        $rango = $puerto.Split('-')
                        for ($i = [int]$rango[0]; $i -le [int]$rango[1]; $i++) {
                            $conexion = Test-NetConnection -ComputerName localhost -Port $i -WarningAction SilentlyContinue
                            if ($conexion.TcpTestSucceeded) {
                                Write-Host "Puerto $i : ABIERTO" -ForegroundColor Green
                            }
                        }
                    }
                    else {
                        $conexion = Test-NetConnection -ComputerName localhost -Port $puerto -WarningAction SilentlyContinue
                        if ($conexion.TcpTestSucceeded) {
                            Write-Host "Puerto $puerto : ABIERTO" -ForegroundColor Green
                        }
                    }
                }
                Pause 
            }
            "11" { 
                Show-MenuHeader "CONEXIONES ACTIVAS"
                netstat -ano
                Pause 
            }
        }
    } until ($op -eq "0")
}

# ==========================================
# INFORMACION SISTEMA
# ==========================================

function Mostrar-Info {
    Show-MenuHeader "INFORMACION DEL SISTEMA"
    Write-Log "Mostrando informacion del sistema" "INFO"
    
    Write-Host "`nEQUIPO:" -ForegroundColor $script:ColorAmarillo
    hostname
    
    Write-Host "`nSISTEMA OPERATIVO:" -ForegroundColor $script:ColorAmarillo
    Get-CimInstance Win32_OperatingSystem | Select Caption, Version, BuildNumber, InstallDate
    
    Write-Host "`nPROCESADOR:" -ForegroundColor $script:ColorAmarillo
    Get-CimInstance Win32_Processor | Select Name, NumberOfCores, NumberOfLogicalProcessors, MaxClockSpeed
    
    Write-Host "`nMEMORIA RAM:" -ForegroundColor $script:ColorAmarillo
    $memoria = Get-CimInstance Win32_ComputerSystem
    $totalRAM = [math]::Round($memoria.TotalPhysicalMemory / 1GB, 2)
    Write-Host "Total: $totalRAM GB"
    
    Write-Host "`nDISCOS:" -ForegroundColor $script:ColorAmarillo
    Get-PSDrive -PSProvider FileSystem | Where-Object { $_.Used -ne $null } | 
        Format-Table Name, @{N='Total(GB)';E={[math]::Round($_.Used/1GB + $_.Free/1GB, 2)}},
        @{N='Libre(GB)';E={[math]::Round($_.Free/1GB, 2)}},
        @{N='Usado(GB)';E={[math]::Round($_.Used/1GB, 2)}} -AutoSize
    
    Write-Host "`nIP:" -ForegroundColor $script:ColorAmarillo
    ipconfig | Select-String "IPv4"
    
    Write-Log "Informacion mostrada" "SUCCESS"
    Pause
}

# ==========================================
# REPARACION
# ==========================================

function Reparar-Windows {
    do {
        Show-MenuHeader "REPARACION WINDOWS"
        Write-Host @"
[1] SFC (System File Checker)
[2] DISM (Deployment Imaging)
[3] Reiniciar Explorer
[4] Reparar red
[5] Escanear integridad del sistema
[0] Volver

"@
        $op = Read-Host "Seleccione"
        
        switch ($op) {
            "1" { 
                Show-MenuHeader "SFC /SCANNOW"
                Write-Log "Ejecutando SFC" "INFO"
                sfc /scannow
                Write-Log "SFC completado" "SUCCESS"
                Pause 
            }
            "2" { 
                Show-MenuHeader "DISM RESTOREHEALTH"
                Write-Log "Ejecutando DISM" "INFO"
                DISM /Online /Cleanup-Image /RestoreHealth
                Write-Log "DISM completado" "SUCCESS"
                Pause 
            }
            "3" { 
                Show-MenuHeader "REINICIAR EXPLORER"
                Stop-Process -Name explorer -Force
                Start-Process explorer
                Write-Host "Explorer reiniciado." -ForegroundColor Green
                Pause 
            }
            "4" { 
                Show-MenuHeader "REPARAR RED"
                Write-Host "Reparando red..." -ForegroundColor Yellow
                netsh winsock reset
                netsh int ip reset
                ipconfig /flushdns
                Write-Host "Red reparada. Reinicie el sistema." -ForegroundColor Green
                Pause 
            }
            "5" { 
                Show-MenuHeader "ESCANEAR INTEGRIDAD"
                Write-Host "Analizando integridad del sistema..." -ForegroundColor Yellow
                Get-WmiObject -Class Win32_SystemEnclosure | Select Manufacturer, Model, SerialNumber
                Get-WmiObject -Class Win32_DiskDrive | Select Model, Size, InterfaceType
                Pause 
            }
        }
    } until ($op -eq "0")
}

# ==========================================
# ADMINISTRACION DE PROCESOS
# ==========================================

function Administracion-Procesos {
    do {
        Show-MenuHeader "ADMINISTRACION DE PROCESOS"
        Write-Host @"
[1] Listar procesos (top RAM)
[2] Listar procesos (top CPU)
[3] Matar proceso por nombre
[4] Matar proceso por PID
[5] Matar proceso por consumo de RAM
[6] Matar todos los procesos de un usuario
[7] Priorizar proceso
[0] Volver

"@
        $op = Read-Host "Seleccione"
        
        switch ($op) {
            "1" {
                Show-MenuHeader "PROCESOS - TOP RAM"
                $procesos = Get-ProcessList -Cantidad 20 -Ordenar "WS"
                Show-ProcessTable -Procesos $procesos
                Pause
            }
            "2" {
                Show-MenuHeader "PROCESOS - TOP CPU"
                $procesos = Get-ProcessList -Cantidad 20 -Ordenar "CPU"
                Show-ProcessTable -Procesos $procesos
                Pause
            }
            "3" {
                Show-MenuHeader "MATAR PROCESO POR NOMBRE"
                $nombre = Read-Host "Ingrese el nombre del proceso"
                Kill-ProcessByName -Nombre $nombre
                Pause
            }
            "4" {
                Show-MenuHeader "MATAR PROCESO POR PID"
                $pid = Read-Host "Ingrese el PID del proceso"
                Kill-ProcessByPID -PID $pid
                Pause
            }
            "5" {
                Show-MenuHeader "MATAR PROCESOS POR CONSUMO DE RAM"
                $limite = Read-Host "Ingrese el limite de RAM en MB (ej: 500)"
                $procesos = Get-Process | Where-Object { $_.WS / 1MB -gt $limite }
                if ($procesos) {
                    Write-Host "`nProcesos encontrados:" -ForegroundColor Yellow
                    $procesos | Format-Table ProcessName, Id, @{N='RAM(MB)';E={[math]::Round($_.WS/1MB,2)}} -AutoSize
                    if (Confirm-Action "¿Desea matar estos procesos?") {
                        $procesos | ForEach-Object {
                            Kill-ProcessByName -Nombre $_.ProcessName
                        }
                    }
                }
                else {
                    Write-Host "No se encontraron procesos con ese consumo." -ForegroundColor Green
                }
                Pause
            }
            "6" {
                Show-MenuHeader "MATAR PROCESOS DE USUARIO"
                $usuario = Read-Host "Ingrese el nombre de usuario"
                $procesos = Get-Process -IncludeUserName | Where-Object { $_.UserName -like "*$usuario*" }
                if ($procesos) {
                    Write-Host "`nProcesos de usuario $usuario :" -ForegroundColor Yellow
                    $procesos | Format-Table ProcessName, Id -AutoSize
                    if (Confirm-Action "¿Desea matar todos estos procesos?") {
                        $procesos | ForEach-Object {
                            Kill-ProcessByName -Nombre $_.ProcessName
                        }
                    }
                }
                else {
                    Write-Host "No se encontraron procesos para ese usuario." -ForegroundColor Red
                }
                Pause
            }
            "7" {
                Show-MenuHeader "PRIORIZAR PROCESO"
                $nombre = Read-Host "Ingrese el nombre del proceso"
                Write-Host "Prioridades disponibles:" -ForegroundColor Yellow
                Write-Host "1. Alta"
                Write-Host "2. Normal"
                Write-Host "3. Baja"
                $prioridad = Read-Host "Seleccione"
                
                $proceso = Get-Process -Name $nombre -ErrorAction SilentlyContinue
                if ($proceso) {
                    try {
                        switch ($prioridad) {
                            "1" { $proceso.PriorityClass = [System.Diagnostics.ProcessPriorityClass]::High }
                            "2" { $proceso.PriorityClass = [System.Diagnostics.ProcessPriorityClass]::Normal }
                            "3" { $proceso.PriorityClass = [System.Diagnostics.ProcessPriorityClass]::BelowNormal }
                        }
                        Write-Host "Prioridad cambiada." -ForegroundColor Green
                    }
                    catch {
                        Write-Host "Error al cambiar prioridad." -ForegroundColor Red
                    }
                }
                Pause
            }
        }
    } until ($op -eq "0")
}

# ==========================================
# DIAGNOSTICO DEL SISTEMA
# ==========================================

function Diagnostico-Sistema {
    Show-MenuHeader "DIAGNOSTICO DEL SISTEMA"
    Write-Log "Iniciando diagnostico" "INFO"
    
    Write-Host "`n=== DIAGNOSTICO RAPIDO ===" -ForegroundColor $script:ColorMagenta
    
    # 1. Memoria
    Write-Host "`n[1/5] Verificando memoria..." -ForegroundColor $script:ColorAmarillo
    $memoria = Get-CimInstance Win32_ComputerSystem
    $totalRAM = [math]::Round($memoria.TotalPhysicalMemory / 1GB, 2)
    Write-Host "  RAM Total: $totalRAM GB"
    if ($totalRAM -lt 4) {
        Write-Host "  ADVERTENCIA: Memoria insuficiente!" -ForegroundColor $script:ColorRojo
    }
    
    # 2. Disco
    Write-Host "`n[2/5] Verificando disco..." -ForegroundColor $script:ColorAmarillo
    $disco = Get-WmiObject Win32_LogicalDisk -Filter "DeviceID='C:'"
    $libre = [math]::Round($disco.FreeSpace / 1GB, 2)
    $total = [math]::Round($disco.Size / 1GB, 2)
    $porcentaje = [math]::Round(($disco.FreeSpace / $disco.Size) * 100, 2)
    Write-Host "  Disco C: $libre GB libre de $total GB ($porcentaje%)"
    if ($porcentaje -lt 10) {
        Write-Host "  ADVERTENCIA: Espacio critico!" -ForegroundColor $script:ColorRojo
    }
    
    # 3. CPU
    Write-Host "`n[3/5] Verificando CPU..." -ForegroundColor $script:ColorAmarillo
    $cpu = Get-CimInstance Win32_Processor
    Write-Host "  CPU: $($cpu.Name)"
    Write-Host "  Núcleos: $($cpu.NumberOfCores)"
    
    # 4. Red
    Write-Host "`n[4/5] Verificando red..." -ForegroundColor $script:ColorAmarillo
    $ping = Test-Connection 8.8.8.8 -Count 2 -Quiet
    if ($ping) {
        Write-Host "  Conexion a Internet: OK" -ForegroundColor Green
    }
    else {
        Write-Host "  Conexion a Internet: FALLO" -ForegroundColor Red
    }
    
    # 5. Servicios criticos
    Write-Host "`n[5/5] Verificando servicios..." -ForegroundColor $script:ColorAmarillo
    $servicios = @("WinDefend", "Spooler", "WSearch", "wuauserv")
    foreach ($servicio in $servicios) {
        $estado = Get-Service -Name $servicio -ErrorAction SilentlyContinue
        if ($estado) {
            Write-Host "  $servicio : $($estado.Status)" -ForegroundColor $(if($estado.Status -eq "Running"){$script:ColorVerde}else{$script:ColorRojo})
        }
    }
    
    Write-Log "Diagnostico completado" "SUCCESS"
    Write-Host "`nDiagnostico completado." -ForegroundColor $script:ColorVerde
    Pause
}

# ==========================================
# HERRAMIENTAS RAPIDAS
# ==========================================

function Herramientas-Rapidas {
    do {
        Show-MenuHeader "HERRAMIENTAS RAPIDAS"
        Write-Host @"
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
                Show-MenuHeader "PUERTOS ABIERTOS"
                netstat -ano
                Pause
            }
            "2" {
                Show-MenuHeader "PROCESOS - TOP RAM"
                Get-Process | Sort WS -Descending | Select -First 15
                Pause
            }
            "3" {
                Show-MenuHeader "REPORTE DEL SISTEMA"
                $archivo = "$env:USERPROFILE\Desktop\ReporteIT.txt"
                Get-ComputerInfo > $archivo
                Write-Host "`nReporte generado:" -ForegroundColor Green
                Write-Host $archivo -ForegroundColor Green
                Write-Log "Reporte generado" "SUCCESS"
                Pause
            }
            "4" {
                Show-MenuHeader "SERIAL DEL EQUIPO"
                Get-CimInstance Win32_BIOS | Select SerialNumber
                Pause
            }
            "5" {
                Show-MenuHeader "USUARIOS CONECTADOS"
                Get-CimInstance Win32_ComputerSystem | Select UserName
                Get-CimInstance Win32_LoggedOnUser | ForEach-Object {
                    $user = Get-CimAssociatedInstance -InputObject $_ -ResultClassName Win32_UserAccount
                    $user | Select Name, Domain
                }
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
    $opcion = Read-Host "`nSeleccione una opcion"
    
    switch ($opcion) {
        "1" { Limpiar-Sistema }
        "2" { Optimizar-Windows }
        "3" { Herramientas-Red }
        "4" {
            do {
                Show-MenuHeader "DISCO Y ALMACENAMIENTO"
                Write-Host @"
[1] Optimizar Disco
[2] Programar Defrag Diario
[3] Analizar espacio en disco
[0] Volver

"@
                $d = Read-Host "Seleccione"
                switch ($d) {
                    "1" { Optimizar-Disco }
                    "2" { Programar-Defrag }
                    "3" { Analizar-Disco }
                }
            } until ($d -eq "0")
        }
        "5" { Mostrar-Info }
        "6" { Reparar-Windows }
        "7" { Herramientas-Rapidas }
        "8" { Administracion-Procesos }
        "9" { Diagnostico-Sistema }
    }
    
} until ($opcion -eq "0")

Write-Host "`nGracias por usar IT TOOLKIT v2.0" -ForegroundColor Green
Write-Host "Log guardado en: $LogFile" -ForegroundColor Gray
Start-Sleep -Seconds 2
