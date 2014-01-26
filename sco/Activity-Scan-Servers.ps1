

Param(
    [string]$root = "c:\appzero-sco",
    [string]$stagingHost = "staging1",
    [string]$stagingPassword = 'DemoPa$$',
    [string]$stagingUser = "Administrator"
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
        Param($r,$stghost,$f,$Trace)
        
        & $r\psh\Scan-Servers.ps1 -root $r -stagingHost $stghost -filename $f
        
    } -Args $root, $stagingHost, "$root\servers\$stagingHost\servers.csv"
    return $result

} catch {
    throw $_.Exception
} finally {
    Remove-PSSession $sess
    $log = $return -join '\n'
}