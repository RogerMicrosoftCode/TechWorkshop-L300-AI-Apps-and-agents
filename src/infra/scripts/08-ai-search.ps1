# 08 - Crear Azure AI Search
# Dependencias: Resource Group

. "$PSScriptRoot\00-set-env.ps1"

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "08 - Creando Azure AI Search" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

Write-Host "Creando AI Search Service: $SEARCH_SERVICE_NAME" -ForegroundColor Yellow

az search service create `
    --name $SEARCH_SERVICE_NAME `
    --resource-group $RESOURCE_GROUP `
    --location $LOCATION `
    --sku standard `
    --identity-type SystemAssigned

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ AI Search Service creado exitosamente" -ForegroundColor Green
} else {
    Write-Error "❌ Error creando AI Search Service"
    exit 1
}
