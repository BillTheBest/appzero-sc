# Copyright (c) 2013 AppZero Software Corporation.  All Rights Reserved.
#



Function New-StagingSession
(
    [Parameter(Mandatory=$true)][string]$stagingHost,
    [Parameter(Mandatory=$true)][string]$stagingPassword,
    [Parameter(Mandatory=$true)][string]$stagingUser
)
{
    $stgpasssec = $stagingPassword | ConvertTo-SecureString -AsPlainText -Force
    $stagingCreds = New-Object System.Management.Automation.PSCredential( $stagingUser, $stgpasssec )
    $sess = New-PSSession -cn $stagingHost -Credential $stagingCreds
    return $sess
}

#####################  Utility Functions ##############################

function Resolve-Error ($ErrorRecord=$Error[0])
{
   $ErrorRecord | Format-List * -Force
   $ErrorRecord.InvocationInfo |Format-List *
   $Exception = $ErrorRecord.Exception
   for ($i = 0; $Exception; $i++, ($Exception = $Exception.InnerException))
   {   "$i" * 80
       $Exception |Format-List * -Force
   }
}
    





