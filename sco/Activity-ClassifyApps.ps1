

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

    . $localPath\psh\AppZeroWorkflow.ps1

    $sess = New-StagingSession -stagingHost $stagingHost `
        -stagingUser $stagingUser -stagingPassword $stagingPassword
        
    $script =
    "
        . $root\psh\AppZero.ps1 $root $stagingHost
        . $root\psh\AppZeroTag.ps1
        ConvertTo-PaceTaggedCSV $sourceHost
        Set-PaceDefaultGYRTags $sourceHost
    "

    $result = Invoke-Staging -stagingHost $stagingHost `
        -stagingPath $stagingPath -stagingSession $sess -ScriptBlock {
            $script
        } 

} catch {
    throw $_.Exception
} finally {
    Remove-PSSession $sess
    $log = $return -join '\n'
}