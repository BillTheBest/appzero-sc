# Copyright (c) 2013 AppZero Software Corporation.  All Rights Reserved.
#

Function Initialize-Pace
(
    [Parameter(Mandatory=$true)]
    [string]$stagingPath
)
{
    $Global:stagingPath = $stagingPath
}


Function Install-AppZero
(
    [Parameter(Mandatory=$true)]
    [string]$targetHost,
    [Parameter(Mandatory=$true)]
    [string]$targetHostUser,
    [Parameter(Mandatory=$false)]
    [string]$targetHostPassword,
    [Parameter(Mandatory=$true)]
    [string]$targetPath
)
{
    $ErrorActionPreference = "Stop"
    $Trace = "Install-AppZero $targetHost $targetHostUser $targetPath `r`n"

    if([string]::IsNullOrEmpty($targetHostPassword))
    {
        $stgsecpass = Read-Host -Prompt "Enter Password for user $targetHostUser on server $targetHost" -AsSecureString
    }
    else
    {
        $stgsecpass = ($targetHostPassword | ConvertTo-SecureString -AsPlainText -Force)
    }

    # connect to staging server
    $stgcreds = New-Object System.Management.Automation.PSCredential( $targetHostUser, $stgsecpass )
    $stgsess = New-PSSession -cn $targetHost -Credential $stgcreds

    if( $Error.Count -gt 0 )
    {
        $Trace += "Error Establishing PSSession to $targetHost`r`n"
        $Trace += "$Error`r`n"
    }

    try {
        
        # on staging server
        $return = Invoke-Command -Session $stgsess -ScriptBlock {
            Param($path,$share,$shareuser,$sharepasssec)

            Copy-Item -Path $targetPath\install\5.5SP1\setup.iss -Destination C:\Windows
            
        
        } -Args $targetPath, $stagingShare, $stagingShareUser, $shrsecpass

    } catch {
        throw $_.Exception    
    } finally {
        Remove-PSSession $stgsess
        $log = $return -join "`r`n"
    }

    
}


Function New-PaceRepo
(
    [Parameter(Mandatory=$true)]
    [string]$targetHost,
    [Parameter(Mandatory=$true)]
    [string]$targetHostUser,
    [Parameter(Mandatory=$false)]
    [string]$targetHostPassword,
    [Parameter(Mandatory=$true)]
    [string]$targetPath,
    [Parameter(Mandatory=$true)]
    [string]$stagingShare,
    [Parameter(Mandatory=$true)]
    [string]$stagingShareUser,
    [Parameter(Mandatory=$false)]
    [string]$stagingSharePassword
)
{
    $ErrorActionPreference = "Stop"
    $Trace = "New-PaceRepo $targetHost $targetHostUser $targetPath $stagingShare $stagingShareUser `r`n"

    if([string]::IsNullOrEmpty($targetHostPassword))
    {
        $stgsecpass = Read-Host -Prompt "Enter Password for user $targetHostUser on server $targetHost" -AsSecureString
    }
    else
    {
        $stgsecpass = ($targetHostPassword | ConvertTo-SecureString -AsPlainText -Force)
    }

    if([string]::IsNullOrEmpty($stagingSharePassword))
    {
        $shrsecpass = Read-Host -Prompt "Enter Password for user $targetHostUser on share $stagingShare" -AsSecureString
    }
    else
    {
        $shrsecpass = ($stagingSharePassword | ConvertTo-SecureString -AsPlainText -Force)
    }

    # connect to staging server
    $stgcreds = New-Object System.Management.Automation.PSCredential( $targetHostUser, $stgsecpass )
    $stgsess = New-PSSession -cn $targetHost -Credential $stgcreds

    if( $Error.Count -gt 0 )
    {
        $Trace += "Error Establishing PSSession to $targetHost`r`n"
        $Trace += "$Error`r`n"
    }

    try {
        
        # on staging server
        $return = Invoke-Command -Session $stgsess -ScriptBlock {
            Param($path,$share,$shareuser,$sharepasssec)
                               
            if( (Test-Path $path) -ne $true ) {
                New-Item -ItemType directory -Path $path
            }

            if(!(Test-Path "K:\")) {

                # connect and map to common share
                $shareCreds = New-Object System.Management.Automation.PSCredential( $shareuser, $sharepasssec )
                New-PSDrive -Name "K" -PSProvider "FileSystem" -Root $share -Credential $shareCreds -ErrorAction:SilentlyContinue
            }

            # copy artifacts from common share
            Copy-Item "K:\*" $path -Recurse -Force 
            
        
        } -Args $targetPath, $stagingShare, $stagingShareUser, $shrsecpass

    } catch {
        throw $_.Exception    
    } finally {
        Remove-PSSession $stgsess
        $log = $return -join "`r`n"
    }
}

Function Remove-PaceRepo
(
    [Parameter(Mandatory=$true)]
    [string]$targetHost,
    [Parameter(Mandatory=$true)]
    [string]$targetPath = "c:\appzero-sco",
    [Parameter(Mandatory=$true)]
    [string]$targetHostUser = "Administrator",
    [Parameter(Mandatory=$false)]
    [string]$targetHostPassword
)
{

    $ErrorActionPreference = "Stop"
    $Trace = "Remove-PaceRepo $targetHost $targetHostUser $targetPath `r`n"

    if([string]::IsNullOrEmpty($targetHostPassword))
    {
        $stgsecpass = Read-Host -Prompt "Enter Password for user $targetHostUser on server $targetHost" -AsSecureString
    }
    else
    {
        $stgsecpass = ($targetHostPassword | ConvertTo-SecureString -AsPlainText -Force)
    }

    $stgcreds = New-Object System.Management.Automation.PSCredential( $targetHostUser, $stgsecpass )
    $stgsess = New-PSSession -cn $targetHost -Credential $stgcreds

    if( $Error.Count -gt 0 )
    {
        $Trace += "Error Establishing PSSession to $targetHost`r`n"
        $Trace += "$Error`r`n"
    }

    try {
        $return = Invoke-Command -Session $stgsess -ScriptBlock { Param($path)
        
            if( (Test-Path $path) -eq $true ) {
                Remove-Item -Path $path -Recurse -Force
            }
        
        } -Args $targetPath
    
    } catch {
        throw $_.Exception    
    } finally {
        Remove-PSSession $stgsess
        $log = $return -join "`r`n"
    }
}

Function New-StagingSession
(
    [Parameter(Mandatory=$true)]
    [string]$stagingHost,
    [Parameter(Mandatory=$true)]
    [string]$stagingPassword,
    [Parameter(Mandatory=$true)]
    [string]$stagingUser
)
{
    $stgpasssec = $stagingPassword | ConvertTo-SecureString -AsPlainText -Force
    $stagingCreds = New-Object System.Management.Automation.PSCredential( $stagingUser, $stgpasssec )
    $sess = New-PSSession -cn $stagingHost -Credential $stagingCreds
    
    $result = Invoke-Command -Session $sess -ScriptBlock {
        Param($stgpath,$stghost)
        Import-Module $stgpath\psh\AppZero.psm1 -ArgumentList $stgpath,$stghost
        Import-Module $stgpath\psh\AppZeroTag.psm1
    } -ArgumentList $stagingPath,$stagingHost
    
    return $sess
}

Function Import-StagingSession
(
    [Parameter(Mandatory=$true)]
    [string]$stagingHost,
    [Parameter(Mandatory=$true)]
    [string]$stagingPassword,
    [Parameter(Mandatory=$true)]
    [string]$stagingUser
)
{
    $sess = New-StagingSession $stagingHost $stagingPassword $stagingUser
    $initscript = 
    "
        Import-Module $stagingPath\psh\AppZero.psm1 -ArgumentList $stagingPath,$stagingHost
        cd $stagingPath
    "
    Invoke-Staging $stagingPath $stagingHost $sess $initscript
    . Import-PSSession $sess -Module AppZero -AllowClobber
}

Function Invoke-Staging
(
    [Parameter(Mandatory=$true)]
    [string]$stagingPath,
    [Parameter(Mandatory=$true)]
    [string]$stagingHost,
    [Parameter(Mandatory=$true)]
    $stagingSession,
    [Parameter(Mandatory=$true)]
    [string]$script 
)
{
    $result = Invoke-Command -Session $stagingSession -ScriptBlock {
        Param($stgpath, $stghost, $stgcmd)
        Import-Module "$stgpath\psh\AppZero.psm1" -ArgumentList $stgpath,$stghost |
            Out-Null
        Import-Module "$stgpath\psh\AppZeroTag.psm1"
        $scriptObj = [scriptblock]::Create($stgcmd)
        & ($scriptObj)
    } -Args $stagingPath, $stagingHost, $script
    return $result
}





#####################  Utility Functions ##############################

function Resolve-Error ($ErrorRecord=$Error[0])
{
   $ErrorRecord | Format-List * -Force
   $ErrorRecord.InvocationInfo |Format-List *
   $Exception = $ErrorRecord.Exception
   for ($i = 0; $Exception; $i++, ($Exception = $Exception.InnerException))
   {   "$i" * 80
       $Exception |Format-List * -Force
   }
}
    





