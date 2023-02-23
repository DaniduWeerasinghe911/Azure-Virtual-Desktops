// Main template to deploy a set of landing zone components at a subscription level
targetScope = 'subscription'

@description('Location of resources.')
param location string = 'australiaeast'

@description('Environment (prd/tst/qa).')
param envShortName string = 'prd'

@description('Customer Short Name')
param custShortName string

@description('Shortname of Landing Zone. Used for resource naming.')
param lzShortName string = 'dckloud'

@description('Object containing resource tags.')
param tags object = {}

param nsgRules array = [
  {
    name: 'AZ_Allow_Inbound_AzureLB_Any_Any_Any'
    properties: {
      protocol: '*'
      sourcePortRange: '*'
      destinationPortRange: '*'
      sourceAddressPrefix: 'AzureLoadBalancer'
      destinationAddressPrefix: '*'
      access: 'Allow'
      priority: 101
      direction: 'Inbound'
    }
  }
  {
    name: 'AZ_Allow_Inbound_App_App_Any_Any'
    properties: {
      protocol: '*'
      sourcePortRange: '*'
      destinationPortRange: '*'
      sourceAddressPrefix: '10.16.16.0/26'
      destinationAddressPrefix: '10.216.16.0/26'
      access: 'Allow'
      priority: 102
      direction: 'Inbound'
    }
  }
  {
    name: 'AZ_Allow_Inbound_ShdVnet_App_Any_Any'
    properties: {
      protocol: '*'
      sourcePortRange: '*'
      destinationPortRange: '*'
      sourceAddressPrefix: '10.10.0.0/16'
      destinationAddressPrefix: '*'
      access: 'Allow'
      priority: 103
      direction: 'Inbound'
    }
  }
  {
    name: 'AZ_Deny_Inbound_Any_Any_Any_Any'
    properties: {
      protocol: '*'
      sourcePortRange: '*'
      destinationPortRange: '*'
      sourceAddressPrefix: '*'
      destinationAddressPrefix: '*'
      access: 'Deny'
      priority: '999'
      direction: 'Inbound'
    }
  }
]

// Resource Names
var rgName = 'rg-${lzShortName}-${envShortName}-${custShortName}'
var logWorkspaceName = 'log-${lzShortName}-${envShortName}-${custShortName}'
var storageName = toLower('st${lzShortName}${envShortName}${custShortName}log')
var vnetName = 'vnet-${lzShortName}-${envShortName}-${custShortName}'
var subnetName = 'snet-${lzShortName}-${envShortName}-${custShortName}'

var diagSettings = {
  name: 'diag-log'
  workspaceId: '/subscriptions/${subscription().subscriptionId}/resourcegroups/${rgName}/providers/microsoft.operationalinsights/workspaces/${logWorkspaceName}'
  storageAccountId: ''
  eventHubAuthorizationRuleId: ''
  eventHubName: ''
  enableLogs: true
  enableMetrics: false
  retentionPolicy: {
    days: 0
    enabled: false
  }
}
resource rg_shdSvcs 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: rgName
  tags: tags
  location: location
}
module nsgaavd '../../../modules/networking/nsg/nsg.bicep' = {
  scope: resourceGroup(rg_shdSvcs.name)
  name: 'deploy-nsg-ae-prd-data'
  params: {
    location:location
    nsgName: 'nsg-ae-prd-data'
    securityRules: nsgRules
    diagSettings: diagSettings
    enableFlowLogs:false
  }
  dependsOn: [
    logAnalytics
  ]
}
module virtualNetwork '../../../modules/networking/vnet/vnet.bicep' = {
  scope: resourceGroup(rg_shdSvcs.name)
  name: 'deployVnet'
  params: {
    location:location
    addressPrefixes: [
      '10.10.0.0/16'
    ]
    subnets: [
      {
        name: subnetName
        addressPrefix: '10.10.4.0/24'
        networkSecurityGroup: nsgaavd.outputs.id
        routeTable: null
        privateEndpointNetworkPolicies: 'Disabled'
        privateLinkServiceNetworkPolicies: 'Enabled'
        serviceEndpoints: [
          {
            service: 'Microsoft.storage'
            locations: 'australiaeast,australiasoutheast'
          }
        ]
        serviceEndpointPolicies: []
        delegations: []
      }
      {
        name: 'GatewaySubnet'
        addressPrefix: '10.10.5.0/24'
        networkSecurityGroup: null
        routeTable: null
        privateEndpointNetworkPolicies: 'Enabled'
        privateLinkServiceNetworkPolicies: 'Enabled'
        serviceEndpoints: []
        serviceEndpointPolicies: []
        delegations: []
      }
    ]
    vnetName: vnetName
    diagSettings: diagSettings
    enableResourceLock:false
  }
  dependsOn: [
    logAnalytics
    rg_shdSvcs
  ]
}
module logAnalytics '../../../Modules/log-analytics/log-analytics.bicep' = {
  name: 'deploy_logAnalytics'
  scope: resourceGroup(rgName)
  params: {
    location:location
    workspaceName: logWorkspaceName
    tags: tags
    retentionInDays: 90
  }
  dependsOn:[
    rg_shdSvcs
  ]
}
module storageForLogs '../../../modules/storage/general-v2/storage.bicep' = {
  scope: resourceGroup(rgName)
  name: 'deploy_storage_for_logs'
  params: {
    location:location
    storageAccountName: storageName
    storageSku: 'Standard_LRS'
  }
  dependsOn:[
    rg_shdSvcs
  ]
}
//Output Resource Name and Resource Id as a standard to allow module referencing.
output logWorkspaceName string = logAnalytics.outputs.name
output logWorkspaceId string = logAnalytics.outputs.id
