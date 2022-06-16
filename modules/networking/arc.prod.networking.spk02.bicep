//MODULE NETWORKING SPOKE 02 BICEP- AZURE ARCHITECT PROJECT

//PARAMS
param location string = resourceGroup().location
param networking_Spoke02 object 
param lxvm_spk02_nic_name string = 'nic-azarc-spk02-lxvmcheckcomms'
param lxvm_spk02_nsg_name string = 'nsg-azarc-spk02-lxvmcheckconns'
param lxvm_spk02_machine_name string = 'lxvmspk02netcheck'
param lxvm_adminuser_spk02 string = 'admin77'
param lxvm_adminpass_spk02 string = 'Pa$$w0rd-007.'
param lxvm_shutdown_name string = 'shutdown-computevm-lxvmspk02netcheck'
@description('Write an email address to receive notifications when vm is running at 22:00')
param email_recipient string = 'a.palma@htmedica.com'

@allowed([
  'Standard_B1ls'
  'Standard_B1ms'
  'Standard_B1s'
  'Standard_B2ms'
  'Standard_B2s'
  'Standard_B4ms'
  'Standard_B4s'
  'Standard_D2s_v3'
  'Standard_D4s_v3'
])

param vmsize string = 'Standard_B2s'

//RESOURCES
resource res_networking_Spk02 'Microsoft.Network/virtualNetworks@2020-05-01' = {
  name: networking_Spoke02.name
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        networking_Spoke02.addressPrefix
      ]
    }
    subnets: [
      {
        name: networking_Spoke02.subnetMangament
        properties: {
          addressPrefix: networking_Spoke02.subnetMangamentPrefix
        }
      }
      {
        name: networking_Spoke02.subnetFrontName
        properties: {
          addressPrefix: networking_Spoke02.subnetFrontPrefix
        }
      }
      {
        name: networking_Spoke02.subnetBackName
        properties: {
          addressPrefix: networking_Spoke02.subnetBackPrefix
        }
      }
    ]
  }
}

//LINUX VM FOR CONNECTION TESTING

 resource nicNameLinuxResource 'Microsoft.Network/networkInterfaces@2020-05-01' = {
  name: lxvm_spk02_nic_name
  location: location
  tags: {
    'az-core-env': 'Shared'
    ' az-core-costCenter ': '00123'
    'az-core-projectcode': 'BicepDeployment- Designing Microsoft Azure Infrastructure Solutions '
    'az-core-purpose': 'Nic VM Linux'
    'az-aut-delete' : 'true'
  }
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: '${res_networking_Spk02.id}/subnets/${networking_Spoke02.subnetMangament}'
          }
        }
      }
    ]
    networkSecurityGroup: {
      id: res_spk02_linuxVm_nsg.id
    }
  }
}

resource res_spk02_linuxVm_nsg 'Microsoft.Network/networkSecurityGroups@2020-06-01' = {
  name: lxvm_spk02_nsg_name
  location: location
  properties: {
    securityRules: [
      {
           name: 'SSH'
           properties : {
               protocol : 'Tcp' 
               sourcePortRange :  '*'
               destinationPortRange :  '22'
               sourceAddressPrefix :  '*'
               destinationAddressPrefix: '*'
               access:  'Allow'
               priority : 1010
               direction : 'Inbound'
               sourcePortRanges : []
               destinationPortRanges : []
               sourceAddressPrefixes : []
               destinationAddressPrefixes : []
          }
      }
      {
           name : 'HTTPS'
           properties : {
               protocol :  'Tcp'
               sourcePortRange :  '*'
               destinationPortRange :  '443'
               sourceAddressPrefix :  '*'
               destinationAddressPrefix :  '*'
               access :  'Allow'
               priority : 1020
               direction :  'Inbound'
               sourcePortRanges : []
               destinationPortRanges : []
               sourceAddressPrefixes : []
               destinationAddressPrefixes : []
          }
      }
      {
           name :  'Collector'
           properties : {
               protocol :  'Udp'
               sourcePortRange :  '*'
               destinationPortRange :  '3000'
               sourceAddressPrefix :  '*'
               destinationAddressPrefix :  '*'
               access :  'Allow'
               priority : 103
               direction :  'Inbound'
               sourcePortRanges : []
               destinationPortRanges : []
               sourceAddressPrefixes : []
               destinationAddressPrefixes : []
          }
      }
    ]
  }
}

resource vmNameLinuxResource 'Microsoft.Compute/virtualMachines@2019-07-01' = {
  name: lxvm_spk02_machine_name
  location: location
  properties: {
    hardwareProfile: {
      vmSize: vmsize
    }
    osProfile: {
      computerName: lxvm_spk02_machine_name
      adminUsername: lxvm_adminuser_spk02
      adminPassword: lxvm_adminpass_spk02
    }
    storageProfile: {
      imageReference: {
        publisher: 'Canonical'
        offer: 'UbuntuServer'
        sku: '16.04.0-LTS'
        version: 'latest'
      }
      osDisk: {
        createOption: 'FromImage'
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nicNameLinuxResource.id
        }
      ]
    }
  }
}

resource res_schedules_shutdown_computevm_vmNameWindowsResource 'microsoft.devtestlab/schedules@2018-09-15' = {
  name: lxvm_shutdown_name
  location: location
  properties: {
    status: 'Enabled'
    taskType: 'ComputeVmShutdownTask'
    dailyRecurrence: {
      time: '2200'
    }
    timeZoneId: 'Romance Standard Time'
    notificationSettings: {
      status: 'Enabled'
      timeInMinutes: 30
      emailRecipient: email_recipient
      notificationLocale: 'en'
    }
    targetResourceId: vmNameLinuxResource.id
  }
}
