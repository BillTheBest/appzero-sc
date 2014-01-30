# Copyright (c) 2013 AppZero Software Corporation.  All Rights Reserved.
#


Param(
    
)

Function ConvertTo-RawPaceCSV
(
    [Parameter(Mandatory=$true)]
    [ValidateScript({[System.IO.Path]::IsPathRooted($_)})]
    [string]$listFile = "L.csv"
)
{
    $lines = Get-Content $listFile
    # blank the second row
    $lines[1] = ""
    # strip quotes and ascii-encode
    $lines | % { $_ -replace '"',"" } |
        Out-File $listFile -Encoding ASCII
}

Function ConvertTo-TaggedPaceCSV
(
    [Parameter(Mandatory=$true)]
    [ValidateScript({
        [System.IO.Path]::IsPathRooted($_)
        Test-Path -Path $_ -IsValid -PathType Leaf
    })]
    [string]$rawCsv,
    [Parameter(Mandatory=$true)]
    [ValidateScript({
        [System.IO.Path]::IsPathRooted($_)
        Test-Path -Path $_ -IsValid -PathType Leaf
    })]
    [string]$taggedCsv = ".\L-classify.csv"
)
{
    #TODO:  add read in of user column lists and tag files

    # read in, add tag column and values
    $output = @(Import-Csv $rawCsv |
        Select-Object *,@{Name='Tag';Expression={$classify[$_."Product Name"]}} )
        
    # add default set of annotation columns
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
    $outfile = Join-Path -Path ( Split-Path -Path $rawCsv -Parent ) -ChildPath $taggedCsv
    $output | Export-Csv $outfile -NoTypeInformation
}

Function Select-PaceProgramTags
(
    [Parameter(Mandatory=$true)]
    [ValidateScript({
        [System.IO.Path]::IsPathRooted($_)
        Test-Path -Path $_ -IsValid -PathType Leaf
    })]
    [string]$taggedCsv
)
{
    # read classification matching rules
    #  each line a name or regex match to installed program names
    $goodMatches = Get-Content $stagingPath\rules\green.regex
    $uglyMatches = Get-Content $stagingPath\rules\yellow.regex
    $badMatches = Get-Content $stagingPath\rules\red.regex

    # classification hash [ program name => tag ]
    $classify = @{}

    # process the rules and assign the tags
    Import-Csv $taggedCsv |
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

    # read in again, set the tag values
    #$output = @(Import-Csv $listFile |
    #    Select-Object *,@{Name='Tag';Expression={$classify[$_."Product Name"]}} )
    $output = @(Import-Csv $taggedCsv | %{ $_.Tag = $classify[$_."Product Name"] } )
        
    # add planning columns for project use
    #$output = $output | Select-Object *, `
    #    @{Name="Business App";Expression={}}, `
    #    @{Name="Maint Window";Expression={}}, `
    #    @{Name="Apps Owner";Expression={}}, `
    #    @{Name="Apps Email";Expression={}}, `
    #    @{Name="Ops Owner";Expression={}}, `
    #    @{Name="Ops Email";Expression={}}, `
    #    @{Name="Drive Layout";Expression={}}, `
    #    @{Name="GB Size";Expression={}}, `
    #    @{Name="Source OS";Expression={}}, `
    #    @{Name="Target OS";Expression={}}, `
    #    @{Name="Notes";Expression={}}

    # save output
    $output | Export-Csv $taggedCsv -NoTypeInformation
}