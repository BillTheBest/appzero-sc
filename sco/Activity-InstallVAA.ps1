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
# Retrieves a VAA from a network share and installs it (dissolves it) onto
# the specified target host
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
#.PARAMETER vaashare
# A UNC path to a network share where the VAA is stored.
#
#.PARAMETER vaashareUser
# The username required to authenticate the network share
#
#.PARAMETER vaasharePassword
# The password required to authenticate the network share
#
#.EXAMPLE
# Activity-InstallVAA "staging1" "c:\az" "c:\autoshares\azstaging" "source1" "\\fileserv1\vaastore" "azautouser" "P@ssw0rd"
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
    [string]$vaashare,
    [Parameter(Mandatory=$true)]
    [string]$vaashareUser,
    [Parameter(Mandatory=$true)]
    [string]$vaasharePassword

)

$ErrorActionPreference = "Stop"

try { 

    $command = {

        Import-Module AppZeroActivity
        Import-Module AppZeroWorkflow
        Initialize-Pace $TargetPath, $LocalBasePath

        $sess = New-AZRemoteSession -TargetHost $TargetHost -LocalBasePath $LocalBasePath -TargetPath $TargetPath
    
        . Import-PSSession -Session $sess -Module AppZero,AppZeroTag 

        $secsharePassword = ($vaasharePassword | ConvertTo-SecureString -AsPlainText -Force)
        $creds = New-Object System.Management.Automation.PSCredential( $vaashareUser, $secsharePassword )

        Install-VAA -source $SourceHost -vaashare $vaashare -Credential $creds
        
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




