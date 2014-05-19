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
# Starts a VAA, docking it if not already docked.
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
# The source host name of the server from which the VAA was extracted.  This
# is also the name of the VAA
#
#.EXAMPLE
# Activity-StartVAA "staging1" "c:\az" "c:\autoshares\azstaging" "source1"
##############################################################################

Param(
    [Parameter(Mandatory=$true)]
    [string]$TargetHost,
    [Parameter(Mandatory=$true)]
    [string]$TargetPath,
    [Parameter(Mandatory=$true)]
    [string]$LocalBasePath,
    [Parameter(Mandatory=$true)]
    [string]$SourceHost
)


$ErrorActionPreference = "Stop"

try { 

    $command = {

        Import-Module AppZeroActivity
        Import-Module AppZeroWorkflow
        Initialize-Pace $TargetPath, $LocalBasePath

        $sess = New-AZRemoteSession -TargetHost $TargetHost -LocalBasePath $LocalBasePath -TargetPath $TargetPath
    
        . Import-PSSession -Session $sess -Module AppZero,AppZeroTag 

        Start-VAA -source $SourceHost
        
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



