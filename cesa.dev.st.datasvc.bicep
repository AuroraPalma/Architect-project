/*
###################################################################################
######              AZURE CLOUD EXPERT SOLUTIONS ARCHITECT                    #####
######                        ENTERPRISE LANDING ZONE                         #####
######            a.palma@htmecia.com / 2022, March, 17th (creation)       #####  
######                           DEV - ENVIRONMENT                            #####
######                   MAIN BICEP DEPLOYMENT / MODULES                      #####
###################################################################################                
*/
/*PARA CUENTA DE ALMACENAMIENTO*/
/***********************************************************  BEGIN PARAMS         */
/* @minLength(3)
@maxLength(24)
@description('Specify a storage account name.')
// param storageAccountName string
// Use of Bicep functions & Vars to generaliza a good naming convention:
var uniqueStorageName = '${storagePrefix}${('mon01')}'
*/
/*variables que restringen los caracteres para el nombre del parámetro*/
@minLength(3)
@maxLength(24)
param storageAccountName string = 'stcesaneudatasvcau01'
/*lista de valores permitidos para los tipos de replicacion de la cuenta de almacenamiento*/
@allowed([
  'Standard_LRS'
  'Standard_GRS'
  'Standard_RAGRS'
  'Standard_ZRS'
  'Premium_LRS'
  'Premium_ZRS'
  'Standard_GZRS'
  'Standard_RAGZRS'
])
param storageSKU string = 'Standard_LRS'
param deploymentLocation string = 'northeurope'

/***********************************************************  END PARAMS         */

resource stAccount_stmazneucordfbi_datasvc 'Microsoft.Storage/storageAccounts@2021-02-01' = {
  name: storageAccountName 
  location: deploymentLocation
  tags:{
    'cesa-ctx-environment': 'development'
    'cesa-ctx-projectcode': 'CESA: Cloud Expert Solutions Architect 2022A'
    'cesa-ctx-purpose': 'Enterprise Landing Zone 01 - Proyectos Alumnos'
  }
  sku:{
    name: storageSKU
    tier: 'Standard'
  }
  kind: 'StorageV2'
  properties: {
    azureFilesIdentityBasedAuthentication: {
      directoryServiceOptions: 'None'
    }
    minimumTlsVersion: 'TLS1_2'
    allowBlobPublicAccess: false
    allowSharedKeyAccess: true
    networkAcls: {
      bypass: 'AzureServices'
      virtualNetworkRules: []
      ipRules: []
      defaultAction: 'Allow'
    }
    supportsHttpsTrafficOnly: true
      encryption: {
      services: {
        file: {
          keyType: 'Account'
          enabled: true
        }
        blob: {
          keyType: 'Account'
          enabled: true
        }
      }
      keySource: 'Microsoft.Storage'
    }
    accessTier: 'Hot'
  }
}
/*los contedores pueden desplegarse en paralelo porque no dependen uno de otro*/
resource cesaDevStorage01_blobService 'Microsoft.Storage/storageAccounts/blobServices@2021-02-01' = {
  parent: stAccount_stmazneucordfbi_datasvc
  name: 'default'
  properties: {
    cors: {
      corsRules: []
    }
    deleteRetentionPolicy: {
      enabled: true
      days: 7
    }
  }
}

resource cesaDevStorage01_container01 'Microsoft.Storage/storageAccounts/blobServices/containers@2021-02-01' = {
  parent: cesaDevStorage01_blobService
  name: 'backupsql'
  properties: {
    defaultEncryptionScope: '$account-encryption-key'
    denyEncryptionScopeOverride: false
    publicAccess: 'None'
  }
  dependsOn: [
    
  ]
}

resource cesaDevStorage01_container02 'Microsoft.Storage/storageAccounts/blobServices/containers@2021-02-01' = {
  parent: cesaDevStorage01_blobService
  name: 'backupssas'
  properties: {
    defaultEncryptionScope: '$account-encryption-key'
    denyEncryptionScopeOverride: false
    publicAccess: 'None'
  }
  dependsOn: [
    
  ]
}
