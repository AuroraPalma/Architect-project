param location string = resourceGroup().location

/* /24 = 256 ips --> from 10.0.1.0 -to- 10.0.1.255 */
param networking_Hub01 object = {
  name: 'vnet-cesa-elz01-hub01'
  addressPrefix: '10.0.1.0/24'
}
/* /24 = 256 ips --> from 10.0.2.0 -to- 10.0.2.255 */
param networking_Hub02 object = {
  name: 'vnet-cesa-elz01-hub02'
  addressPrefix: '10.0.2.0/24'
}

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

param networking_deployVpnGateway bool = false

param networking_vpnGateway object = {
  name: 'vgw-cesa-elz-vgw01'
  subnetName: 'GatewaySubnet'
  subnetPrefix: '10.0.1.72/29'
  pipName: 'pip-cesa-elz01-vgw01'
}

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
