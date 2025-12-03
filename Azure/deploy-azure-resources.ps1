# Script para desplegar recursos de Azure usando Bicep
# Este script usa el archivo parameters.json para el despliegue

$resourceGroupName = "techworkshop-l300-ai-agents"
$bicepFilePath = "$(Join-Path $PSScriptRoot '..\src\infra\DeployAzureResources.bicep')"
$parametersFilePath = "$(Join-Path $PSScriptRoot '..\src\infra\parameters.json')"

Write-Host "Iniciando despliegue de recursos de Azure..." -ForegroundColor Cyan
Write-Host "Resource Group: $resourceGroupName" -ForegroundColor Yellow
Write-Host "Bicep File: $bicepFilePath" -ForegroundColor Yellow
Write-Host "Parameters File: $parametersFilePath" -ForegroundColor Yellow

# Verificar que el archivo de parámetros existe
if (-not (Test-Path $parametersFilePath)) {
    Write-Host "Error: El archivo parameters.json no existe. Ejecuta primero create-parameters-json.ps1" -ForegroundColor Red
    exit 1
}

# Desplegar recursos usando Azure CLI
az deployment group create `
    --resource-group $resourceGroupName `
    --template-file $bicepFilePath `
    --parameters $parametersFilePath

if ($LASTEXITCODE -eq 0) {
    Write-Host "Despliegue completado exitosamente!" -ForegroundColor Green
} else {
    Write-Host "Error en el despliegue de recursos." -ForegroundColor Red
    exit 1
}
