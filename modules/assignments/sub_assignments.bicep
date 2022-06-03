targetScope = 'subscription'

// PARAMETERS
param policySource string = 'Bicep'
param assignmentIdentityLocation string
param assignmentEnforcementMode string
param customInitiativeIds array
param tagNames array
param tagValue string
param tagValuesToIgnore array
param effect string
param appGatewayAlerts object
param logAnalytics string
param vmBackup object

resource tagging_assignment 'Microsoft.Authorization/policyAssignments@2020-09-01' = {
  name: 'tagging_assignment'
  location: assignmentIdentityLocation
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    displayName: 'Tag Governance Assignment - Sub Scope'
    description: 'Tag Governance Assignment Sub Scope via ${policySource}'
    enforcementMode: assignmentEnforcementMode
    metadata: {
      source: policySource
      version: '1.0.0'
    }
    policyDefinitionId: customInitiativeIds[1] // maps to tagging_initiative in sub_initiatives.bicep
    parameters: {
      tagName1: {
        value: tagNames[0]
      }
      tagName2: {
        value: tagNames[1]
      }
      tagName3: {
        value: tagNames[2]
      }
      tagValue: {
        value: tagValue
      }
      tagValuesToIgnore: {
        value: tagValuesToIgnore
      }
      effect: {
        value: effect
      }
    }
  }
}
