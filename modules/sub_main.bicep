targetScope = 'subscription'

// PARAMETERS
@description('Name of new Resource Group created for supporting resources e.g. "Action Group".')
param resourceGroupName string = 'ActionGroupRG'

@description('Location of new Resource Group e.g. "australiaeast".')
param resourceGrouplocation string = 'australiaeast'

@description('Resource name of action group.')
param actionGroupName string = 'Operations'

@description('Indicates whether this action group is enabled. If an action group is not enabled, then none of its receivers will receive communications.')
param actionGroupEnabled bool = true

@description('The short name of the action group.')
param actionGroupShortName string = 'ops'

@description('The name of the email receiver.')
param actionGroupEmailName string = 'jloudon'

@description('The email address of this receiver.')
param actionGroupEmail string = 'testemail@mail.com'

@description('Indicates whether to use common alert schema.')
param actionGroupAlertSchema bool = true
param assignmentEnforcementMode string = 'Default'
param assignmentIdentityLocation string = 'australiaeast'
param policySource string = 'globalbao/azure-policy-as-code'
param policyCategory string = 'Custom'
param tagNames array = [
  'cor-aut-delete'
]
param tagValue string = 'True'
param tagValuesToIgnore array = []
param logAnalytics string = ''
param effect string = 'Modify'
param appGatewayAlerts object = {}
param vmBackup object = {}

// POLICY DEFINITIONS MODULE
module sub_definitions './definitions/sub_definitions.bicep' = {
  name: 'sub_definitions'
}

// POLICYSET DEFINITIONS MODULE
module sub_initiatives './initiatives/sub_initiatives.bicep' = {
  name: 'sub_initiatives'
  dependsOn: [
    sub_definitions
  ]
  params: {
    policySource: policySource
    policyCategory: policyCategory
    customPolicyIds: sub_definitions.outputs.customPolicyIds
    customPolicyNames: sub_definitions.outputs.customPolicyNames
  }
}

// POLICY ASSIGNMENTS MODULE
module sub_assignments './assignments/sub_assignments.bicep' = {
  name: 'sub_assignments'
  dependsOn: [
    sub_initiatives
  ]
  params: {
    policySource: policySource
    assignmentIdentityLocation: assignmentIdentityLocation
    assignmentEnforcementMode: assignmentEnforcementMode
    customInitiativeIds: sub_initiatives.outputs.customInitiativeIds
    tagNames: tagNames
    tagValue: tagValue
    tagValuesToIgnore: tagValuesToIgnore
    effect: effect
    appGatewayAlerts: appGatewayAlerts
    logAnalytics: logAnalytics
    vmBackup: vmBackup
  }
}

// OUTPUTS 
output resourceNamesForCleanup array = [ // outputs here can be consumed by an .azcli script to delete deployed resources
  sub_definitions.outputs.customPolicyIds
  sub_initiatives.outputs.customInitiativeIds
]
