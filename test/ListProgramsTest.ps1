$root = "c:\appzero-sco"
$ErrorActionPreference = "Stop"

try {

$stagingPassword = 'DemoPa$$' | ConvertTo-SecureString -AsPlainText -Force
$stagingUser = "Administrator"
$stagingCreds = New-Object System.Management.Automation.PSCredential( $stagingUser, $stagingPassword )

$sess = New-PSSession -cn "staging1" -Credential $stagingCreds

$return = Invoke-Command -Session $sess -ScriptBlock { Param($r,$f)
    & $r\psh\Scan-Servers.ps1 -root "$r" -filename "$f"
    Write-Host "$root\servers\staging1\servers.csv"
    #& $r\Scan-Servers.bat
} -Args $root, "$root\servers\staging1\servers.csv"

} catch {
    throw $_.Exception
} finally {
    $log = $return -join '\n'
}