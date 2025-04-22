####################################################################################################################################
# Desripción Script: Este script detecta la version de Cobian utilizada y reinicia su servicio.                                      #
# Esta diseñado para funcionar junto Atera, donde ya existe un script capaz detectar el tipo de error y lanzar este script para      #
# realizar el autohealing.                                                                                                           #
# Autor: Marc Esteve                                                                                                                 #
# Organización: Accon Software SL                                                                                                    #
# Versión: v1                                                                                                                        #
# Fecha: 24/04/2025                                                                                                                  #
######################################################################################################################################

# --- Configuración ---
$NombreServicioCobian11 = "cbVSCService11"
$NombreServicioCobianReflector = "CobVSCRequester"
$TiempoEsperaReinicioSegundos = 30

# --- Función para reiniciar un servicio ---
function Restart-CobianService {
    param(
        [string]$ServiceName
    )

    $Servicio = Get-Service -Name $ServiceName -ErrorAction SilentlyContinue
    if ($Servicio) {
        Write-Host "Intentando reiniciar el servicio '$ServiceName'..."
        try {
            Restart-Service -Name $ServiceName -Force
            Start-Sleep -Seconds $TiempoEsperaReinicioSegundos
            $ServicioPostReinicio = Get-Service -Name $ServiceName
            if ($ServicioPostReinicio.Status -eq "Running") {
                Write-Host "El servicio '$ServiceName' se ha reiniciado correctamente."
            } else {
                Write-Warning "No se pudo reiniciar el servicio '$ServiceName'. Estado actual: $($ServicioPostReinicio.Status)"
            }
        } catch {
            Write-Error "Error al intentar reiniciar el servicio '$ServiceName': $($_.Exception.Message)"
        }
        return $true # Indica que se intentó reiniciar el servicio (existiera o no)
    } else {
        Write-Host "El servicio '$ServiceName' no está instalado en este sistema."
        return $false # Indica que el servicio no se encontró
    }
}

# --- Detección de la versión de Cobian y reinicio del servicio ---
if (Get-Service -Name $NombreServicioCobianReflector -ErrorAction SilentlyContinue) {
    Write-Host "Se detectó Cobian Reflector."
    Restart-CobianService -ServiceName $NombreServicioCobianReflector
} elseif (Get-Service -Name $NombreServicioCobian11 -ErrorAction SilentlyContinue) {
    Write-Host "Se detectó Cobian Backup 11."
    Restart-CobianService -ServiceName $NombreServicioCobian11
} else {
    Write-Warning "No se encontró una instalación de Cobian Backup conocida. No se pudo reiniciar ningún servicio."
}