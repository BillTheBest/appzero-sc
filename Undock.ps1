# Copyright (c) 2013 AppZero Software Corporation.  All Rights Reserved.
#

Param(
    [Parameter(Mandatory=$true)]
    [string]$vaaname
)


#$vaas = Join-Path -Path $root -ChildPath "VAAs"
#$vaa = Join-Path -Path $vaas -ChildPath $vaaname
$vaa = "C:\sco\VAAs\wamp"

$appzundock = $Env:AppZero_Path + "appzundock.exe"

pushd "c:\Program Files\AppZero"
 
& $appzundock $vaa

popd

    

