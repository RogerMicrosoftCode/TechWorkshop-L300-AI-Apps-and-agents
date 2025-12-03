# Script para generar parameters.json para despliegue en Azure

$parametersContent = @"
{
  "`$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    "userPrincipalId": {
      "value": "$(az ad signed-in-user show --query id -o tsv)"
    }
  }
}
"@

$outputPath = "$(Join-Path $PSScriptRoot '..\src\infra\parameters.json')"
$parametersContent | Out-File -FilePath $outputPath -Encoding utf8

Write-Host "Archivo parameters.json generado correctamente en $outputPath." -ForegroundColor Green
