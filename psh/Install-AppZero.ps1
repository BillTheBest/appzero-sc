# Copyright (c) 2013 AppZero Software Corporation.  All Rights Reserved.
#
# Set up a new PACE working repo

Param(
    [Parameter(Mandatory=$true)]
    [string]$targetHost,
    
    [Parameter(Mandatory=$true)]
    [string]$version,
    
    [Parameter(Mandatory=$true)]
    [string]$targetPath,
    
    [Parameter(Mandatory=$true)]
    [string]$targetHostUser,
    
    [Parameter(Mandatory=$true)]
    [string]$targetHostPassword,
    
    [Parameter(Mandatory=$true)]
    [string]$stagingShare,
    
    [Parameter(Mandatory=$true)]
    [string]$stagingShareUser,
    
    [Parameter(Mandatory=$true)]
    [string]$stagingSharePassword
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

        $ErrorActionPreference = "Stop"
        
        if( (Test-Path $path) -ne $true ) {
            New-Item -ItemType directory -Path $path
        }

        $sharepasssec = ($sharepass | ConvertTo-SecureString -AsPlainText -Force)
        $shareCreds = New-Object System.Management.Automation.PSCredential( $shareuser, $sharepasssec )

        $success = $true

        try {
            #New-PSDrive -Name "K" -PSProvider "FileSystem" -Root $share -Credential $shareCreds
            net use K: $share $sharepass /user:$shareuser
        } catch {
            $success = $false
            $msg = "Failed to map network drive: "
            $msg += $_.Exception.Message
            throw $msg
        }

        try {
            Copy-Item "$share\*" $path -Recurse -Force
        } catch {
            $success = $false
            $msg = "Failed to copy repo from share: "
            $msg += $_.Exception.Message
            throw $msg
        }

        try {
            Copy-Item "$share\install\$ver\setup.iss" "C:\windows\"
        } catch {
            $success = $false
            throw "Failed to copy .ISS file"
        }
        
        $cmd = "$path\install\$ver\AppZero64-BitSetup.exe /s /f1`"c:\windows\setup.iss`""
        "Running command: $cmd" | Out-File c:\install.log
        cmd /c $cmd |  Out-File c:\install.log -Append

        if($success -eq $true) {
            Restart-Computer -Force
        }
        
    } -Args $targetPath, $stagingShare, $stagingShareUser, $stagingSharePassword, $version

} catch {
    throw $_.Exception    
} finally {
    Remove-PSSession $stgsess
    $log = $return -join "`r`n"
}