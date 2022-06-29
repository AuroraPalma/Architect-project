//MODULE NETWORKING ON PREMISE BICEP- AZURE ARCHITECT PROJECT

//PARAMS
param location string = resourceGroup().location
/* /24 = 256 ips --> from 172.16.1.0 -to- 172.16.1.255 */
param networking_OnPremises object
param networking_deploy_OnPrem_VpnGateway bool
param networking_OnPrem_vpnGateway object
param lxvm_onprem_nic_name string
param lxvm_onprem_nsg_name string
param lxvm_onprem_machine_name string
param lxvm_adminuser_onprem string
param lxvm_adminpass_onprem string
param lxvm_shutdown_name string
@description('Write an email address to receive notifications when vm is running at 22:00')
param email_recipient string

//RESOURCES
resource res_networking_OnPremises 'Microsoft.Network/virtualNetworks@2020-05-01' = {
  name: networking_OnPremises.name
  location: location
  tags: {
    'az-core-env': 'Shared'
    'az-core-costCenter': '00123'
    'az-core-projectcode': 'BicepDeployment- Designing Microsoft Azure Infrastructure Solutions '
    'az-core-purpose': 'Networking On premise'
    'az-aut-delete' : 'true'
  }
  properties: {
    addressSpace: {
      addressPrefixes: [
        networking_OnPremises.addressPrefix
      ]
    }
    subnets: [
      {
        name: networking_OnPremises.subnetTransitName
        properties: {
          addressPrefix: networking_OnPremises.subnetTransit
        }
      }
      {
        name: networking_OnPrem_vpnGateway.subnetName
        properties: {
          addressPrefix: networking_OnPrem_vpnGateway.subnetPrefix
        }
      }
    ]
  }
}

resource res_networking_OnPrem_vpnGateway_pip 'Microsoft.Network/publicIPAddresses@2019-11-01' = if (networking_deploy_OnPrem_VpnGateway) {
  name: networking_OnPrem_vpnGateway.pipName
  location: location
  tags: {
    'az-core-env': 'Shared'
    'az-core-costCenter': '00123'
    'az-core-projectcode': 'BicepDeployment- Designing Microsoft Azure Infrastructure Solutions '
    'az-core-purpose': 'Networking On premise'
    'az-aut-delete' : 'true'
  }  
  properties: {
    publicIPAllocationMethod: 'Dynamic'
  }
}

resource res_networking_OnPrem_vpnGateway 'Microsoft.Network/virtualNetworkGateways@2019-11-01' = if (networking_deploy_OnPrem_VpnGateway) {
  name: networking_OnPrem_vpnGateway.name
  location: location
  tags: {
    'az-core-env': 'Shared'
    'az-core-costCenter': '00123'
    'az-core-projectcode': 'BicepDeployment- Designing Microsoft Azure Infrastructure Solutions '
    'az-core-purpose': 'Networking On premise'
    'az-aut-delete' : 'true'
  }
  properties: {
    ipConfigurations: [
      {
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: resourceId('Microsoft.Network/virtualNetworks/subnets', networking_OnPremises.name, networking_OnPrem_vpnGateway.subnetName)
          }
          publicIPAddress: {
            id: res_networking_OnPrem_vpnGateway_pip.id
          }
        }
        name: 'vnetGatewayConfig'
      }
    ]
    sku: {
      name:  'Basic'
      tier:  'Basic'
    }
    gatewayType: 'Vpn'
    vpnType: 'RouteBased'
    enableBgp: false
  }
  dependsOn: [
    res_networking_OnPremises
  ]
}

//Linux VM for connection testing

 resource nicNameLinuxResource 'Microsoft.Network/networkInterfaces@2020-05-01' = {
  name: lxvm_onprem_nic_name
  location: location
  tags: {
    'az-core-env': 'Shared'
    'az-core-costCenter': '00123'
    'az-core-projectcode': 'BicepDeployment- Designing Microsoft Azure Infrastructure Solutions '
    'az-core-purpose': 'Networking On premise'
    'az-aut-delete' : 'true'
  }
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: '${res_networking_OnPremises.id}/subnets/${networking_OnPremises.subnetTransitName}'
          }
        }
      }
    ]
    networkSecurityGroup: {
      id: res_onprem_linuxVm_nsg.id
    }
  }
}

resource res_onprem_linuxVm_nsg 'Microsoft.Network/networkSecurityGroups@2020-06-01' = {
  name: lxvm_onprem_nsg_name
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
  name: lxvm_onprem_machine_name
  location: location
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_B4ms'
    }
    osProfile: {
      computerName: lxvm_onprem_machine_name
      adminUsername: lxvm_adminuser_onprem
      adminPassword: lxvm_adminpass_onprem
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

