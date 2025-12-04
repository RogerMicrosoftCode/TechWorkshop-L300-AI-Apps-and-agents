# 09 - Asignar roles RBAC
# Dependencias: Cosmos DB, AI Search, AI Services

. "$PSScriptRoot\00-set-env.ps1"

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "09 - Asignando roles RBAC" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# Role IDs
$cosmosDbBuiltInDataContributorRoleId = "00000000-0000-0000-0000-000000000002"
$cosmosDbBuiltInDataReaderRoleId = "00000000-0000-0000-0000-000000000001"
$cosmosDbAccountReaderRoleId = "fbdf93bf-df7d-467e-a4d2-9458aa1360c8"
$cognitiveServicesOpenAIUserRoleId = "5e0bd9bd-7b93-4f28-af87-19fc36ad61bd"
$cognitiveServicesContributorRoleId = "25fbc0a9-bd7c-42a3-aa1a-3b75d497ee68"

# Obtener IDs de recursos
Write-Host "Obteniendo IDs de recursos..." -ForegroundColor Yellow

$cosmosAccountId = az cosmosdb show --name $COSMOS_DB_NAME --resource-group $RESOURCE_GROUP --query id -o tsv
$searchPrincipalId = az search service show --name $SEARCH_SERVICE_NAME --resource-group $RESOURCE_GROUP --query identity.principalId -o tsv
$aiFoundryId = az cognitiveservices account show --name $AI_FOUNDRY_NAME --resource-group $RESOURCE_GROUP --query id -o tsv

Write-Host "`n1. Asignando Cosmos DB Data Contributor al usuario..." -ForegroundColor Yellow
az cosmosdb sql role assignment create `
    --account-name $COSMOS_DB_NAME `
    --resource-group $RESOURCE_GROUP `
    --scope $cosmosAccountId `
    --principal-id $USER_PRINCIPAL_ID `
    --role-definition-id "$cosmosAccountId/sqlRoleDefinitions/$cosmosDbBuiltInDataContributorRoleId"

Write-Host "`n2. Asignando Cosmos DB Account Reader a AI Search..." -ForegroundColor Yellow
az role assignment create `
    --assignee $searchPrincipalId `
    --role $cosmosDbAccountReaderRoleId `
    --scope $cosmosAccountId

Write-Host "`n3. Asignando Cosmos DB Data Reader a AI Search..." -ForegroundColor Yellow
az cosmosdb sql role assignment create `
    --account-name $COSMOS_DB_NAME `
    --resource-group $RESOURCE_GROUP `
    --scope $cosmosAccountId `
    --principal-id $searchPrincipalId `
    --role-definition-id "$cosmosAccountId/sqlRoleDefinitions/$cosmosDbBuiltInDataReaderRoleId"

Write-Host "`n4. Asignando Cosmos DB Data Contributor a AI Search..." -ForegroundColor Yellow
az cosmosdb sql role assignment create `
    --account-name $COSMOS_DB_NAME `
    --resource-group $RESOURCE_GROUP `
    --scope $cosmosAccountId `
    --principal-id $searchPrincipalId `
    --role-definition-id "$cosmosAccountId/sqlRoleDefinitions/$cosmosDbBuiltInDataContributorRoleId"

Write-Host "`n5. Asignando Cognitive Services OpenAI User a AI Search en AI Foundry..." -ForegroundColor Yellow
az role assignment create `
    --assignee $searchPrincipalId `
    --role $cognitiveServicesOpenAIUserRoleId `
    --scope $aiFoundryId

Write-Host "`n6. Asignando Cognitive Services Contributor a AI Search en AI Foundry..." -ForegroundColor Yellow
az role assignment create `
    --assignee $searchPrincipalId `
    --role $cognitiveServicesContributorRoleId `
    --scope $aiFoundryId

if ($LASTEXITCODE -eq 0) {
    Write-Host "`n✅ Roles asignados exitosamente" -ForegroundColor Green
} else {
    Write-Warning "⚠️  Algunos roles pueden haber fallado. Revisar los mensajes anteriores."
}
