# Create Resource Group for Tech Workshop L300 AI Agents
# This script creates the resource group needed for the workshop

$resourceGroupName = "techworkshop-l300-ai-agents"
$location = "eastus2"

Write-Host "Creating resource group: $resourceGroupName in location: $location" -ForegroundColor Cyan

az group create --name $resourceGroupName --location $location

if ($LASTEXITCODE -eq 0) {
    Write-Host "Resource group created successfully!" -ForegroundColor Green
} else {
    Write-Host "Failed to create resource group." -ForegroundColor Red
    exit 1
}
