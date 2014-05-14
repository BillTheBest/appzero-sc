# Copyright (c) 2013 AppZero Software Corporation.  All Rights Reserved.
#

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
    $dotPacePath = Join-Path -Path $LocalBasePath -ChildPath ".pace"
    $credsPath = Join-Path -Path $dotPacePath -ChildPath "$TargetHost.creds"
    $creds = Import-Clixml $credsPath
    $sess = New-PSSession -cn $TargetHost -Credential $creds
    
    $result = Invoke-Command -Session $sess -ScriptBlock {
        Param($stgpath,$stghost)
        Import-Module $stgpath\psh\AppZero.psm1 -ArgumentList $stgpath,$stghost
        Import-Module $stgpath\psh\AppZeroTag.psm1
    } -ArgumentList $TargetPath,$TargetHost
    
    return $sess
}