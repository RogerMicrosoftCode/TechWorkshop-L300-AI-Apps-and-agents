# ===================================================================================================
# deploy-containerapp.ps1
# Deploys the Tech Workshop application to Azure Container Apps
# Connects to all backend services: Cosmos DB, AI Services, Storage, AI Search, App Insights
# ===================================================================================================

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "Deploying Container App" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan

# Source environment variables
. "$PSScriptRoot\00-set-env.ps1"

# Define names
$containerAppName = "c4bcbfa2-webapp"
$environmentName = "c4bcbfa2-cae"
$acrName = "26e84cdccosureg"
$imageName = "techworkshopl300/zava"
$imageTag = "latest"
$fullImageName = "${acrName}.azurecr.io/${imageName}:${imageTag}"

Write-Host "Container App Name: $containerAppName" -ForegroundColor Yellow
Write-Host "Environment: $environmentName" -ForegroundColor Yellow
Write-Host "Image: $fullImageName" -ForegroundColor Yellow

# ===================================================================================================
# Step 1: Get ACR credentials
# ===================================================================================================
Write-Host "`nRetrieving Azure Container Registry credentials..." -ForegroundColor Green

$acrUsername = $acrName
$acrPassword = az acr credential show --name $acrName --resource-group $RESOURCE_GROUP --query "passwords[0].value" -o tsv

if ([string]::IsNullOrEmpty($acrPassword)) {
    Write-Host "✗ Failed to retrieve ACR password" -ForegroundColor Red
    exit 1
}

Write-Host "✓ ACR credentials retrieved" -ForegroundColor Green

# ===================================================================================================
# Step 2: Get Cosmos DB connection details
# ===================================================================================================
Write-Host "`nRetrieving Cosmos DB configuration..." -ForegroundColor Green

$cosmosDbName = "7241d2cb-cosmosdb"
$cosmosDbEndpoint = az cosmosdb show --name $cosmosDbName --resource-group $RESOURCE_GROUP --query "documentEndpoint" -o tsv
$cosmosDbKey = az cosmosdb keys list --name $cosmosDbName --resource-group $RESOURCE_GROUP --query "primaryMasterKey" -o tsv
$cosmosDbDatabase = "zava"

if ([string]::IsNullOrEmpty($cosmosDbEndpoint)) {
    Write-Host "✗ Failed to retrieve Cosmos DB endpoint" -ForegroundColor Red
    exit 1
}

Write-Host "✓ Cosmos DB: $cosmosDbEndpoint" -ForegroundColor Green

# ===================================================================================================
# Step 3: Get AI Services configuration
# ===================================================================================================
Write-Host "`nRetrieving AI Services configuration..." -ForegroundColor Green

$aiServicesName = "aif-26e84cdc"
$aiServicesEndpoint = az cognitiveservices account show --name $aiServicesName --resource-group $RESOURCE_GROUP --query "properties.endpoint" -o tsv
$aiServicesKey = az cognitiveservices account keys list --name $aiServicesName --resource-group $RESOURCE_GROUP --query "key1" -o tsv

if ([string]::IsNullOrEmpty($aiServicesEndpoint)) {
    Write-Host "✗ Failed to retrieve AI Services endpoint" -ForegroundColor Red
    exit 1
}

Write-Host "✓ AI Services: $aiServicesEndpoint" -ForegroundColor Green

# ===================================================================================================
# Step 4: Get Azure AI Search configuration
# ===================================================================================================
Write-Host "`nRetrieving Azure AI Search configuration..." -ForegroundColor Green

$searchServiceName = "26e84cdc-search"
$searchEndpoint = "https://${searchServiceName}.search.windows.net"
$searchKey = az search admin-key show --service-name $searchServiceName --resource-group $RESOURCE_GROUP --query "primaryKey" -o tsv

if ([string]::IsNullOrEmpty($searchKey)) {
    Write-Host "✗ Failed to retrieve Search key" -ForegroundColor Red
    exit 1
}

Write-Host "✓ AI Search: $searchEndpoint" -ForegroundColor Green

# ===================================================================================================
# Step 5: Get Storage Account configuration
# ===================================================================================================
Write-Host "`nRetrieving Storage Account configuration..." -ForegroundColor Green

$storageAccountName = "92f7d5c5sa"
$storageConnectionString = az storage account show-connection-string --name $storageAccountName --resource-group $RESOURCE_GROUP --query "connectionString" -o tsv

if ([string]::IsNullOrEmpty($storageConnectionString)) {
    Write-Host "✗ Failed to retrieve Storage connection string" -ForegroundColor Red
    exit 1
}

Write-Host "✓ Storage Account: $storageAccountName" -ForegroundColor Green

# ===================================================================================================
# Step 6: Get Application Insights configuration
# ===================================================================================================
Write-Host "`nRetrieving Application Insights configuration..." -ForegroundColor Green

$appInsightsName = "26e84cdc-cosu-ai"
$instrumentationKey = az resource show `
    --resource-group $RESOURCE_GROUP `
    --name $appInsightsName `
    --resource-type "Microsoft.Insights/components" `
    --query "properties.InstrumentationKey" `
    -o tsv

$connectionString = az resource show `
    --resource-group $RESOURCE_GROUP `
    --name $appInsightsName `
    --resource-type "Microsoft.Insights/components" `
    --query "properties.ConnectionString" `
    -o tsv

if ([string]::IsNullOrEmpty($instrumentationKey)) {
    Write-Host "⚠ Warning: Could not retrieve App Insights key" -ForegroundColor Yellow
    $instrumentationKey = ""
    $connectionString = ""
} else {
    Write-Host "✓ Application Insights configured" -ForegroundColor Green
}

# ===================================================================================================
# Step 7: Check if Container App exists
# ===================================================================================================
Write-Host "`nChecking if Container App exists..." -ForegroundColor Green

$existingApp = az containerapp show --name $containerAppName --resource-group $RESOURCE_GROUP 2>$null

if ($null -ne $existingApp) {
    Write-Host "⚠ Container App already exists. Deleting..." -ForegroundColor Yellow
    az containerapp delete --name $containerAppName --resource-group $RESOURCE_GROUP --yes
    Start-Sleep -Seconds 5
    Write-Host "✓ Old Container App deleted" -ForegroundColor Green
}

# ===================================================================================================
# Step 8: Create Container App with all configurations
# ===================================================================================================
Write-Host "`nCreating Container App..." -ForegroundColor Green
Write-Host "This may take a few minutes..." -ForegroundColor Yellow

az containerapp create `
    --name $containerAppName `
    --resource-group $RESOURCE_GROUP `
    --environment $environmentName `
    --image $fullImageName `
    --registry-server "${acrName}.azurecr.io" `
    --registry-username $acrUsername `
    --registry-password $acrPassword `
    --target-port 8000 `
    --ingress external `
    --cpu 1.0 `
    --memory 2.0Gi `
    --min-replicas 1 `
    --max-replicas 3 `
    --env-vars `
        "AZURE_COSMOS_ENDPOINT=$cosmosDbEndpoint" `
        "AZURE_COSMOS_KEY=$cosmosDbKey" `
        "AZURE_COSMOS_DATABASE=$cosmosDbDatabase" `
        "AZURE_OPENAI_ENDPOINT=$aiServicesEndpoint" `
        "AZURE_OPENAI_KEY=$aiServicesKey" `
        "AZURE_SEARCH_ENDPOINT=$searchEndpoint" `
        "AZURE_SEARCH_KEY=$searchKey" `
        "AZURE_STORAGE_CONNECTION_STRING=$storageConnectionString" `
        "APPINSIGHTS_INSTRUMENTATIONKEY=$instrumentationKey" `
        "APPLICATIONINSIGHTS_CONNECTION_STRING=$connectionString" `
        "PORT=8000" `
    --output json > containerapp-output.json

if ($LASTEXITCODE -ne 0) {
    Write-Host "✗ Failed to create Container App" -ForegroundColor Red
    exit 1
}

Write-Host "✓ Container App created successfully" -ForegroundColor Green

# ===================================================================================================
# Step 9: Get Container App URL
# ===================================================================================================
Write-Host "`nRetrieving Container App URL..." -ForegroundColor Green

$appUrl = az containerapp show `
    --name $containerAppName `
    --resource-group $RESOURCE_GROUP `
    --query "properties.configuration.ingress.fqdn" `
    -o tsv

if ([string]::IsNullOrEmpty($appUrl)) {
    Write-Host "⚠ Warning: Could not retrieve app URL" -ForegroundColor Yellow
} else {
    $fullUrl = "https://$appUrl"
    Write-Host "✓ Application URL: $fullUrl" -ForegroundColor Green
}

# ===================================================================================================
# Step 10: Verify Container App status
# ===================================================================================================
Write-Host "`nVerifying Container App status..." -ForegroundColor Green

$appStatus = az containerapp show `
    --name $containerAppName `
    --resource-group $RESOURCE_GROUP `
    --query "{Name:name, ProvisioningState:properties.provisioningState, RunningStatus:properties.runningStatus}" `
    --output table

Write-Host $appStatus

# ===================================================================================================
# Summary
# ===================================================================================================
Write-Host "`n============================================" -ForegroundColor Cyan
Write-Host "Container App Deployment Completed!" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "Container App Name: $containerAppName" -ForegroundColor White
Write-Host "Application URL: $fullUrl" -ForegroundColor White
Write-Host "Environment: $environmentName" -ForegroundColor White
Write-Host "Image: $fullImageName" -ForegroundColor White
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "`nConfigured Services:" -ForegroundColor Yellow
Write-Host "✓ Cosmos DB: $cosmosDbEndpoint" -ForegroundColor White
Write-Host "✓ AI Services: $aiServicesEndpoint" -ForegroundColor White
Write-Host "✓ AI Search: $searchEndpoint" -ForegroundColor White
Write-Host "✓ Storage Account: $storageAccountName" -ForegroundColor White
Write-Host "✓ Application Insights: Configured" -ForegroundColor White
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "`nNext steps:" -ForegroundColor Yellow
Write-Host "1. Visit: $fullUrl" -ForegroundColor White
Write-Host "2. Test the application functionality" -ForegroundColor White
Write-Host "3. Monitor logs in Application Insights" -ForegroundColor White
Write-Host "4. Check Container App logs if needed:" -ForegroundColor White
Write-Host "   az containerapp logs show --name $containerAppName --resource-group $RESOURCE_GROUP --follow" -ForegroundColor Gray
Write-Host "============================================" -ForegroundColor Cyan

# Clean up temporary file
Remove-Item -Path "containerapp-output.json" -Force -ErrorAction SilentlyContinue
