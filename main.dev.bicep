/*
###################################################################################
######              AZURE CLOUD EXPERT SOLUTIONS ARCHITECT                    #####
######                        ENTERPRISE LANDING ZONE                         #####
######            a.palma@htmedica.com / 2022, March, 17th (creation)       #####  
######                           DEV - ENVIRONMENT                            #####
######                   MAIN BICEP DEPLOYMENT / MODULES                      #####
###################################################################################                
*/
/* Definición de parámetros de la implementación 
Poner variables y ponerlo con descripciones*/
param elz_networking_rg_hub01_name string = 'rg-cesa-elz01-hub01-networking-01'
param elz_storage_rg_hub01_name string = 'rg-cesa-elz01-hub01-st-01'
param deployment_location string = deployment().location
param currentDateTime string = utcNow()
param elz_networking_rg_onprem_name string = 'rg-cesa-onprem-networking-01'
param elz_networking_rg_spk01_name string = 'rg-cesa-elz01-spk01-networking-01'
/* param elz_storage_rg_spk01_name string = 'rg-cesa-elz01-spk01-st-01' */
param elz_workloads_rg_spk01_name string = 'rg-cesa-elz01-spk01-wkls01_01'
param elz_networking_rg_spk02_name string = 'rg-cesa-elz01-spk02-networking-01'
/* param elz_storage_rg_spk02_name string = 'rg-cesa-elz01-spk02-st-01'*/
param elz_workloads_rg_spk02_name string = 'rg-cesa-elz01-spk02-wkls01_01'
param elz_log_analytics_rg_name string = 'rg-arc-analytics_01'
param elz_alerts_monitor_rg_name string = 'rg-alerts-monitor-dev-01'

targetScope = 'subscription'


resource res_elz_networking_rg_hub01_name 'Microsoft.Resources/resourceGroups@2021-01-01' = {
  name: elz_networking_rg_hub01_name
  location: deployment_location /* northeurope */
  tags: {
    'cor-ctx-environment': 'development'
    'cor-ctx-projectcode': 'Verne Technology - Curso Cloud Expert Solution Architect'
    'cor-ctx-purpose': 'Grupo de recursos para las redes del hub'
    'cor-aut-delete' : 'true'
  }
}

resource res_elz_storage_rg_hub01_name 'Microsoft.Resources/resourceGroups@2021-01-01' = {
  name: elz_storage_rg_hub01_name
  location: deployment_location
  tags: {
    'cor-ctx-environment': 'development'
    'cor-ctx-projectcode': 'Verne Technology - Curso Cloud Expert Solution Architect'
    'cor-ctx-purpose': 'Grupo de recursos para las cuentas de almacenamiento del hub'
    'cor-aut-delete' : 'true'
  }
}

resource res_elz_networking_rg_onprem_name 'Microsoft.Resources/resourceGroups@2021-01-01' = {
  name: elz_networking_rg_onprem_name
  location: deployment_location
  tags: {
    'cor-ctx-environment': 'development'
    'cor-ctx-projectcode': 'Verne Technology - Curso Cloud Expert Solution Architect'
    'cor-ctx-purpose': 'Grupo de recursos para las redes que simulan on-premises'
    'cor-aut-delete' : 'true'
  }
  dependsOn: [
    res_elz_networking_rg_hub01_name
  ]
}

resource res_elz_networking_rg_spk01_name 'Microsoft.Resources/resourceGroups@2021-01-01' = {
  name: elz_networking_rg_spk01_name
  location: deployment_location
  tags: {
    'cor-ctx-environment': 'development'
    'cor-ctx-projectcode': 'Verne Technology - Curso Cloud Expert Solution Architect'
    'cor-ctx-purpose': 'Grupo de recursos para las redes del Spoke-01'
    'cor-aut-delete' : 'true'
  }
}

resource res_elz_networking_rg_spk02_name 'Microsoft.Resources/resourceGroups@2021-01-01' = {
  name: elz_networking_rg_spk02_name
  location: deployment_location
  tags: {
    'cor-ctx-environment': 'development'
    'cor-ctx-projectcode': 'Verne Technology - Curso Cloud Expert Solution Architect'
    'cor-ctx-purpose': 'Grupo de recursos para las redes del Spoke-02'
    'cor-aut-delete' : 'true'
  }
}

resource res_elz_workloads_rg_spk01_name 'Microsoft.Resources/resourceGroups@2021-01-01' = {
  name: elz_workloads_rg_spk01_name
  location: deployment_location
  tags: {
    'cor-ctx-environment': 'development'
    'cor-ctx-projectcode': 'Verne Technology - Curso Cloud Expert Solution Architect'
    'cor-ctx-purpose': 'Grupo de recursos para los recursos de las cargas de trabajo del Spoke01'
    'cor-aut-delete' : 'true'
  }
}

resource res_elz_workloads_rg_spk02_name 'Microsoft.Resources/resourceGroups@2021-01-01' = {
  name: elz_workloads_rg_spk02_name
  location: deployment_location
  tags: {
    'cor-ctx-environment': 'development'
    'cor-ctx-projectcode': 'Verne Technology - Curso Cloud Expert Solution Architect'
    'cor-ctx-purpose': 'Grupo de recursos para los recursos de las cargas de trabajo del Spoke02'
    'cor-aut-delete' : 'true'
  }
}

resource res_elz_log_analytics_rg_name 'Microsoft.Resources/resourceGroups@2021-01-01' = {
  name: elz_log_analytics_rg_name
  location:deployment_location
  tags:{
    'cor-aut-delete' : 'true'
  }
}

resource res_elz_alerts_monitor_rg_name 'Microsoft.Resources/resourceGroups@2021-01-01' = {
  name: elz_alerts_monitor_rg_name
  location: deployment_location
  tags:{
    'cor-aut-delete' : 'true'
  }
}
module mod_cesaDevElz01_Networking_OnPrem_Deploy 'modules/networking/cesa.dev.networking.onprem.bicep' = {
  name: '${'cesaDevElz01Networking_OnPrem_'}${currentDateTime}'
  scope: res_elz_networking_rg_onprem_name
  params:{
    location: deployment_location
  }
  // TO-DO: params dev/pro
}

module mod_cesaDevElz01_Networking_Hub_Deploy 'modules/networking/cesa.dev.networking.hub01.bicep' = {
  name: '${'cesaDevElz01Networking_hub01_'}${currentDateTime}'
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
    mod_cesaDevElz01_Networking_Hub_Deploy
  ]
}

module mod_cesaDevElz01_Vnet2Vnet_OnPrem_Conn_Deploy 'modules/networking/cesa.dev.networking.OnPrem.Vnet2VnetCon.bicep' = {
  name: '${'cesaDevElz01Net_Vnet2Vnet_Conn_'}${currentDateTime}'
  scope: res_elz_networking_rg_onprem_name
  params:{
    location: deployment_location
  }
  dependsOn:[
    mod_cesaDevElz01_Networking_OnPrem_Deploy
  ]
}

module mod_cesaDevElz01_Vnet2Vnet_Hub_Conn_Deploy 'modules/networking/cesa.dev.networking.Hub.Vnet2VnetCon.bicep' = {
  name: '${'cesaDevElz01Net_Vnet2Vnet_Hub_Conn_'}${currentDateTime}'
  scope: res_elz_networking_rg_hub01_name
  params:{
    location: deployment_location
  }
  dependsOn:[
    mod_cesaDevElz01_Networking_Hub_Deploy
  ]
}

module mod_cesaDevElz01_Networking_Spk01_Deploy 'modules/networking/cesa.dev.networking.spk01.bicep' = {
  name: '${'cesaDevElz01Networking_Spk01_'}${currentDateTime}'
  scope: res_elz_networking_rg_spk01_name
  params:{
    location: deployment_location
  }
  // TO-DO: params dev/pro
}
module mod_cesaDevElz01_Networking_Spk02_Deploy 'modules/networking/cesa.dev.networking.spk02.bicep' = {
  name: '${'cesaDevElz01Networking_Spk02_'}${currentDateTime}'
  scope: res_elz_networking_rg_spk02_name
  params:{
    location: deployment_location
  }
  // TO-DO: params dev/pro
}

/*Log analytics*/
module mod_architect_devLoganalytics_Hub_Deploy 'modules/arc.dev.loganalytics.bicep' = {
  name: '${'architectDevLoganalytics_Hub_'}${currentDateTime}'
  scope: res_elz_log_analytics_rg_name
  params:{
    location:deployment_location
  }
}
/*Azure Policy*/

module mod_architect_dev_Policies_Deploy 'modules/policy.bicep' = {
  name:'${'architectDevPolicies_general_'}${currentDateTime}'
  params:{
    listOfAllowedLocations: [
      'northeurope'
      'westeurope'
    ]
  }
}

module mod_architect_dev_Alerts_Deploy 'modules/alertrule.monitor.bicep' = {
  name:'${'architectDevAlerts_Monitor_'}${currentDateTime}'
  scope: res_elz_alerts_monitor_rg_name
}
/*
module mod_architectdev_KeyVault_Hub_Deploy 'modules/arc.dev.keyvault.bicep' = {
  name: '${'architectdevKeyvault_Hub_'}${currentDateTime}'
  scope: res_elz_networking_rg_hub01_name
  params:{
    location:deployment_location
  }
}

module mod_cesaDev_Workload_spk01_Deploy 'modules/cesa.dev.worload.spk.bicep' = {
  name: '${'cesadevworkload_Spk01_'}${currentDateTime}'
  scope: res_elz_workloads_rg_spk01_name
  params:{
    location:deployment_location
  }
}
*/
