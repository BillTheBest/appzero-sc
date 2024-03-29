
Param(
    [Parameter(Mandatory=$true)]
    [string]$sourceHost,
    [string]$stagingHost = "staging1",
    [string]$stagingPassword = 'DemoPa$$',
    [string]$stagingUser = "Administrator"


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
        Param($stgPath,$stgHost,$srcHost)
        
        & $stgPath\psh\New-RDP.ps1 -Path "$stgPath\servers\$stgHost\PACE\$srcHost\$srcHost.rdp" -Server $srcHost -Force

    } -Args $stagingPath, $stagingHost, $sourceHost
    
} catch {
    throw $_.Exception
} finally {
    Remove-PSSession $sess
    $log = $return -join '\n'
}


$return = Invoke-Command -Session $sess -ScriptBlock {
    Param($r,$v)
    & c:\repo\New-RDP.ps1 -Path "$r\PACE\$v\$v.rdp" -Server $v -Force
} -Args $root, $vaa