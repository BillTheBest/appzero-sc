# Copyright (c) 2013 AppZero Software Corporation.  All Rights Reserved.
#

Param(
    [string]$tag = "Green"
)

$programs = Import-Csv L-classify.csv

# set Select=yes (in memory) on those entries with the provided tag
$selection = @( $programs | Where-Object { $_."Tag" -eq $tag } )
$selection | foreach { $_."Select?" = "yes" }

# update the L-classify.csv with the 
$programs | Export-Csv L-classify.csv -NoTypeInformation

# copy off the original L.csv before updating
Copy-Item L.csv L-orig.csv

# select only the original columns, update L.csv
$programs | Select-Object "Select?", "Product Name" | Export-Csv L.csv -NoTypeInformation

