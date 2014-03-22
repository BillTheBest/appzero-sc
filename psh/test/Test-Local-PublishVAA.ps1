
Param
(
    [Parameter(Mandatory=$true)]
    [string]$source
)

$stagingPath = "c:\appzero-sco"
$stagingHost = "staging1"
$shareUser = "Administrator"
$sharePassword = 'DemoPa$$'


Import-Module $stagingPath\psh\AppZero.psm1 -DisableNameChecking -ArgumentList $stagingPath,$stagingHost
Import-Module $stagingPath\psh\AppZeroTag.psm1 -DisableNameChecking
cd $stagingPath

$secsharePassword = ($sharePassword | ConvertTo-SecureString -AsPlainText -Force)
$creds = New-Object System.Management.Automation.PSCredential( $shareUser, $secsharePassword )

Publish-VAA $source \\sco\vaastore $creds

    

