

Param(
    [Parameter(Mandatory=$true)]
    [string]$sourceHost,
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
    $return = Invoke-Command -Session $sess -ScriptBlock {
        Param($stgHost,$stgPath,$srcHost)
        
        pushd "$stgPath\servers\$stgHost\PACE\$srcHost"
        & $stgPath\psh\Select-AppsByTag.ps1
        popd
        
    } -Args $stagingHost, $stagingPath, $sourceHost

} catch {
    throw $_.Exception
} finally {
    Remove-PSSession $sess
    $log = $return -join '\n'
}