param location string = resourceGroup().location

/* /24 = 256 ips --> from 172.16.1.0 -to- 172.16.1.255 */
param networking_OnPremises object = {
  name: 'vnet-cesa-elz01-onpremises01'
  addressPrefix: '172.16.1.0/24'
  subnetTransitName: 'snet-onprem-transit'
  subnetTransit: '172.16.1.0/26'
}
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
    ]
  }
}
