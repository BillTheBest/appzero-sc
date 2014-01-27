# Copyright (c) 2013 AppZero Software Corporation.  All Rights Reserved.
#
# Scan an L.csv file and add a column indicating
#  - Known Good
#  - Known Ugly (Complex)
#  - Known Bad
#  - Unknown

Param(
    [Parameter(Mandatory=$true)]
    [string]$stagingHost,
    [Parameter(Mandatory=$true)]
    [string]$stagingPath,
    [Parameter(Mandatory=$true)]
    [string]$sourceHost
)

$listFile = "$stagingPath\servers\$stagingHost\PACE\$sourceHost\L.csv"

# read classification matching rules
#  each line a name or regex match to installed program names
$goodMatches = Get-Content $stagingPath\rules\green.regex
$uglyMatches = Get-Content $stagingPath\rules\yellow.regex
$badMatches = Get-Content $stagingPath\rules\red.regex

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
$outfile = Join-Path -Path ( Split-Path -Path $listFile -Parent ) -ChildPath ".\L-classify.csv"
$output | Export-Csv $outfile -NoTypeInformation
