//MODULE LOG ANALYTICS DEV BICEP- AZURE ARCHITECT PROJECT

//PARAMS
@description('Name of the workspace.')
param workspaceName string

@description('Pricing tier: PerGB2018 or legacy tiers (Free, Standalone, PerNode, Standard or Premium) which are not available to all customers.')
@allowed([
  'PerGB2018'
  'Free'
  'Standalone'
  'PerNode'
  'Standard'
  'Premium'
])
param sku string

@description('Specifies the location for the workspace.')
param location string = resourceGroup().location

@description('Number of days to retain data.')
param retentionInDays int

//RESOURCES
resource loganalyticsdev_resource 'Microsoft.OperationalInsights/workspaces@2021-12-01-preview' = {
  name: workspaceName
  location: location
  tags: {
    'az-core-purpose': 'Log Virtual Machines and bastion'
    'Env': 'Monitor'
  }
  properties: {
    /*defaultDataCollectionRuleResourceId: 'string'*/
    features: {
      disableLocalAuth: false
      enableDataExport: true
      enableLogAccessUsingOnlyResourcePermissions: true
      immediatePurgeDataOn30Days: true
    }
    retentionInDays: retentionInDays
    sku: {
      name: sku
    }
  }
}
