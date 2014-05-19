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
# Installs the AppZero Cloud product and AppZero Cmdlets for PowerShell, and
# creates a local copy of the PACE staging repository, on specified target host
#
#.DESCRIPTION
#
#.PARAMETER TargetHost
# The host where the components are to be installed
#
#.PARAMETER TargetPath
# The path on the target host where the components are to be installed
#
#.PARAMETER StagingShare
# The network share containing the staging repository
#
#.PARAMETER CodeShare
# The network share containing the code repository
#
#.PARAMETER StagingShareUser
# The username required to authenticate the network shares
#
#.PARAMETER StagingSharePassword
# The password required to authenticate the network shares
#
#.PARAMETER LocalBasePath
# The local path to the staging repository
#
#.EXAMPLE
# Activity-Install-AppZero "staging1" "c:\az" "\\fileserv1\azstaging" "\\fileserv2\appzero-sc" "azautouser" "P@ssw0rd" "c:\autoshares\azstaging"
##############################################################################

Param(
    [Parameter(Mandatory=$true)]
    [string]$TargetHost,
    [Parameter(Mandatory=$true)]
    [string]$TargetPath,
    [Parameter(Mandatory=$true)]
    [string]$StagingShare,
    [Parameter(Mandatory=$true)]
    [string]$CodeShare,
    [Parameter(Mandatory=$true)]
    [string]$StagingShareUser,
    [Parameter(Mandatory=$true)]
    [string]$StagingSharePassword,
    [Parameter(Mandatory=$true)]
    [string]$LocalBasePath
)

Import-Module AppZeroWorkflow

Initialize-Pace -stagingPath targetPath -LocalBasePath $LocalBasePath
Install-AppZero $TargetHost $TargetPath $StagingShare $CodeShare $StagingShareUser $StagingSharePassword

