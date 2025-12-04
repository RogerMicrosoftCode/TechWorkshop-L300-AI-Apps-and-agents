# Script maestro - Ejecuta todos los scripts en orden
# Uso: .\run-all.ps1

$ErrorActionPreference = "Stop"

Write-Host "========================================" -ForegroundColor Magenta
Write-Host "  Despliegue Completo de Azure Resources" -ForegroundColor Magenta
Write-Host "========================================`n" -ForegroundColor Magenta

$scripts = @(
    "01-resource-group.ps1",
    "02-storage-account.ps1",
    "03-cosmos-db.ps1",
    "04-log-analytics.ps1",
    "05-app-insights.ps1",
    "06-container-registry.ps1",
    "07-ai-services.ps1",
    "08-ai-search.ps1",
    "09-role-assignments.ps1",
    "99-validate.ps1"
)

$startTime = Get-Date

foreach ($script in $scripts) {
    $scriptPath = Join-Path $PSScriptRoot $script
    
    if (Test-Path $scriptPath) {
        Write-Host "`nEjecutando: $script" -ForegroundColor Magenta
        Write-Host "========================================" -ForegroundColor Magenta
        
        & $scriptPath
        
        if ($LASTEXITCODE -ne 0 -and $LASTEXITCODE -ne $null) {
            Write-Error "❌ Error ejecutando $script. Abortando."
            exit 1
        }
    } else {
        Write-Warning "⚠️  Script no encontrado: $script"
    }
}

$endTime = Get-Date
$duration = $endTime - $startTime

Write-Host "`n========================================" -ForegroundColor Magenta
Write-Host "✅ Despliegue completado exitosamente" -ForegroundColor Green
Write-Host "   Tiempo total: $($duration.ToString('mm\:ss'))" -ForegroundColor White
Write-Host "========================================`n" -ForegroundColor Magenta
