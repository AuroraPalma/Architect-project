//MODULE STORAGE ACCOUNT BICEP- AZURE ARCHITECT PROJECT

//PARAMS
param location string = resourceGroup().location
@minLength(3)
@maxLength(24)
param storageAccountName string = 'stazarcaccountshared01'
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

//RESOURCES
resource stAccount_stmazneucordfbi_datasvc 'Microsoft.Storage/storageAccounts@2021-02-01' = {
  name: storageAccountName 
  location: location
  tags:{
    'Env': 'Dev'
    'az-core-projectcode': 'BicepDeployment- Designing Microsoft Azure Infrastructure Solutions '
    'az-core-purpose': 'General purpose storage'
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

resource arcDevStorage01_blobService 'Microsoft.Storage/storageAccounts/blobServices@2021-02-01' = {
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

resource arcDevStorage01_container01 'Microsoft.Storage/storageAccounts/blobServices/containers@2021-02-01' = {
  parent: arcDevStorage01_blobService
  name: 'backupsql'
  properties: {
    defaultEncryptionScope: '$account-encryption-key'
    denyEncryptionScopeOverride: false
    publicAccess: 'None'
  }
  dependsOn: [
    
  ]
}

resource arcDevStorage01_container02 'Microsoft.Storage/storageAccounts/blobServices/containers@2021-02-01' = {
  parent: arcDevStorage01_blobService
  name: 'backupssas'
  properties: {
    defaultEncryptionScope: '$account-encryption-key'
    denyEncryptionScopeOverride: false
    publicAccess: 'None'
  }
  dependsOn: [
    
  ]
}
