# Copyright (c) 2013 AppZero Software Corporation.  All Rights Reserved.
#



Function New-PaceRepo
(
    [Parameter(Mandatory=$true)]
    [string]$targetHost,
    [Parameter(Mandatory=$true)]
    [string]$targetHostUser,
    [Parameter(Mandatory=$true)]
    [string]$targetHostPassword,
    [Parameter(Mandatory=$true)]
    [string]$targetPath,
    [Parameter(Mandatory=$true)]
    [string]$stagingShare,
    [Parameter(Mandatory=$true)]
    [string]$stagingShareUser,
    [Parameter(Mandatory=$true)]
    [string]$stagingSharePassword
)
{

    $ErrorActionPreference = "Stop"
    $Trace = "Setup PACE Working Repo Activity `r`n"

    $stgsecpass = ($targetHostPassword | ConvertTo-SecureString -AsPlainText -Force)
    $stgcreds = New-Object System.Management.Automation.PSCredential( $targetHostUser, $stgsecpass )
    $stgsess = New-PSSession -cn $targetHost -Credential $stgcreds

    if( $Error.Count -gt 0 )
    {
        $Trace += "Error Establishing PSSession to $targetHost`r`n"
        $Trace += "$Error`r`n"
    }

    try {
        $return = Invoke-Command -Session $stgsess -ScriptBlock {
            Param($path,$share,$shareuser,$sharepass)
        
            if( (Test-Path $path) -ne $true ) {
                New-Item -ItemType directory -Path $path
            }

            if(!(Test-Path "K:\")) {
                $sharepasssec = ($sharepass | ConvertTo-SecureString -AsPlainText -Force)
                $shareCreds = New-Object System.Management.Automation.PSCredential( $shareuser, $sharepasssec )
                New-PSDrive -Name "K" -PSProvider "FileSystem" -Root $share -Credential $shareCreds
            }

            Copy-Item "K:\*" $path -Recurse -Force 
        
        } -Args $targetPath, $stagingShare, $stagingShareUser, $stagingSharePassword

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
    [string]$targetPath = "c:\appzero-sco",
    [string]$targetHostUser = "Administrator",
    [string]$targetHostPassword = 'DemoPa$$'
)
{

    $ErrorActionPreference = "Stop"
    $Trace = "Remove PACE Working Repo Activity `r`n"

    $stgsecpass = ($targetHostPassword | ConvertTo-SecureString -AsPlainText -Force)
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

Function Clear-PaceData
(
    [Parameter(Mandatory=$true)]
    [string]$targetHost,
    [string]$targetPath = "c:\appzero-sco",
    [string]$targetHostUser = "Administrator",
    [string]$targetHostPassword = 'DemoPa$$'
)
{

    $ErrorActionPreference = "Stop"
    $Trace = "Remove PACE Working Repo Activity `r`n"

    $stgsecpass = ($targetHostPassword | ConvertTo-SecureString -AsPlainText -Force)
    $stgcreds = New-Object System.Management.Automation.PSCredential( $targetHostUser, $stgsecpass )
    $stgsess = New-PSSession -cn $targetHost -Credential $stgcreds

    if( $Error.Count -gt 0 )
    {
        $Trace += "Error Establishing PSSession to $targetHost`r`n"
        $Trace += "$Error`r`n"
    }

    try {
        $return = Invoke-Command -Session $stgsess -ScriptBlock { Param($tgthost,$path)
        
            $pacepath = "$path\servers\$tgthost\PACE"
            if( (Test-Path $pacepath ) -eq $true ) {
                Remove-Item -Path $pacepath -Recurse -Force
            }
        
        } -Args $targetHost, $targetPath
    
    } catch {
        throw $_.Exception    
    } finally {
        Remove-PSSession $stgsess
        $log = $return -join "`r`n"
    }
}


Function New-StagingSession
(
    [Parameter(Mandatory=$true)][string]$stagingHost,
    [Parameter(Mandatory=$true)][string]$stagingPassword,
    [Parameter(Mandatory=$true)][string]$stagingUser
)
{
    $stgpasssec = $stagingPassword | ConvertTo-SecureString -AsPlainText -Force
    $stagingCreds = New-Object System.Management.Automation.PSCredential( $stagingUser, $stgpasssec )
    $sess = New-PSSession -cn $stagingHost -Credential $stagingCreds
    return $sess
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
        . "$stgpath\psh\AppZero.ps1" -rootPath $stgpath -stagingHost $stghost |
            Out-Null
        . "$stgpath\psh\AppZeroTag.ps1"
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
    





