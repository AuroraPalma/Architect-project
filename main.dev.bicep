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
param email_recipient_spk01 string = 'a.palma@htmedica.com'
param lxvm_spk02_nic_name string = 'nic-azarc-spk02-lxvmcheckcomms'
param lxvm_spk02_nsg_name string = 'nsg-azarc-spk02-lxvmcheckconns'
param lxvm_spk02_machine_name string = 'lxvmspk02netcheck'
param lxvm_adminuser_spk02 string = 'admin77'
param lxvm_adminpass_spk02 string = 'Pa$$w0rd-007.'
param lxvm_shutdown_name_spk02 string = 'shutdown-computevm-lxvmspk02netcheck'
@description('Write an email address to receive notifications when vm is running at 22:00')
param email_recipient_spk02 string = 'a.palma@htmedica.com'

//ALERT RULE PARAMS
param subscriptionid string = '/subscriptions/4c81b137-e05f-43f5-a271-e5a7c3ce6f74'
param activityLogAlerts_Alert_new_user_name string = 'Alert new user'
param activityLogAlerts_Delete_subscription_name string = 'Delete subscription'
param activityLogAlerts_Certificate_Key_vault_alert_name string = 'Certificate Key vault alert'
param activityLogAlerts_Policy_Definition_Alert_name string = 'Policy Definition Alert'
param activityLogAlerts_Policy_Tenant_alert_name string = 'Policy Tenant alert'
param field_category_name string = 'category'
param field_equals_name string = 'Administrative'
param field_operation_name string = 'operationName'

//BASTION PARAMS

@description('Virtual network name')
param vnetName string = networking_Hub01.name

@description('The address prefix to use for the Bastion subnet')
param addressPrefix string = '10.0.1.64/29'

@description('The name of the Bastion public IP address')
param publicIpName string = 'pip-hub01-bastion-01'

@description('The name of the Bastion host')
param bastionHostName string = 'bas-azarc-hub01-bastion-shared-01'

//KEY VAULT PARAMS

@description('Specifies the name of the key vault.')
param keyVaultName string = 'kvault-azarc-hub01-01'

@description('Specifies whether Azure Virtual Machines are permitted to retrieve certificates stored as secrets from the key vault.')
param enabledForDeployment bool = true

@description('Specifies whether Azure Disk Encryption is permitted to retrieve secrets from the vault and unwrap keys.')
param enabledForDiskEncryption bool = true

@description('Specifies whether Azure Resource Manager is permitted to retrieve secrets from the key vault.')
param enabledForTemplateDeployment bool = true

@description('Specifies the Azure Active Directory tenant ID that should be used for authenticating requests to the key vault. Get it by using Get-AzSubscription cmdlet.')
param tenantId string = subscription().tenantId

@description('Specifies the object ID of a user, service principal or security group in the Azure Active Directory tenant for the vault. The object ID must be unique for the list of access policies. Get it by using Get-AzADUser or Get-AzADServicePrincipal cmdlets.')
param objectId string = 'cd6fd6f1-a0c4-4402-8e74-dee66ddf5485'

@description('Specifies the permissions to keys in the vault. Valid values are: all, encrypt, decrypt, wrapKey, unwrapKey, sign, verify, get, list, create, update, import, delete, backup, restore, recover, and purge.')
param keysPermissions array = [
  'all'
]

@description('Specifies the permissions to secrets in the vault. Valid values are: all, get, list, set, delete, backup, restore, recover, and purge.')
param secretsPermissions array = [
  'all'
]

@description('Specifies whether the key vault is a standard vault or a premium vault.')
@allowed([
  'standard'
  'premium'
])
param skuName string = 'standard'

@description('Specifies the name of the secret that you want to create.')
param secretName string = 'lxm-password-datascience-spk01'
param secretName_shared string = 'lxm-password-shared-hubonprem01'

//LOG ANALYTICS PARAMS
//Dev
@description('Name of the workspace.')
param workspaceName string = 'lg-azarc-analytics-hub01-001'

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
@description('Number of days to retain data.')
param retentionInDays int = 30

//STORAGE PARAMS

@minLength(3)
@maxLength(24)
param storageAccountName string = 'stazarcaccountshared01'
@allowed([
  'Standard_LRS'
  'Standard_GRS'
  'Standard_RAGRS'
  'Standard_ZRS'
  'Premium_LRS'
  'Premium_ZRS'
  'Standard_GZRS'
  'Standard_RAGZRS'
])
param storageSKU string = 'Standard_LRS'

//Prod
@description('Name of the workspace.')
param workspaceName_prod string = 'lg-azarc-analytics-prod-001'

//WORKLOAD
//SPOKE 01 DEV PARAMS 

@description('The secondary replica region for the Cosmos DB account.')
param secondaryRegion string = 'westeurope'

@allowed([
  'Eventual'
  'ConsistentPrefix'
  'Session'
  'BoundedStaleness'
  'Strong'
])
@description('The default consistency level of the Cosmos DB account.')
param defaultConsistencyLevel string = 'Session'

@minValue(10)
@maxValue(2147483647)
@description('Max stale requests. Required for BoundedStaleness. Valid ranges, Single Region: 10 to 1000000. Multi Region: 100000 to 1000000.')
param maxStalenessPrefix int = 100000

@minValue(5)
@maxValue(86400)
@description('Max lag time (minutes). Required for BoundedStaleness. Valid ranges, Single Region: 5 to 84600. Multi Region: 300 to 86400.')
param maxIntervalInSeconds int = 300

@allowed([
  true
  false
])
@description('Enable automatic failover for regions')
param automaticFailover bool = true

@description('The name for the database')
param databaseName string = 'Db-cosmos-dev-data-001'

@description('The name for the container')
param containerName string = 'dataingestioncosmos'

@minValue(400)
@maxValue(1000000)
@description('The throughput for the container')
param throughput int = 400

@description('Username for Administrator Account')
param adminUsername string = 'vmadmin'

@description('The name of you Virtual Machine.')
param vmName string = 'lxvm-data-science-dev'

@description('Choose between CPU or GPU processing')
@allowed([
  'CPU-4GB'
  'CPU-7GB'
  'CPU-8GB'
  'CPU-14GB'
  'CPU-16GB'
  'GPU-56GB'
])
param cpu_gpu string = 'CPU-4GB'

@description('Name of the Network Security Group')
param networkSecurityGroupName string = 'nsg-lxm-data-science-networking-01'

@description('SSH Key or password for the Virtual Machine. SSH key is recommended.')
@secure()
param adminPasswordOrKey string
param storageSKU_spoke string = 'Standard_LRS'
@description('Nombre de la aplicación o proyecto - Prefijo para el nombre de los recursos')
param resourceName string = 'lxvm-data-science-dev'

//SPOKE 02 PROD PARAMS
@description('The name for the database')
param databaseName_p string = 'Db-cosmos-prod-data-001'

@description('The name for the container')
param containerName_p string = 'dataingestioncosmos'

@description('Username for Administrator Account')
param adminUsername_p string = 'vmadmin'

@description('The name of you Virtual Machine.')
param vmName_p string = 'lxvm-azarc-science-prod-001'

@description('Choose between CPU or GPU processing')
@allowed([
  'CPU-4GB'
  'CPU-7GB'
  'CPU-8GB'
  'CPU-14GB'
  'CPU-16GB'
  'GPU-56GB'
])
param cpu_gpu_p string = 'CPU-4GB'

param log_analytics_rg_name string = 'rg-azarc-analytics-monitor-01'
@description('Name of the Network Security Group')
param networkSecurityGroupName_p string = 'nsg-lxm-azarc-science-networking-02'

@description('Type of authentication to use on the Virtual Machine. SSH key is recommended.')
@allowed([
  'sshPublicKey'
  'password'
])
param authenticationType string = 'password'

@description('SSH Key or password for the Virtual Machine. SSH key is recommended.')
@secure()
param adminPasswordOrKey_p string
param storageSKU_p string = 'Standard_LRS'
@description('Nombre de la aplicación o proyecto - Prefijo para el nombre de los recursos')
param resourceName_p string = 'lxvm-data-science-prod'

//SCOPE
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
    addressPrefix:addressPrefix
    vnetName:vnetName
    bastionHostName:bastionHostName
    publicIpName:publicIpName
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
    email_recipient:email_recipient_spk01
  }
}
module mod_architectprod_Networking_Spk02_Deploy 'modules/networking/arc.prod.networking.spk02.bicep' = {
  name: '${'architectprodNetworking_Spk02_'}${currentDateTime}'
  scope: res_elz_networking_rg_spk02_name
  params:{
    location: deployment_location
    networking_Spoke02:networking_Spoke02
    lxvm_adminpass_spk02:lxvm_adminpass_spk02
    lxvm_adminuser_spk02:lxvm_adminuser_spk02
    lxvm_shutdown_name:lxvm_shutdown_name_spk02
    lxvm_spk02_machine_name:lxvm_spk02_machine_name
    lxvm_spk02_nic_name:lxvm_spk02_nic_name
    lxvm_spk02_nsg_name:lxvm_spk02_nsg_name
    email_recipient:email_recipient_spk02
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
    sku:sku
    retentionInDays:retentionInDays
    workspaceName:workspaceName
  }
}

module mod_architectprod_Loganalytics_Deploy 'modules/arc.prod.loganalytics.bicep' = {
  name: '${'architectprodLoganalytics_'}${currentDateTime}'
  scope: res_elz_log_analytics_rg_name
  params:{
    location:deployment_location
    sku:sku
    workspaceName:workspaceName_prod
    retentionInDays:retentionInDays
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
  params:{
    activityLogAlerts_Alert_new_user_name:activityLogAlerts_Alert_new_user_name
    activityLogAlerts_Certificate_Key_vault_alert_name:activityLogAlerts_Certificate_Key_vault_alert_name
    activityLogAlerts_Delete_subscription_name:activityLogAlerts_Delete_subscription_name
    activityLogAlerts_Policy_Definition_Alert_name:activityLogAlerts_Policy_Definition_Alert_name
    activityLogAlerts_Policy_Tenant_alert_name:activityLogAlerts_Policy_Tenant_alert_name
    field_category_name:field_category_name
    field_equals_name:field_equals_name
    field_operation_name:field_operation_name
    subscriptionid:subscriptionid
  }
}

module mod_architectdev_KeyVault_Hub_Deploy 'modules/arc.dev.keyvault.bicep' = {
  name: '${'architectdevKeyvault_Hub_'}${currentDateTime}'
  scope: res_elz_networking_rg_hub01_name
  params:{
    location:deployment_location
    secretValue: 'usr$Am1n-2223'
    secretValue_shared: 'Pa$$w0rd-007.'
    enabledForDeployment:enabledForDeployment
    enabledForDiskEncryption:enabledForDiskEncryption
    enabledForTemplateDeployment:enabledForTemplateDeployment
    keysPermissions:keysPermissions
    keyVaultName:keyVaultName
    objectId:objectId
    secretName:secretName
    secretName_shared:secretName_shared
    secretsPermissions:secretsPermissions
    skuName:skuName
    tenantId:tenantId
  }
}

module mod_architectdev_storage_Hub_Deploy 'modules/arc.dev.st.datasvc.bicep' = {
  name: '${'architectdevstorage_Hub_'}${currentDateTime}'
  scope: res_elz_storage_rg_hub01_name
  params: {
    location: deployment_location
    storageAccountName:storageAccountName
    storageSKU:storageSKU
  }
}
module mod_architectdev_Workload_spk01_Deploy 'modules/arc.dev.worload.spk.bicep' = {
  name: '${'architectdevworkload_Spk01_'}${currentDateTime}'
  scope: res_elz_workloads_rg_spk01_name
  params:{
    location:deployment_location
    networking_Spoke01:networking_Spoke01
    adminPasswordOrKey: 'usr$Am1n-2223'
    adminUsername:adminUsername
    automaticFailover:automaticFailover
    containerName:containerName
    cpu_gpu:cpu_gpu
    databaseName:databaseName
    defaultConsistencyLevel:defaultConsistencyLevel
    elz_networking_rg_spk01_name:elz_networking_rg_spk01_name
    maxIntervalInSeconds:maxIntervalInSeconds
    maxStalenessPrefix:maxStalenessPrefix
    networkSecurityGroupName:networkSecurityGroupName
    resourceName:resourceName
    secondaryRegion:secondaryRegion
    storageSKU:storageSKU_spoke
    throughput:throughput
    vmName:vmName
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
    elz_networking_rg_spk02_name:elz_networking_rg_spk02_name
    adminUsername:adminUsername_p
    automaticFailover:automaticFailover
    containerName:containerName_p
    cpu_gpu:cpu_gpu_p
    databaseName:databaseName_p
    defaultConsistencyLevel:defaultConsistencyLevel
    log_analytics_rg_name:elz_log_analytics_rg_name
    maxIntervalInSeconds:maxIntervalInSeconds
    maxStalenessPrefix:maxStalenessPrefix
    networkSecurityGroupName:networkSecurityGroupName_p
    resourceName:resourceName_p
    secondaryRegion:secondaryRegion
    storageSKU:storageSKU_p
    throughput:throughput
    vmName:vmName_p
  }
  dependsOn:[
    mod_architectprod_Networking_Spk02_Deploy
    mod_architectprod_Loganalytics_Deploy
  ]
}
