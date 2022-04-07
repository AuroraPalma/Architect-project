/*
para lanzarlo: az account set --subscription "Aurora Palma"
*/
param location string = resourceGroup().location

/* /24 = 256 ips --> from 10.0.1.0 -to- 10.0.1.255 */
param networking_Hub01 object = {
  name: 'vnet-cesa-elz01-hub01'
  addressPrefix: '10.0.1.0/24'
}

/* /24 = 256 ips --> from 10.0.2.0 -to- 10.0.2.255 */
/*param networking_Hub02 object = {
  name: 'vnet-cesa-elz01-hub02'
  addressPrefix: '10.0.2.0/24'
}
*/

param networking_AzureFirewall object = {
  name: 'afw-cesa-elz01-firewall01'
  publicIPAddressName: 'pip-cesa-elz01-afw01'
  subnetName: 'AzureFirewallSubnet'
  subnetPrefix: '10.0.1.0/26' /* 10.0.1.0 -> 10.0.1.63 */
  routeName: 'udr-cesa-elz01-nxthop-to-fw'
}

param networking_bastionHost object = {
  name: 'bas-cesa-elz01-bastionhost01'
  publicIPAddressName: 'pip-cesa-elz01-bas01'
  subnetName: 'AzureBastionSubnet'
  nsgName: 'nsg-hub01-bastion'
  subnetPrefix: '10.0.1.64/29'/* 10.0.1.64 -> 10.0.1.71 */
}

param networking_deploy_VpnGateway bool = true

param networking_vpnGateway object = {
  name: 'vgw-cesa-elz01-hub-vgw01'
  subnetName: 'GatewaySubnet'
  subnetPrefix: '10.0.1.72/29'
  pipName: 'pip-cesa-elz01-hub-vgw01'
}

/* -> 2022-04-06 -> params */
param networking_hub01_localNetworkGateway object = {
  name: 'lgw-cesa-elz01-hub01-lgw01'
  localAddressPrefix: '10.0.1.0/24'
}
param networking_hub01_conn object = {
  name: 'con-cesa-elz01-hub01-con01'
  connectionType: 'IPSec'
  enableBgp: true
  sharedKey: 'cesa-mola-este-curso-2022-abc'

} 
/* <- 2022-04-06 <- params */



resource res_networking_Hub01 'Microsoft.Network/virtualNetworks@2020-05-01' = {
  name: networking_Hub01.name
  location: location
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
        name: networking_bastionHost.subnetName
        properties: {
          addressPrefix: networking_bastionHost.subnetPrefix
        }
      }
      {
        name: networking_vpnGateway.subnetName
        properties: {
          addressPrefix: networking_vpnGateway.subnetPrefix
        }
      }
    ]
  }
}

/* MLopezG -> 2022-0406: Añadimos soporte VPNGateway para el Hub + 1 MV Linux para testear comunicaciones */

resource res_networking_Hub_vpnGateway_pip 'Microsoft.Network/publicIPAddresses@2019-11-01' = if (networking_deploy_VpnGateway) {
  name: 'pip-cesa-elz01-hub-vgw01'
  location: location
  properties: {
    publicIPAllocationMethod: 'Dynamic'
  }
}

resource res_networking_Hub_vpnGateway 'Microsoft.Network/virtualNetworkGateways@2021-05-01' = if (networking_deploy_VpnGateway) {
  name: networking_vpnGateway.name
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
/* 
resource res_networking_Hub01_localNetworkGateway 'Microsoft.Network/localNetworkGateways@2021-02-01' = if (networking_deploy_VpnGateway) {
  name: networking_hub01_localNetworkGateway.name
  location: location
  properties: {
    localNetworkAddressSpace: {
      addressPrefixes: networking_hub01_localNetworkGateway.localAddressPrefix
    }
    gatewayIpAddress: res_networking_Hub_vpnGateway_pip.id
  }
}

resource res_networking_Hub01_conn 'Microsoft.Network/connections@2021-02-01' = if (networking_deploy_VpnGateway) {
  name: networking_hub01_conn.name
  location: location
  properties: {
    connectionType:  networking_hub01_conn.connectionType
    virtualNetworkGateway1: {
      id: res_networking_Hub_vpnGateway.id
      properties: {
        
      }
    }
    enableBgp: networking_hub01_conn.enableBgp
    sharedKey: networking_hub01_conn.sharedKey
    localNetworkGateway2: {
      id: res_networking_Hub01_localNetworkGateway.id
      properties: {
        
      }
    }
  }
  dependsOn: []
}
 */
