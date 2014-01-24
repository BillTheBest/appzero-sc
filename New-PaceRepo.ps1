$targetPath = "c:\appzero-sco"
$targetHost = "staging1"
$ErrorActionPreference = "Stop"

$Trace = "Setup PACE Working Repo Activity `r`n"

$stagingPassword = 'DemoPa$$' | ConvertTo-SecureString -AsPlainText -Force
$stagingUser = "Administrator"
$stagingCreds = New-Object System.Management.Automation.PSCredential( $stagingUser, $stagingPassword )
$stgsess = New-PSSession -cn $targetHost -Credential $stagingCreds

if( $Error.Count -gt 0 )
{
    $Trace += "Error Establishing PSSession to $targetHost`r`n"
    $Trace += "$Error`r`n"
}

try {
    $return = Invoke-Command -Session $stgsess -ScriptBlock { Param($path,$uncrepo)
        if( (Test-Path $path) -ne $true ) {
            New-Item -ItemType directory -Path $path
            New-Item -ItemType directory -Path "$path\psh"
            New-Item -ItemType directory -Path "$path\servers"
        }
        $repoPassword = 'DemoPa$$' | ConvertTo-SecureString -AsPlainText -Force
        $repoUser = "sco\Administrator"
        $repoCreds = New-Object System.Management.Automation.PSCredential( $repoUser, $repoPassword )
        New-PSDrive -Name "K" -PSProvider "FileSystem" -Root "$uncrepo" -Credential $repoCreds
        Copy-Item $uncrepo\* $path\psh -Recurse -Force 
    } -Args $targetPath, "\\sco\appzero-field"
    
    Remove-PSSession $stgsess
    
} finally {
    $log = $return -join "`r`n"
}