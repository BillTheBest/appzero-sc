# Copyright (c) 2013 AppZero Software Corporation.  All Rights Reserved.
#
# Set up a new PACE working repo

Param(
    [string]$targetHost = "prod1",
    [string]$version = "5.4SP1.1",
    [string]$targetPath = "c:\appzero-sco",
    [string]$targetHostUser = "Administrator",
    [string]$targetHostPassword = "P@ssw0rd",
    [string]$stagingShare = "\\sco\appzero-field",
    [string]$stagingShareUser = "sco\Administrator",
    [string]$stagingSharePassword = "P@ssw0rd"
)


cd C:\Users\Administrator\dev\appzero-field
Import-Module .\psh\AppZeroWorkflow.psm1
Install-AppZero $targetHost $version $targetPath $targetHostUser $targetHostPassword $stagingShare $stagingShareUser $stagingSharePassword

