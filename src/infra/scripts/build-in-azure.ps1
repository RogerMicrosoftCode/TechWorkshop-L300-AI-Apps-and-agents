# ===================================================================================================
# build-in-azure.ps1
# Builds the Docker image directly in Azure Container Registry (no local Docker required)
# Uses ACR Build Tasks to build the image in the cloud
# ===================================================================================================

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "Building Docker Image in Azure" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan

# Source environment variables
. "$PSScriptRoot\00-set-env.ps1"

# Define names
$acrName = "26e84cdccosureg"
$imageName = "techworkshopl300/zava"
$imageTag = "latest"

Write-Host "Container Registry: $acrName" -ForegroundColor Yellow
Write-Host "Image Name: $imageName" -ForegroundColor Yellow
Write-Host "Image Tag: $imageTag" -ForegroundColor Yellow

# Navigate to src directory where Dockerfile is located
$srcPath = Join-Path $PSScriptRoot "..\.."
Write-Host "`nSource Path: $srcPath" -ForegroundColor Green
Set-Location $srcPath

# Verify Dockerfile exists
if (-not (Test-Path "Dockerfile")) {
    Write-Host "✗ Error: Dockerfile not found in $srcPath" -ForegroundColor Red
    exit 1
}

Write-Host "✓ Dockerfile found" -ForegroundColor Green

# ===================================================================================================
# Step 1: Create a minimal .env file (required by Dockerfile)
# ===================================================================================================
Write-Host "`nCreating temporary .env file..." -ForegroundColor Green

$envContent = @"
# Temporary .env for Docker build
AZURE_COSMOS_ENDPOINT=placeholder
AZURE_COSMOS_KEY=placeholder
AZURE_OPENAI_ENDPOINT=placeholder
AZURE_OPENAI_KEY=placeholder
AZURE_STORAGE_CONNECTION_STRING=placeholder
AZURE_SEARCH_ENDPOINT=placeholder
AZURE_SEARCH_KEY=placeholder
"@

$envContent | Out-File -FilePath ".env" -Encoding UTF8 -Force
Write-Host "✓ Temporary .env file created" -ForegroundColor Green

# ===================================================================================================
# Step 2: Build image in Azure using ACR Build
# ===================================================================================================
Write-Host "`nBuilding Docker image in Azure Container Registry..." -ForegroundColor Green
Write-Host "This process uploads source code to Azure and builds remotely." -ForegroundColor Yellow
Write-Host "This may take 5-10 minutes..." -ForegroundColor Yellow

az acr build `
    --registry $acrName `
    --image "${imageName}:${imageTag}" `
    --file Dockerfile `
    .

if ($LASTEXITCODE -ne 0) {
    Write-Host "✗ ACR Build failed" -ForegroundColor Red
    Write-Host "Check the error message above for details" -ForegroundColor Red
    exit 1
}

Write-Host "✓ Image built successfully in Azure" -ForegroundColor Green

# ===================================================================================================
# Step 3: Verify image in ACR
# ===================================================================================================
Write-Host "`nVerifying image in Azure Container Registry..." -ForegroundColor Green

az acr repository show --name $acrName --repository $imageName --output table

if ($LASTEXITCODE -ne 0) {
    Write-Host "⚠ Warning: Could not verify image" -ForegroundColor Yellow
} else {
    Write-Host "✓ Image verified in ACR" -ForegroundColor Green
}

# ===================================================================================================
# Step 4: List image tags
# ===================================================================================================
Write-Host "`nListing available image tags..." -ForegroundColor Green

az acr repository show-tags --name $acrName --repository $imageName --output table

# ===================================================================================================
# Summary
# ===================================================================================================
Write-Host "`n============================================" -ForegroundColor Cyan
Write-Host "Azure Build Completed!" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "Registry: ${acrName}.azurecr.io" -ForegroundColor White
Write-Host "Image: ${imageName}:${imageTag}" -ForegroundColor White
Write-Host "Full Image Path: ${acrName}.azurecr.io/${imageName}:${imageTag}" -ForegroundColor White
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "`nNext steps:" -ForegroundColor Yellow
Write-Host "1. Run: .\deploy-containerapp.ps1" -ForegroundColor White
Write-Host "2. Wait for deployment to complete" -ForegroundColor White
Write-Host "3. Test the application URL" -ForegroundColor White
Write-Host "============================================" -ForegroundColor Cyan

# Clean up temporary file
Remove-Item -Path ".env" -Force -ErrorAction SilentlyContinue
Write-Host "`n✓ Cleanup completed" -ForegroundColor Green
