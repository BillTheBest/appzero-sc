
Param(
$stagingPath = "c:\appzero-sco",
$localPath = "c:\Users\Administrator\dev\appzero-field",
$stagingHost = "prod1",

$emailUser = "gboschi@appzero.com",
$emailPass = 'ts0tm!tm'
)

$ErrorActionPreference = "Stop"

try {

    $command = {
        Import-Module $localPath\psh\AppZeroWorkflow.psm1
        Initialize-Pace $stagingPath
        Import-Module $localPath\sco\AppZeroActivity.psm1

        $sess = New-AZRemoteSession -TargetHost $stagingHost -LocalBasePath $localPath\servers -TargetPath $stagingPath
    
        . Import-PSSession -Session $sess -Module AppZero,AppZeroTag 

        $servers = Get-PaceSourceInstalledPrograms
        $servers | %{
            ConvertTo-PaceTaggedCsv $_
            Set-PaceDefaultGYRTags $_
            Select-PaceProgramsByTag $_ 
            ConvertTo-PaceRawCsv $_

            Send-DiscoveryOutput $emailUser $emailPass $_
        }

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
    $Trace
} finally {
    if($sess) {
        Remove-PSSession $sess
    }
    #$log = $return -join '\n'
}


