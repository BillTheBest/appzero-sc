# Copyright (c) 2013 AppZero Software Corporation.  All Rights Reserved.
#
# Scan an L.csv file and add a column indicating
#  - Known Good
#  - Known Ugly (Complex)
#  - Known Bad
#  - Unknown

Param(
    [string]$listFile = "L.csv",
    [string]$goodFile = "..\..\..\repo\rules\green.regex",
    [string]$uglyFile = "..\..\..\repo\rules\yellow.regex",
    [string]$badFile = "..\..\..\repo\rules\red.regex"
)

# read classification matching rules
#  each line a name or regex match to installed program names
$goodMatches = Get-Content $goodFile
$uglyMatches = Get-Content $uglyFile
$badMatches = Get-Content $badFile

# classification hash [ program name => tag ]
$classify = @{}

# process the rules and assign the tags
Import-Csv $listFile |
    ForEach {
        #Write-Host "Product Name is " $_."Product Name"
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

# read in again, add tag column and values
$output = @(Import-Csv $listFile |
    Select-Object *,@{Name='Tag';Expression={$classify[$_."Product Name"]}} )
    
# add planning columns for project use
$output = $output | Select-Object *, `
    @{Name="Business App";Expression={}}, `
    @{Name="Maint Window";Expression={}}, `
    @{Name="Apps Owner";Expression={}}, `
    @{Name="Apps Email";Expression={}}, `
    @{Name="Ops Owner";Expression={}}, `
    @{Name="Ops Email";Expression={}}, `
    @{Name="Drive Layout";Expression={}}, `
    @{Name="GB Size";Expression={}}, `
    @{Name="Source OS";Expression={}}, `
    @{Name="Target OS";Expression={}}, `
    @{Name="Notes";Expression={}}

# save output
$outfile = ".\L-classify.csv"
$output | Export-Csv $outfile -NoTypeInformation
