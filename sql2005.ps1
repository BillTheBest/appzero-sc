# Copyright (c) 2013 AppZero Software Corporation.  All Rights Reserved.
#
# Experimental script to automate sql2005 migration

# Determine if a service account is one of the built-in
#  accounts, so we know if we need to set a password
Function Is-BuiltInAccount([string]$user)
{
    Write-Host "Checking if account [$user] is a built-in account"
    $builtin = $false
    switch -exact -casesensitive ($user)
    {
        "NT AUTHORITY\LocalSystem" { $builtin = $true }
        "NT AUTHORITY\NetworkService" { $builtin = $true }
        Default { $builtin =  $false }
    }
    Write-Host "Account [$user] is built-in:  $builtin"
    return $builtin
}

# Get the Service Account name used by a specified
#  service in the VAA
Function Get-ServiceAccount([string]$vaa,[string]$service)
{
    Write-Host "Getting Service Account from Service $service in VAA $vaa"
    $info = ( &$appzsc $vaa list |
        Select-String -Pattern $service -SimpleMatch -Context 0,5 -CaseSensitive )
    
    $account_line = $info.Context.PostContext[3]
    $account = $account_line.substring( 10 ).trim()  # strip the "Username: " prefix
    Write-Host "Service Account is $account"
    return $account
}

$echoargs = $Env:AppZero_Path + "echoargs.exe"
$appzpace = $Env:AppZero_Path + "appzpace.exe"
$appzcreate = $Env:AppZero_Path + "appzcreate.exe"
$appzpedit = $Env:AppZero_Path + "appzpedit.exe"
$appzsvc = $Env:AppZero_Path + "appzsvc.exe"
$appzdock = $Env:AppZero_Path + "appzdock.exe"
$appzstart = $Env:AppZero_Path + "appzstart.exe"
$appzsc = $Env:AppZero_Path + "appzsc.exe"
$appzundock = $Env:AppZero_Path + "appzundock.exe"

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

# set up a list of services we select into the vaa
$startlist = @()

# use /M for "machine output" easier to parse
& $appzsvc $vaa list /M |
    tee -Variable output | Out-Host
    
# split the string, drop the first 3 which are env variables
$items = $output.Split(";")
$source_services = $items[3..$items.length]
ForEach ( $source_service in $source_services )
{
    # hack:  it so happens on this box that all the services found,
    # are needed for sql server
    # todo: do some name matching to filter down

    $svcname = $source_service.Split(",")[0]
    if( $svcname )
    {    
        # add the service to the vaa
        & $appzsvc $vaa add $svcname
        
        # check if we need to set a password
        $service_account = Get-ServiceAccount -vaa $vaa -service $svcname
        $builtin = Is-BuiltInAccount( $service_account )
        if( $builtin -eq $false )
        {
            # prompt user for password
            $service_creds = Get-Credential( $service_account )
            # set the password in the vaa
            $service_password = $service_creds.GetNetworkCredential().password
            & $appzsc $vaa config /P $service_password |
                tee -Variable output | Out-Host
            
        }
        
        # add the service to the start list
        # TODO:  should check auto/manual/disable status
        $startlist += $svcname            
    }
}
    

    
 
Write-Host "Docking vaa"
& $appzdock $vaa |
    tee -Variable output | Out-Host
        
ForEach( $svc in $startlist ) {
    
    & $appzstart $vaa $svc
}

Write-Host "Undocking vaa"
& $appzundock $vaa |
    tee -Variable output | Out-Host
    







    

    









