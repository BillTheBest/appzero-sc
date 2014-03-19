# Copyright (c) 2013 AppZero Software Corporation.  All Rights Reserved.
#
# Set up a new PACE working repo

Param(
    [string]$targetHost = "staging1",
    [string]$version = "5.4SP1.1",
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
        Param($path,$share,$shareuser,$sharepass,$ver)
        
        if( (Test-Path $path) -ne $true ) {
            New-Item -ItemType directory -Path $path
        }

        $sharepasssec = ($sharepass | ConvertTo-SecureString -AsPlainText -Force)
        $shareCreds = New-Object System.Management.Automation.PSCredential( $shareuser, $sharepasssec )
        New-PSDrive -Name "K" -PSProvider "FileSystem" -Root $share -Credential $shareCreds
        Copy-Item "$share\*" $path -Recurse -Force

        Copy-Item "$share\install\$ver\setup.iss" "C:\windows\"
        $cmd = "$path\install\$ver\AppZero64-BitSetup.exe /s /f1`"c:\windows\setup.iss`""
        "Running command: $cmd" | Out-File c:\install.log
        cmd /c $cmd |  Out-File c:\install.log -Append
        Restart-Computer -Force
        
    } -Args $targetPath, $stagingShare, $stagingShareUser, $stagingSharePassword, $version

} catch {
    throw $_.Exception    
} finally {
    Remove-PSSession $stgsess
    $log = $return -join "`r`n"
}