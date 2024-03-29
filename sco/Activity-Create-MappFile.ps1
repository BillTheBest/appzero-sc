# Copyright (c) 2013-2014 AppZero Software Corporation
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
# Executes component discovery from the specified target host and creates
# a .Mapp file for each server listed in the target host's staging repository
#
#.DESCRIPTION
#
#.PARAMETER TargetHost
# The host where the operation is to be performed
#
#.PARAMETER TargetPath
# The path on the target host containing the staging repository
#
#.PARAMETER LocalBasePath
# The local path to the staging repository
#
#.EXAMPLE
# Activity-CreateMappFiles "staging1" "c:\az" "c:\autoshares\azstaging"
##############################################################################

Param(
    [Parameter(Mandatory=$true)]
    [string]$TargetHost,
    [Parameter(Mandatory=$true)]
    [string]$TargetPath,
    [Parameter(Mandatory=$true)]
    [string]$LocalBasePath
)

$ErrorActionPreference = "Stop"

try { 

    $command = {

        Import-Module AppZeroActivity
        Import-Module AppZeroWorkflow
        Initialize-Pace $TargetPath, $LocalBasePath

        $sess = New-AZRemoteSession -TargetHost $TargetHost -LocalBasePath $LocalBasePath -TargetPath $TargetPath
    
        . Import-PSSession -Session $sess -Module AppZero,AppZeroTag 

        $servers = Get-SourceMappFiles
        
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
} finally {
    if($sess) {
        Remove-PSSession $sess
    }
}

