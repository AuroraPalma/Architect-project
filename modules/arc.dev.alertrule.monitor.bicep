param subscriptionid string = '/subscriptions/4c81b137-e05f-43f5-a271-e5a7c3ce6f74'
param activityLogAlerts_Alert_new_user_name string = 'Alert new user'
param activityLogAlerts_Delete_subscription_name string = 'Delete subscription'
param activityLogAlerts_Certificate_Key_vault_alert_name string = 'Certificate Key vault alert'
param activityLogAlerts_Policy_Definition_Alert_name string = 'Policy Definition Alert'
param activityLogAlerts_Policy_Tenant_alert_name string = 'Policy Tenant alert'


param field_category_name string = 'category'
param field_equals_name string = 'Administrative'
param field_operation_name string = 'operationName'

resource activityLogAlerts_Alert_new_user_name_resource 'microsoft.insights/activityLogAlerts@2020-10-01' = {
  name: activityLogAlerts_Alert_new_user_name
  location: 'Global'
  tags: {
    'Monitor': 'alert rule'
    'Env': 'Development'
  }
  properties: {
    scopes: [
      subscriptionid
    ]
    condition: {
      allOf: [
        {
          field: field_category_name
          equals: field_equals_name
        }
        {
          field: field_operation_name
          equals: 'Microsoft.ApiManagement/service/users/action'
        }
      ]
    }
    actions: {
      actionGroups: []
    }
    enabled: true
  }
}

resource activityLogAlerts_Delete_subscription 'microsoft.insights/activityLogAlerts@2020-10-01' = {
  name: activityLogAlerts_Delete_subscription_name
  location: 'Global'
  tags: {
    'Monitor': 'alert rule'
    'Env': 'Development'
  }
  properties: {
    scopes: [
      subscriptionid
    ]
    condition: {
      allOf: [
        {
          field: field_category_name
          equals: field_equals_name
        }
        {
          field: field_operation_name
          equals: 'Microsoft.ApiManagement/service/subscriptions/delete'
        }
      ]
    }
    actions: {
      actionGroups: []
    }
    enabled: true
  }
}

resource activityLogAlerts_Certificate_Key_vault_alert 'microsoft.insights/activityLogAlerts@2020-10-01' = {
  name: activityLogAlerts_Certificate_Key_vault_alert_name
  location: 'Global'
  tags: {
    'Monitor': 'alert rule'
    'Env': 'Development'
  }
  properties: {
    scopes: [
      subscriptionid
    ]
    condition: {
      allOf: [
        {
          field: field_category_name
          equals: field_equals_name
        }
        {
          field: field_operation_name
          equals: 'Microsoft.ApiManagement/service/workspaces/namedValues/refreshSecret/action'
        }
      ]
    }
    actions: {
      actionGroups: []
    }
    enabled: true
  }
}

resource activityLogAlerts_Policy_Definition_Alert 'microsoft.insights/activityLogAlerts@2020-10-01' = {
  name: activityLogAlerts_Policy_Definition_Alert_name
  location: 'Global'
  tags: {
    'Monitor': 'alert rule'
    'Env': 'Development'
  }
  properties: {
    scopes: [
      subscriptionid
    ]
    condition: {
      allOf: [
        {
          field: field_category_name
          equals: field_equals_name
        }
        {
          field: field_operation_name
          equals: 'Microsoft.Authorization/policyDefinitions/write'
        }
      ]
    }
    actions: {
      actionGroups: []
    }
    enabled: true
  }
}

resource activityLogAlerts_Policy_Tenant_alert 'microsoft.insights/activityLogAlerts@2020-10-01' = {
  name: activityLogAlerts_Policy_Tenant_alert_name
  location: 'Global'
  tags: {
    'Monitor': 'alert rule'
    'Env': 'Development'
  }
  properties: {
    scopes: [
      subscriptionid
    ]
    condition: {
      allOf: [
        {
          field: field_category_name
          equals: field_equals_name
        }
        {
          field: field_operation_name
          equals: 'Microsoft.ApiManagement/service/policy/write'
        }
      ]
    }
    actions: {
      actionGroups: []
    }
    enabled: true
  }
}
