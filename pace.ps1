# Copyright (c) 2013 AppZero Software Corporation.  All Rights Reserved.
#
# Script Functions for PACE Discovery

Param(
    [Parameter(Mandatory=$true)]
    [string] $filename,
    [Parameter(Mandatory=$true)]
    [string] $pattern
)

$appzpace = $Env:AppZero_Path + "appzpace.exe"

# Get installed program lists using appzpace
Function Get-InstalledPrograms([string]$credentialsFile)
{
    & $appzpace /M /L $credentialsFile |
        tee -Variable output | Out-Host
}

Function Select-InstalledPrograms([string]$listFile, [string]$regex)
{
    $programs = @()
    $programs = @(Import-Csv -Path $listfile)
    
    $programs | foreach {
        $programName = $_."Product Name"
        if( $programName -match $regex )
        {
            $_."Select?" = "yes"
        }
    }
    
    $programs | Export-Csv -Path $listFile -NoTypeInformation
}



Select-InstalledPrograms -listFile $filename -regex $pattern


