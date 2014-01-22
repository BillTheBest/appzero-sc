# Copyright (c) 2013 AppZero Software Corporation.  All Rights Reserved.
#

Param(
    [Parameter(Mandatory=$true)]
    [string] $root
)

$appzpace = $Env:AppZero_Path + "appzpace.exe"
$credsFile = $(Resolve-Path "$root\servers.csv")

& $appzpace /M /T $(Resolve-Path $credsFile)