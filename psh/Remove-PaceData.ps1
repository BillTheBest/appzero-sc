# Copyright (c) 2013 AppZero Software Corporation.  All Rights Reserved.
#
# Set up a new PACE working repo

Param(
    [string]$targetHost = "staging1",
    [string]$targetPath = "c:\appzero-sco",
    [string]$targetHostUser = "Administrator",
    [string]$targetHostPassword = 'DemoPa$$'
)

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