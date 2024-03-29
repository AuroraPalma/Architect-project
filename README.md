# Azure Expert Solutions Architect 

## Introducción
Entorno completo de una zona de aterrizaje emprearial (enterprise landing zone o ELZ) en la nube Microsoft Azure.
* Infraestructura como código:

Al usar la infraestructura como código, se puede volver a implementar el entorno en cada versión de la solución. Estas versiones pueden incorporar pequeños cambios de configuración o incluso actualizaciones significativas. Este proceso ayuda a evitar el desfase de configuración. Si se realiza un cambio accidental en un recurso, se puede corregir mediante la reimplementación de la configuración. Al seguir este enfoque, está documentando el entorno mediante código.
La infraestructura como código puede ayudar a comprender mejor cómo funciona Azure y cómo solucionar problemas que puedan surgir. Por ejemplo, cuando se crea una máquina virtual mediante Azure Portal, algunos recursos creados se abstraen de la vista. Los discos administrados y las tarjetas de interfaz de red se implementan en segundo plano. Al implementar la misma máquina virtual mediante la infraestructura como código, tiene control total sobre todos los recursos que se crean.
* Código imperativo y declarativo:

```Con el código imperativo, se ejecuta una secuencia de comandos, en un orden específico, para llegar a una configuración final. El enfoque imperativo es como un manual de instrucciones paso a paso. Se logra mediante programación con un lenguaje de scripting como Bash o Azure PowerShell. Los scripts ejecutan una serie de pasos para crear, modificar e incluso quitar los recursos.```

```CLI
#!/usr/bin/env bash
az group create \
    --name storage-resource-group \
    --location eastus

az storage account create \
    --name mystorageaccount \
    --resource-group storage-resource-group \
    --kind StorageV2 \
    --access-tier Hot \
    --https-only true
```

```Con el código declarativo, solo se especifica la configuración final. El código no define cómo realizar la tarea. El enfoque declarativo es como el manual de instrucciones de la vista desglosada.En Azure, se realiza un enfoque de código declarativo utilizando plantillas.```
* JSON
* Bicep
* Ansible, por RedHat
* Terraform, por HashiCorp

```
resource storageAccount 'Microsoft.Storage/storageAccounts@2019-06-01' = {
  name: 'mystorageaccount'
  location: 'eastus'
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    accessTier: 'hot'
    supportsHttpsTrafficOnly: true
  }
}
```
```La sección de recursos define la configuración de la cuenta de almacenamiento. Esta sección contiene el nombre, la ubicación y las propiedades de la cuenta de almacenamiento, incluida su SKU y el tipo de cuenta que es.```
* Código ejemplo

```
param location string = resourceGroup().location
param namePrefix string = 'storage'

var storageAccountName = '${namePrefix}${uniqueString(resourceGroup().id)}'
var storageAccountSku = 'Standard_RAGRS'

resource storageAccount 'Microsoft.Storage/storageAccounts@2019-06-01' = {
  name: storageAccountName
  location: location
  kind: 'StorageV2'
  sku: {
    name: storageAccountSku
  }
  properties: {
    accessTier: 'Hot'
    supportsHttpsTrafficOnly: true
  }
}

output storageAccountId string = storageAccount.id
```
Las versiones más recientes de la CLI de Azure y el módulo de Azure PowerShell tienen compatibilidad integrada con Bicep. Puede usar los mismos comandos de implementación para implementar plantillas de Bicep y JSON.

```CLI
az deployment group create --template-file ./main.bicep --resource-group storage-resource-group
```

Puede ver la plantilla JSON que se envía a Resource Manager mediante el comando bicep build. En el ejemplo siguiente, una plantilla de Bicep se convierte en su plantilla JSON correspondiente:
```bicep build ./main.bicep```
Puede usar la CLI de Bicep para descompilar cualquier plantilla de ARM en una plantilla de Bicep mediante el comando ```bicep decompile```
## Nomenclatura
```bicep
<Resource Type>-<Project>-<Workload1>-<Workload2>-<Environment><Instance id>

rg-azarc-hub-networking-shared-01
bas-azarc-hub01-bastion-shared-01
vgtw-azarc-hub01-vgw01
```

## Etiquetado
```bicep
<azure>-<core/automatization>-<description>
    'az-core-env': For environment (mandatoryTag)
    ' az-core-costCenter ': For costcenter
    'az-core-projectcode': Name of the project
    'az-core-purpose': What is the purpose of the resource
    'az-aut-delete': 'Boolean true or false if the resource is going to be deleted by Azure bash
```

# required steps - azure authentication
```CLI
az login
az account list
```
# required steps - deploy to devtest
```CLI
az account set -s 'xxxx-xxxx-xxxx-xxxx-xxxx'
az deployment sub create -f ./main.bicep -l australiaeast -p ./params-devtest.json
```

## Commands
```CLI
az login
```
``` CLI 
az login --username <emailaddress> -t <customerTenantId-or-Domain>
```
```CLI
az account set --subscription <customerSubscriptionId>
```
```CLI
az group list --output table
```
```CLI
az group create \
    --name storage-resource-group \
    --location eastus
```
```CLI
az deployment group create --template-file ./main.bicep --resource-group storage-resource-group
```
```CLI
az deployment sub create --name Bicepdeployment --location northeurope --template-file .\main.dev.bicep
```
az deployment group create --name deploy1 --resource-group "test" --template-file .\storageaccount.bicep

Para borrarlo todo desde bash en Azure: 
az group list --tag az-aut-delete=true --query [].name -o tsv | xargs -otl az group delete --no-wait  --yes --name



