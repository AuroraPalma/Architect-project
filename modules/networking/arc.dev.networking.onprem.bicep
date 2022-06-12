//MODULE NETWORKING ON PREMISE BICEP- AZURE ARCHITECT PROJECT

//PARAMS
param location string = resourceGroup().location
/* /24 = 256 ips --> from 172.16.1.0 -to- 172.16.1.255 */
param networking_OnPremises object = {
  name: 'vnet-azarc-onpremises01'
  addressPrefix: '172.16.1.0/24'
  subnetTransitName: 'snet-onprem-transit'
  subnetTransit: '172.16.1.0/26'
}

param networking_deploy_OnPrem_VpnGateway bool = true

param networking_OnPrem_vpnGateway object = {
  name: 'vgw-azarc-onprem-vgw01'
  subnetName: 'GatewaySubnet'
  subnetPrefix: '172.16.1.64/29'
  pipName: 'pip-azarc-onprem-vgw01'
}

//RESOURCES
resource res_networking_OnPremises 'Microsoft.Network/virtualNetworks@2020-05-01' = {
  name: networking_OnPremises.name
  location: location
  tags: {
    'Env': 'Infrastructure'
    'CostCenter': '00123'
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
    'Env': 'Infrastructure'
    'CostCenter': '00123'
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
    'Env': 'Infrastructure'
    'CostCenter': '00123'
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

resource res_linuxVm_OnPrem_pip 'Microsoft.Network/publicIPAddresses@2019-11-01' = if (networking_deploy_OnPrem_VpnGateway) {
  name: 'pip-azarc-onprem-lxvm1'
  location: location
  tags: {
    'Env': 'Infrastructure'
    'CostCenter': '00123'
    'az-core-projectcode': 'BicepDeployment- Designing Microsoft Azure Infrastructure Solutions '
    'az-core-purpose': 'Networking On premise'
    'az-aut-delete' : 'true'
  }  
  properties: {
    publicIPAllocationMethod: 'Dynamic'
    publicIPAddressVersion: 'IPv4'
    dnsSettings: {
      domainNameLabel: 'lxvmarchitectonpremconncheck'
    }
    idleTimeoutInMinutes: 4
  }
  sku: {
    name: 'Basic'
  }
}

 resource nicNameLinuxResource 'Microsoft.Network/networkInterfaces@2020-05-01' = {
  name: 'nic-azarc-onprem-lxvmcheckcomms'
  location: location
  tags: {
    'Env': 'Infrastructure'
    'CostCenter': '00123'
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
          publicIPAddress: {
            id: res_linuxVm_OnPrem_pip.id
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
  name: 'nsg-azarc-onprem-lxvmcheckcomms'
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
  name: 'lxvmonpnetcheck'
  location: location
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_B4ms'
    }
    osProfile: {
      computerName: 'lxvmonpnetcheck'
      adminUsername: 'admin77'
      adminPassword: 'Pa$$w0rd-007.'
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
  name: 'shutdown-computevm-lxvmonpnetcheck'
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
      emailRecipient: 'a.palma@htmedica.com'
      notificationLocale: 'en'
    }
    targetResourceId: vmNameLinuxResource.id
  }
}

