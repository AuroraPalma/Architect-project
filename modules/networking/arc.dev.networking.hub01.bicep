//MODULE NETWORKING HUB BICEP- AZURE ARCHITECT PROJECT

//PARAMS
param location string = resourceGroup().location
/* /24 = 256 ips --> from 10.0.1.0 -to- 10.0.1.255 */
param networking_Hub01 object = {
  name: 'vnet-azarc-hub01'
  addressPrefix: '10.0.1.0/24'
  subnetTransitName: 'snet-hub01-transit'
  subnetTransit: '10.0.1.80/29'
}

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
  subnetFrontName: 'snet-spk01-front'
  subnetFrontPrefix: '10.2.0.0/25'
  subnetBackName: 'snet-spk01-back'
  subnetBackPrefix: '10.2.0.128/25'

}

param networking_deploy_VpnGateway bool = true

param networking_AzureFirewall object = {
  name: 'afw-azarc-firewall01'
  publicIPAddressName: 'pip-azarc-afw01'
  subnetName: 'AzureFirewallSubnet'
  subnetPrefix: '10.0.1.0/26' /* 10.0.1.0 -> 10.0.1.63 */
  routeName: 'udr-azarc-nxthop-to-fw'
}

param networking_vpnGateway object = {
  name: 'vgw-azarc-hub01-vgw01'
  subnetName: 'GatewaySubnet'
  subnetPrefix: '10.0.1.72/29'
  pipName: 'pip-azarc-hub01-vgw01'
}

//RESOURCES
resource res_networking_Hub01 'Microsoft.Network/virtualNetworks@2020-05-01' = {
  name: networking_Hub01.name
  location: location
  tags: {
    'Env': 'Infrastructure'
    'CostCenter': '00123'
    'az-core-projectcode': 'BicepDeployment- Designing Microsoft Azure Infrastructure Solutions '
    'az-core-purpose': 'Networking Hub'
    'az-aut-delete' : 'true'
  }
  properties: {
    addressSpace: {
      addressPrefixes: [
        networking_Hub01.addressPrefix
      ]
    }
    subnets: [
      {
        name: networking_AzureFirewall.subnetName
        properties: {
          addressPrefix: networking_AzureFirewall.subnetPrefix
        }
      }
      {
        name: networking_vpnGateway.subnetName
        properties: {
          addressPrefix: networking_vpnGateway.subnetPrefix
        }
      }
      {
        name: networking_Hub01.subnetTransitName
        properties: {
          addressPrefix: networking_Hub01.subnetTransit
        }
      }
    ]
  }
}

resource res_networking_Hub_vpnGateway_pip 'Microsoft.Network/publicIPAddresses@2019-11-01' = if (networking_deploy_VpnGateway) {
  name: 'pip-azarc-hub-vgw01'
  location: location
  tags: {
    'Env': 'Infrastructure'
    'CostCenter': '00123'
    'az-core-projectcode': 'BicepDeployment- Designing Microsoft Azure Infrastructure Solutions '
    'az-core-purpose': 'Networking Hub'
    'az-aut-delete' : 'true'
  }
  properties: {
    publicIPAllocationMethod: 'Dynamic'
  }
}

resource res_networking_Hub_vpnGateway 'Microsoft.Network/virtualNetworkGateways@2021-05-01' = if (networking_deploy_VpnGateway) {
  name: networking_vpnGateway.name
  location: location
  tags: {
    'Env': 'Infrastructure'
    'CostCenter': '00123'
    'az-core-projectcode': 'BicepDeployment- Designing Microsoft Azure Infrastructure Solutions '
    'az-core-purpose': 'IPSEC tunnel simulation Hub - On prem'
    'az-aut-delete' : 'true'
  }
  properties: {
    ipConfigurations: [
      {
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: resourceId('Microsoft.Network/virtualNetworks/subnets', networking_Hub01.name, networking_vpnGateway.subnetName)
          }
          publicIPAddress: {
            id: res_networking_Hub_vpnGateway_pip.id
          }
        }
        name: 'vnetGatewayConfig'
      }
    ]
    sku: {
      name: 'Basic'
      tier: 'Basic'
    }
    gatewayType: 'Vpn'
    vpnType: 'RouteBased'
    enableBgp: false
  }
  dependsOn: [
    res_networking_Hub01
  ]
}

//Linux VM for connection testing

resource res_linuxVm_Hub01_pip 'Microsoft.Network/publicIPAddresses@2019-11-01' = if (networking_deploy_VpnGateway) {
  name: 'pip-azarc-hub01-lxvm2'
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
      domainNameLabel: 'lxvmarchitecturehub01conncheck'
    }
    idleTimeoutInMinutes: 4
  }
  sku: {
    name: 'Basic'
  }
}

 resource nicNameLinuxResource 'Microsoft.Network/networkInterfaces@2020-05-01' = {
  name: 'nic-azarc-hub01-lxvmcheckcomms'
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
            id: '${res_networking_Hub01.id}/subnets/${networking_Hub01.subnetTransitName}'
          }
          publicIPAddress: {
            id: res_linuxVm_Hub01_pip.id
          }
        }
      }
    ]
    networkSecurityGroup: {
      id: res_hub01_linuxVm_nsg.id
    }
  }
}

resource res_hub01_linuxVm_nsg 'Microsoft.Network/networkSecurityGroups@2020-06-01' = {
  name: 'nsg-azarc-hub01-lxvmcheckconns'
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
  name: 'lxvmhubnetcheck'
  location: location
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_B4ms'
    }
    osProfile: {
      computerName: 'lxvmhubnetcheck'
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
  name: 'shutdown-computevm-lxvmhubnetcheck'
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

resource res_networking_Spk01_Vnet 'Microsoft.Network/virtualNetworks@2020-05-01' existing = {
  name: networking_Spoke01.name
  scope: resourceGroup('rg-azarc-spk01-networking-01')
}

resource res_networking_Spk02_Vnet 'Microsoft.Network/virtualNetworks@2020-05-01' existing = {
  name: networking_Spoke02.name
  scope: resourceGroup('rg-azarc-spk02-networking-01')
}

resource res_peering_Hub01_2_Spk01  'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2020-06-01' = {
  name: '${res_networking_Hub01.name}/per-azarc-hub01-to-spk01'
  properties: {
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    allowGatewayTransit: true
    useRemoteGateways: false
    remoteVirtualNetwork: {
      id: res_networking_Spk01_Vnet.id
    }
  }
  dependsOn: [
    res_networking_Hub01
  ]
}

resource res_peering_Hub01_to_Spk02 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2020-06-01' = {
  name: '${res_networking_Hub01.name}/per-azarc-hub01-to-spk02'
  properties: {
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    allowGatewayTransit: true
    useRemoteGateways: false
    remoteVirtualNetwork: {
      id: res_networking_Spk02_Vnet.id
    }
  }
  dependsOn: [
    res_networking_Hub01
  ]
}

