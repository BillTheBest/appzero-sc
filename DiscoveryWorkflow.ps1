# Copyright (c) 2013 AppZero Software Corporation.  All Rights Reserved.
#
# Strip quotes and 2nd-row comma to make PACE happy

Param(
    [string]$root,
    [string]$repo
)

$rules = "$repo\rules"

cd $root
& K:\Scan-Servers.ps1 .\servers.csv
$pacePath = "$root\PACE"

$serverPaths = Get-ChildItem -Name $pacePath
$serverPaths | % {
    cd $pacePath\$_
    
    & K:\ClassifyApps.ps1 .\L.csv $rules\green.regex $rules\yellow.regex $rules\red.regex
    & K:\Select-AppsByTag.ps1
    & K:\MassageCSV.ps1
    & K:\Email-DiscoveryOutput.ps1
}

cd $root
