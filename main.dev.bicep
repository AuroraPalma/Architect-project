//MAIN BICEP- AZURE ARCHITECT PROJECT

//PARAMS
param elz_networking_rg_hub01_name string = 'rg-azarc-hub-networking-01'
param elz_storage_rg_hub01_name string = 'rg-azarc-hub-st-01'
param deployment_location string = deployment().location
param currentDateTime string = utcNow()
param elz_networking_rg_onprem_name string = 'rg-azarc-onprem-networking-01'
param elz_networking_rg_spk01_name string = 'rg-azarc-spk01-networking-01'
param elz_workloads_rg_spk01_name string = 'rg-azarc-spk01-dev-01'
param elz_networking_rg_spk02_name string = 'rg-azarc-spk02-networking-01'
param elz_workloads_rg_spk02_name string = 'rg-azarc-spk02-prod-01'
param elz_log_analytics_rg_name string = 'rg-azarc-analytics-dev-01'
param elz_alerts_monitor_rg_name string = 'rg-azarc-alerts-monitor-dev-01'

targetScope = 'subscription'

//RESOURCES
resource res_elz_networking_rg_hub01_name 'Microsoft.Resources/resourceGroups@2021-01-01' = {
  name: elz_networking_rg_hub01_name
  location: deployment_location
  tags: {
    'Env': 'Infrastructure'
    'CostCenter': '00123'
    'az-core-projectcode': 'BicepDeployment- Designing Microsoft Azure Infrastructure Solutions '
    'az-core-purpose': 'Networking Hub'
    'az-aut-delete' : 'true'
  }
}

resource res_elz_storage_rg_hub01_name 'Microsoft.Resources/resourceGroups@2021-01-01' = {
  name: elz_storage_rg_hub01_name
  location: deployment_location
  tags: {
    'Env': 'Infrastructure'
    'CostCenter': '00123'
    'az-core-projectcode': 'BicepDeployment- Designing Microsoft Azure Infrastructure Solutions '
    'az-core-purpose': 'Storage Accounts Hub'
    'az-aut-delete' : 'true'
  }
}

resource res_elz_networking_rg_onprem_name 'Microsoft.Resources/resourceGroups@2021-01-01' = {
  name: elz_networking_rg_onprem_name
  location: deployment_location
  tags: {
    'Env': 'Infrastructure'
    'CostCenter': '00123'
    'az-core-projectcode': 'BicepDeployment- Designing Microsoft Azure Infrastructure Solutions '
    'az-core-purpose': 'Networking On premise- Simulation'
    'az-aut-delete' : 'true'
  }
  dependsOn: [
    res_elz_networking_rg_hub01_name
  ]
}

resource res_elz_networking_rg_spk01_name 'Microsoft.Resources/resourceGroups@2021-01-01' = {
  name: elz_networking_rg_spk01_name
  location: deployment_location
  tags: {
    'Env': 'Infrastructure'
    'CostCenter': '00123'
    'az-core-projectcode': 'BicepDeployment- Designing Microsoft Azure Infrastructure Solutions '
    'az-core-purpose': 'Networking Spoke01'
    'az-aut-delete' : 'true'
  }
}

resource res_elz_networking_rg_spk02_name 'Microsoft.Resources/resourceGroups@2021-01-01' = {
  name: elz_networking_rg_spk02_name
  location: deployment_location
  tags: {
    'Env': 'Infrastructure'
    'CostCenter': '00123'
    'az-core-projectcode': 'BicepDeployment- Designing Microsoft Azure Infrastructure Solutions '
    'az-core-purpose': 'Networking Spoke02'
    'az-aut-delete' : 'true'
  }
}

resource res_elz_workloads_rg_spk01_name 'Microsoft.Resources/resourceGroups@2021-01-01' = {
  name: elz_workloads_rg_spk01_name
  location: deployment_location
  tags: {
    'Env': 'DevTest'
    'CostCenter': '00124'
    'az-core-projectcode': 'BicepDeployment- Designing Microsoft Azure Infrastructure Solutions '
    'az-core-purpose': 'Project-Data Science'
    'az-aut-delete' : 'true'
  }
}

resource res_elz_workloads_rg_spk02_name 'Microsoft.Resources/resourceGroups@2021-01-01' = {
  name: elz_workloads_rg_spk02_name
  location: deployment_location
  tags: {
    'Env': 'Production'
    'CostCenter': '00125'
    'az-core-projectcode': 'BicepDeployment- Designing Microsoft Azure Infrastructure Solutions '
    'az-core-purpose': 'Project-Web'
    'az-aut-delete' : 'true'
  }
}

resource res_elz_log_analytics_rg_name 'Microsoft.Resources/resourceGroups@2021-01-01' = {
  name: elz_log_analytics_rg_name
  location:deployment_location
  tags:{
    'Env': 'Monitoring'
    'CostCenter': '00123'
    'az-core-projectcode': 'BicepDeployment- Designing Microsoft Azure Infrastructure Solutions '
    'az-core-purpose': 'Log analytics-Resource Group'
    'az-aut-delete' : 'true'
  }
}

resource res_elz_alerts_monitor_rg_name 'Microsoft.Resources/resourceGroups@2021-01-01' = {
  name: elz_alerts_monitor_rg_name
  location: deployment_location
  tags:{
    'Env': 'Monitoring'
    'CostCenter': '00123'
    'az-core-projectcode': 'BicepDeployment- Designing Microsoft Azure Infrastructure Solutions '
    'az-core-purpose': 'Alerts Monitor-Resource Group'
    'az-aut-delete' : 'true'
  }
}

//MODULES
module mod_architectdev_Networking_OnPrem_Deploy 'modules/networking/arc.dev.networking.onprem.bicep' = {
  name: '${'architectdevNetworking_OnPrem_'}${currentDateTime}'
  scope: res_elz_networking_rg_onprem_name
  params:{
    location: deployment_location
  }
  // TO-DO: params dev/pro
}

module mod_architectdev_Networking_Hub_Deploy 'modules/networking/arc.dev.networking.hub01.bicep' = {
  name: '${'architectdevNetworking_hub01_'}${currentDateTime}'
  scope: res_elz_networking_rg_hub01_name
  params:{
    location: deployment_location
  }
  // TO-DO: params dev/pro
}

module mod_architectdev_bastion_Hub_Deploy 'modules/arc.dev.bastion.bicep' = {
  name: '${'architectdev_bastion_Hub_'}${currentDateTime}'
  scope:res_elz_networking_rg_hub01_name
  params:{
    location:deployment_location
  }
  dependsOn:[
    mod_architectdev_Networking_Hub_Deploy
  ]
}

module mod_architectdev_Vnet2Vnet_OnPrem_Conn_Deploy 'modules/networking/arc.dev.networking.OnPrem.Vnet2VnetCon.bicep' = {
  name: '${'architectdevNet_Vnet2Vnet_Conn_'}${currentDateTime}'
  scope: res_elz_networking_rg_onprem_name
  params:{
    location: deployment_location
  }
  dependsOn:[
    mod_architectdev_Networking_OnPrem_Deploy
    mod_architectdev_Networking_Hub_Deploy
  ]
}

module mod_architectdev_Vnet2Vnet_Hub_Conn_Deploy 'modules/networking/arc.dev.networking.Hub.Vnet2VnetCon.bicep' = {
  name: '${'architectdevNet_Vnet2Vnet_Hub_Conn_'}${currentDateTime}'
  scope: res_elz_networking_rg_hub01_name
  params:{
    location: deployment_location
  }
  dependsOn:[
    mod_architectdev_Networking_Hub_Deploy
    mod_architectdev_Networking_OnPrem_Deploy
  ]
}

module mod_architectdev_Networking_Spk01_Deploy 'modules/networking/arc.dev.networking.spk01.bicep' = {
  name: '${'architectdevNetworking_Spk01_'}${currentDateTime}'
  scope: res_elz_networking_rg_spk01_name
  params:{
    location: deployment_location
  }
  // TO-DO: params dev/pro
}
module mod_architectdev_Networking_Spk02_Deploy 'modules/networking/arc.dev.networking.spk02.bicep' = {
  name: '${'architectdevNetworking_Spk02_'}${currentDateTime}'
  scope: res_elz_networking_rg_spk02_name
  params:{
    location: deployment_location
  }
  // TO-DO: params dev/pro
}

/*Log analytics*/
module mod_architectdev_Loganalytics_Hub_Deploy 'modules/arc.dev.loganalytics.bicep' = {
  name: '${'architectdevLoganalytics_Hub_'}${currentDateTime}'
  scope: res_elz_log_analytics_rg_name
  params:{
    location:deployment_location
  }
}
/*Azure Policy*/

module mod_architectdev_Policies_Deploy 'modules/arc.dev.policy.v2.bicep' = {
  name:'${'architectdevPolicies_general_'}${currentDateTime}'
  params:{
    listOfAllowedLocations: [
      'northeurope'
      'westeurope'
    ]
    assignmentIdentityLocation: 'northeurope'
    mandatoryTag1Value:'Env'
  }
}

module mod_architectdev_Alerts_Deploy 'modules/arc.dev.alertrule.monitor.bicep' = {
  name:'${'architectdevAlerts_Monitor_'}${currentDateTime}'
  scope: res_elz_alerts_monitor_rg_name
}

module mod_architectdev_KeyVault_Hub_Deploy 'modules/arc.dev.keyvault.bicep' = {
  name: '${'architectdevKeyvault_Hub_'}${currentDateTime}'
  scope: res_elz_networking_rg_hub01_name
  params:{
    location:deployment_location
    secretValue: 'usr$Am1n-2223'
    secretValue_windows: 'usr$Am1n-2224'
  }
}

module mod_architectdev_storage_Hub_Deploy 'modules/arc.dev.st.datasvc.bicep' = {
  name: '${'architectdevstorage_Hub_'}${currentDateTime}'
  scope: res_elz_storage_rg_hub01_name
  params: {
    location: deployment_location
  }
}
module mod_architectdev_Workload_spk01_Deploy 'modules/arc.dev.worload.spk.bicep' = {
  name: '${'architectdevworkload_Spk01_'}${currentDateTime}'
  scope: res_elz_workloads_rg_spk01_name
  params:{
    location:deployment_location
    adminPasswordOrKey: 'usr$Am1n-2223'
    adminUserPass: 'usr$Am1n-2224'
  }
  dependsOn: [
        mod_architectdev_Networking_Spk01_Deploy
        mod_architectdev_Loganalytics_Hub_Deploy
  ]
}

