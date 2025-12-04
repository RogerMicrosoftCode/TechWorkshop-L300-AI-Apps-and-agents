# ===================================================================================================
# build-and-push-docker.ps1
# Builds the Docker image for the Tech Workshop application and pushes it to Azure Container Registry
# ===================================================================================================

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "Building and Pushing Docker Image" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan

# Source environment variables
. "$PSScriptRoot\00-set-env.ps1"

# Define image names
$acrName = "26e84cdccosureg"
$imageName = "techworkshopl300/zava"
$imageTag = "latest"
$fullImageName = "${acrName}.azurecr.io/${imageName}:${imageTag}"

Write-Host "Container Registry: $acrName" -ForegroundColor Yellow
Write-Host "Image Name: $imageName" -ForegroundColor Yellow
Write-Host "Full Image: $fullImageName" -ForegroundColor Yellow

# Navigate to src directory where Dockerfile is located
$srcPath = Join-Path $PSScriptRoot "..\.."
Write-Host "`nNavigating to: $srcPath" -ForegroundColor Green
Set-Location $srcPath

# Verify Dockerfile exists
if (-not (Test-Path "Dockerfile")) {
    Write-Host "✗ Error: Dockerfile not found in $srcPath" -ForegroundColor Red
    exit 1
}

Write-Host "✓ Dockerfile found" -ForegroundColor Green

# ===================================================================================================
# Step 1: Create a minimal .env file for Docker build (required by Dockerfile)
# ===================================================================================================
Write-Host "`nCreating temporary .env file for Docker build..." -ForegroundColor Green

$envContent = @"
# Temporary .env for Docker build
# Real configuration will be provided via Container App environment variables
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
# Step 2: Login to Azure Container Registry
# ===================================================================================================
Write-Host "`nLogging in to Azure Container Registry..." -ForegroundColor Green

az acr login --name $acrName

if ($LASTEXITCODE -ne 0) {
    Write-Host "✗ Failed to login to ACR" -ForegroundColor Red
    exit 1
}

Write-Host "✓ Successfully logged in to ACR" -ForegroundColor Green

# ===================================================================================================
# Step 3: Build Docker image
# ===================================================================================================
Write-Host "`nBuilding Docker image..." -ForegroundColor Green
Write-Host "This may take several minutes..." -ForegroundColor Yellow

docker build -t $fullImageName .

if ($LASTEXITCODE -ne 0) {
    Write-Host "✗ Docker build failed" -ForegroundColor Red
    exit 1
}

Write-Host "✓ Docker image built successfully" -ForegroundColor Green

# ===================================================================================================
# Step 4: Push image to Azure Container Registry
# ===================================================================================================
Write-Host "`nPushing image to Azure Container Registry..." -ForegroundColor Green
Write-Host "This may take several minutes..." -ForegroundColor Yellow

docker push $fullImageName

if ($LASTEXITCODE -ne 0) {
    Write-Host "✗ Docker push failed" -ForegroundColor Red
    exit 1
}

Write-Host "✓ Image pushed successfully to ACR" -ForegroundColor Green

# ===================================================================================================
# Step 5: Verify image in ACR
# ===================================================================================================
Write-Host "`nVerifying image in Azure Container Registry..." -ForegroundColor Green

az acr repository show --name $acrName --repository $imageName --output table

if ($LASTEXITCODE -ne 0) {
    Write-Host "⚠ Warning: Could not verify image in ACR" -ForegroundColor Yellow
} else {
    Write-Host "✓ Image verified in ACR" -ForegroundColor Green
}

# ===================================================================================================
# Step 6: List image tags
# ===================================================================================================
Write-Host "`nListing image tags..." -ForegroundColor Green

az acr repository show-tags --name $acrName --repository $imageName --output table

# ===================================================================================================
# Summary
# ===================================================================================================
Write-Host "`n============================================" -ForegroundColor Cyan
Write-Host "Docker Build and Push Completed!" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "Image: $fullImageName" -ForegroundColor White
Write-Host "Registry: ${acrName}.azurecr.io" -ForegroundColor White
Write-Host "Repository: $imageName" -ForegroundColor White
Write-Host "Tag: $imageTag" -ForegroundColor White
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "`nNext steps:" -ForegroundColor Yellow
Write-Host "1. Deploy Container App with this image" -ForegroundColor White
Write-Host "2. Configure environment variables" -ForegroundColor White
Write-Host "3. Test the application" -ForegroundColor White
Write-Host "============================================" -ForegroundColor Cyan

# Clean up temporary .env file
Remove-Item -Path ".env" -Force -ErrorAction SilentlyContinue
