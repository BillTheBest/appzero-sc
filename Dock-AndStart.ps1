# Copyright (c) 2013 AppZero Software Corporation.  All Rights Reserved.
#

Param(
    [Parameter(Mandatory=$true)]
    [string]$vaa
)

Function Get-VaaServiceNames( $vaapath )
{
    $lines = @(& $appzsc $vaapath list | Where { $_ -match "Service " })
    $names = @( $lines | For-EachObject { $_ -replace "Service ", "" })
    return $names
}

Function Get-VaaExecutablePaths( $vaapath )
{
    $listpath = "$vaapath\scripts\autoexec"
    $exes = @()
    if( Test-Path $listpath -eq $true ) {
        $exes = Get-Content $listpath
    }
    return $exes
}


$appzdock = $Env:AppZero_Path + "appzdock.exe"
$appzstart = $Env:AppZero_Path + "appzstart.exe"
$appzsc = $Env:AppZero_Path + "appzsc.exe"

#-- Dock and Start    
 
Write-Host "Docking vaa"
& $appzdock $vaa |
    tee -Variable output | Out-Host
    
        
$startlist = Get-VaaServiceNames( $vaa )
$startlist | { & $appzstart $vaa $_ }

$runlist = GetVaaExecutablePaths( $vaa )
$runlist | { & $appzrun $vaa $_
    

