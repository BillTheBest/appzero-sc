

Param(
    [string]$root = "c:\appzero-sco",
    [string]$stagingHost = "staging1",
    [string]$stagingPassword = 'DemoPa$$',
    [string]$stagingUser = "Administrator",
    [string]$localPath = "c:\Users\Administrator\dev\appzero-field"
)

try {
    
    . $localPath\psh\AppZeroWorkflow.ps1
    
    $sess = New-StagingSession -stagingHost $stagingHost -stagingUser $stagingUser -stagingPassword $stagingPassword
    $script =
    "
        . $root\psh\AppZero.ps1 $root $stagingHost
        Get-PaceSourceInstalledPrograms
    "
    $result = Invoke-Staging -stagingHost $stagingHost -stagingPath $root -stagingSession $sess -Script $script
                    
    $SourceServers = @()
    foreach( $s in $result ) {
        $SourceServers += $s
    }
    return $SourceServers
    

} catch {
    throw $_.Exception
} finally {
    Remove-PSSession $sess
    #$log = $return -join '\n'
}