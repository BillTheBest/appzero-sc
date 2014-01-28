# Copyright (c) 2013 AppZero Software Corporation.  All Rights Reserved.
#

Param(
    [Parameter(Mandatory=$true)]
    [string]$stagingPath,
    [Parameter(Mandatory=$true)]
    [string]$stagingHost
)

$appzpace = $Env:AppZero_Path + "appzpace.exe"

$credsFile = $(Resolve-Path "$stagingPath\servers\$stagingHost\servers.csv")

& $appzpace /M /C $credsFile

