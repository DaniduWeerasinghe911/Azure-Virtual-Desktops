// Main template to deploy a set of landing zone components at a subscription level
targetScope = 'subscription'

@description('Location of resources.')
param location string = 'australiaeast'

@description('Environment (prd/tst/qa).')
param envShortName string

@description('Shortname of location. Used for resource naming.')
param custShortName string

@description('Shortname of Landing Zone. Used for resource naming.')
param lzShortName string

@description('AVD Host Location')
param avdHostLocation string = 'eastUS'

@description('Host Pool Type')
param hostPoolType string = 'Pooled'

@description('Location for all standard resources to be deployed into.')
param loadBalancerType string = 'BreadthFirst'

@description('Location for all standard resources to be deployed into.')
param preferredAppGroupType string = 'desktop'

@description('Log Analytics Workspace ID')
param logWorkspaceID string


param baseTime string = utcNow('u')
var expirationTime = dateTimeAdd(baseTime, 'P3D')
var worksSpacefriendlyName = 'workspace-${custShortName}'
var hostPoolFriendlyName = 'hpool-${lzShortName}-${envShortName}-${custShortName}'
var avdRgName = 'rg-${lzShortName}-avd-${envShortName}-${custShortName}'

@description('Object containing resource tags.')
var tags  = {
  AppName : lzShortName
  Environment:envShortName
  costcentre:custShortName
  Customer:custShortName
}

// Resource Names

var diagSettings = {
  name: 'diag-log'
  workspaceId: logWorkspaceID
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

resource rg_shdSvcs 'Microsoft.Resources/resourceGroups@2021-04-01' existing = {
  name: avdRgName
}

module deployAVD '../../../Modules/HostPool/wvd.bicep' = {
  scope: resourceGroup(rg_shdSvcs.name)
  name: 'deployHostPool'
  params: {
    avdHostLocation: avdHostLocation
    hostPoolFriendlyName: hostPoolFriendlyName
    hostPoolType: hostPoolType
    loadBalancerType: loadBalancerType
    preferredAppGroupType: preferredAppGroupType
    worksSpacefriendlyName: worksSpacefriendlyName
    expirationTime: expirationTime
    diagSettings: diagSettings
  }
}


output avdRgName string = avdRgName
output hostPoolFriendlyName string = hostPoolFriendlyName
output worksSpacefriendlyName string = worksSpacefriendlyName
output hostpoolid string = deployAVD.outputs.hostPoolId
