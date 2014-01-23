# Copyright (c) 2013 AppZero Software Corporation.  All Rights Reserved.
#
# Executes a scan of multiple servers to build out a pace database for
# subsequent selection and migration

Param(
    [Parameter(Mandatory=$true)]
    [string] $root,
    [Parameter(Mandatory=$true)]
    [string] $filename
)

$appzpace = $Env:AppZero_Path + "appzpace.exe"

# Get installed program lists using appzpace
Function Get-InstalledPrograms([string]$credentialsFile)
{
    & $appzpace /M /L $credentialsFile
}

# appzpace /L /M wants to run in the install dir
#  resolve the filepath from cwd first
Push-Location $root
$fullpath = Resolve-Path $filename
Pop-Location
Push-Location $Env:AppZero_Path
Get-InstalledPrograms -credentialsFile $fullpath
Pop-Location




