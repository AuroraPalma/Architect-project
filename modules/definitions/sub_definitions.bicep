targetScope = 'subscription'
// VARIABLES
var add_tag_to_rg = json(loadTextContent('./custom/add_tag_to_rg.json'))
// CUSTOM DEFINITIONS
resource addTagToRG 'Microsoft.Authorization/policyDefinitions@2020-09-01' = {
  name: 'add_tag_to_rg'
  properties: add_tag_to_rg.properties
}

// OUTPUTS
output customPolicyIds array = [
  addTagToRG.id
]

output customPolicyNames array = [
  addTagToRG.properties.displayName
]
