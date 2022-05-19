
param location string = resourceGroup().location

/* /22 = 1000 ips --> from 10.1.0.0 -to- 10.1.3.255 */
param networking_Spoke01 object = {
  name: 'vnet-cesa-elz01-spk01'
  addressPrefix: '10.1.0.0/22'
  subnetFrontName: 'snet-spk01-front'
  subnetFrontPrefix: '10.1.0.0/25'
  subnetBackName: 'snet-spk01-back'
  subnetBackPrefix: '10.1.0.128/25'
  subnetMangament: 'snet-spk01-mngnt'
  subnetMangamentPrefix: '10.1.1.0/29'

}

param adminUserName string = 'usrwinadmin'
param adminUserPass string = 'usr$Am1n-2223'
param vmSize string = 'Standard_A1_v2'
param vmParadaDiariaNombre string = 'shutdown-computevm-vm-windows-01'

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
        name: networking_Spoke01.subnetMangament
        properties: {
          addressPrefix: networking_Spoke01.subnetMangamentPrefix
        }
      }
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
resource res_schedules_shutdown_computevm_vmNameWindowsResource 'microsoft.devtestlab/schedules@2018-09-15' = {
  name: vmParadaDiariaNombre
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
    targetResourceId: res_vmNameWindowsResource_name.id
  }
}

/*  PEERINGS HUB - SPOKES  */

/*resource*/

/* 'EXISTING' -> We use this kind of reference to access an existing element in the same RG: */
resource res_networking_Hub01_Vnet 'Microsoft.Network/virtualNetworks@2020-05-01' existing = {
  name: 'vnet-cesa-elz01-hub01'
  scope: resourceGroup('rg-cesa-elz01-hub01-networking-01')
}


resource res_peering_Spk01_2_Hub01  'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2020-06-01' = {
  name: '${res_networking_Spk01.name}/per-cesa-elz01-hub01-to-spk01'
  properties: {
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    allowGatewayTransit: false
    useRemoteGateways: false
    remoteVirtualNetwork: {
      id: res_networking_Hub01_Vnet.id
    }
  }
}
