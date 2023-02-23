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

@description('Object containing resource tags.')
param tags object = {}

@description('Number of AVD Instances')
param avd_number_Of_Instances int = 1

@description('AVD Registration Token')
param avdregtoken string

@description('Domain Join User Name')
param domainJoinUserName string

@description('Domain Join User Secret Name to retrive it from KV')
param domainJoinSecretName string

@description('Local User Name')
param localAdminUserName string

@description('Local User Secret Name to retrive it from KV')
param localAdminSecretName string

@description('Domain to Join')
param domainToJoin string

@description('Active Directory OU Path')
param ouPath string

@description('DSC Storage Account Name')
param dscStorageAccount string

@description('DSC Storage Account Containter Name')
param dscStorageAccountContainer string

@description('Prefix Value for the Virtual Machines')
param vmPrefix string

@description('Virtual Machine Type')
param vmSize string

var rgName = 'rg-${lzShortName}-avd-${envShortName}-${custShortName}'
var platformRgName = 'rg-${lzShortName}-platform-${envShortName}-${custShortName}'
var existingVNETName = 'vnet-${lzShortName}-${envShortName}-${custShortName}'
var existingSubnetName = 'snet-${lzShortName}-${envShortName}-${custShortName}-avd'
var existingkeyvaultName = 'kv-${lzShortName}-${envShortName}-${custShortName}'
var logWorkspaceName = 'log-${lzShortName}-${envShortName}-${custShortName}'
var hostpoolName = 'hpool-${lzShortName}-${envShortName}-${custShortName}'

var logAnalyticsId = '/subscriptions/${subscription().subscriptionId}/resourceGroups/${platformRgName}/providers/Microsoft.OperationalInsights/workspaces/${logWorkspaceName}'
var subnetID = '/subscriptions/${subscription().subscriptionId}/resourceGroups/${platformRgName}/providers/Microsoft.Network/virtualNetworks/${existingVNETName}/subnets/${existingSubnetName}'
var hostpoolID = '/subscriptions/${subscription().subscriptionId}/resourceGroups/${rgName}/providers/Microsoft.DesktopVirtualization/hostpools/${hostpoolName}'
// Resource Names
var diagSettings = {
  name: 'diag-log'
  workspaceId: logAnalyticsId
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

var applicationGroupArray = [
  {
    appgroupName: 'FileExplorer'
    appgroupType: 'RemoteApp'
    applicationAlias: 'FileExplorer'
    applicationPath: 'c:\\windows\\explorer.exe'
    applicationDesc: 'Windows File Explorer'
  }
  {
    appgroupName: 'MSEdge'
    appgroupType: 'RemoteApp'
    applicationAlias: 'microsoftedge'
    applicationPath: 'C:\\Program Files (x86)\\Microsoft\\Edge\\Application\\msedge.exe'
    applicationDesc: 'Microsoft Edge'
  }
]

var applicationGroupIDArray = [
  '/subscriptions/${subscription().subscriptionId}/resourceGroups/${rgName}/providers/Microsoft.DesktopVirtualization/applicationgroups/MSEdge'
  '/subscriptions/${subscription().subscriptionId}/resourceGroups/${rgName}/providers/Microsoft.DesktopVirtualization/applicationgroups/FileExplorer'
  '/subscriptions/${subscription().subscriptionId}/resourceGroups/${rgName}/providers/Microsoft.DesktopVirtualization/applicationgroups/desktop-appgroup'
]

var healthDataCollectionRuleResourceId = '/subscriptions/${subscription().subscriptionId}/resourceGroups/${platformRgName}/providers/Microsoft.Insights/dataCollectionRules/Microsoft-VMInsights-Health'


resource rg_shdSvcs 'Microsoft.Resources/resourceGroups@2021-04-01' existing = {
  name: rgName
}

resource keyVault 'Microsoft.KeyVault/vaults@2019-09-01' existing = {
  scope: resourceGroup(platformRgName)
  name: existingkeyvaultName
}

resource hostpool 'Microsoft.DesktopVirtualization/hostPools@2021-09-03-preview' existing = {
  scope: resourceGroup(rgName)
  name: hostpoolName
}

module deployAVD '../../../Modules/HostPool/VM.bicep' = {
  scope: resourceGroup(rgName)
  name: 'deploy_avd_hosts'
  params: {
    location: location
    AVDnumberOfInstances: avd_number_Of_Instances
    avdRegToken: avdregtoken
    domainJoinPassword: keyVault.getSecret(domainJoinSecretName)
    domainJoinUser: domainJoinUserName
    domainToJoin: domainToJoin
    dscStorageAccount: dscStorageAccount
    dscStorageAccountContainer: dscStorageAccountContainer
    administratorAccountPassword: keyVault.getSecret(localAdminSecretName)
    administratorAccountUserName: localAdminUserName
    vmPrefix: vmPrefix
    vmSize: vmSize
    subnetID: subnetID
    ouPath: ouPath
    healthDataCollectionRuleResourceId: healthDataCollectionRuleResourceId
    logAnalyticsId: logAnalyticsId
  }
}

module applicationGroups '../../../modules/HostPool/avd.applicationgroup.bicep' = [for appgroup in applicationGroupArray: {
  scope: resourceGroup(rg_shdSvcs.name)
  name: 'deploy_avd_applicationgroups_${appgroup.appgroupName}'
  dependsOn: [
    deployAVD
  ]
  params: {
    appGroupName: appgroup.appgroupName
    appgroupType: appgroup.appgroupType
    hostpoolID: hostpoolID
    applicationAlias: appgroup.applicationAlias
    applicationDesc: appgroup.applicationDesc
    applicationPath: appgroup.applicationPath
    location: hostpool.location
  }
}]

module workspace '../../../modules/HostPool/avd.worksplace.bicep' = {
  scope: resourceGroup(rg_shdSvcs.name)
  name: 'deploy_avd_workspace'
  dependsOn: [
    applicationGroups
  ]
  params: {
    avdworkspacename: 'workspace-${custShortName}'
    location: hostpool.location
    appgroupref: applicationGroupIDArray
  }
}
