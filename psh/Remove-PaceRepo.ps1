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
    $return = Invoke-Command -Session $stgsess -ScriptBlock { Param($path)
        
        if( (Test-Path $path) -eq $true ) {
            Remove-Item -Path $path -Recurse -Force
        }
        
    } -Args $targetPath
    
    Remove-PSSession $stgsess
    
} finally {
    $log = $return -join "`r`n"
}