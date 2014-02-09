
Param(
    [string]$stagingHost = "staging1",
    [string]$stagingPassword = 'DemoPa$$',
    [string]$stagingUser = "Administrator",
    [string]$stagingPath = "c:\appzero-sco"
)

$ErrorActionPreference = "Stop"

$stgpasssec = $stagingPassword | ConvertTo-SecureString -AsPlainText -Force
$stagingCreds = New-Object System.Management.Automation.PSCredential( $stagingUser, $stgpasssec )
$sess = New-PSSession -cn $stagingHost -Credential $stagingCreds

if( $Error.Count -gt 0 )
{
    $Trace += "Error Establishing PSSession to $targetHost`r`n"
    $Trace += "$Error`r`n"
}

try {

    $result = Invoke-Command -Session $sess -ScriptBlock {
        Param($stgPath, $stgHost,$f)
        . $stgPath\psh\AppZero.ps1 -rootPath $stgPath -stagingHost $stgHost
        
        New-VAA
    
    } -Args $stagingPath, $stagingHost, "$root\servers\$stagingHost\servers.csv"
    
} catch {
    throw $_.Exception
} finally {
    Remove-PSSession $sess
    $log = $return -join '\n'
}