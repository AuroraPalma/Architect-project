param location string = resourceGroup().location
param networking_Spoke02 object = {
  name: 'vnet-cesa-elz01-spk02'
  addressPrefix: '10.2.0.0/22'
  subnetFrontName: 'snet-spk01-front'
  subnetFrontPrefix: '10.2.0.0/25'
  subnetBackName: 'snet-spk01-back'
  subnetBackPrefix: '10.2.0.128/25'

}

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
