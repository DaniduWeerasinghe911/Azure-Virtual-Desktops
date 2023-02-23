<#
.SYNOPSIS
	Basic script to install ccm client

.DESCRIPTION
    This script install the ccm client from the .\files folder

.PARAMETER SMSSITECODE
    SCCM Site code to connect client to
    Optional

.PARAMETER FSP
    FSP for ccm clinet to connect to
    Optional

.PARAMETER SMSMP
    SMSMP for ccm client to connect to
    Optional

.PARAMETER DNSSUFFIX
    DNSSUFFIX for ccm client to use
    Optional

.EXAMPLE

    .\Install-CCMClient.ps1

.NOTES
	Version:				0.01
    Author:					Thor Schutze
                            Arinco
    Creation Date:			23/09/2020 12:00:00 PM
    Purpose/Change:			Initial development

    Required Modules:
                            None

    Dependencies:			None

    Limitations:            Executed by packer.exe:

    Supported Platforms*:   Windows 10 Multisession 1909 with Office
                            *Currently not tested against other platforms

    Version History:
                            [23/09/2020 - 0.01 - Thor Schutze]: Initial release
#>

param (
    [Parameter(Mandatory = $false)]
    [string]$SMSSITECODE = 'KP1',

    [Parameter(Mandatory = $false)]
    [string]$FSP = 'kwpcmp001.core.kmtltd.net.au',

    [Parameter(Mandatory = $false)]
    [string]$SMSMP = 'kwpcmm001.core.kmtltd.net.au',

    [Parameter(Mandatory = $false)]
    [string]$DNSSUFFIX = 'core.kmtltd.net.au'
)
$ErrorActionPreference='Stop'
$PSScriptRoot = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition

$date = Get-Date -Format yyyyMMddhhmmss
Start-Transcript -Path $env:temp\ccmclientinstall-$date.log

Write-Host "[CCMCLIENT]:: Current script directory $($PSScriptRoot)"

$installArgs = [string]::Format("c:\windows\ccmsetup\files\ccmsetup.exe SMSSITECODE={0} FSP={1} SMSMP={2} RESETKEYINFORMATION=TRUE SMSCACHESIZE=30720 DNSSUFFIX={3} /ForceInstall /noservice",$SMSSITECODE,$FSP,$SMSMP,$DNSSUFFIX)

Invoke-Expression $installArgs

Stop-Transcript