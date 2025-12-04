# 03 - Crear Cosmos DB Account y Database
# Dependencias: Resource Group

. "$PSScriptRoot\00-set-env.ps1"

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "03 - Creando Cosmos DB" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

Write-Host "Creando Cosmos DB Account: $COSMOS_DB_NAME" -ForegroundColor Yellow

az cosmosdb create `
    --name $COSMOS_DB_NAME `
    --resource-group $RESOURCE_GROUP `
    --locations regionName=$LOCATION failoverPriority=0 isZoneRedundant=False `
    --default-consistency-level Session `
    --kind GlobalDocumentDB

if ($LASTEXITCODE -ne 0) {
    Write-Error "❌ Error creando Cosmos DB Account"
    exit 1
}

Write-Host "Creando Cosmos DB Database: $COSMOS_DB_DATABASE" -ForegroundColor Yellow

az cosmosdb sql database create `
    --account-name $COSMOS_DB_NAME `
    --resource-group $RESOURCE_GROUP `
    --name $COSMOS_DB_DATABASE

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Cosmos DB creado exitosamente" -ForegroundColor Green
} else {
    Write-Error "❌ Error creando Cosmos DB Database"
    exit 1
}
