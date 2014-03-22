
$stagingPath = "c:\appzero-sco"
$stagingHost = "staging1"
$stagingHostUser = "Administrator"
$stagingHostPassword = 'DemoPa$$'


Import-Module $stagingPath\psh\AppZero.psm1 -DisableNameChecking -ArgumentList $stagingPath,$stagingHost
Import-Module $stagingPath\psh\AppZeroTag.psm1 -DisableNameChecking
cd $stagingPath

Reset-PaceData
$sources = Get-PaceSourceInstalledPrograms
$sources | %{
    ConvertTo-PaceTaggedCSV $_
    Set-PaceDefaultGYRTags $_
    Select-PaceProgramsByTag $_ Green
    ConvertTo-PaceRawCSV $_
}
Get-SourceMappFiles
New-VAA
