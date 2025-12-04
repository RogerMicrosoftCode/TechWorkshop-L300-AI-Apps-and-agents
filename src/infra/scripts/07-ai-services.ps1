# 07 - Crear AI Services (Cognitive Services)
# Dependencias: Resource Group

. "$PSScriptRoot\00-set-env.ps1"

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "07 - Creando AI Services" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

Write-Host "Creando AI Foundry: $AI_FOUNDRY_NAME" -ForegroundColor Yellow

az cognitiveservices account create `
    --name $AI_FOUNDRY_NAME `
    --resource-group $RESOURCE_GROUP `
    --location $LOCATION `
    --kind AIServices `
    --sku S0 `
    --custom-domain $AI_FOUNDRY_NAME `
    --yes

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ AI Services creado exitosamente" -ForegroundColor Green
} else {
    Write-Error "❌ Error creando AI Services"
    exit 1
}

# Nota: AI Project es una extensión de AI Foundry que requiere APIs específicas
# y puede que no esté disponible via CLI estándar. Se puede crear via portal o ARM template.
Write-Host "⚠️  AI Project debe crearse desde Azure AI Foundry Portal" -ForegroundColor Yellow
