# Copyright (c) 2013 AppZero Software Corporation.  All Rights Reserved.
#

Param(
    [Parameter(Mandatory=$true)]
    [string] $filename
)

$appzpace = $Env:AppZero_Path + "appzpace.exe"

& $appzpace /M /C $(Resolve-Path $filename)
& $appzpace /M /T $(Resolve-Path $filename)