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

$entries = @()

if( Test-Path $filename )
{
    Import-Csv $filename | Write-Host
    $entries = @(Import-Csv $filename)
    #Write-Host $entries
}

#Write-Host $entryrigen
$entries += $entry
#Write-Host $entries
    
$entries | Export-Csv -Path $filename -NoTypeInformation
