# Script base de entorno - Lee parameters.json y configura variables
# Ejecutar primero con: . .\00-set-env.ps1

$ErrorActionPreference = "Stop"

# Ruta al parameters.json
$PARAM_FILE = Join-Path $PSScriptRoot "..\parameters.json"

if (-not (Test-Path $PARAM_FILE)) {
    Write-Error "No se encuentra parameters.json en: $PARAM_FILE"
    exit 1
}

# Leer parameters.json
$params = Get-Content $PARAM_FILE | ConvertFrom-Json

# Función auxiliar para leer parámetros
function Get-Param {
    param([string]$name)
    return $params.parameters.$name.value
}

# Variables globales
$global:USER_PRINCIPAL_ID = Get-Param "userPrincipalId"
$global:LOCATION = "eastus2"  # O leer de params si lo agregas
$global:RESOURCE_GROUP = "techworkshop-l300-ai-agents"

# Generar nombres únicos (simular uniqueString)
$chars = '0123456789abcdef'.ToCharArray()
$global:UNIQUE_STRING = -join ((1..8) | ForEach-Object { $chars | Get-Random })

$global:COSMOS_DB_NAME = "$UNIQUE_STRING-cosmosdb"
$global:COSMOS_DB_DATABASE = "zava"
$global:STORAGE_ACCOUNT_NAME = "${UNIQUE_STRING}sa"
$global:AI_FOUNDRY_NAME = "aif-$UNIQUE_STRING"
$global:AI_PROJECT_NAME = "proj-$UNIQUE_STRING"
$global:SEARCH_SERVICE_NAME = "$UNIQUE_STRING-search"
$global:WEB_APP_NAME = "$UNIQUE_STRING-app"
$global:APP_SERVICE_PLAN_NAME = "$UNIQUE_STRING-cosu-asp"
$global:LOG_ANALYTICS_NAME = "$UNIQUE_STRING-cosu-la"
$global:APP_INSIGHTS_NAME = "$UNIQUE_STRING-cosu-ai"
$global:CONTAINER_REGISTRY_NAME = "${UNIQUE_STRING}cosureg"
$global:WEB_APP_SKU = "B1"
$global:REGISTRY_SKU = "Standard"

Write-Host "✅ Variables de entorno configuradas:" -ForegroundColor Green
Write-Host "   Resource Group: $RESOURCE_GROUP"
Write-Host "   Location: $LOCATION"
Write-Host "   User Principal ID: $USER_PRINCIPAL_ID"
Write-Host "   Unique String: $UNIQUE_STRING"
