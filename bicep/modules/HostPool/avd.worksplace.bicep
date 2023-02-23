@description('AVD Workspace Name')
param avdworkspacename string

@description('Location for the Workspace')
param location string = 'eastus'

@description('Application Group Reference')
param appgroupref array = []

resource workspace 'Microsoft.DesktopVirtualization/workspaces@2021-07-12' = {
  name: avdworkspacename
  location: location
  properties: {
    applicationGroupReferences:appgroupref
    description: 'AVD Workspace'
    friendlyName: avdworkspacename
  }
}

output workspaceid string = workspace.id
