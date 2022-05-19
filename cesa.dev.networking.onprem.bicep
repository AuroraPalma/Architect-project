/*
para lanzarlo: az account set --subscription "VSES – MPN_02"
*/
param location string = resourceGroup().location

/* /24 = 256 ips --> from 172.16.1.0 -to- 172.16.1.255 */
param networking_OnPremises object = {
  name: 'vnet-cesa-elz01-onpremises01'
  addressPrefix: '172.16.1.0/24'
  /*addressPrefix: '172.16.1.0/29'*/
  subnetTransitName: 'snet-onprem-transit'
  subnetTransit: '172.16.1.0/26'
}

param networking_deploy_OnPrem_VpnGateway bool = true

param networking_OnPrem_vpnGateway object = {
  name: 'vgw-cesa-elz01-onprem-vgw01'
  subnetName: 'GatewaySubnet'
  /*addressPrefix: '172.16.1.8/24'*/
  subnetPrefix: '172.16.1.64/29'
  pipName: 'pip-cesa-elz01-onprem-vgw01'
}

/* -> 2022-04-06 -> params 
param networking_OnPrem_localNetworkGateway object = {
  name: 'lgw-cesa-elz01-onprem-lgw01'
  localAddressPrefix: '172.16.1.0/26'
}*/
/* -> 2022-05-18 -> params */
param networking_OnPrem_localNetworkGateway object = {
  name: 'lgw-cesa-elz01-onprem-lgw01'
  localAddressPrefix: '10.0.1.80/29' /*10.0.1.80 - 10.0.1.87 (3 + 5*/
}

resource res_networking_OnPremises 'Microsoft.Network/virtualNetworks@2020-05-01' = {
  name: networking_OnPremises.name
  location: location
  tags: {
    'cor-ctx-environment': 'development'
    'cor-ctx-projectcode': 'Verne Technology - Curso Cloud Expert Solution Architect'
    'cor-ctx-purpose': ''
    'cor-aut-delete' : 'true'
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

/* MLopezG -> 2022-0406: Añadimos soporte VPNGateway para ONPREM + 1 MV Linux para testear comunicaciones */

resource res_networking_OnPrem_vpnGateway_pip 'Microsoft.Network/publicIPAddresses@2019-11-01' = if (networking_deploy_OnPrem_VpnGateway) {
  name: networking_OnPrem_vpnGateway.pipName
  location: location
  tags: {
    'cor-ctx-environment': 'development'
    'cor-ctx-projectcode': 'Verne Technology - Curso Cloud Expert Solution Architect'
    'cor-ctx-purpose': ''
    'cor-aut-delete' : 'true'
  }  
  properties: {
    publicIPAllocationMethod: 'Dynamic'
  }
}

resource res_networking_OnPrem_vpnGateway 'Microsoft.Network/virtualNetworkGateways@2019-11-01' = if (networking_deploy_OnPrem_VpnGateway) {
  name: networking_OnPrem_vpnGateway.name
  location: location
  tags: {
    'cor-ctx-environment': 'development'
    'cor-ctx-projectcode': 'Verne Technology - Curso Cloud Expert Solution Architect'
    'cor-ctx-purpose': 'Simula túnel IPSec entre On-Premises y Hub01 Azure'
    'cor-aut-delete' : 'true'
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

resource res_networking_OnPrem_localNetworkGateway 'Microsoft.Network/localNetworkGateways@2021-02-01' = if (networking_deploy_OnPrem_VpnGateway) {
  name: networking_OnPrem_localNetworkGateway.name
  location: location
  tags: {
    'cor-ctx-environment': 'development'
    'cor-ctx-projectcode': 'Verne Technology - Curso Cloud Expert Solution Architect'
    'cor-ctx-purpose': 'Pasarela local (local gateway) para enrutar tráfico entre las redes. El tráfico de estas redes irá por el túnel'
    'cor-aut-delete' : 'true'
  }
  properties: {
    localNetworkAddressSpace: {
      addressPrefixes: [
        networking_OnPrem_localNetworkGateway.localAddressPrefix
      ]
    }
    /*https://docs.microsoft.com/en-us/azure/templates/microsoft.network/publicipaddresses?tabs=bicep#publicipaddresspropertiesformat*/
    gatewayIpAddress: res_networking_OnPrem_vpnGateway_pip.properties.ipAddress  /*'20.238.39.157'*/
  }
}

/*
/* Azure VPN Site-to-Site ++ localNetworkGateway resource ++ Connection resource: */
/* 
  Especifique también los prefijos de dirección IP que se enrutarán a través 
  de la puerta de enlace VPN al dispositivo VPN. Los prefijos de dirección que 
  especifique son los prefijos que se encuentran en la red local.
*/
/*  
resource res_networking_OnPrem_conn 'Microsoft.Network/connections@2021-02-01' = if (networking_deploy_OnPrem_VpnGateway) {
  name: networking_OnPrem_conn.name
  location: location
  tags: {
    'cor-ctx-environment': 'development'
    'cor-ctx-projectcode': 'Verne Technology - Curso Cloud Expert Solution Architect'
    'cor-ctx-purpose': 'Conexión para enrutar tráfico entre redes (extremos del túnel). El tráfico de estas redes irá por el túnel'
    'cor-aut-delete' : 'true'
  }
  properties: {
    connectionProtocol: 'IKEv2'
    connectionType: networking_OnPrem_conn.connectionType
    virtualNetworkGateway1: {

      id: res_networking_OnPrem_vpnGateway.id
      properties: {
      }
    }
    enableBgp: networking_OnPrem_conn.enableBgp
    sharedKey: networking_OnPrem_conn.sharedKey
    localNetworkGateway2: {

      id: res_networking_OnPrem_localNetworkGateway.id
      properties: {
      }
    }
  }
  dependsOn: [
    res_networking_OnPremises
  ]
}
 */

/* desplegamos MÁQUINA LINUX para testear conectividades */

resource res_linuxVm_OnPrem_pip 'Microsoft.Network/publicIPAddresses@2019-11-01' = if (networking_deploy_OnPrem_VpnGateway) {
  name: 'pip-cesa-elz01-onprem-lxvm1'
  location: location
  tags: {
    'cor-ctx-environment': 'development'
    'cor-ctx-projectcode': 'Verne Technology - Curso Cloud Expert Solution Architect'
    'cor-ctx-purpose': ''
    'cor-aut-delete' : 'true'
  }  
  properties: {
    publicIPAllocationMethod: 'Dynamic'
    publicIPAddressVersion: 'IPv4'
    dnsSettings: {
      domainNameLabel: 'cesalxvmonpremcheckcomms'
    }
    idleTimeoutInMinutes: 4
  }
  sku: {
    name: 'Basic'
  }
}

 resource nicNameLinuxResource 'Microsoft.Network/networkInterfaces@2020-05-01' = {
  name: 'nic-cesa-elz01-onprem-lxvmcheckcomms'
  location: location
  tags: {
    'cor-ctx-environment': 'development'
    'cor-ctx-projectcode': 'Verne Technology - Curso Cloud Expert Solution Architect'
    'cor-ctx-purpose': 'NIC Máquina linux testing conectividades de red'
    'cor-aut-delete' : 'true'
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
  name: 'nsg-cesa-elz01-onprem-lxvmcheckcomms'
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
      adminUsername: 'cesadmin77'
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
      emailRecipient: 'mlopezg@vernegroup.com'
      notificationLocale: 'en'
    }
    targetResourceId: vmNameLinuxResource.id
  }
}
