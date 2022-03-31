
param location string = resourceGroup().location

/* /22 = 1000 ips --> from 10.1.0.0 -to- 10.1.3.255 */
param networking_Spoke01 object = {
  name: 'vnet-cesa-elz01-spk01'
  addressPrefix: '10.1.0.0/22'
  subnetFrontName: 'snet-spk01-front'
  subnetFrontPrefix: '10.1.0.0/25'
  subnetBackName: 'snet-spk01-back'
  subnetBackPrefix: '10.1.0.128/25'

}

param adminUserName string = 'usrwinadmin'
param adminUserPass string = 'usr$Am1n-2223'
param vmSize string = 'Standard_A1_v2'

var nicNameWindows = 'nic-windows-01'
var vmNameWindows = 'vm-windows-01'
var windowsOSVersion = '2016-Datacenter'


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

resource nicNameWindowsResource 'Microsoft.Network/networkInterfaces@2020-05-01' = {
  name: nicNameWindows
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: '${res_networking_Spk01.id}/subnets/${networking_Spoke01.subnetFrontName}'
          }
        }
      }
    ]
  }
}

resource res_vmNameWindowsResource_name 'Microsoft.Compute/virtualMachines@2019-07-01' = {
  name: vmNameWindows
  location: location
  dependsOn: [
    nicNameWindowsResource
  ]
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    osProfile: {
      computerName: vmNameWindows
      adminUsername: adminUserName
      adminPassword: adminUserPass
    }
    storageProfile: {
      imageReference: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: windowsOSVersion
        version: 'latest'
      }
      osDisk: {
        createOption: 'FromImage'
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: resourceId('Microsoft.Network/networkInterfaces', nicNameWindows)
        }
      ]
    }
  }
}
