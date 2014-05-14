# Copyright (c) 2013-2014 AppZero Software Corporation.  All Rights Reserved.
#

Param(
    [Parameter(Mandatory=$true)]
    $sourceRootPath
)



# this is the documented path for user-installed modules
$userModulesPath = "$Home\Documents\WindowsPowerShell\Modules"

# it should be in the system PSModulePath already but make sure
$p = [Environment]::GetEnvironmentVariable("PSModulePath")
if( ($p.Contains($userModulesPath)) -ne $true ) {
    $p += ";$userModulesPath"
    [Environment]::SetEnvironmentVariable("PSModulePath",$p)
}

# Create a module dir and copy the modules to it
$AZModulePath = New-Item -Path (Join-Path -Path $userModulesPath -ChildPath "AppZero") -ItemType directory
Copy-Item -Path "$sourceRootPath\Modules\*" -Destination $AZModulePath

# Do a test import-module and see if it flies
Import-Module -Name AppZeroActivity

