# 01 - Crear Resource Group
# Dependencias: Ninguna

. "$PSScriptRoot\00-set-env.ps1"

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "01 - Creando Resource Group" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

Write-Host "Creando Resource Group: $RESOURCE_GROUP en $LOCATION" -ForegroundColor Yellow

az group create `
    --name $RESOURCE_GROUP `
    --location $LOCATION

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Resource Group creado exitosamente" -ForegroundColor Green
} else {
    Write-Error "❌ Error creando Resource Group"
    exit 1
}
