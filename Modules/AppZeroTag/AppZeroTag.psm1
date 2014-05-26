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

Function Get-PaceRawCsvPath
(
    [Parameter(Mandatory=$true)]
    [string]$source
)
{
    return "$(Get-PaceLocation $source)\ProductList.csv"
}

Function Show-PaceRawCsv
(
    [Parameter(Mandatory=$true)]
    [string]$source
)
{
    Import-Csv "$(Get-PaceRawCsvPath $source)"
}

Function Get-PaceTaggedCsvPath
(
    [Parameter(Mandatory=$true)]
    [string]$source
)
{
    return "$(Get-PaceLocation $source)\ProductList-classify.csv"
}

Function Show-PaceTaggedCsv
(
    [Parameter(Mandatory=$true)]
    [string]$source
)
{
    Import-Csv "$(Get-PaceTaggedCsvPath $source)" |
        Format-Table -Property "Select?", "Product Name", "Tag"
}

Function Reset-PaceRawCsv
(
    [Parameter(Mandatory=$true)]
    [string]$source
)
{
    Copy-Item -Path "$(Get-PaceLocation $source)\original-ProductList.csv" -Destination "$(Get-PaceRawCsvPath $source)"
}

Function ConvertTo-PaceRawCSV
(
    [Parameter(Mandatory=$true)]
    [string]$source,
    [string]$rawCsv = ".\ProductList.csv"
)
{
    $taggedCsv = (Get-PaceTaggedCsvPath $source)

    if([System.IO.Path]::IsPathRooted($taggedCsv) -ne $true)
    {
        $taggedCsv = Join-Path -Path (pwd) -ChildPath $taggedCsv
        $taggedCsv = Resolve-Path -Path $taggedCsv
    }
    if((Test-Path -Path $taggedCsv -IsValid -PathType Leaf) -ne $true)
    {
        throw "$taggedCsv is not a valid path"
    }
    
    $outfile = Join-Path -Path ( Split-Path -Path $taggedCsv -Parent ) -ChildPath $rawCsv
    
    # if the raw CSV is already there, make a backup
    if( (Test-Path -Path $outfile) -eq $true )
    {
        $backupLeafName = "original-$(Split-Path -Leaf $outfile)"
        $backupfile = Join-Path -Path ( Split-Path -Path $outfile -Parent ) -ChildPath $backupLeafName
        Copy-Item -Path $outfile -Destination $backupfile
    }

    # read the tagged csv, select only the raw columns, and
    #  write that to the output file
    $programs = (Import-Csv $taggedCsv)
    $programs | Select-Object "Select?", "Product Name" |
        Export-Csv $outfile -NoTypeInformation

    # now read the output file back in as raw text, and tweak it
    #  to the format appzpace.exe expects
    
    $lines = Get-Content $outfile
    # blank the second row
    $lines[1] = ""
    # strip quotes and ascii-encode
    $lines | % { $_ -replace '"',"" } |
        Out-File $outfile -Encoding ASCII
}

Function ConvertTo-PaceTaggedCSV
(
    [Parameter(Mandatory=$true)]
    [string]$source,
    [string]$taggedCsv = ".\ProductList-classify.csv"
)
{
    $rawCsv = (Get-PaceRawCsvPath $source)

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

Function Set-PaceDefaultGYRTags
(
    [Parameter(Mandatory=$true)]
    [string]$source
)
{
    $taggedCsv = (Get-PaceTaggedCsvPath $source)

    # read classification matching rules
    #  each line a name or regex match to installed program names
    $rulesPath = "$stagingPath\appzero-sc\rules"

    $goodMatches = Get-Content $rulesPath\green.regex
    $uglyMatches = Get-Content $rulesPath\yellow.regex
    $badMatches = Get-Content $rulesPath\red.regex

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
    $output = @(Import-Csv $taggedCsv | %{ $_.Tag = ($classify[$_."Product Name"]); $_ })
        
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

Function Select-PaceProgramsByTag
(
    [Parameter(Mandatory=$true)]
    [string]$source,
    [string]$tag = "Green"
)
{
    $taggedCsv = (Get-PaceTaggedCsvPath $source)

    if([System.IO.Path]::IsPathRooted($taggedCsv) -ne $true)
    {
        $taggedCsv = Join-Path -Path (pwd) -ChildPath $taggedCsv
        $taggedCsv = Resolve-Path -Path $taggedCsv
    }
    if((Test-Path -Path $taggedCsv -IsValid -PathType Leaf) -ne $true)
    {
        throw "$taggedCsv is not a valid path"
    }

    $programs = Import-Csv $taggedCsv

    # set Select=yes (in memory) on those entries with the provided tag
    $selection = @( $programs | Where-Object { $_."Tag" -eq $tag } )
    $selection | foreach { $_."Select?" = "yes" }

    # update the tagged csv with selections
    $programs | Export-Csv $taggedCsv -NoTypeInformation
}