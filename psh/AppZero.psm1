# Copyright (c) 2013 AppZero Software Corporation.  All Rights Reserved.
#

# this runs on module import to check the required arguments
# need to do this way because cmdletbinding() is still broken for modules in v3
Param()
. {
    Param(
        [Parameter(Mandatory=$true)]
        [ValidateScript({[string]::IsNullOrEmpty($_) -ne $true})]
        $rootPath,
        [Parameter(Mandatory=$true)]
        [ValidateScript({[string]::IsNullOrEmpty($_) -ne $true})]
        $stagingHost
    )

    $GLOBAL:stagingPath = $rootPath
    $GLOBAL:stagingHost = $stagingHost
} @args



if([System.IO.Path]::IsPathRooted($stagingPath) -ne $True) {
    $stagingPath = Join-Path -Path (pwd) -ChildPath $stagingPath
    $stagingPath = Resolve-Path -Path $stagingPath
}

Function Get-PaceLocation([string]$source)
{
    $loc = "$stagingPath\servers\$stagingHost\PACE"
    if( [string]::IsNullOrEmpty($source) -ne $true ) {
        $loc = Join-Path -Path $loc -ChildPath $source
    }
    return $loc
}

Function Get-VAALocation([string]$source)
{
    $loc = "$stagingPath\servers\$stagingHost\VAAs"
    if( [string]::IsNullOrEmpty($source) -ne $true ) {
        $loc = Join-Path -Path $loc -ChildPath $source
    }
    return $loc
}

Function Get-PaceStagingHostLocation()
{
    return "$stagingPath\servers\$stagingHost"
}

Function Get-PaceCredentialsFile([string]$filename = "servers.csv")
{
    return "$stagingPath\servers\$stagingHost\$filename"
}

Function Out-PaceLog([string]$logText)
{
    Process {
        $parent = Get-PaceStagingHostLocation
        $log = Join-Path -Path $parent -ChildPath ".\$stagingHost.log"
        $timestamp = Get-Date
        "$timestamp $_" | Out-File $log -Append
    }
}

Function Reset-PaceData()
{
    $pacepath = "$stagingPath\servers\$stagingHost\PACE"
    $vaapath = "$stagingPath\servers\$stagingHost\VAA"
    if( (Test-Path $pacepath ) -eq $true ) {
        Remove-Item -Path $pacepath -Recurse -Force
    }
    if( (Test-Path $vaapath) -eq $true ) {
        Remove-Item -Path $vaapath -Recurse -Force
    }
}


$appzcmd = $Env:AppZero_Path + "appzcmd.exe"
$appzcompress = $Env:AppZero_Path + "appzcompress.exe"
$appzcotf = $Env:AppZero_Path + "appzcotf.exe"
$appzcreate = $Env:AppZero_Path + "appzcreate.exe"
$appzdel = $Env:AppZero_Path + "appzdel.exe"
$appzdepends = $Env:AppZero_Path + "appzdepends.exe"
$appzdissolve = $Env:AppZero_Path + "appzdissolve.exe"
$appzdock = $Env:AppZero_Path + "appzdock.exe"
$appzenvedit = $Env:AppZero_Path + "appzenvedit.exe"
$appzgroup = $Env:AppZero_Path + "appzgroup.exe"
$appzlist = $Env:AppZero_Path + "appzlist.exe"
$appzmgr = $Env:AppZero_Path + "appzmgr.exe"
$appzmigrate = $Env:AppZero_Path + "appzmigrate.exe"
$appznsedit = $Env:AppZero_Path + "appznsedit.exe"
$appzpace = $Env:AppZero_Path + "appzpace.exe"
$appzpedit = $Env:AppZero_Path + "appzpedit.exe"
$appzprecheck = $Env:AppZero_Path + "appzprecheck.exe"
$appzpreiis = $Env:AppZero_Path + "appzpreIIS.exe"
$appzprocl = $Env:AppZero_Path + "appzprocl.exe"
$appzprop = $Env:AppZero_Path + "appzprop.exe"
$appzmmenus = $Env:AppZero_Path + "appzmmenus.exe"
$appzrun = $Env:AppZero_Path + "appzrun.exe"
$appzruntimelog = $Env:AppZero_Path + "appzruntimelog.exe"
$appzruntimeloglevel = $Env:AppZero_Path + "appzruntimeloglevel.exe"
$appzsc = $Env:AppZero_Path + "appzsc.exe"
$appzstart = $Env:AppZero_Path + "appzstart.exe"
$appzstatus = $Env:AppZero_Path + "appzstatus.exe"
$appzstop = $Env:AppZero_Path + "appzstop.exe"
$appzsvc = $Env:AppZero_Path + "appzsvc.exe"
$appztemplatecreate = $Env:AppZero_Path + "appztemplatecreate.exe"
$appztether = $Env:AppZero_Path + "appztether.exe"
$appztetheradmin = $Env:AppZero_Path + "appztetheradmin.exe"
$appzuncompress = $Env:AppZero_Path + "appzuncompress.exe"
$appzundock = $Env:AppZero_Path + "appzundock.exe"
$appzupgrade = $Env:AppZero_Path + "appzupgrade.exe"
$appzuser = $Env:AppZero_Path + "appzuser.exe"
$appzvdrive = $Env:AppZero_Path + "appzvdrive.exe"

Function Get-PaceSourceInstalledPrograms
(
    [string]$credentialsFile
)
{
    if( [string]::IsNullOrEmpty($credentialsFile) ) {
        $credentialsFile = Get-PaceCredentialsFile
    } elseif( [System.IO.Path]::IsPathRooted($credentialsFile) -ne $true) {
        $credentialsFile = Join-Path -Path (Get-StagingHostLocation) -ChildPath $credentialsFile
        $credentialsFile = Resolve-Path -Path $credentialsFile
    }
    
    if((Test-Path -Path $credentialsFile -IsValid -PathType Leaf) -ne $true)
    {
        throw "$credentialsFile is not a valid path"
    }

    & $appzpace /M /L $credentialsFile |
        Out-PaceLog

    if( $LASTEXITCODE -gt 0 )
    {
        throw "Error executing $appzpace - exit code is $LASTEXITCODE"
    }
    
    $sources = @()
    $parent = Split-Path -Parent $credentialsFile
    if( (Test-Path -Path $parent\PACE) -eq $true ) {
        $sources = Get-ChildItem -Path $parent\PACE -Name
    }
    return $sources
}

# make this a New- function
Function Get-SourceMappFiles
(
    [string]$credentialsFile
)
{
    if( [string]::IsNullOrEmpty($credentialsFile) ) {
        $credentialsFile = Get-PaceCredentialsFile
    } elseif( [System.IO.Path]::IsPathRooted($credentialsFile) -ne $true) {
        $credentialsFile = Join-Path -Path (Get-StagingHostLocation) -ChildPath $credentialsFile
        $credentialsFile = Resolve-Path -Path $credentialsFile
    }
    
    if((Test-Path -Path $credentialsFile -IsValid -PathType Leaf) -ne $true)
    {
        throw "$credentialsFile is not a valid path"
    }

    & $appzpace /M /C $credentialsFile |
        Out-PaceLog
    
    $parent = Split-Path -Parent $credentialsFile
    $sources = Get-ChildItem -Path $parent\PACE -Name
    return $sources
}

Function Remove-SourceMappFile([string]$source)
{
    $mappFile = Join-Path -Path (Get-PaceLocation $source) -ChildPath "Mapp.xml"
    Remove-Item -Path $mappFile
}

Function New-VAA
(
    [string]$credentialsFile
)
{
    if( [string]::IsNullOrEmpty($credentialsFile) ) {
        $credentialsFile = Get-PaceCredentialsFile
    } elseif( [System.IO.Path]::IsPathRooted($credentialsFile) -ne $true) {
        $credentialsFile = Join-Path -Path (Get-StagingHostLocation) -ChildPath $credentialsFile
        $credentialsFile = Resolve-Path -Path $credentialsFile
    }
    
    if((Test-Path -Path $credentialsFile -IsValid -PathType Leaf) -ne $true)
    {
        throw "$credentialsFile is not a valid path"
    }

    & $appzpace /M /T $credentialsFile |
        Out-PaceLog
    
    $parent = Split-Path -Parent $credentialsFile
    $sources = Get-ChildItem -Path $parent\VAAs -Name
    return $sources
}

Function Remove-VAA
(
    [Parameter(Mandatory=$true)]
    [string]$source
)
{
    $vaapath = (Get-VAALocation $source)

    pushd "$Env:AppZero_Path"
    
    & $appzdel $vaapath |
        Out-PaceLog
        
    popd
}

Function Register-VAA
(
    [Parameter(Mandatory=$true)]
    [string]$source
)
{
    $vaapath = (Get-VAALocation $source)

    pushd "$Env:AppZero_Path"
    
    & $appzdock $vaapath |
        Out-PaceLog
        
    popd
    
    return $vaapath
}

Function Compress-VAA
(
    [Parameter(Mandatory=$true)]
    [string]$source
)
{
    $vaapath = (Get-VAALocation $source)

    pushd "$Env:AppZero_Path"
    
    & $appzcompress $vaapath |
        Out-PaceLog
        
    popd
    
    return $vaapath
}

Function Publish-VAA
(
    [Parameter(Mandatory=$true)]
    [string]$source,
    [Parameter(Mandatory=$true)]
    [string]$vaashare,
    [Parameter(Mandatory=$true)]
    [ValidateNotNull()]
    [System.Management.Automation.PSCredential]
    [System.Management.Automation.Credential()]
    $Credential = [System.Management.Automation.PSCredential]::Empty,
    [Parameter(Mandatory=$false)]
    [string]$Path = $source
)
{
    $vaapath = (Get-VAALocation $source)
    $storepath = "$vaashare\$path"
    $timestamp = Get-Date -Format "yyyy-MM-dd hh.mm.ss"
    #$capFileName = "$source-$timestamp.cap"
    $capFileName = "$source.cap"

    New-PSDrive -Name "V" -PSProvider "FileSystem" -Root $vaashare -Credential $Credential |
        Out-Null

    if( (Test-Path -Path $storepath) -ne $true) {
        New-Item -Path "$storepath" -Type directory |
            Out-Null
    }
    $capfile = Join-Path -Path $storepath -ChildPath $capFileName
    Copy-Item -Path "$vaapath.cap" -Destination $capfile
    
    return $capfile
}

Function Unregister-VAA
(
    [Parameter(Mandatory=$true)]
    [string]$source
)
{
    $vaapath = (Get-VAALocation $source)

    pushd "$Env:AppZero_Path"
    
    & $appzundock $vaapath |
        Out-PaceLog
        
    popd
    
    return $vaapath
}

Function Start-VAA
(
    [Parameter(Mandatory=$true)]
    [string]$source
)
{
    $vaapath = (Get-VAALocation $source)
    
    if( (Get-VaaStatus $vaapath) -ne "Docked" )
    {
        # vaa path return value is generated below
        # drop the return value here so we don't dup it
        Dock-VAA $source | Out-Null
    }
    
    pushd "$Env:AppZero_Path"
        
    $startlist = Get-VaaServiceNames $vaapath 
    $startlist | %{ & $appzstart $vaapath $_ } |
        Out-PaceLog

    $runlist = Get-VaaExecutablePaths $vaapath 
    $runlist | %{ & $appzrun $vaapath $_ }
        Out-PaceLog
    
    popd
    
    return $vaapath
}

Function Install-VAA
(
    [Parameter(Mandatory=$true)]
    [string]$source,
    [Parameter(Mandatory=$true)]
    [string]$vaashare,
    [Parameter(Mandatory=$true)]
    [ValidateNotNull()]
    [System.Management.Automation.PSCredential]
    [System.Management.Automation.Credential()]
    $Credential = [System.Management.Automation.PSCredential]::Empty,
    [Parameter(Mandatory=$false)]
    [string]$Path = $source
)
{
    $vaapath = (Get-VAALocation $source)
    $storepath = "$vaashare\$path"
    $timestamp = Get-Date -Format "yyyy-MM-dd hh.mm.ss"
    #$capFileName = "$source-$timestamp.cap"
    $capFileName = "$source.cap"

    New-PSDrive -Name "V" -PSProvider "FileSystem" -Root $vaashare -Credential $Credential |
        Out-Null

    $capfile = Join-Path -Path $storepath -ChildPath $capFileName
    $localpath = "$(Get-PaceStagingHostLocation)\VAAs\"
    New-item -ItemType Directory -Force -Path $localpath
    Copy-Item -Path $capfile -Destination $localpath

    pushd "$Env:AppZero_Path"

    & $appzuncompress /S "$localpath\$capFileName" |
        Out-PaceLog
    
    & $appzdissolve $vaapath |
        Out-PaceLog
        
    popd
    
    return $vaapath
}


Function Get-VaaServiceNames
(
    [Parameter(Mandatory=$true)]
    [ValidateScript({[System.IO.Path]::IsPathRooted($_)})]
    [string]$vaapath
)
{
    $lines = @(& $appzsc $vaapath list | Where { $_ -match "Service " })
    $names = @( $lines | %{ $_ -replace "Service ", "" })
    return $names
}


Function Get-VaaExecutablePaths
(
    [Parameter(Mandatory=$true)]
    [ValidateScript({[System.IO.Path]::IsPathRooted($_)})]
    [string]$vaapath
)
{
    $listpath = "$vaapath\scripts\autoexec"
    $exes = @()
    if( (Test-Path $listpath) -eq $true ) {
        $exes = Get-Content $listpath
    }
    return $exes
}

Function Get-VAAStatus
(
    [Parameter(Mandatory=$true)]
    [ValidateScript({[System.IO.Path]::IsPathRooted($_)})]
    [string]$vaapath
)
{
    $status = ((& $appzlist $vaapath) -split "\): ")[1]
    return $status
}

########################  These Should be separated out #######################

Function Send-DiscoveryOutput
(
    [Parameter(Mandatory=$true)]
    [string]$emailUser,
    [Parameter(Mandatory=$true)]
    [string]$emailPassword,
    [Parameter(Mandatory=$true)]
    [string]$server
)
{
    $EmailFrom = $emailUser
    $EmailTo = $emailUser
    $Subject = "Discovery Output for Server $server"
    $Body = @"
    Please review the attached Worksheet.
    Thank You.
"@

    $SMTPServer = "smtp.gmail.com"
    $SMTPClient = New-Object Net.Mail.SmtpClient($SmtpServer, 587)
    $SMTPClient.EnableSsl = $true
    $SMTPClient.Credentials = New-Object System.Net.NetworkCredential
    $SMTPClient.Credentials = New-Object System.Net.NetworkCredential($emailUser, $emailPassword)

    $emailMessage = New-Object System.Net.Mail.MailMessage
    $emailMessage.From = $EmailFrom
    $emailMessage.To.Add($EmailTo)
    $emailMessage.Subject = $Subject
    $emailMessage.Body = $Body

    $taggedCsv = (Get-PaceTaggedCsvPath $server)
    $renamedCsv = Join-Path -Path (Get-PaceLocation $server) -ChildPath "Discovery-For-Server-$server.csv"
    Copy-Item -Path $taggedCsv -Destination $renamedCsv
    $attachmentPath = Resolve-Path -Path $renamedCsv
    $attachment = New-Object System.Net.Mail.Attachment( $attachmentPath )
    $emailMessage.Attachments.Add($attachment)

    $SMTPClient.send($emailMessage)
    $emailMessage.dispose()
    Remove-Item -Path $renamedCsv
}

Function Send-MappFile
(
    [Parameter(Mandatory=$true)]
    [string]$emailUser,
    [Parameter(Mandatory=$true)]
    [string]$emailPassword,
    [Parameter(Mandatory=$true)]
    [string]$server
)
{
    $EmailFrom = $emailUser
    $EmailTo = $emailUser
    $Subject = "App Component Scan Output for Server $server"
    $Body = @"
    Please review the attached Mapp file.
    Thank You.
"@

    $SMTPServer = "smtp.gmail.com"
    $SMTPClient = New-Object Net.Mail.SmtpClient($SmtpServer, 587)
    $SMTPClient.EnableSsl = $true
    $SMTPClient.Credentials = New-Object System.Net.NetworkCredential
    $SMTPClient.Credentials = New-Object System.Net.NetworkCredential($emailUser, $emailPassword)

    $emailMessage = New-Object System.Net.Mail.MailMessage
    $emailMessage.From = $EmailFrom
    $emailMessage.To.Add($EmailTo)
    $emailMessage.Subject = $Subject
    $emailMessage.Body = $Body

    $mappFile = Join-Path -Path (Get-PaceLocation $server) -ChildPath ".\Mapp.xml"
    $renamedFile = Join-Path -Path (Get-PaceLocation $server) -ChildPath ".\MappFile-For-Server-$server.csv"
    Copy-Item -Path $mappFile -Destination $renamedFile
    $attachmentPath = Resolve-Path -Path $renamedFile
    $attachment = New-Object System.Net.Mail.Attachment( $attachmentPath )
    $emailMessage.Attachments.Add($attachment)

    $SMTPClient.send($emailMessage)
    $emailMessage.dispose()
    Remove-Item -Path $renamedFile
}

Function Send-ErrorNotification
(
    [Parameter(Mandatory=$true)]
    [string]$emailUser,
    [Parameter(Mandatory=$true)]
    [string]$emailPassword,
    [Parameter(Mandatory=$true)]
    [string]$runbookName,
    [Parameter(Mandatory=$true)]
    [string]$server,
    [Parameter(Mandatory=$true)]
    [string]$errorContent
)
{
    $EmailFrom = $emailUser
    $EmailTo = $emailUser
    $Subject = "Failure in runbook $runbookName"
    #$Body = "An error occurred in Runbook $rubookName:`r`n" +
    #    "Error Information: `r`n" + $errorContent

    $SMTPServer = "smtp.gmail.com"
    $SMTPClient = New-Object Net.Mail.SmtpClient($SmtpServer, 587)
    $SMTPClient.EnableSsl = $true
    $SMTPClient.Credentials = New-Object System.Net.NetworkCredential($emailUser, $emailPassword)

    $emailMessage = New-Object System.Net.Mail.MailMessage
    $emailMessage.From = $EmailFrom
    $emailMessage.To.Add($EmailTo)
    $emailMessage.Subject = $Subject
    $emailMessage.Body = $Body

    $SMTPClient.send($emailMessage)
}