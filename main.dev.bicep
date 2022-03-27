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
param elz_storage_rg_hub01_name string = 'rg-cesa-elz01-hub01-storage-01'
param deployment_location string = deployment().location
param currentDateTime string = utcNow()

param elz_ntw_hubNetwork object = {
  name: 'vnet-cesa-elz-hub01'
  addressPrefix: '10.0.0.0/20'
}
/*es un diccionario*/

/*en bicep se utiliza targetScope para que seleccione el scope */
/*importante: comando az cli hace referencia a sub*/
/*az deployment sub create --location northeurope --template-file .\main.dev.bicep*/

targetScope = 'subscription'

/*ahora se puede crear el grupo de recursos*/

resource elz_networking_rg_hub01 'Microsoft.Resources/resourceGroups@2021-01-01' = {
  name: elz_networking_rg_hub01_name
  location: deployment_location
}

resource elz_storage_rg_hub01 'Microsoft.Resources/resourceGroups@2021-01-01' = {
  name: elz_storage_rg_hub01_name
  location: deployment_location
}
/*modulo para poner fecha en el deployment UNA VEZ se haya creado la cuenta de almacenamiento*/
/*module cesaDevStorageDataSvc_Deploy 'cesa.dev.st.datasvc.bicep' = {
  name: '${'cesaDevHubStorageDataSvc_'}${currentDateTime}'
  scope: elz_storage_rg_hub01
  // TO-DO: params dev/pro
}
*/


