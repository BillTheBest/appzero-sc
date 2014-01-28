
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
        Param($stgPath,$stgHost)
        
        & $stgPath\psh\Create-MappFile.ps1 -stagingPath $stgPath -stagingHost $stghost
        
    } -Args $stagingPath, $stagingHost
    
} catch {
    throw $_.Exception
} finally {
    Remove-PSSession $sess
    $log = $return -join '\n'
}