# Copyright (c) 2013 AppZero Software Corporation.  All Rights Reserved.
#

$stagingPassword = "1trigence$" | ConvertTo-SecureString -AsPlainText -Force
$stagingUser = "dest1\Administrator"
$stagingCreds = New-Object System.Management.Automation.PSCredential( $stagingUser, $stagingPassword )


