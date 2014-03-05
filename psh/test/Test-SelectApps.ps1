$stagingHost = "staging1"
$stagingUser = "Administrator"
$stagingPassword = 'DemoPa$$'
$stagingPath = "c:\appzero-sco"
$localPath = "C:\Users\Administrator\dev\appzero-field"
$sourceHost = "wamp"

$ErrorActionPreference = "Stop"


try {
        . $localPath\psh\AppZeroWorkflow.ps1

    $sess = New-StagingSession -stagingHost $stagingHost `
        -stagingUser $stagingUser -stagingPassword $stagingPassword
    
    $script =
    "
        . $stagingPath\psh\AppZero $stagingPath $stagingHost
        Select-PaceProgramsByTag $sourceHost Green
        ConvertTo-PaceRawCsv $sourceHost
    "

     $result = Invoke-Staging -stagingHost $stagingHost `
        -stagingPath $stagingPath -stagingSession $sess -Script $script  

} catch {
    throw $_.Exception
} finally {
    Remove-PSSession $sess
    $log = $return -join '\n'
}

