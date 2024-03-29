﻿# Copyright (c) 2013-2014 AppZero Software Corporation
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


##############################################################################
#.SYNOPSIS
# Executes discovery of installed programs from the specified target host.
#
#.DESCRIPTION
#
#.PARAMETER TargetHost
# The host where the components are to be installed
#
#.PARAMETER TargetPath
# The path on the target host where the operation is to be performed.
#
#.PARAMETER LocalBasePath
# The local path to the staging repository.  This is used to retrieve the
# saved credentials needed to authenticate to the target host
#
#.PARAMETER emailUser
# The username of an email account used to distribute reports
#
#.PARAMETER emailPassword
# The password of an email account used to distribute reports
#
#.EXAMPLE
# Activity-DiscoveryInstalledPrograms "staging1" "c:\az" "c:\autoshares\azstaging" "azuser@contoso.com" "P@ssw0rd"
##############################################################################

Param(
    [Parameter(Mandatory=$true)]
    [string]$TargetHost,
    [Parameter(Mandatory=$true)]
    [string]$TargetPath,
    [Parameter(Mandatory=$true)]
    [string]$LocalBasePath,
    [Parameter(Mandatory=$true)]
    [string]$emailUser,
    [Parameter(Mandatory=$true)]
    [string]$emailPass
)

$ErrorActionPreference = "Stop"

try {

    $command = {
        
        Import-Module AppZeroActivity
        Import-Module AppZeroWorkflow

        Initialize-Pace -stagingPath $TargetPath -LocalBasePath $LocalBasePath

        $sess = New-AZRemoteSession -TargetHost $TargetHost -LocalBasePath $LocalBasePath -TargetPath $TargetPath
    
        . Import-PSSession -Session $sess -Module AppZero,AppZeroTag 

        $servers = Get-PaceSourceInstalledPrograms
        $servers | %{
            ConvertTo-PaceTaggedCsv $_
            Set-PaceDefaultGYRTags $_
            Select-PaceProgramsByTag $_ 
            ConvertTo-PaceRawCsv $_

            #Send-DiscoveryOutput $emailUser $emailPass $_
        }

    }

    $elapsed = Measure-Command $command
    $TimeElapsed = $elapsed.tostring()

    $SourceServers = @()
    foreach( $s in $servers) {
        $SourceServers += $s
    }
    $SourceServers
    

} catch {
    $Trace += "caught exception `r`n"
    $Trace += $Error[0]
    $Trace
} finally {
    if($sess) {
        Remove-PSSession $sess
    }
    #$log = $return -join '\n'
}


