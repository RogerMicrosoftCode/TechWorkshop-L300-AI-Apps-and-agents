# 02 - Crear Storage Account
# Dependencias: Resource Group

. "$PSScriptRoot\00-set-env.ps1"

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "02 - Creando Storage Account" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

Write-Host "Creando Storage Account: $STORAGE_ACCOUNT_NAME" -ForegroundColor Yellow

az storage account create `
    --name $STORAGE_ACCOUNT_NAME `
    --resource-group $RESOURCE_GROUP `
    --location $LOCATION `
    --sku Standard_LRS `
    --kind StorageV2 `
    --access-tier Hot

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Storage Account creado exitosamente" -ForegroundColor Green
} else {
    Write-Error "❌ Error creando Storage Account"
    exit 1
}
