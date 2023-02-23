# Windows Virtual Desktop Overview

## Host pools
A host pool is a collection of Azure virtual machines that register to Windows Virtual Desktop as session hosts when you run the Windows Virtual Desktop agent. All session host virtual machines in a host pool should be sourced from the same image for a consistent user experience.

A host pool can be one of two types:

- Personal, where each session host is assigned to individual users.
- Pooled, where session hosts can accept connections from any user authorized to an app group within the host pool.

in this deployment host pool type is Pooled

You can set additional properties on the host pool to change its load-balancing behavior, how many sessions each session host can take, and what the user can do to session hosts in the host pool while signed in to their Windows Virtual Desktop sessions. You control the resources published to users through app groups.

## App groups
An app group is a logical grouping of applications installed on session hosts in the host pool. An app group can be one of two types:

- RemoteApp, where users access the RemoteApps you individually select and publish to the app group
- Desktop, where users access the full desktop

By default, a desktop app group (named "Desktop Application Group") is automatically created whenever you create a host pool. You can remove this app group at any time. However, you can't create another desktop app group in the host pool while a desktop app group exists. To publish RemoteApps, you must create a RemoteApp app group. You can create multiple RemoteApp app groups to accommodate different worker scenarios. Different RemoteApp app groups can also contain overlapping RemoteApps.

To publish resources to users, you must assign them to app groups. When assigning users to app groups, consider the following things:

- A user can be assigned to both a desktop app group and a RemoteApp app group in the same host pool. However, users can only launch one type of app group per session. Users can't launch both types of app groups at the same time in a single session.
- A user can be assigned to multiple app groups within the same host pool, and their feed will be an accumulation of both app groups.

# Workspaces
A workspace is a logical grouping of application groups in Windows Virtual Desktop. Each Windows Virtual Desktop application group must be associated with a workspace for users to see the remote apps and desktops published to them.

# Deployment Components
 - Resource Group
 - Hostpool
 - 2 X Application Groups
 - Wokspace
 - Default App Group for Desktop Group

# Naming Convention

var worksSpacefriendlyName = 'workspace-${custShortName}'
var hostPoolFriendlyName = 'hpool-${lzShortName}-${envShortName}-${custShortName}'
var rgName = 'rg-avd-${envShortName}-${custShortName}'

# Application Groups
 - MSEdge -  This application group will be used to publish Microsoft Edge app to Virtual Desktop
 - FileExplorer - This application group will be used to publish File Explorer app to Virtual Desktop

# Hostpool
 - Hostpool will be used to publish the session hosts to Virtual Desktop (At the time of the deployment Host use Windows 11 image and a small config VM size)

[Back to Home](/README.md)