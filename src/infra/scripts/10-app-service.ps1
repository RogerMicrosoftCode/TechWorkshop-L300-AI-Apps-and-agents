# ===================================================================================================
# 10-app-service.ps1
# Creates Azure App Service Plan and Web App for the Tech Workshop application
# ===================================================================================================

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "Creating App Service Plan and Web App..." -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan

# Source environment variables
. "$PSScriptRoot\00-set-env.ps1"

# Define App Service names
$appServicePlanName = "${UNIQUE_STRING}-asp"
$webAppName = "${UNIQUE_STRING}-webapp"

Write-Host "App Service Plan Name: $appServicePlanName" -ForegroundColor Yellow
Write-Host "Web App Name: $webAppName" -ForegroundColor Yellow

# ===================================================================================================
# Step 1: Create App Service Plan (trying P0v3 Premium - better chance than Free/Basic)
# ===================================================================================================
Write-Host "`nCreating App Service Plan..." -ForegroundColor Green

try {
    az appservice plan create `
        --name $appServicePlanName `
        --resource-group $RESOURCE_GROUP `
        --location $LOCATION `
        --is-linux `
        --sku P0v3 `
        --output table
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✓ App Service Plan created successfully" -ForegroundColor Green
    } else {
        Write-Host "✗ Failed to create App Service Plan with P0v3 SKU" -ForegroundColor Red
        Write-Host "Trying B1 Basic SKU..." -ForegroundColor Yellow
        
        az appservice plan create `
            --name $appServicePlanName `
            --resource-group $RESOURCE_GROUP `
            --location $LOCATION `
            --is-linux `
            --sku B1 `
            --output table
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✓ App Service Plan created successfully with B1 SKU" -ForegroundColor Green
        } else {
            Write-Host "✗ Failed to create App Service Plan. Quota issues persist." -ForegroundColor Red
            throw "Cannot create App Service Plan due to quota limitations"
        }
    }
} catch {
    Write-Host "✗ Error creating App Service Plan: $_" -ForegroundColor Red
    exit 1
}

# ===================================================================================================
# Step 2: Get Container Registry credentials
# ===================================================================================================
Write-Host "`nRetrieving Container Registry credentials..." -ForegroundColor Green

$acrName = "${UNIQUE_STRING}reg"
$acrUsername = $acrName
$acrPassword = az acr credential show --name $acrName --resource-group $RESOURCE_GROUP --query "passwords[0].value" -o tsv

if ([string]::IsNullOrEmpty($acrPassword)) {
    Write-Host "✗ Failed to retrieve ACR password" -ForegroundColor Red
    exit 1
}

Write-Host "✓ Retrieved ACR credentials" -ForegroundColor Green

# ===================================================================================================
# Step 3: Get Application Insights Instrumentation Key
# ===================================================================================================
Write-Host "`nRetrieving Application Insights key..." -ForegroundColor Green

$appInsightsName = "${UNIQUE_STRING}-cosu-ai"
$instrumentationKey = az resource show `
    --resource-group $RESOURCE_GROUP `
    --name $appInsightsName `
    --resource-type "Microsoft.Insights/components" `
    --query "properties.InstrumentationKey" `
    -o tsv

if ([string]::IsNullOrEmpty($instrumentationKey)) {
    Write-Host "⚠ Warning: Could not retrieve App Insights key" -ForegroundColor Yellow
    $instrumentationKey = ""
}

Write-Host "✓ Retrieved Application Insights key" -ForegroundColor Green

# ===================================================================================================
# Step 4: Create Web App
# ===================================================================================================
Write-Host "`nCreating Web App..." -ForegroundColor Green

$dockerImage = "${acrName}.azurecr.io/${UNIQUE_STRING}/techworkshopl300/zava"

az webapp create `
    --name $webAppName `
    --resource-group $RESOURCE_GROUP `
    --plan $appServicePlanName `
    --deployment-container-image-name $dockerImage `
    --output table

if ($LASTEXITCODE -ne 0) {
    Write-Host "✗ Failed to create Web App" -ForegroundColor Red
    exit 1
}

Write-Host "✓ Web App created successfully" -ForegroundColor Green

# ===================================================================================================
# Step 5: Configure Web App settings
# ===================================================================================================
Write-Host "`nConfiguring Web App settings..." -ForegroundColor Green

az webapp config set `
    --name $webAppName `
    --resource-group $RESOURCE_GROUP `
    --linux-fx-version "DOCKER|${dockerImage}" `
    --min-tls-version 1.2 `
    --http20-enabled true `
    --output table

# Configure container settings
az webapp config container set `
    --name $webAppName `
    --resource-group $RESOURCE_GROUP `
    --docker-custom-image-name $dockerImage `
    --docker-registry-server-url "https://${acrName}.azurecr.io" `
    --docker-registry-server-user $acrUsername `
    --docker-registry-server-password $acrPassword `
    --output table

Write-Host "✓ Container registry configured" -ForegroundColor Green

# ===================================================================================================
# Step 6: Configure App Settings
# ===================================================================================================
Write-Host "`nConfiguring application settings..." -ForegroundColor Green

az webapp config appsettings set `
    --name $webAppName `
    --resource-group $RESOURCE_GROUP `
    --settings `
        WEBSITES_ENABLE_APP_SERVICE_STORAGE=false `
        DOCKER_REGISTRY_SERVER_URL="https://${acrName}.azurecr.io" `
        DOCKER_REGISTRY_SERVER_USERNAME=$acrUsername `
        DOCKER_REGISTRY_SERVER_PASSWORD=$acrPassword `
        APPINSIGHTS_INSTRUMENTATIONKEY=$instrumentationKey `
        APPLICATIONINSIGHTS_CONNECTION_STRING="InstrumentationKey=${instrumentationKey}" `
    --output table

Write-Host "✓ Application settings configured" -ForegroundColor Green

# ===================================================================================================
# Step 7: Enable HTTPS only
# ===================================================================================================
Write-Host "`nEnabling HTTPS only..." -ForegroundColor Green

az webapp update `
    --name $webAppName `
    --resource-group $RESOURCE_GROUP `
    --https-only true `
    --client-affinity-enabled false `
    --output table

Write-Host "✓ HTTPS enforcement enabled" -ForegroundColor Green

# ===================================================================================================
# Summary
# ===================================================================================================
Write-Host "`n============================================" -ForegroundColor Cyan
Write-Host "App Service deployment completed!" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "App Service Plan: $appServicePlanName" -ForegroundColor White
Write-Host "Web App: $webAppName" -ForegroundColor White
Write-Host "Web App URL: https://${webAppName}.azurewebsites.net" -ForegroundColor White
Write-Host "============================================" -ForegroundColor Cyan
