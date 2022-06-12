//MODULE NETWORKING SPOKE 01 BICEP- AZURE ARCHITECT PROJECT

//PARAMS
param location string = resourceGroup().location

/* /22 = 1000 ips --> from 10.1.0.0 -to- 10.1.3.255 */
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

param networking_Hub01 object = {
  name: 'vnet-azarc-hub01'
  addressPrefix: '10.0.1.0/24'
  subnetTransitName: 'snet-hub01-transit'
  subnetTransit: '10.0.1.80/29'
}

param per_spk01_name string = 'per-azarc-hub01-to-spk01'
param networking_rg_hub01_name string = 'rg-azarc-hub-networking-01'
param lxvm_spk01_pip_name string = 'pip-azarc-spk01-lxvm01'
param lxvm_spk01_nic_name string = 'nic-azarc-spk01-lxvmcheckcomms'
param lxvm_spk01_nsg_name string = 'nsg-azarc-spk01-lxvmcheckconns'
param lxvm_spk01_machine_name string = 'lxvmspk01netcheck'
param lxvm_adminuser_spk01 string = 'admin77'
param lxvm_adminpass_spk01 string = 'Pa$$w0rd-007.'
param lxvm_shutdown_name string = 'shutdown-computevm-lxvmspk01netcheck'
@description('Write an email address to receive notifications when vm is running at 22:00')
param email_recipient string = 'a.palma@htmedica.com'
//RESOURCES
resource res_networking_Spk01 'Microsoft.Network/virtualNetworks@2020-05-01' = {
  name: networking_Spoke01.name
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        networking_Spoke01.addressPrefix
      ]
    }
    subnets: [
      {
        name: networking_Spoke01.subnetMangament
        properties: {
          addressPrefix: networking_Spoke01.subnetMangamentPrefix
        }
      }
      {
        name: networking_Spoke01.subnetFrontName
        properties: {
          addressPrefix: networking_Spoke01.subnetFrontPrefix
        }
      }
      {
        name: networking_Spoke01.subnetBackName
        properties: {
          addressPrefix: networking_Spoke01.subnetBackPrefix
        }
      }
    ]
  }
}

//LINUX VM FOR CONNECTION TESTING

resource res_linuxVm_spk01_pip 'Microsoft.Network/publicIPAddresses@2019-11-01' = {
  name: lxvm_spk01_pip_name
  location: location
  tags: {
    'Env': 'Infrastructure'
    'CostCenter': '00123'
    'az-core-projectcode': 'BicepDeployment- Designing Microsoft Azure Infrastructure Solutions '
    'az-core-purpose': 'Connectivity Check'
    'az-aut-delete' : 'true'
  }  
  properties: {
    publicIPAllocationMethod: 'Dynamic'
    publicIPAddressVersion: 'IPv4'
    dnsSettings: {
      domainNameLabel: 'lxvmarchitecturespk01conncheck'
    }
    idleTimeoutInMinutes: 4
  }
  sku: {
    name: 'Basic'
  }
}

 resource nicNameLinuxResource 'Microsoft.Network/networkInterfaces@2020-05-01' = {
  name: lxvm_spk01_nic_name
  location: location
  tags: {
    'Env': 'Infrastructure'
    'CostCenter': '00123'
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
            id: '${res_networking_Spk01.id}/subnets/${networking_Spoke01.subnetMangament}'
          }
          publicIPAddress: {
            id: res_linuxVm_spk01_pip.id
          }
        }
      }
    ]
    networkSecurityGroup: {
      id: res_spk01_linuxVm_nsg.id
    }
  }
}

resource res_spk01_linuxVm_nsg 'Microsoft.Network/networkSecurityGroups@2020-06-01' = {
  name: lxvm_spk01_nsg_name
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
  name: lxvm_spk01_machine_name
  location: location
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_B4ms'
    }
    osProfile: {
      computerName: lxvm_spk01_machine_name
      adminUsername: lxvm_adminuser_spk01
      adminPassword: lxvm_adminpass_spk01
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

//PEERINGS HUB - SPOKES

resource res_networking_Hub01_Vnet 'Microsoft.Network/virtualNetworks@2020-05-01' existing = {
  name: networking_Hub01.name
  scope: resourceGroup(networking_rg_hub01_name)
}

resource res_peering_Spk01_2_Hub01  'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2020-06-01' = {
  name: '${res_networking_Spk01.name}/${per_spk01_name}'
  properties: {
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    allowGatewayTransit: false
    useRemoteGateways: false
    remoteVirtualNetwork: {
      id: res_networking_Hub01_Vnet.id
    }
  }
}


