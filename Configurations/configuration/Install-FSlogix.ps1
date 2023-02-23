<#
    .SYNOPSIS
        Installs FxLogix on Windows Virtual Machine.    
        
    .DESCRIPTION
        This script will install FxLogix on a Windows Virtual Machine and configure
        the required registry keys for user profiles to point to an Azure file share.

    .PARAMETER azureFileShare
        Azure file share path, example fsprofile.file.core.windows.net\share 

    .EXAMPLE
        .\Install-FXlogix.ps1 -azureFileShare "fsprofile.file.core.windows.net\share"
           

    .NOTES
        Version:				0.1
        Author:					AJ Bajada

        Creation Date:			29/04/2020
        Purpose/Change:			Initial script development

        Required Modules:       None                                

        Dependencies:			Executed with account that has administrator access to the virtual machine.

        Limitations:            None

        Supported Platforms*:   Azure
                                *Currently not tested against other platforms                               

        Version History:        [29/04/2020 - 0.1 - AJ Bajada]: Initial script development
#>

<##====================================================================================
	PARAMETERS
##===================================================================================#>
param (
    [Parameter(Mandatory=$true)]
    [string]$azureFileShare
)

<##====================================================================================
	GLOBAL CONFIGURATION
##===================================================================================#>
$ErrorActionPreference = 'Stop'
$url = "https://aka.ms/fslogix_download"

<##====================================================================================
	MAIN CODE
##===================================================================================#>
# Start log file
$date = Get-Date -Format yyyyMMddhhmmss
Start-Transcript -Path $env:temp\FsLogix$date.log
# Make temporary directory to store binaries
$dir = (New-Guid).Guid.Substring(0,10)
New-Item -Path c:\$dir -ItemType Directory
# Download FxLogix binaries
Invoke-WebRequest -Uri $url -OutFile C:\$dir\FxLogix.zip
# Install FxLogix
Expand-Archive C:\$dir\FxLogix.zip -DestinationPath C:\$dir\FxLogix
$path = "C:\$dir\FxLogix\x64\Release\FSLogixAppsSetup.exe"
& $path /install /quiet /norestart
# Set registry keys for user profiles
New-Item -Path "HKLM:\SOFTWARE\FSLogix\Profiles" -Force
New-ItemProperty -Path "HKLM:\SOFTWARE\FSLogix\Profiles" -Name "VHDLocations" -Value "\\$azureFileShare" -PropertyType MultiString -Force
New-ItemProperty -Path "HKLM:\SOFTWARE\FSLogix\Profiles" -Name "Enabled" -Value 1 -PropertyType DWORD -Force
# Wait for install to finish
Start-Sleep -Seconds 60
# Remove temporary directory
Get-ChildItem -Path C:\$dir -Recurse | Remove-Item -Force -Confirm:$false -Recurse
Remove-Item -Path C:\$dir -Force -Confirm:$false -Recurse
# Stop log file
Stop-Transcript