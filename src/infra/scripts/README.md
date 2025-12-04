# 🚀 Scripts de Despliegue - Tech Workshop L300 AI Apps and Agents

Este directorio contiene scripts de PowerShell para desplegar los recursos de Azure usando Azure CLI y Azure Container Apps.

## 📋 Estructura de Scripts

### **Scripts de Infraestructura** (Numerados por dependencias)

1. **00-set-env.ps1** - Configuración de variables de entorno
2. **01-resource-group.ps1** - Crea el Resource Group
3. **02-storage-account.ps1** - Crea Storage Account
4. **03-cosmos-db.ps1** - Crea Cosmos DB Account y Database
5. **04-log-analytics.ps1** - Crea Log Analytics Workspace
6. **05-app-insights.ps1** - Crea Application Insights
7. **06-container-registry.ps1** - Crea Azure Container Registry
8. **07-ai-services.ps1** - Crea AI Services (Cognitive Services)
9. **08-ai-search.ps1** - Crea Azure AI Search
10. **09-role-assignments.ps1** - Asigna roles RBAC
11. **10-app-service.ps1** - ⚠️ App Service (bloqueado por cuota en MCAPS)
12. **99-validate.ps1** - Valida que todos los recursos se crearon correctamente
13. **run-all.ps1** - Script maestro que ejecuta todos en orden

### **Scripts de Build y Deployment**

- **build-in-azure.ps1** ⭐ - Construye imagen Docker en Azure (sin Docker local)
- **build-and-push-docker.ps1** - Construye localmente y pushea a ACR
- **deploy-containerapp.ps1** - Despliega Container App con todas las configuraciones

### **Documentación**

- **QUOTA-REQUEST-GUIDE.md** - Guía para solicitar aumento de cuota de App Service
- **CONTAINERAPP-VS-APPSERVICE.md** - Comparación Container Apps vs App Service

## Dependencias del Grafo de Recursos

```
Resource Group (01)
├── Storage Account (02)
├── Cosmos DB (03)
│   └── Cosmos DB Database
├── Log Analytics (04)
│   └── App Insights (05)
├── Container Registry (06)
├── AI Services (07)
│   └── AI Project (manual desde portal)
└── AI Search (08)
    └── Role Assignments (09)
        ├── Cosmos DB Roles
        ├── AI Services Roles
        └── User Roles
```

## Uso

### Opción 1: Ejecutar todos los scripts
```powershell
cd src\infra\scripts
.\run-all.ps1
```

### Opción 2: Ejecutar scripts individualmente
```powershell
cd src\infra\scripts

# Ejecutar en orden
.\01-resource-group.ps1
.\02-storage-account.ps1
.\03-cosmos-db.ps1
# ... etc
```

### Opción 3: Ejecutar solo algunos recursos
```powershell
# Por ejemplo, si solo quieres crear Storage y Cosmos DB
.\01-resource-group.ps1
.\02-storage-account.ps1
.\03-cosmos-db.ps1
```

## Requisitos Previos

1. **Azure CLI** instalado y configurado
2. **PowerShell** 5.1 o superior (o PowerShell Core 7+)
3. **parameters.json** con el userPrincipalId configurado:
   ```json
   {
     "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#",
     "contentVersion": "1.0.0.0",
     "parameters": {
       "userPrincipalId": {
         "value": "tu-object-id-aqui"
       }
     }
   }
   ```
4. **Sesión activa de Azure CLI**:
   ```powershell
   az login
   az account set --subscription "tu-subscription-id"
   ```

## Recursos NO Incluidos

Los siguientes recursos del Bicep original **NO** están incluidos en estos scripts debido a limitaciones de cuota:

- **App Service Plan** - Requiere cuota de VM que no está disponible en las suscripciones MCAPS
- **Web App** - Depende del App Service Plan

Si tu suscripción tiene cuota disponible, puedes agregar estos scripts adicionales.

## Notas Importantes

1. **AI Project**: No se puede crear directamente via Azure CLI. Debe crearse desde Azure AI Foundry Portal después de que AI Services esté desplegado.

2. **Nombres Únicos**: Los nombres de recursos se generan usando un string único aleatorio. Si necesitas nombres específicos, modifica `00-set-env.ps1`.

3. **Roles RBAC**: Los roles pueden tardar unos minutos en propagarse. Si encuentras errores de permisos inmediatamente después del despliegue, espera 5-10 minutos.

4. **Costos**: Estos recursos generan costos en Azure. Asegúrate de eliminarlos cuando no los necesites:
   ```powershell
   az group delete --name techworkshop-l300-ai-agents --yes --no-wait
   ```

## Validación

Después del despliegue, ejecuta el script de validación:
```powershell
.\99-validate.ps1
```

Este script verifica que todos los recursos se crearon correctamente y muestra los endpoints importantes.

## Troubleshooting

### Error: "Subscription over quota"
- Tu suscripción no tiene cuota suficiente para el recurso
- Solicita aumento de cuota o usa otra suscripción

### Error: "Resource name already exists"
- Los nombres de algunos recursos deben ser únicos globalmente
- Modifica `00-set-env.ps1` para usar un UNIQUE_STRING diferente

### Error: "Authorization failed"
- Verifica que tienes permisos suficientes en la suscripción
- Algunos recursos requieren rol de "Owner" o "Contributor"

## Limpieza

Para eliminar todos los recursos:
```powershell
az group delete --name techworkshop-l300-ai-agents --yes --no-wait
```
