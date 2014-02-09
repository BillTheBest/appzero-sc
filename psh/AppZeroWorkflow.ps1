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



Function Email-DiscoveryOutput
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

Function Email-MappFile
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

Function Email-ErrorNotification
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
    





