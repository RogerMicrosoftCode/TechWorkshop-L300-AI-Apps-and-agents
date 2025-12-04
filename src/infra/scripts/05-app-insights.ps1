# 05 - Crear Application Insights
# Dependencias: Resource Group, Log Analytics

. "$PSScriptRoot\00-set-env.ps1"

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "05 - Creando Application Insights" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

Write-Host "Obteniendo ID de Log Analytics Workspace..." -ForegroundColor Yellow
$workspaceId = az monitor log-analytics workspace show `
    --resource-group $RESOURCE_GROUP `
    --workspace-name $LOG_ANALYTICS_NAME `
    --query id -o tsv

Write-Host "Creando Application Insights: $APP_INSIGHTS_NAME" -ForegroundColor Yellow

az monitor app-insights component create `
    --app $APP_INSIGHTS_NAME `
    --location $LOCATION `
    --resource-group $RESOURCE_GROUP `
    --application-type web `
    --kind web `
    --workspace $workspaceId

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Application Insights creado exitosamente" -ForegroundColor Green
} else {
    Write-Error "❌ Error creando Application Insights"
    exit 1
}
