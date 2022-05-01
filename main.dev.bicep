/*
###################################################################################
######              AZURE CLOUD EXPERT SOLUTIONS ARCHITECT                    #####
######                        ENTERPRISE LANDING ZONE                         #####
######            a.palma@htmedica.com / 2022, March, 17th (creation)       #####  
######                           DEV - ENVIRONMENT                            #####
######                   MAIN BICEP DEPLOYMENT / MODULES                      #####
###################################################################################                
*/
/* Definición de parámetros de la implementación */
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

/*es un diccionario*/

/*en bicep se utiliza targetScope para que seleccione el scope */
/*importante: comando az cli hace referencia a sub*/
/*az deployment sub create --location northeurope --template-file .\main.dev.bicep*/

targetScope = 'subscription'

/*ahora se puede crear el grupo de recursos*/
resource res_elz_networking_rg_hub01 'Microsoft.Resources/resourceGroups@2021-01-01' = {
  name: elz_networking_rg_hub01_name
  location: deployment_location /* northeurope */
  tags: {
    'cor-ctx-environment': 'development'
    'cor-ctx-projectcode': 'Verne Technology - Curso Cloud Expert Solution Architect'
    'cor-ctx-purpose': 'Grupo de recursos para las redes del hub'
    'cor-aut-delete' : 'true'
  }
}

resource res_elz_storage_rg_hub01 'Microsoft.Resources/resourceGroups@2021-01-01' = {
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
resource res_elz_workloads_rg_spk01_name 'Microsoft.Resources/resourceGroups@2021-01-01' = {
  name: elz_workloads_rg_spk01_name
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
    'cor-ctx-purpose': 'Grupo de recursos para las redes del Spoke-01'
    'cor-aut-delete' : 'true'
  }
}
/*
resource res_elz_storage_rg_spk02_name 'Microsoft.Resources/resourceGroups@2021-01-01' = {
  name: elz_storage_rg_spk02_name
  location: deployment_location
  tags: {
    'cor-ctx-environment': 'development'
    'cor-ctx-projectcode': 'Verne Technology - Curso Cloud Expert Solution Architect'
    'cor-ctx-purpose': 'Grupo de recursos para las redes del Spoke-01'
    'cor-aut-delete' : 'true'
  }
}*/

resource res_elz_workloads_rg_spk02_name 'Microsoft.Resources/resourceGroups@2021-01-01' = {
  name: elz_workloads_rg_spk02_name
  location: deployment_location
  tags: {
    'cor-ctx-environment': 'development'
    'cor-ctx-projectcode': 'Verne Technology - Curso Cloud Expert Solution Architect'
    'cor-ctx-purpose': 'Grupo de recursos para las redes del Spoke-01'
    'cor-aut-delete' : 'true'
  }
}

/*modulo para poner fecha en el deployment UNA VEZ se haya creado la cuenta de almacenamiento*/
/*
module cesaDevStorageDataSvc_Deploy 'cesa.dev.st.datasvc.bicep' = {
  name: '${'cesaDevHubStorageDataSvc_'}${currentDateTime}'
  scope: res_elz_storage_rg_hub01
  // TO-DO: params dev/pro
}
*/

module cesaDevElz01_Networking_OnPrem_Deploy 'cesa.dev.networking.onprem.bicep' = {
  name: '${'cesaDevElz01Networking_OnPrem_'}${currentDateTime}'
  scope: res_elz_networking_rg_onprem_name
  // TO-DO: params dev/pro
}

module cesaDevElz01_Networking_Hub_Deploy 'cesa.dev.networking.hub01.bicep' = {
  name: '${'cesaDevElz01Networking_hub01_'}${currentDateTime}'
  scope: res_elz_networking_rg_hub01
  // TO-DO: params dev/pro
}

module cesaDevElz01_Networking_Spoke01_Deploy 'cesa.dev.networking.spk01.bicep' = {
  name: '${'cesaDevElz01Networking_spoke_01'}${currentDateTime}'
  scope: res_elz_networking_rg_spk01_name
}
