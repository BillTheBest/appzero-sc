
Param(
$stagingPath = "c:\appzero-sco",
$stagingPassword ='P@ssw0rd',
$stagingUser = "Administrator",
$localPath = "c:\Users\Administrator\dev\appzero-field",
$stagingHost = "prod1",
$source = "wamp",
$vaashare = "\\sco\vaastore"
)

$ErrorActionPreference = "Stop"

$secsharePassword = ($stagingPassword | ConvertTo-SecureString -AsPlainText -Force)
$creds = New-Object System.Management.Automation.PSCredential( $stagingUser, $secsharePassword )

try { 

    $command = {
        Import-Module $localPath\psh\AppZeroWorkflow.psm1
        Initialize-Pace $stagingPath

        $sess = New-StagingSession -stagingHost $stagingHost `
            -stagingUser $stagingUser -stagingPassword $stagingPassword
    
        . Import-PSSession -Session $sess -Module AppZero,AppZeroTag 

        Install-VAA $source $vaashare $creds
        
    }


    $elapsed = Measure-Command $command
    $TimeElapsed = $elapsed.tostring()

    $SourceServers = @()
    foreach( $s in $servers) {
        $SourceServers += $s
    }
    $SourceServers
    

} catch {
    $Trace += "caught exception `r`n"
    $Trace += $Error[0]
} finally {
    Remove-PSSession $sess
    #$log = $return -join '\n'
}


