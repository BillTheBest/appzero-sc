# Copyright (c) 2013-2014 AppZero Software Corporation.  All Rights Reserved.
#

Param(
    [Parameter(Mandatory=$true)]
    $sourceRootPath
)

#Save the current value in the $p variable.
$p = [Environment]::GetEnvironmentVariable("PSModulePath")

#Add the new path to the $p variable. Begin with a semi-colon separator.
if( ($p.Contains($sourceRootPath)) -ne $true ) {
    $p += ";$sourceRootPath\sco"
}

#Add the paths in $p to the PSModulePath value.
[Environment]::SetEnvironmentVariable("PSModulePath",$p)
