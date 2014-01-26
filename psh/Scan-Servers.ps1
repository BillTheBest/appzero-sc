# Copyright (c) 2013 AppZero Software Corporation.  All Rights Reserved.
#
# Executes a scan of multiple servers to build out a pace database for
# subsequent selection and migration

Param(
    [Parameter(Mandatory=$true)]
    [string] $root,
    [Parameter(Mandatory=$true)]
    [string] $stagingHost,
    [Parameter(Mandatory=$true)]
    [string] $filename
    
)

$appzpace = $Env:AppZero_Path + "appzpace.exe"

$fullpath = Resolve-Path $filename
$log = Join-Path -Path (Split-Path -Parent $fullpath) -ChildPath "PaceLog.txt"

# Get installed program lists using appzpace
Function Get-InstalledPrograms([string]$credentialsFile)
{
    & $appzpace /M /L $credentialsFile |
        Out-File $log -Append
    $sources = Get-ChildItem -Path $root\servers\$stagingHost\PACE -Name
    return $sources
}

# appzpace /L /M wants to run in the install dir
#  resolve the filepath from cwd first

Get-InstalledPrograms -credentialsFile $fullpath






