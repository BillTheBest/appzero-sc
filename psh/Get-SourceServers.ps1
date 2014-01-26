# Copyright (c) 2013 AppZero Software Corporation.  All Rights Reserved.
#
# Executes a scan of multiple servers to build out a pace database for
# subsequent selection and migration

Param(
    [Parameter(Mandatory=$true)]
    [string] $root,
    [Parameter(Mandatory=$true)]
    [string] $stagingHost
)


return Get-ChildItem -Path "$root\servers\$stagingHost\PACE" -Name







