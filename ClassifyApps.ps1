﻿# Copyright (c) 2013 AppZero Software Corporation.  All Rights Reserved.
#
# Scan an L.csv file and add a column indicating
#  - Known Good
#  - Known Ugly (Complex)
#  - Known Bad
#  - Unknown

Param(
    [string]$listFile = "L.csv",
    [string]$goodFile = "green.regex",
    [string]$uglyFile = "yellow.regex",
    [string]$badFile = "red.regex"
)

# read classification matching rules
$goodMatches = Get-Content $goodFile
$uglyMatches = Get-Content $uglyFile
$badMatches = Get-Content $badFile

# classification hash
$classify = @{}

Import-Csv $listFile |
    ForEach {
        Write-Host "Product Name is " $_."Product Name"
        $prodName = $_."Product Name"
        
        ForEach( $rule in $goodMatches ) {
            if( $prodName -match $rule ) {
                $classify.Add( $prodName,"Green" )
                break
            }
        }
        
        ForEach( $rule in $uglyMatches ) {
            if( $prodName -match $rule ) {
                $classify.Add( $prodName,"Yellow" )
                break
            }
        }
        
        ForEach( $rule in $badMatches ) {
            if( $prodName -match $rule ) {
                $classify.Add( $prodName,"Red" )
                break
            }
        }
    }


$output = @(Import-Csv $listFile |
    Select-Object *,@{Name='Classification';Expression={$classify[$_."Product Name"]}} )
$outfile = ".\L-classify.csv"
$output | Export-Csv $outfile -NoTypeInformation