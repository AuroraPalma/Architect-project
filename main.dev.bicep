//MAIN BICEP- AZURE ARCHITECT PROJECT

//PARAMS

//RESOURCE GROUPS
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

//NETWORKING
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

//Connection VPN
param networking_Hub01_conn object = {
  name: 'con-azarc-hub01-con01'
  connectionType: 'Vnet2Vnet'   /*Site-to-Site => IPSec*/
  enableBgp: false
  sharedKey: 'az_305_desingning_solutions2022'

} 
param networking_deploy_Hub01_VpnGateway bool = true

param networking_hub01_localNetworkGateway object = {
  name: 'lgw-azarc-hub01-lgw01'
  localAddressPrefix: '172.16.1.0/26'
}

param networking_vpnGateway object = {
  name: 'vgw-azarc-hub01-vgw01'
  subnetName: 'GatewaySubnet'
  subnetPrefix: '10.0.1.72/29'
  pipName: 'pip-azarc-hub01-vgw01'
}

param networking_OnPrem_vpnGateway object = {
  name: 'vgw-azarc-onprem-vgw01'
  subnetName: 'GatewaySubnet'
  subnetPrefix: '172.16.1.64/29'
  pipName: 'pip-azarc-onprem-vgw01'
}

param networking_OnPrem_conn object = {
  name: 'con-azarc-onprem-con01'
  connectionType: 'Vnet2Vnet'   /*Site-to-Site => IPSec*/
  enableBgp: false
  sharedKey: 'az_305_desingning_solutions2022'

} 
param networking_OnPrem_localNetworkGateway object = {
  name: 'lgw-azarc-onprem-lgw01'
  localAddressPrefix: '10.0.1.80/29' /*10.0.1.80 - 10.0.1.87 (3 + 5*/
}

//Networking Hub

param networking_deploy_VpnGateway bool = true

param networking_AzureFirewall object = {
  name: 'afw-azarc-firewall01'
  publicIPAddressName: 'pip-azarc-afw01'
  subnetName: 'AzureFirewallSubnet'
  subnetPrefix: '10.0.1.0/26' /* 10.0.1.0 -> 10.0.1.63 */
  routeName: 'udr-azarc-nxthop-to-fw'
}
param lxvm_hub_nic_name string = 'nic-azarc-hub01-lxvmcheckcomms'
param lxvm_hub_nsg_name string = 'nsg-azarc-hub01-lxvmcheckconns'
param lxvm_hub_machine_name string = 'lxvmhubnetcheck'
param lxvm_adminuser_hub string = 'admin77'
param lxvm_adminpass_hub string = 'Pa$$w0rd-007.'
param lxvm_shutdown_name string = 'shutdown-computevm-lxvmhubnetcheck'
@description('Write an email address to receive notifications when vm is running at 22:00')
param email_recipient string = 'a.palma@htmedica.com'

//Networking On Premise

param networking_OnPremises object = {
  name: 'vnet-azarc-onpremises01'
  addressPrefix: '172.16.1.0/24'
  subnetTransitName: 'snet-onprem-transit'
  subnetTransit: '172.16.1.0/26'
}
param networking_deploy_OnPrem_VpnGateway bool = true
param lxvm_onprem_nic_name string = 'nic-azarc-onprem-lxvmcheckcomms'
param lxvm_onprem_nsg_name string = 'nsg-azarc-onprem-lxvmcheckcomms'
param lxvm_onprem_machine_name string = 'lxvmonpnetcheck'
param lxvm_adminuser_onprem string = 'admin77'
param lxvm_adminpass_onprem string = 'Pa$$w0rd-007.'
param lxvm_shutdown_name_onprem string = 'shutdown-computevm-lxvmonpnetcheck'
@description('Write an email address to receive notifications when vm is running at 22:00')
param email_recipient_onprem string = 'a.palma@htmedica.com'

//Networking Spokes

param lxvm_spk01_nic_name string = 'nic-azarc-spk01-lxvmcheckcomms'
param lxvm_spk01_nsg_name string = 'nsg-azarc-spk01-lxvmcheckconns'
param lxvm_spk01_machine_name string = 'lxvmspk01netcheck'
param lxvm_adminuser_spk01 string = 'admin77'
param lxvm_adminpass_spk01 string = 'Pa$$w0rd-007.'
param lxvm_shutdown_name_spoke string = 'shutdown-computevm-lxvmspk01netcheck'
@description('Write an email address to receive notifications when vm is running at 22:00')
param email_recipient_spoke string = 'a.palma@htmedica.com'


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
    networking_deploy_OnPrem_VpnGateway:networking_deploy_OnPrem_VpnGateway
    networking_OnPrem_vpnGateway:networking_OnPrem_vpnGateway
    networking_OnPremises:networking_OnPremises
    lxvm_adminuser_onprem:lxvm_adminuser_onprem
    lxvm_adminpass_onprem:lxvm_adminpass_onprem
    lxvm_onprem_machine_name:lxvm_onprem_machine_name
    lxvm_onprem_nic_name:lxvm_onprem_nic_name
    lxvm_onprem_nsg_name:lxvm_onprem_nsg_name
    lxvm_shutdown_name:lxvm_shutdown_name_onprem
    email_recipient:email_recipient_onprem
  }
}

module mod_architectdev_Networking_Hub_Deploy 'modules/networking/arc.dev.networking.hub01.bicep' = {
  name: '${'architectdevNetworking_hub01_'}${currentDateTime}'
  scope: res_elz_networking_rg_hub01_name
  params:{
    location: deployment_location
    networking_Hub01:networking_Hub01
    networking_AzureFirewall:networking_AzureFirewall
    networking_deploy_VpnGateway:networking_deploy_VpnGateway
    networking_vpnGateway:networking_vpnGateway
    lxvm_hub_machine_name:lxvm_hub_machine_name
    lxvm_adminpass_hub:lxvm_adminpass_hub
    lxvm_adminuser_hub:lxvm_adminuser_hub
    lxvm_hub_nic_name:lxvm_hub_nic_name
    lxvm_hub_nsg_name:lxvm_hub_nsg_name
    lxvm_shutdown_name:lxvm_shutdown_name
    email_recipient:email_recipient
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
    networking_deploy_OnPrem_VpnGateway:networking_deploy_OnPrem_VpnGateway
    networking_OnPrem_conn:networking_OnPrem_conn
    networking_OnPrem_localNetworkGateway:networking_OnPrem_localNetworkGateway
    networking_OnPrem_vpnGateway:networking_OnPrem_vpnGateway
    networking_rg_hub_name:elz_networking_rg_hub01_name
    networking_vpnGateway:networking_vpnGateway
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
    networking_deploy_Hub01_VpnGateway:networking_deploy_Hub01_VpnGateway
    networking_Hub01_conn:networking_Hub01_conn
    networking_hub01_localNetworkGateway:networking_hub01_localNetworkGateway
    networking_OnPrem_vpnGateway:networking_OnPrem_vpnGateway
    networking_vpnGateway:networking_vpnGateway
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
    lxvm_adminpass_spk01:lxvm_adminpass_spk01
    lxvm_adminuser_spk01:lxvm_adminuser_spk01
    lxvm_shutdown_name:lxvm_shutdown_name_spoke
    lxvm_spk01_machine_name:lxvm_spk01_machine_name
    lxvm_spk01_nic_name:lxvm_spk01_nic_name
    lxvm_spk01_nsg_name:lxvm_spk01_nsg_name
    email_recipient:email_recipient_spoke
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
    mod_architecdev_Peering_Hub_spk01_deploy
    mod_architecprod_Peering_Hub_spk02_deploy
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
    mod_architecdev_Peering_Hub_spk01_deploy
    mod_architecprod_Peering_Hub_spk02_deploy
    mod_architectdev_Peering_Spok01_Deploy
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
    mandatoryTag1Value:'az-core-env'
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
