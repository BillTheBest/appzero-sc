# Copyright (c) 2013 AppZero Software Corporation.  All Rights Reserved.
#
# Sequence of discovery time steps

Param(
    [string]$root,
    [string]$repo
)

$rules = "$repo\rules"

cd $root
& $repo\Scan-Servers.ps1 .\servers.csv
$pacePath = "$root\PACE"

$serverPaths = Get-ChildItem -Name $pacePath
$serverPaths | % {
    cd $pacePath\$_
    
    & $repo\ClassifyApps.ps1 .\L.csv $rules\green.regex $rules\yellow.regex $rules\red.regex
    & $repo\Select-AppsByTag.ps1
    & $repo\MassageCSV.ps1
    & $repo\Email-DiscoveryOutput.ps1
}

cd $root
