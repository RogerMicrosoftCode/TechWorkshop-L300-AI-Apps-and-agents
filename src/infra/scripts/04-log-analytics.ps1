# 04 - Crear Log Analytics Workspace
# Dependencias: Resource Group

. "$PSScriptRoot\00-set-env.ps1"

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "04 - Creando Log Analytics Workspace" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

Write-Host "Creando Log Analytics: $LOG_ANALYTICS_NAME" -ForegroundColor Yellow

az monitor log-analytics workspace create `
    --resource-group $RESOURCE_GROUP `
    --workspace-name $LOG_ANALYTICS_NAME `
    --location $LOCATION `
    --retention-time 90 `
    --quota 1

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Log Analytics Workspace creado exitosamente" -ForegroundColor Green
} else {
    Write-Error "❌ Error creando Log Analytics Workspace"
    exit 1
}
