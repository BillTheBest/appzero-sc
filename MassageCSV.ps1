# Copyright (c) 2013 AppZero Software Corporation.  All Rights Reserved.
#
# Strip quotes and 2nd-row comma to make PACE happy

Param(
    [string]$listFile = "L.csv"
)

$lines = Get-Content $listFile
# blank the second row
$lines[1] = ""
# strip quotes
$lines | % { $_ -replace '"',"" } | Out-File $listFile -Encoding ASCII

