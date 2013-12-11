# Copyright (c) 2013 AppZero Software Corporation.  All Rights Reserved.
#
# Experimental script to automate sql2005 migration

$echoargs = $Env:AppZero_Path + "echoargs.exe"
$appzpace = $Env:AppZero_Path + "appzpace.exe"
$appzcreate = $Env:AppZero_Path + "appzcreate.exe"
$appzpedit = $Env:AppZero_Path + "appzpedit.exe"
$appzsvc = $Env:AppZero_Path + "appzsvc.exe"

$srchost = "sqlsource"

$creds = Get-Credential "Administrator"
$password = $creds.GetNetworkCredential().password

$appliancepath = "c:\appliances\"
$key = Get-Date -Format hms
$vaa = $appliancepath + "sql-" + $key

& $appzpace /L sqlsource Administrator $password |
    tee -Variable output | Out-Host

& $appzcreate $vaa /E |
    tee -Variable output | Out-Host

& $appzpedit $vaa CPROP_USE_TETHER Y $srchost Administrator $password |
    tee -Variable output | Out-Host

# use /M for "machine output" easier to parse
& $appzsvc $vaa list /M |
    tee -Variable output | Out-Host
    
# split the string, drop the first 3 which are env variables
$items = $output.Split(";")
$items[3..$items.length] |
    ForEach {
        # hack:  it so happens on this box that all the services found,
        # are needed for sql server
        # todo: do some name matching to filter down
    
        $svcname = $_.Split(",")[0]
        # deal with blank string at the end
        if( $svcname ) {
            "Adding " + $svcname | Write-Host
            & $appzsvc $vaa add $svcname
        }
    }
    



    

    









