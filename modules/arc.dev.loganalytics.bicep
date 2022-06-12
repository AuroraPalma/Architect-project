@description('Name of the workspace.')
param workspaceName string = 'lg-azarc-hub-analytics-001'

@description('Pricing tier: PerGB2018 or legacy tiers (Free, Standalone, PerNode, Standard or Premium) which are not available to all customers.')
@allowed([
  'PerGB2018'
  'Free'
  'Standalone'
  'PerNode'
  'Standard'
  'Premium'
])
param sku string = 'PerGB2018'

@description('Specifies the location for the workspace.')
param location string = resourceGroup().location

@description('Number of days to retain data.')
param retentionInDays int = 30

@description('true to use resource or workspace permissions. false to require workspace permissions.')
param resourcePermissions bool = true

resource loganalyticsdev_resource 'Microsoft.OperationalInsights/workspaces@2021-12-01-preview' = {
  name: workspaceName
  location: location
  tags: {
    tagName1: 'Log Virtual Machines and cosmos'
    tagName2: 'Monitor'
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
