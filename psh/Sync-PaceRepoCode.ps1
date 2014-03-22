# Copyright (c) 2013 AppZero Software Corporation.  All Rights Reserved.
#
# Set up a new PACE working repo

Param(
    [string]$targetHost = "staging1",
    [string]$targetPath = "c:\appzero-sco",
    [string]$targetHostUser = "Administrator",
    [string]$targetHostPassword = 'DemoPa$$',
    [string]$stagingShare = "\\sco\appzero-field",
    [string]$stagingShareUser = "sco\Administrator",
    [string]$stagingSharePassword = 'DemoPa$$'
)

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
        
        if( (Test-Path $path) -eq $true ) {
            $sharepasssec = ($sharepass | ConvertTo-SecureString -AsPlainText -Force)
            $shareCreds = New-Object System.Management.Automation.PSCredential( $shareuser, $sharepasssec )
            New-PSDrive -Name "K" -PSProvider "FileSystem" -Root $share -Credential $shareCreds
            Copy-Item "$share\psh\*" "$path\psh" -Recurse -Force 
        }

        
        
    } -Args $targetPath, $stagingShare, $stagingShareUser, $stagingSharePassword

} catch {
    throw $_.Exception    
} finally {
    Remove-PSSession $stgsess
    $log = $return -join "`r`n"
}