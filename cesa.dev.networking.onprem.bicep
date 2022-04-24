/*este código levanta la vpn gateway onprem con una red virtual y una ip address publica*/
param location string = resourceGroup().location
/*
para lanzarlo: az account set --subscription "Aurora Palma"
*/
/* /24 = 256 ips --> from 172.16.1.0 -to- 172.16.1.255 */
param networking_OnPremises object = {
  name: 'vnet-cesa-elz01-onpremises01'
  addressPrefix: '172.16.1.0/24'
  subnetTransitName: 'snet-onprem-transit'
  subnetTransit: '172.16.1.0/26'
}
param networking_deploy_OnPrem_VpnGateway bool = true

param networking_OnPrem_vpnGateway object = {
  name: 'vgw-cesa-elz01-onprem-vgw01'
  subnetName: 'GatewaySubnet'
  /*addressPrefix: '172.16.1.8/24'*/
  subnetPrefix: '172.16.1.64/26'
  pipName: 'pip-cesa-elz01-onprem-vgw01'
}
/* -> 2022-04-06 -> params */
param networking_OnPrem_localNetworkGateway object = {
  name: 'lgw-cesa-elz01-onprem-lgw01'
  localAddressPrefix: '172.16.1.0/26'
}
param networking_OnPrem_conn object = {
  name: 'con-cesa-elz01-onprem-con01'
  connectionType: 'IPSec'
  enableBgp: true
  sharedKey: 'cesa-mola-este-curso-2022-abc'

} 
/* <- 2022-04-06 <- params */
resource res_networking_OnPremises 'Microsoft.Network/virtualNetworks@2020-05-01' = {
  name: networking_OnPremises.name
  location: location
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
  name: 'pip-cesa-elz01-onprem-vgw01'
  location: location
  properties: {
    publicIPAllocationMethod: 'Dynamic'
  }
}

resource res_networking_OnPrem_vpnGateway 'Microsoft.Network/virtualNetworkGateways@2021-05-01' = if (networking_deploy_OnPrem_VpnGateway) {
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
      name: 'Basic'
      tier: 'Basic'
    }
    gatewayType: 'Vpn'
    vpnType: 'RouteBased'
    enableBgp: false
  }
  dependsOn: [
    res_networking_OnPremises
  ]
}

/* Azure VPN Site-to-Site ++ localNetworkGateway resource ++ Connection resource: */
/* 
  Especifique también los prefijos de dirección IP que se enrutarán a través 
  de la puerta de enlace VPN al dispositivo VPN. Los prefijos de dirección que 
  especifique son los prefijos que se encuentran en la red local.
*/
/*
resource res_networking_OnPrem_localNetworkGateway 'Microsoft.Network/localNetworkGateways@2021-02-01' = if (networking_deploy_OnPrem_VpnGateway) {
  name: networking_OnPrem_localNetworkGateway.name
  location: location
  properties: {
    localNetworkAddressSpace: {
      addressPrefixes: networking_OnPrem_localNetworkGateway.localAddressPrefix
    }
    gatewayIpAddress: res_networking_OnPrem_vpnGateway_pip.id
  }
}

resource res_networking_OnPrem_conn 'Microsoft.Network/connections@2021-02-01' = if (networking_deploy_OnPrem_VpnGateway) {
  name: networking_OnPrem_conn.name
  location: location
  properties: {
    connectionType:  networking_OnPrem_conn.connectionType
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
  dependsOn: []
}
*/
