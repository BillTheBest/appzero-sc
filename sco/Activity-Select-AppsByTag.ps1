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
# Selects for migration programs classified with a given tag
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
# The local path to the staging repository.  This is used to retrieve the
# saved credentials needed to authenticate to the target host
#
#.PARAMETER SourceHost
# The hostname of the source machine where the installed programs were
# discovered.  This is also the name of the subdirectory of <staging path>\PACE
# where the discovery information is stored.
#
#.PARAMETER TagName
# The tag to select by
#
#.EXAMPLE
# Activity-Select-AppsByTag "staging1" "c:\az" "c:\autoshares\azstaging" "source1" "Green"
##############################################################################

Param(
    [Parameter(Mandatory=$true)]
    [string]$TargetHost,
    [Parameter(Mandatory=$true)]
    [string]$TargetPath,
    [Parameter(Mandatory=$true)]
    [string]$LocalBasePath,
    [Parameter(Mandatory=$true)]
    [string]$SourceHost,
    [Parameter(Mandatory=$true)]
    [string]$TagName
)

$ErrorActionPreference = "Stop"

try { 

    $command = {

        Import-Module AppZeroActivity
        Import-Module AppZeroWorkflow
        Initialize-Pace $TargetPath, $LocalBasePath

        $sess = New-AZRemoteSession -TargetHost $TargetHost -LocalBasePath $LocalBasePath -TargetPath $TargetPath
    
        . Import-PSSession -Session $sess -Module AppZero,AppZeroTag 

        Select-PaceProgramsByTag $SourceHost $TagName
        ConvertTo-PaceRawCsv $SourceHost
        
    }


    $elapsed = Measure-Command $command
    $TimeElapsed = $elapsed.tostring()
    

} catch {
    $Trace += "caught exception `r`n"
    $Trace += $Error[0]
} finally {
    if($sess) {
        Remove-PSSession $sess
    }
}


