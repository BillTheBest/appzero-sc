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

Import-Module AppZeroWorkflow

Function New-AZRemoteSession
(
    [Parameter(Mandatory=$true)]
    [string]$TargetHost,
    [Parameter(Mandatory=$true)]
    [string]$LocalBasePath,
    [Parameter(Mandatory=$true)]
    [string]$TargetPath
)
{
    
    $creds = Get-AZRemoteCredentials -TargetHost $TargetHost -LocalBasePath $LocalBasePath
    $sess = New-PSSession -cn $TargetHost -Credential $creds
    
    $result = Invoke-Command -Session $sess -ScriptBlock {
        Param($stgpath,$stghost)
        Import-Module AppZero -ArgumentList $stgpath,$stghost
        Import-Module AppZeroTag
    } -ArgumentList $TargetPath,$TargetHost
    
    return $sess
}

