# Copyright (c) 2013 AppZero Software Corporation.  All Rights Reserved.
#
# Template PSH script to automate sql2005 migration

<#
    .SYNOPSIS
        Automated harness to discover, select, and extract applications
        from a source server into an AppZero VAA
        
    .DESCRIPTION
        This script implements an automated sequence of AppZero CLI
        commands to discover, select and extract applications into an
        AppZero Virtual Application Appliance (VAA).
        
    .PARAMETER srchost
        The hostname or IP address of the source machine
    .PARAMETER password
        The Local Administrator password of the source machine.  If
        this parameter is not passed the user is prompted to provide
        the password
    .PARAMETER administrator
        Specifies an alternate username for the Local Administrator
        account of the source machine.  The default is "Administrator"
    .PARAMETER services
        The path to a file containing names or patterns of Windows Services
        to be added individually to the VAA.
    
#>



Param(
    [Parameter(Mandatory=$true)]
    [string]$srchost,
    [string]$password,
    [string]$administrator = "Administrator",
    [string]$programs,
    [string]$services
) # end param

# prebuilt paths to the executables for convenience
$echoargs = $Env:AppZero_Path + "echoargs.exe"
$appzpace = $Env:AppZero_Path + "appzpace.exe"
$appzcreate = $Env:AppZero_Path + "appzcreate.exe"
$appzpedit = $Env:AppZero_Path + "appzpedit.exe"
$appzsvc = $Env:AppZero_Path + "appzsvc.exe"
$appzdock = $Env:AppZero_Path + "appzdock.exe"
$appzstart = $Env:AppZero_Path + "appzstart.exe"
$appzsc = $Env:AppZero_Path + "appzsc.exe"
$appzundock = $Env:AppZero_Path + "appzundock.exe"
$appzuser = $Env:AppZero_Path + "appzuser.exe"


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
        "LocalSystem" { $builtin = $true }
        "NetworkService" { $builtin = $true }
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
    $pattern = "Service $service"
    $info = ( &$appzsc $vaa list |
        Select-String -Pattern $pattern -SimpleMatch -Context 0,5 -CaseSensitive )
    
    $account_line = $info.Context.PostContext[3]
    $account = $account_line.Substring( 10 ).trim()  # strip the "Username: " prefix
    Write-Host "Service Account is $account"
    
    # appzsc seems to prefix local account names with ".\", but
    #  the Windows credentials popup box doesn't like that
    if( $account.StartsWith(".\") -eq $true )
    {
        $account = $account.Substring( 2 )
    }
    
    return $account
}

# Extract a local user account from the source server, into the vaa
Function Export-UserAccount([string]$srchost, [string]$password, [string]$vaa, [string]$username)
{
    # the command output is a series of "SID: <sid>  Name: <name>" lines,
    #  with two spaces separating the name-value pairs, and one space between name and value
    # todo:  Administrator may have been renamed, take from parameter and use here
    $sid = @((& $appzuser /L $srchost $administrator $password |
        Select-String -Pattern $username ) -split "  " -split " " )[1]
        
    & $appzuser /X $srchost $administrator $password $sid $vaa
}

# prompt user for Local-Admin credentials to the source
$creds = Get-Credential $administrator
$password = $creds.GetNetworkCredential().password

# generate appliance name
# 
$appliancepath = "c:\appliances\"
$key = Get-Date -Format hms
$vaa = $appliancepath + "Untitled-" + $key

# the appzpace line isn't actually doing anything for now
# todo:  substitute appzpace /M /T to create the VAA
& $appzpace /L $srchost $administrator $password |
    tee -Variable output | Out-Host
& $appzcreate $vaa /E |
    tee -Variable output | Out-Host
    


# set tether properties
& $appzpedit $vaa CPROP_USE_TETHER Y $srchost Administrator $password |
    tee -Variable output | Out-Host    


#--  Select Individual Services As Necessary


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
        
        # check if it's a builtin account, or we need to set a password
        $service_account = Get-ServiceAccount -vaa $vaa -service $svcname
        $builtin = Is-BuiltInAccount( $service_account )
        if( $builtin -eq $false )
        {   
            # move the local user account from the source
            Export-UserAccount -srchost $srchost -password $password -vaa $vaa -username $service_account
            
            # prompt user for password
            $service_creds = Get-Credential( $service_account )
            # set the password in the vaa
            $service_password = $service_creds.GetNetworkCredential().password
            & $appzsc $vaa config $svcname /U $service_account /P $service_password |
                tee -Variable output | Out-Host
        }
        
        # add the service to the start list
        # TODO:  should check auto/manual/disable status
        $startlist += $svcname            
    }
}
    

#-- Dock and Start    
 
Write-Host "Docking vaa"
& $appzdock $vaa |
    tee -Variable output | Out-Host
        
ForEach( $svc in $startlist ) {
    
    & $appzstart $vaa $svc
}

Write-Host "Undocking vaa"
& $appzundock $vaa |
    tee -Variable output | Out-Host
    







    

    









