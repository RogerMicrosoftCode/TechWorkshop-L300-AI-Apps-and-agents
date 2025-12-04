# 99 - Validar despliegue
# Dependencias: Todos los recursos anteriores

. "$PSScriptRoot\00-set-env.ps1"

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "99 - Validando despliegue" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

$resources = @(
    @{ Name = "Resource Group"; Command = "az group show --name $RESOURCE_GROUP --query name -o tsv" },
    @{ Name = "Storage Account"; Command = "az storage account show --name $STORAGE_ACCOUNT_NAME --resource-group $RESOURCE_GROUP --query name -o tsv" },
    @{ Name = "Cosmos DB"; Command = "az cosmosdb show --name $COSMOS_DB_NAME --resource-group $RESOURCE_GROUP --query name -o tsv" },
    @{ Name = "Log Analytics"; Command = "az monitor log-analytics workspace show --resource-group $RESOURCE_GROUP --workspace-name $LOG_ANALYTICS_NAME --query name -o tsv" },
    @{ Name = "App Insights"; Command = "az monitor app-insights component show --app $APP_INSIGHTS_NAME --resource-group $RESOURCE_GROUP --query name -o tsv" },
    @{ Name = "Container Registry"; Command = "az acr show --name $CONTAINER_REGISTRY_NAME --resource-group $RESOURCE_GROUP --query name -o tsv" },
    @{ Name = "AI Services"; Command = "az cognitiveservices account show --name $AI_FOUNDRY_NAME --resource-group $RESOURCE_GROUP --query name -o tsv" },
    @{ Name = "AI Search"; Command = "az search service show --name $SEARCH_SERVICE_NAME --resource-group $RESOURCE_GROUP --query name -o tsv" }
)

$allValid = $true

foreach ($resource in $resources) {
    Write-Host "Validando $($resource.Name)... " -NoNewline -ForegroundColor Yellow
    try {
        $result = Invoke-Expression $resource.Command 2>$null
        if ($result) {
            Write-Host "✅ OK ($result)" -ForegroundColor Green
        } else {
            Write-Host "❌ No encontrado" -ForegroundColor Red
            $allValid = $false
        }
    } catch {
        Write-Host "❌ Error" -ForegroundColor Red
        $allValid = $false
    }
}

Write-Host "`n========================================" -ForegroundColor Cyan
if ($allValid) {
    Write-Host "✅ Todos los recursos validados correctamente" -ForegroundColor Green
    
    # Mostrar outputs importantes
    Write-Host "`nOutputs:" -ForegroundColor Cyan
    $cosmosEndpoint = az cosmosdb show --name $COSMOS_DB_NAME --resource-group $RESOURCE_GROUP --query documentEndpoint -o tsv
    Write-Host "  Cosmos DB Endpoint: $cosmosEndpoint" -ForegroundColor White
    Write-Host "  Storage Account: $STORAGE_ACCOUNT_NAME" -ForegroundColor White
    Write-Host "  Search Service: $SEARCH_SERVICE_NAME" -ForegroundColor White
    Write-Host "  Container Registry: $CONTAINER_REGISTRY_NAME" -ForegroundColor White
} else {
    Write-Host "⚠️  Algunos recursos no se pudieron validar" -ForegroundColor Yellow
}
