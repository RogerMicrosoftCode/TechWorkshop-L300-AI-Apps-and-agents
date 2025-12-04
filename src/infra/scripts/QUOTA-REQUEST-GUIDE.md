# 📋 Guía para Solicitar Aumento de Cuota en Azure

## 🎯 Objetivo
Esta guía te ayudará a solicitar un aumento de cuota para **App Service Plans** en tu suscripción de Azure cuando encuentres el error:
```
Operation cannot be completed without additional quota.
Current Limit (Basic VMs): 0
```

---

## 📝 Métodos para Solicitar Aumento de Cuota

### **Método 1: Azure Portal (Recomendado - Más Rápido)**

#### Paso 1: Acceder al Portal de Soporte
1. Abre [Azure Portal](https://portal.azure.com)
2. En el menú de búsqueda superior, escribe: **"Quotas"**
3. Selecciona **"Quotas"** del menú de servicios

#### Paso 2: Buscar el Límite de App Service
1. En la página de Quotas, busca: **"Compute"** o **"App Service"**
2. Filtra por:
   - **Provider**: `Microsoft.Web`
   - **Location**: `East US 2` (o tu región)
3. Busca los siguientes límites:
   - `Basic App Service instances`
   - `Standard App Service instances`
   - `Premium App Service instances`

#### Paso 3: Solicitar Aumento
1. Haz clic en el límite que necesitas aumentar
2. Haz clic en **"Request quota increase"**
3. Completa el formulario:
   - **New limit**: Ingresa el número deseado (ejemplo: 10 para Basic)
   - **Justification**: Explica tu caso de uso
   ```
   Ejemplo: "Necesito desplegar aplicaciones para un workshop técnico 
   de AI Apps and Agents. Requiero App Service Plan Basic B1 para 
   hospedar aplicaciones containerizadas."
   ```
4. Haz clic en **"Submit"**

#### ⏱️ Tiempo de Respuesta
- **Solicitudes automáticas**: Aprobación instantánea (si el aumento es pequeño)
- **Solicitudes manuales**: 1-3 días hábiles

---

### **Método 2: Azure CLI**

Puedes abrir un ticket de soporte directamente desde la línea de comandos:

```powershell
# Crear un ticket de soporte para aumento de cuota
az support tickets create \
  --ticket-name "AppServiceQuotaIncrease" \
  --title "Solicitud de Aumento de Cuota - App Service Plan" \
  --description "Necesito aumentar la cuota de App Service Plan Basic de 0 a 10 en la región East US 2 para desplegar aplicaciones containerizadas del workshop Tech L300." \
  --severity "minimal" \
  --contact-country "US" \
  --contact-email "tu-email@microsoft.com" \
  --contact-first-name "Tu Nombre" \
  --contact-last-name "Tu Apellido" \
  --contact-preferred-contact-method "email" \
  --contact-preferred-timezone "Pacific Standard Time" \
  --problem-classification "/providers/Microsoft.Support/services/quota_service_guid/problemClassifications/web_app_quota_problemClassification_guid"
```

---

### **Método 3: Crear Ticket de Soporte Manualmente**

#### Paso 1: Abrir Soporte
1. En Azure Portal, haz clic en **"Help + support"** (ícono de signo de interrogación)
2. Selecciona **"Create a support request"**

#### Paso 2: Completar el Formulario

**Basics Tab:**
- **Issue type**: Service and subscription limits (quotas)
- **Subscription**: Selecciona tu suscripción MCAPS
- **Quota type**: **Compute-VM (cores-vCPUs) subscription limit increases** o **App Service**
- Haz clic en **"Next"**

**Details Tab:**
- **Location**: East US 2
- **Resource**: App Service Plan
- **SKU**: Basic, Standard, o Premium (según lo que necesites)
- **New limit**: Número deseado (ejemplo: 10)
- **Deployment model**: Resource Manager
- **Provide details**:
  ```
  Necesito aumentar el límite de App Service Plan en la región East US 2.
  
  Uso actual: 0
  Límite actual: 0
  Nuevo límite solicitado: 10
  
  Justificación: Desplegar aplicaciones containerizadas para el workshop 
  Tech L300 AI Apps and Agents. Requiero hospedar aplicaciones Python 
  con FastAPI conectadas a servicios de Azure AI.
  ```

**Contact Information Tab:**
- Completa tus datos de contacto
- **Preferred contact method**: Email
- Haz clic en **"Create"**

---

## 🔍 Verificar Estado de la Solicitud

### Azure Portal
1. Ve a **"Help + support"**
2. Selecciona **"All support requests"**
3. Busca tu ticket por título o número

### Azure CLI
```powershell
# Listar todos los tickets de soporte
az support tickets list --output table

# Ver detalles de un ticket específico
az support tickets show --ticket-name "AppServiceQuotaIncrease"
```

---

## ⚡ Alternativas Inmediatas (Sin Esperar Cuota)

Mientras esperas la aprobación de cuota, puedes usar:

### 1. **Azure Container Apps** (Recomendado)
- ✅ No requiere cuota de App Service
- ✅ Serverless y escalable automáticamente
- ✅ Soporta contenedores Docker
- ✅ Integración con ACR, App Insights, etc.
- 💰 Más económico (pay-per-use)

```powershell
# Ya creado en tu caso:
# Container Apps Environment: c4bcbfa2-cae
```

### 2. **Azure Container Instances (ACI)**
- Simple para contenedores individuales
- No requiere orquestación

### 3. **Azure Kubernetes Service (AKS)**
- Para aplicaciones más complejas
- Mayor control y flexibilidad

---

## 📊 Límites Comunes por Suscripción

| Tipo de Suscripción | App Service Plan Límite por Defecto |
|---------------------|--------------------------------------|
| **Free Trial** | 10 instancias Free/Basic |
| **Pay-As-You-Go** | 100 instancias por región |
| **MCAPS** | **0-10** (varía por asignación) |
| **Enterprise Agreement** | 100+ (configurable) |

---

## 🎓 Recursos Adicionales

- [Documentación oficial de cuotas de Azure](https://learn.microsoft.com/azure/azure-resource-manager/management/azure-subscription-service-limits)
- [Límites de App Service](https://learn.microsoft.com/azure/azure-resource-manager/management/azure-subscription-service-limits#app-service-limits)
- [Cómo solicitar aumentos de cuota](https://learn.microsoft.com/azure/quotas/quickstart-increase-quota-portal)

---

## ✅ Checklist de Solicitud

- [ ] Identificar el tipo de cuota necesaria (Basic/Standard/Premium)
- [ ] Determinar la región (East US 2)
- [ ] Calcular el número de instancias necesarias
- [ ] Preparar justificación del negocio
- [ ] Enviar solicitud por Azure Portal o CLI
- [ ] Guardar número de ticket de soporte
- [ ] Monitorear estado de la solicitud
- [ ] Considerar alternativas mientras esperas (Container Apps)

---

## 📞 Contacto de Soporte

Si necesitas ayuda urgente:
- **Azure Support**: Desde Azure Portal > Help + support
- **Microsoft Learn**: [https://learn.microsoft.com](https://learn.microsoft.com)
- **Azure Community**: [https://techcommunity.microsoft.com/azure](https://techcommunity.microsoft.com/azure)

---

**Nota**: Para workshops y demos, **Azure Container Apps** es la alternativa recomendada ya que proporciona funcionalidad similar a App Service sin las restricciones de cuota.
