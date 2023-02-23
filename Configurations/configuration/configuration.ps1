configuration WVDSoftwareInstall {

    param
    (
        [Parameter(mandatory = $true)]
        [string]$wvdRegistrationToken,

        [Parameter(mandatory = $true)]
        [string]$azureUserProfileShare,

        [Parameter(mandatory = $true)]
        [string]$installCcmClient
    )

    $ErrorActionPreference = 'Stop'
    $ScriptPath = $PSScriptRoot
    Import-DscResource -ModuleName PsDesiredStateConfiguration
    node "localhost"
    {
        LocalConfigurationManager {
            RebootNodeIfNeeded = $true
            ConfigurationMode  = "ApplyOnly"
        }

        if((Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Name ProductName).ProductName -like "*Server*"){
            WindowsFeature RDS-RD-Server {
                Ensure = "Present"
                Name   = "RDS-RD-Server"
            }
        }

        Script InstallWVDAgent {
            GetScript  = {
                return @{'Result' = '' }
            }
            SetScript  = {
                & "$using:ScriptPath\Install-WVDAgent.ps1" -registrationToken $using:wvdRegistrationToken

            }
            TestScript = {
                if((Test-Path "HKLM:\SOFTWARE\Microsoft\RDInfraAgent") -eq $true -and (Test-Path "HKLM:\SOFTWARE\Microsoft\RDAgentBootLoader") -eq $true){
                    return $true
                }
                else{
                    return $false
                }
            }
        }

        if($azureUserProfileShare -ne "false"){
            Script InstallFSLogix {
                GetScript  = {
                    return @{'Result' = '' }
                }
                SetScript  = {
                    & "$using:ScriptPath\Install-Fslogix.ps1" -azureFileShare $using:azureUserProfileShare

                }
                TestScript = {
                    Test-Path "HKLM:\SOFTWARE\FSLogix\Apps"
                }
            }
        }

        if($installCcmClient -ne "false"){
            Script InstallCcmClient {
                GetScript  = {
                    return @{'Result' = '' }
                }
                SetScript  = {
                    & "$using:ScriptPath\install-CCMClient.ps1"
                }
                TestScript = {
                    Test-Path "HKLM:\SOFTWARE\Microsoft\CCM"
                }
            }
        }

        Script runPostCustomizations {
            GetScript  = {
                return @{'Result' = '' }
            }
            SetScript  = {
                if (Test-Path C:\Windows\Build\Scripts\Virtual-Desktop-Optimization-Tool\Win10_VirtualDesktop_Optimize.ps1 -PathType Leaf) {
                    & "C:\Windows\Build\Scripts\Virtual-Desktop-Optimization-Tool\Win10_VirtualDesktop_Optimize.ps1"
                }
            }
            TestScript = {
                Test-Path "HKLM:\SOFTWARE\Build\Kmart-DSC"
            }
        }

        Script runKmartPostCustomizations {
            GetScript  = {
                return @{'Result' = '' }
            }
            SetScript  = {
                if (Test-Path c:\windows\build\scripts\VM_Kmart_Post_Customization.ps1 -PathType Leaf) {
                    & "c:\windows\build\scripts\VM_Kmart_Post_Customization.ps1"
                }
            }
            TestScript = {
                Test-Path "HKLM:\SOFTWARE\Build\Kmart-DSC"
            }
            DependsOn = '[Script]runPostCustomizations'
        }
    }
}