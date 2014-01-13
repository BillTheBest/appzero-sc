# Copyright (c) 2013 AppZero Software Corporation.  All Rights Reserved.
#

Param(
    [Parameter(Mandatory=$true)]
    [string] $credsFile
)

$appzpace = $Env:AppZero_Path + "appzpace.exe"

& $appzpace /M /C $(Resolve-Path $credsFile)
