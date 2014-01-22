# Copyright (c) 2013 AppZero Software Corporation.  All Rights Reserved.
#

Param(
    [Parameter(Mandatory=$true)]
    [string]$vaa
)




$appzundock = $Env:AppZero_Path + "appzundock.exe"

pushd "c:\Program Files\AppZero"
 
Write-Host "Undocking vaa"
& $appzundock $vaa |
    tee -Variable output | Out-Host

popd

    

