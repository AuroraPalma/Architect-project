//MAIN BICEP- AZURE ARCHITECT PROJECT

//PARAMS
//Resource Groups
param elz_networking_rg_hub01_name string = 'rg-azarc-hub01-networking-shared-01'
param elz_storage_rg_hub01_name string = 'rg-azarc-hub01-st-shared-01'
param deployment_location string = deployment().location
param currentDateTime string = utcNow()
param elz_networking_rg_onprem_name string = 'rg-azarc-onprem-networking-shared-01'
param elz_networking_rg_spk01_name string = 'rg-azarc-spk01-networking-dev-01'
param elz_workloads_rg_spk01_name string = 'rg-azarc-spk01-dev-01'
param elz_networking_rg_spk02_name string = 'rg-azarc-spk02-networking-prod-01'
param elz_workloads_rg_spk02_name string = 'rg-azarc-spk02-prod-01'
param elz_log_analytics_rg_name string = 'rg-azarc-analytics-monitor-01'
param elz_alerts_monitor_rg_name string = 'rg-azarc-alerts-monitor-01'

//Networking
param networking_Spoke01 object = {
  name: 'vnet-azarc-spk01'
  addressPrefix: '10.1.0.0/22'
  subnetFrontName: 'snet-spk01-front'
  subnetFrontPrefix: '10.1.0.0/25'
  subnetBackName: 'snet-spk01-back'
  subnetBackPrefix: '10.1.0.128/25'
  subnetMangament: 'snet-spk01-mngnt'
  subnetMangamentPrefix: '10.1.1.0/29'

}
param networking_Spoke02 object = {
  name: 'vnet-azarc-spk02'
  addressPrefix: '10.2.0.0/22'
  subnetFrontName: 'snet-spk02-front'
  subnetFrontPrefix: '10.2.0.0/25'
  subnetBackName: 'snet-spk02-back'
  subnetBackPrefix: '10.2.0.128/25'
  subnetMangament: 'snet-spk02-mngnt'
  subnetMangamentPrefix: '10.2.1.0/29'

}

param networking_Hub01 object = {
  name: 'vnet-azarc-hub01'
  addressPrefix: '10.0.1.0/24'
  subnetTransitName: 'snet-hub01-transit'
  subnetTransit: '10.0.1.80/29'
}

param per_spk01_name string = 'per-azarc-spk01-to-hub01'
param per_spk02_name string = 'per-azarc-spk02-to-hub01'
param per_hub01spk01_name string = 'per-azarc-hub01-to-spk01'
param per_hub01spk02_name string = 'per-azarc-hub01-to-spk02'
param peering_spok01_to_hub_name string = '${networking_Spoke01.name}/${per_spk01_name}'
param peering_spok02_to_hub_name string = '${networking_Spoke02.name}/${per_spk02_name}'
param peering_hub01_to_spk01_name string = '${networking_Hub01.name}/${per_hub01spk01_name}'
param peering_hub01_to_spok02_name string = '${networking_Hub01.name}/${per_hub01spk02_name}'

targetScope = 'subscription'

//RESOURCES
resource res_elz_networking_rg_hub01_name 'Microsoft.Resources/resourceGroups@2021-01-01' = {
  name: elz_networking_rg_hub01_name
  location: deployment_location
  tags: {
    'az-core-env': 'Shared'
    'az-core-costCenter': '00123'
    'az-core-projectcode': 'BicepDeployment- Designing Microsoft Azure Infrastructure Solutions '
    'az-core-purpose': 'Networking Hub'
    'az-aut-delete' : 'true'
  }
}

resource res_elz_storage_rg_hub01_name 'Microsoft.Resources/resourceGroups@2021-01-01' = {
  name: elz_storage_rg_hub01_name
  location: deployment_location
  tags: {
    'az-core-env': 'Shared'
    'az-core-costCenter': '00123'
    'az-core-projectcode': 'BicepDeployment- Designing Microsoft Azure Infrastructure Solutions '
    'az-core-purpose': 'Storage Accounts Hub'
    'az-aut-delete' : 'true'
  }
}

resource res_elz_networking_rg_onprem_name 'Microsoft.Resources/resourceGroups@2021-01-01' = {
  name: elz_networking_rg_onprem_name
  location: deployment_location
  tags: {
    'az-core-env': 'Shared'
    'az-core-costCenter': '00123'
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
    'az-core-env': 'Development'
    'az-core-costCenter': '00123'
    'az-core-projectcode': 'BicepDeployment- Designing Microsoft Azure Infrastructure Solutions '
    'az-core-purpose': 'Networking Spoke01'
    'az-aut-delete' : 'true'
  }
}

resource res_elz_networking_rg_spk02_name 'Microsoft.Resources/resourceGroups@2021-01-01' = {
  name: elz_networking_rg_spk02_name
  location: deployment_location
  tags: {
    'az-core-env': 'Production'
    'az-core-costCenter': '00123'
    'az-core-projectcode': 'BicepDeployment- Designing Microsoft Azure Infrastructure Solutions '
    'az-core-purpose': 'Networking Spoke02'
    'az-aut-delete' : 'true'
  }
}

resource res_elz_workloads_rg_spk01_name 'Microsoft.Resources/resourceGroups@2021-01-01' = {
  name: elz_workloads_rg_spk01_name
  location: deployment_location
  tags: {
    'az-core-env': 'Development'
    'az-core-costCenter': '00124'
    'az-core-projectcode': 'BicepDeployment- Designing Microsoft Azure Infrastructure Solutions '
    'az-core-purpose': 'Project-Data Science'
    'az-aut-delete' : 'true'
  }
}

resource res_elz_workloads_rg_spk02_name 'Microsoft.Resources/resourceGroups@2021-01-01' = {
  name: elz_workloads_rg_spk02_name
  location: deployment_location
  tags: {
    'az-core-env': 'Production'
    'az-core-costCenter': '00125'
    'az-core-projectcode': 'BicepDeployment- Designing Microsoft Azure Infrastructure Solutions '
    'az-core-purpose': 'Project-Web'
    'az-aut-delete' : 'true'
  }
}

resource res_elz_log_analytics_rg_name 'Microsoft.Resources/resourceGroups@2021-01-01' = {
  name: elz_log_analytics_rg_name
  location:deployment_location
  tags:{
    'az-core-env': 'Monitoring shared'
    'az-core-costCenter': '00123'
    'az-core-projectcode': 'BicepDeployment- Designing Microsoft Azure Infrastructure Solutions '
    'az-core-purpose': 'Log analytics-Resource Group'
    'az-aut-delete' : 'true'
  }
}

resource res_elz_alerts_monitor_rg_name 'Microsoft.Resources/resourceGroups@2021-01-01' = {
  name: elz_alerts_monitor_rg_name
  location: deployment_location
  tags:{
    'az-core-env': 'Monitoring shared'
    'az-core-costCenter': '00123'
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
}

module mod_architectdev_Networking_Hub_Deploy 'modules/networking/arc.dev.networking.hub01.bicep' = {
  name: '${'architectdevNetworking_hub01_'}${currentDateTime}'
  scope: res_elz_networking_rg_hub01_name
  params:{
    location: deployment_location
    networking_Hub01:networking_Hub01
  }
  dependsOn: [
    mod_architectdev_Networking_Spk01_Deploy
    mod_architectprod_Networking_Spk02_Deploy
  ]
}

module mod_architectdev_bastion_Hub_Deploy 'modules/arc.dev.bastion.bicep' = {
  name: '${'architectdev_bastion_Hub_'}${currentDateTime}'
  scope:res_elz_networking_rg_hub01_name
  params:{
    location:deployment_location
    networking_Hub01:networking_Hub01
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
    networking_rg_onprem_name:elz_networking_rg_onprem_name
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
    networking_Spoke01:networking_Spoke01
  }
}
module mod_architectprod_Networking_Spk02_Deploy 'modules/networking/arc.prod.networking.spk02.bicep' = {
  name: '${'architectprodNetworking_Spk02_'}${currentDateTime}'
  scope: res_elz_networking_rg_spk02_name
  params:{
    location: deployment_location
    networking_Spoke02:networking_Spoke02
  }
}

module mod_architecdev_Peering_Hub_spk01_deploy 'modules/networking/peering/arc.dev.hub.peering.spok01.bicep'={
  name:'${'architectdevPeering_hub_spoke01_'}${currentDateTime}'
  scope:res_elz_networking_rg_hub01_name
  params:{
    location:deployment_location
    elz_networking_rg_spk01_name:elz_networking_rg_spk01_name
    networking_Spoke01:networking_Spoke01
    peering_hub01_to_spk01_name: peering_hub01_to_spk01_name
  }
  dependsOn:[
    mod_architectdev_Networking_Spk01_Deploy
    mod_architectdev_Networking_Hub_Deploy
  ]
}

module mod_architecprod_Peering_Hub_spk02_deploy 'modules/networking/peering/arc.prod.hub.peering.spok02.bicep'={
  name:'${'architectprodPeering_hub_spoke02_'}${currentDateTime}'
  scope:res_elz_networking_rg_hub01_name
  params:{
    location:deployment_location
    networking_Spoke02:networking_Spoke02
    elz_networking_rg_spk02_name:elz_networking_rg_spk02_name
    peering_hub01_to_spok02_name:peering_hub01_to_spok02_name
  }
  dependsOn:[
    mod_architectprod_Networking_Spk02_Deploy
    mod_architectdev_Networking_Hub_Deploy
    mod_architecdev_Peering_Hub_spk01_deploy
  ]
}

module mod_architectdev_Peering_Spok01_Deploy 'modules/networking/peering/arc.dev.peerings.spk01.bicep' = {
  name: '${'architectdevPeering_Spk01_'}${currentDateTime}'
  scope: res_elz_networking_rg_spk01_name
  params:{
    location: deployment_location
    elz_networking_rg_hub01_name:elz_networking_rg_hub01_name
    elz_networking_rg_spk01_name: elz_networking_rg_spk01_name
    networking_Hub01:networking_Hub01
    networking_Spoke01:networking_Spoke01
    peering_spok01_to_hub_name:peering_spok01_to_hub_name
  }
  dependsOn:[
    mod_architectdev_Networking_Hub_Deploy
    mod_architectdev_Networking_Spk01_Deploy
  ]
}

module mod_architectdev_Peering_Spok02_Deploy 'modules/networking/peering/arc.prod.peeringsk02.bicep' = {
  name: '${'architectdevPeering_Spk02_'}${currentDateTime}'
  scope: res_elz_networking_rg_spk02_name
  params:{
    location: deployment_location
    elz_networking_rg_hub01_name:elz_networking_rg_hub01_name
    elz_networking_rg_spk02_name:elz_networking_rg_spk02_name
    networking_Hub01:networking_Hub01
    networking_Spoke02:networking_Spoke02
    peering_spok02_to_hub_name:peering_spok02_to_hub_name
  }
  dependsOn:[
    mod_architectdev_Networking_Hub_Deploy
    mod_architectprod_Networking_Spk02_Deploy
  ]
}

/*Log analytics*/
module mod_architectdev_Loganalytics_hub_Deploy 'modules/arc.dev.loganalytics.bicep' = {
  name: '${'architectdevLoganalytics_hub_'}${currentDateTime}'
  scope: res_elz_log_analytics_rg_name
  params:{
    location:deployment_location
  }
}

module mod_architectprod_Loganalytics_Deploy 'modules/arc.prod.loganalytics.bicep' = {
  name: '${'architectprodLoganalytics_'}${currentDateTime}'
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
    secretValue_shared: 'Pa$$w0rd-007.'
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
    networking_Spoke01:networking_Spoke01
    adminPasswordOrKey: 'usr$Am1n-2223'
  }
  dependsOn: [
        mod_architectdev_Networking_Spk01_Deploy
        mod_architectdev_Loganalytics_hub_Deploy
  ]
}

module mod_architectprod_Workload_spk02_Deploy 'modules/arc.prod.worload.spk2.bicep' = {
  name: '${'architectprodworkload_Spk02_'}${currentDateTime}'
  scope:res_elz_workloads_rg_spk02_name
  params:{
    location:deployment_location
    networking_Spoke02:networking_Spoke02
    adminPasswordOrKey: 'usr$Am1n-2223'
  }
  dependsOn:[
    mod_architectprod_Networking_Spk02_Deploy
    mod_architectprod_Loganalytics_Deploy
  ]
}
