# Copyright (c) 2013 AppZero Software Corporation.  All Rights Reserved.
#

Param(
    [string]$tag = "Green"
)

$programs = Import-Csv L-classify.csv
$selection = @( $programs | Where-Object { $_."Tag" -eq $tag } )
$selection | foreach { $_."Select?" = "yes" }

$programs | Select-Object "Select?", "Product Name" | Export-Csv L.csv -NoTypeInformation

