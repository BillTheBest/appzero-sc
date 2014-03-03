$stagingHost = "staging1"
$stagingUser = "Administrator"
$stagingPassword = 'DemoPa$$'
$stagingPath = "c:\appzero-sco"
$localPath = "C:\Users\Administrator\dev\appzero-field"

$ErrorActionPreference = "Stop"

try {
    . $localPath\psh\AppZeroWorkflow.ps1

    
    $sess = New-StagingSession -stagingHost $stagingHost `
        -stagingUser $stagingUser -stagingPassword $stagingPassword

    $script =
    "
        . $stagingPath\psh\AppZero.ps1 $stagingPath $stagingHost
        Get-SourceMappFiles | %{ Remove-SourceMappFile `$_ }
    "

    $result = Invoke-Staging -stagingHost $stagingHost `
        -stagingPath $stagingPath -stagingSession $sess -Script $script
        
    $SourceServers = @()
    foreach( $s in $result ) {
        $SourceServers += $s
    }
    $SourceServers
    

} catch {
    throw $_.Exception
} finally {
    Remove-PSSession $sess
    $log = $return -join '\n'
}