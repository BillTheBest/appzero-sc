# Copyright (c) 2013 AppZero Software Corporation.  All Rights Reserved.
#
# Script to create / edit server list CSV

Param(
    [Parameter(Mandatory=$true)]
    [string] $filename,
    [Parameter(Mandatory=$true)]
    [string] $hostname,
    #[Parameter(Mandatory=$true)]
    #[string] $username = "Administrator",
    [Parameter(Mandatory=$true)]
    [string] $password
)

$entry = New-Object PSObject
$entry | Add-Member -MemberType Noteproperty -Name "Hostname" -Value $hostname
$entry | Add-Member -MemberType Noteproperty -Name "Password" -Value $password

if( Test-Path $filename )
{
    Import-Csv $filename | Write-Host
    $entries = @(Import-Csv $filename)
    Write-Host $entries
}
else
{
    $entries = @()
    Write-Host $entries
}
Write-Host $entry
$entries += $entry
    
Export-Csv -Path $filename -InputObject $entries -NoTypeInformation
