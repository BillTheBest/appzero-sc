# Copyright (c) 2013 AppZero Software Corporation.  All Rights Reserved.
#
# Setup a PACE working repository at a specified root folder location
# - maps 

Param(
    [Parameter(Mandatory=$true,Position=0)]
    [string]$repo,
    [Parameter(Mandatory=$true,Position=1)]
    [string]$root
)

#$repo = Resolve-Path -Path "$repo"
New-PSDrive -Name "K" -PSProvider FileSystem -Root "$repo" -Persist



if( ( Test-Path $root ) -ne $true ) {
    New-Item -Type directory -Path $root
    $root = Resolve-Path $root
}

Copy-Item K:\test\servers.csv $root\servers.csv

if( ( Test-Path $root\PACE ) -eq $true ) {
    del $root\PACE -Recurse
}

if( ( Test-Path $root\VAAs ) -eq $true ) {
    del $root\VAAs -Recurse
}
