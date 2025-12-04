# 06 - Crear Azure Container Registry
# Dependencias: Resource Group

. "$PSScriptRoot\00-set-env.ps1"

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "06 - Creando Container Registry" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

Write-Host "Creando Container Registry: $CONTAINER_REGISTRY_NAME" -ForegroundColor Yellow

az acr create `
    --name $CONTAINER_REGISTRY_NAME `
    --resource-group $RESOURCE_GROUP `
    --location $LOCATION `
    --sku $REGISTRY_SKU `
    --admin-enabled true

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Container Registry creado exitosamente" -ForegroundColor Green
} else {
    Write-Error "❌ Error creando Container Registry"
    exit 1
}
