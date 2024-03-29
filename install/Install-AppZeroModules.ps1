﻿# Copyright (c) 2013-2014 AppZero Software Corporation.  All Rights Reserved.
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

# Copy the modules to the user-installed modules path
# - first make sure the Modules folder exists or Copy-Item won't do the right thing
if((Test-Path $userModulesPath -PathType Container) -ne $true) {
    New-Item -Path $userModulesPath -ItemType container
}

Copy-Item -Path "$sourceRootPath\Modules\*" -Destination $userModulesPath -Recurse

# Test correct installation by importing some modules
# Import-Module -Name AppZero -Scope Local
Import-Module -Name AppZeroActivity -Scope Local


