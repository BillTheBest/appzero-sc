# Copyright (c) 2013 AppZero Software Corporation.  All Rights Reserved.
#
# Executes a scan of multiple servers to build out a pace database for
# subsequent selection and migration

Param(
    [Parameter(Mandatory=$true)]
    [string] $filename
)

$appzpace = $Env:AppZero_Path + "appzpace.exe"

# Get installed program lists using appzpace
Function Get-InstalledPrograms([string]$credentialsFile)
{
    & $appzpace /M /L $credentialsFile |
        tee -Variable output | Out-Host
}

# appzpace /L /M wants to run in the install dir
#  resolve the filepath from cwd first
$fullpath = Resolve-Path $filename
Push-Location $Env:AppZero_Path
Get-InstalledPrograms -credentialsFile $fullpath
Pop-Location




