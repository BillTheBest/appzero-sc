
$stagingPath = "c:\appzero-sco"
$stagingHost = "staging1"
$stagingHostUser = "Administrator"
$stagingHostPassword = 'DemoPa$$'


Import-Module $stagingPath\psh\AppZero.psm1 -DisableNameChecking -ArgumentList $stagingPath,$stagingHost
Import-Module $stagingPath\psh\AppZeroTag.psm1 -DisableNameChecking
cd $stagingPath


Reset-PaceData
Write-Host "Getting Installed Programs $_"
$sources = Get-PaceSourceInstalledPrograms
$sources
$sources | %{
    ConvertTo-PaceTaggedCSV $_
    Set-PaceDefaultGYRTags $_
    Select-PaceProgramsByTag $_ Green
    ConvertTo-PaceRawCSV $_
}
Write-Host "Creating Mapp File $_"
$mapps = Get-SourceMappFiles
$mapps

Write-Host "Creating VAAs $_"
$vaas = New-VAA
$vaas
    

