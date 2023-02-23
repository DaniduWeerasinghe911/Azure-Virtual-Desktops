<#
    .SYNOPSIS
        Installs Windows Virtual Desktop Agent on Windows Virtual Machine.

    .DESCRIPTION
        This script will install windows virtual desktop agent and register the virtual machine
        to the Windows Virtual Desktop host pool using the registration token provided.

    .PARAMETER registrationToken
        Registration token to register virtual machine to WVD host pool, obtained by running command 
        "Get-AzWvdRegistrationInfo -ResourceGroupName <resourcegroupname> -HostPoolName <hostpoolname>"       

    .EXAMPLE
        .\Install-WVDSoftware.ps1 -wvdRegistrationToken TOKEN      
           

    .NOTES
        Version:				0.1
        Author:					AJ Bajada

        Creation Date:			01/05/2020
        Purpose/Change:			Initial script development

        Required Modules:       None                                

        Dependencies:			Executed with account that has administrator access to the virtual machine.

        Limitations:            None

        Supported Platforms*:   Azure
                                *Currently not tested against other platforms                               

        Version History:        [01/05/2020 - 0.1 - AJ Bajada]: Initial script development
#>

<##====================================================================================
	PARAMETERS
##===================================================================================#>
param (
    [Parameter(Mandatory = $true)]
    [string]$registrationToken    
)

<##====================================================================================
	GLOBAL CONFIGURATION
##===================================================================================#>
$ErrorActionPreference = "Stop"
$wvdAgentInstallUrl = "https://query.prod.cms.rt.microsoft.com/cms/api/am/binary/RWrmXv"
$wvdAgentBootloaderInstallUrl = "https://query.prod.cms.rt.microsoft.com/cms/api/am/binary/RWrxrH"

<##====================================================================================
	MAIN CODE
##===================================================================================#>
# Start log file
$date = Get-Date -Format yyyyMMddhhmmss
Start-Transcript -Path $env:temp\WVDAgent$date.log
# Make temporary directory to store binaries
$dir = (New-Guid).Guid.Substring(0, 10)
New-Item -Path c:\$dir -ItemType Directory
# Download WVD Agent binaries
Invoke-WebRequest -Uri $wvdAgentInstallUrl -OutFile C:\$dir\wvdAgent.msi
Invoke-WebRequest -Uri $wvdAgentBootloaderInstallUrl -OutFile C:\$dir\wvdAgentBootloader.msi
# Install WVD Agent
& C:\$dir\wvdAgent.msi REGISTRATIONTOKEN=$registrationToken /log $env:temp\WVDAgentInstall$date.log /quiet
# Install WVD Agent Bootloader
& C:\$dir\wvdAgentBootloader.msi /log $env:temp\WVDAgentBootloaderInstall$date.log /quiet
# Wait for install to finish
Start-Sleep -Seconds 120
# Remove temporary directory
Get-ChildItem -Path C:\$dir -Recurse | Remove-Item -Force -Confirm:$false -Recurse
Remove-Item -Path C:\$dir -Force -Confirm:$false -Recurse
# Stop log file
Stop-Transcript