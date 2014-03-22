
$stagingPath = "c:\appzero-sco"
$localPath = "C:\Users\Administrator\dev\appzero-field"
$stagingHost = "staging1"
$stagingHostUser = "Administrator"
$stagingHostPassword = 'DemoPa$$'

Import-Module "$localPath\psh\AppZeroWorkflow.psm1"
Initialize-Pace $stagingPath
$sess = New-StagingSession $stagingHost $stagingHostPassword $stagingHostUser
$initscript = 
"
    Import-Module $stagingPath\psh\AppZero.psm1 -DisableNameChecking -ArgumentList $stagingPath,$stagingHost
    Import-Module $stagingPath\psh\AppZeroTag.psm1 -DisableNameChecking
    cd $stagingPath
"
Invoke-Staging $stagingPath $stagingHost $sess $initscript
. Import-PSSession $sess -Module AppZero,AppZeroTag -AllowClobber

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
