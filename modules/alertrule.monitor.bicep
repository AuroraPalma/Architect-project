param activityLogAlerts_Alert_new_user_name string = 'Alert new user'
param activityLogAlerts_Delete_subscription_name string = 'Delete subscription'
param subscriptionid string = '/subscriptions/4c81b137-e05f-43f5-a271-e5a7c3ce6f74'


resource activityLogAlerts_Alert_new_user_name_resource 'microsoft.insights/activityLogAlerts@2020-10-01' = {
  name: activityLogAlerts_Alert_new_user_name
  location: 'Global'
  tags: {
    Monitor: 'alert rule'
  }
  properties: {
    scopes: [
      subscriptionid
    ]
    condition: {
      allOf: [
        {
          field: 'category'
          equals: 'Administrative'
        }
        {
          field: 'operationName'
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

resource Delete_subscription 'microsoft.insights/activityLogAlerts@2020-10-01' = {
  name: activityLogAlerts_Delete_subscription_name
  location: 'Global'
  tags: {
    Monitor: 'alert rule'
  }
  properties: {
    scopes: [
      subscriptionid
    ]
    condition: {
      allOf: [
        {
          field: 'category'
          equals: 'Administrative'
        }
        {
          field: 'operationName'
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
