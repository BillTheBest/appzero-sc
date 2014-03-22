
$stagingPath = "c:\appzero-sco"
$stagingHost = "staging1"
$stagingHostUser = "Administrator"
$stagingHostPassword = 'DemoPa$$'


Import-Module $stagingPath\psh\AppZero.psm1 -DisableNameChecking -ArgumentList $stagingPath,$stagingHost

cd $stagingPath

Write-Host "Resetting Pace Data"
Reset-PaceData

@(1..10) | %{
    Write-Host "Getting Installed Programs $_"
    $sources = Get-PaceSourceInstalledPrograms
    $sources
}
