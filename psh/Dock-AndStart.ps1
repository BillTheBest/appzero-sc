# Copyright (c) 2013 AppZero Software Corporation.  All Rights Reserved.
#

Param(
    [Parameter(Mandatory=$true)]
    [string]$stagingHost,
    [Parameter(Mandatory=$true)]
    [string]$stagingPath,
    [Parameter(Mandatory=$true)]
    [string]$sourceHost
)

$vaas = Join-Path -Path "$stagingPath\servers\$stagingHost\" -ChildPath "VAAs"
$vaa = Join-Path -Path $vaas -ChildPath $sourceHost

Function Get-VaaServiceNames( $vaapath )
{
    $lines = @(& $appzsc $vaapath list | Where { $_ -match "Service " })
    $names = @( $lines | %{ $_ -replace "Service ", "" })
    return $names
}

Function Get-VaaExecutablePaths( $vaapath )
{
    $listpath = "$vaapath\scripts\autoexec"
    $exes = @()
    if( (Test-Path $listpath) -eq $true ) {
        $exes = Get-Content $listpath
    }
    return $exes
}


$appzdock = $Env:AppZero_Path + "appzdock.exe"
$appzstart = $Env:AppZero_Path + "appzstart.exe"
$appzsc = $Env:AppZero_Path + "appzsc.exe"

#-- Dock and Start    

pushd "$Env:AppZero_Path"
 
& $appzdock $vaa |
    tee -Variable output | Out-Null
    
        
$startlist = Get-VaaServiceNames( $vaa )
$startlist | %{ & $appzstart $vaa $_ }

$runlist = Get-VaaExecutablePaths( $vaa )
$runlist | %{ & $appzrun $vaa $_ }
    
popd

return $output