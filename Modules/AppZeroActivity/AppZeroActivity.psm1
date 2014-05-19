# Copyright (c) 2013 AppZero Software Corporation.  All Rights Reserved.
#

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

