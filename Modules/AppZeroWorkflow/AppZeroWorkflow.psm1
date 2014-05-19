# Copyright (c) 2013 AppZero Software Corporation.  All Rights Reserved.
#

Function Initialize-Pace
(
    [Parameter(Mandatory=$true)]
    [string]$stagingPath,
    [Parameter(Mandatory=$true)]
    [string]$LocalBasePath
)
{
    $Global:stagingPath = $stagingPath
    $Global:localBasePath = $LocalBasePath
}

Function Initialize-PaceRepo
(
    [Parameter(Mandatory=$true)]
    [string]$sourcesFile,
    [Parameter(Mandatory=$true)]
    [string]$localBasePath,
    [Parameter(Mandatory=$true)]
    [string[]]$discoveryHosts,
    [Parameter(Mandatory=$true)]
    [string[]]$stagingHosts,
    [Parameter(Mandatory=$true)]
    [string[]]$uatHosts,
    [Parameter(Mandatory=$true)]
    [string[]]$prodHosts
)
{
    # load the server credentials file
    $sources = gc $sourcesFile

    # create a .pace directory to indicate a pace repo
    $dotPacePath = Join-Path -Path $localBasePath -ChildPath ".pace"
    if( (Test-Path -Path $dotPacePath -PathType Container) -ne $true )
    {
        New-Item -ItemType directory -Path $dotPacePath
    }
    else
    {
        # if it's already there delete the contents
        #Get-ChildItem -Path $dotPacePath | Remove-Item -Recurse
    }
    
    # put everything in a \servers folder under local base
    $serversDirPath = Join-Path -Path $localBasePath -ChildPath "servers"
    if( (Test-Path -Path $serversDirPath -PathType Container) -ne $true )
    {
        New-Item -ItemType directory -Path $serversDirPath
    }
    else
    {
        # if it's already there delete the contents
        #Get-ChildItem -Path $serverDirPath | Remove-Item -Recurse
    }

    $discoveryCount = $discoveryHosts.Length
    for( $d = 0 ; $d -lt $discoveryCount ; $d++ )
    {
        $serverSubDirPath = Join-Path -Path $serversDirPath -ChildPath ($discoveryHosts[$d])
        New-Item -ItemType directory -Path $serverSubDirPath
        Set-AZRemoteCredentials -TargetHost $discoveryHosts[$d] -LocalBasePath $localBasePath
        $assignedSources = @()
        $assignedSources = @( 0..($sources.Count - 1) | %{ if( ($_ % $discoveryCount) -eq $d ) { $sources[$_] } } )
        $serverSourcesFile = Join-Path -Path $serverSubDirPath -ChildPath "servers.csv"
        $assignedSources | Add-Content -Path $serverSourcesFile
    }

    $stagingCount = $stagingHosts.Length
    for( $s = 0 ; $s -lt $stagingCount ; $s++ )
    {
        $serverSubDirPath = Join-Path -Path $serversDirPath -ChildPath ($stagingHosts[$s])
        New-Item -ItemType directory -Path $serverSubDirPath
        Set-AZRemoteCredentials -TargetHost $stagingHosts[$s] -LocalBasePath $localBasePath
        $assignedSources = @()
        $assignedSources = @( 0..($sources.Count - 1) | %{ if( ($_ % $stagingCount) -eq $s ) { $sources[$_] } } )
        $serverSourcesFile = Join-Path -Path $serverSubDirPath -ChildPath "servers.csv"
        $assignedSources | Add-Content -Path $serverSourcesFile 
    }
    
    $uatCount = $uatHosts.Length
    for( $u = 0 ; $u -lt $uatCount ; $u++ )
    {
        $serverSubDirPath = Join-Path -Path $serversDirPath -ChildPath ($uatHosts[$u])
        New-Item -ItemType directory -Path $serverSubDirPath
        Set-AZRemoteCredentials -TargetHost $uatHosts[$u] -LocalBasePath $localBasePath
        $assignedSources = @()
        $assignedSources = @( 0..($sources.Count - 1) | %{ if( ($_ % $uatCount) -eq $u ) { $sources[$_] } } )
        $serverSourcesFile = Join-Path -Path $serverSubDirPath -ChildPath "servers.csv"
        $assignedSources | Add-Content -Path $serverSourcesFile
    }

    $prodCount = $prodHosts.Length
    for( $p = 0 ; $p -lt $prodCount ; $p++ )
    {
        $serverSubDirPath = Join-Path -Path $serversDirPath -ChildPath ($prodHosts[$p])
        New-Item -ItemType directory -Path $serverSubDirPath
        Set-AZRemoteCredentials -TargetHost $prodHosts[$p] -LocalBasePath $localBasePath
        $assignedSources = @()
        $assignedSources = @( 0..($sources.Count - 1) | %{ if( ($_ % $prodCount) -eq $p ) { $sources[$_] } } )
        $serverSourcesFile = Join-Path -Path $serverSubDirPath -ChildPath "servers.csv"
        $assignedSources | Add-Content -Path $serverSourcesFile
    }
}

Function Set-AZRemoteCredentials
(
    [Parameter(Mandatory=$true)]
    [string]$TargetHost,
    [Parameter(Mandatory=$true)]
    [string]$LocalBasePath,
    [string]$UserName = "Administrator"
)
{
    $dotPacePath = Join-Path -Path $localBasePath -ChildPath ".pace"
    $credsPath = Join-Path -Path $dotPacePath -ChildPath "$targetHost.creds"
    $creds = Get-Credential -UserName $userName -Message "Enter Credentials for host $targetHost"
    $creds | Export-Clixml $credsPath
}

Function Get-AZRemoteCredentials
(
    [Parameter(Mandatory=$true)]
    [string]$TargetHost,
    [Parameter(Mandatory=$true)]
    [string]$LocalBasePath
)
{
    $dotPacePath = Join-Path -Path $LocalBasePath -ChildPath ".pace"
    $credsPath = Join-Path -Path $dotPacePath -ChildPath "$TargetHost.creds"
    $creds = Import-Clixml $credsPath
    return $creds
}

Function Install-AppZero
(
    [Parameter(Mandatory=$true)]
    [string]$TargetHost,
    
    [Parameter(Mandatory=$true)]
    [string]$targetPath,
    
    [Parameter(Mandatory=$true)]
    [string]$stagingShare,

    [Parameter(Mandatory=$true)]
    [string]$codeShare,
    
    [Parameter(Mandatory=$true)]
    [string]$stagingShareUser,
    
    [Parameter(Mandatory=$true)]
    [string]$stagingSharePassword
)
{
    $ErrorActionPreference = "Stop"
    $Trace = "Setup PACE Working Repo Activity `r`n"

    $stgcreds = Get-AZRemoteCredentials -TargetHost $TargetHost -LocalBasePath $LocalBasePath
    $stgsess = New-PSSession -cn $TargetHost -Credential $stgcreds

    if( $Error.Count -gt 0 )
    {
        $Trace += "Error Establishing PSSession to $targetHost`r`n"
        $Trace += "$Error`r`n"
    }

    try {
        $return = Invoke-Command -Session $stgsess -ScriptBlock {
            Param($path,$stgshare,$codeshare,$shareuser,$sharepass)

            $ErrorActionPreference = "Stop"
        
            if( (Test-Path $path) -ne $true ) {
                New-Item -ItemType directory -Path $path
            }

            $sharepasssec = ($sharepass | ConvertTo-SecureString -AsPlainText -Force)
            $shareCreds = New-Object System.Management.Automation.PSCredential( $shareuser, $sharepasssec )

            $success = $true

            # set up the code repo path under the staging path
            #$subfolder = (Get-Item $codeshare).Name
            $subfolder = "appzero-sc"
            $localCodePath = Join-Path -Path $path -ChildPath $subfolder

            try {
                #New-PSDrive -Name "K" -PSProvider "FileSystem" -Root $share -Credential $shareCreds
                net use K: $stgshare $sharepass /user:$shareuser
                #net use K: $codeshare $sharepass /user:$shareuser
            } catch {
                $success = $false
                $msg = "Failed to map network drive: "
                $msg += $_.Exception.Message
                throw $msg
            }

            try {
                # make local copy of staging share
                Copy-Item "$stgshare\*" $path -Recurse -Force
                
                # make local copy of code share
                New-Item -ItemType directory -Path $localCodePath
                Copy-Item "$codeshare\Modules" $localCodePath -Recurse -Force
                Copy-Item "$codeshare\install" $localCodePath -Recurse -Force
                Copy-Item "$codeshare\rules" $localCodePath -Recurse -Force
                try {
                    & "$localCodePath\install\Install-AppZeroModules.ps1" -sourceRootPath $localCodePath
                } catch {
                    $_.Exception.Message | Out-File c:\install.log -Append
                    "Paths: $localCodePath" | Out-File c:\install.log -Append
                    throw $_
                }
            } catch {
                $success = $false
                $msg = "Failed to copy repo from share: "
                $msg += $_.Exception.Message
                throw $msg
            }

            try {
                Copy-Item "$codeshare\install\setup.iss" "C:\windows\"
            } catch {
                $success = $false
                throw "Failed to copy .ISS file"
            }
        
            $cmd = "$localCodePath\install\AppZero64-BitSetup.exe /s /f1`"c:\windows\setup.iss`""
            "Running command: $cmd" | Out-File c:\install.log
            cmd /c $cmd |  Out-File c:\install.log -Append

            if($success -eq $true) {
                Restart-Computer -Force
            }
        
        } -Args $targetPath, $stagingShare, $codeShare, $stagingShareUser, $stagingSharePassword

    } catch {
        throw $_.Exception    
    } finally {
        Remove-PSSession $stgsess
        $log = $return -join "`r`n"
    }

    
}


Function New-PaceRepo
(
    [Parameter(Mandatory=$true)]
    [string]$targetHost,
    [Parameter(Mandatory=$true)]
    [string]$targetHostUser,
    [Parameter(Mandatory=$false)]
    [string]$targetHostPassword,
    [Parameter(Mandatory=$true)]
    [string]$targetPath,
    [Parameter(Mandatory=$true)]
    [string]$stagingShare,
    [Parameter(Mandatory=$true)]
    [string]$stagingShareUser,
    [Parameter(Mandatory=$false)]
    [string]$stagingSharePassword
)
{
    $ErrorActionPreference = "Stop"
    $Trace = "New-PaceRepo $targetHost $targetHostUser $targetPath $stagingShare $stagingShareUser `r`n"

    if([string]::IsNullOrEmpty($targetHostPassword))
    {
        $stgsecpass = Read-Host -Prompt "Enter Password for user $targetHostUser on server $targetHost" -AsSecureString
    }
    else
    {
        $stgsecpass = ($targetHostPassword | ConvertTo-SecureString -AsPlainText -Force)
    }

    if([string]::IsNullOrEmpty($stagingSharePassword))
    {
        $shrsecpass = Read-Host -Prompt "Enter Password for user $targetHostUser on share $stagingShare" -AsSecureString
    }
    else
    {
        $shrsecpass = ($stagingSharePassword | ConvertTo-SecureString -AsPlainText -Force)
    }

    # connect to staging server
    $stgcreds = New-Object System.Management.Automation.PSCredential( $targetHostUser, $stgsecpass )
    $stgsess = New-PSSession -cn $targetHost -Credential $stgcreds

    if( $Error.Count -gt 0 )
    {
        $Trace += "Error Establishing PSSession to $targetHost`r`n"
        $Trace += "$Error`r`n"
    }

    try {
        
        # on staging server
        $return = Invoke-Command -Session $stgsess -ScriptBlock {
            Param($path,$share,$shareuser,$sharepasssec)
                               
            if( (Test-Path $path) -ne $true ) {
                New-Item -ItemType directory -Path $path
            }

            if(!(Test-Path "K:\")) {

                # connect and map to common share
                $shareCreds = New-Object System.Management.Automation.PSCredential( $shareuser, $sharepasssec )
                New-PSDrive -Name "K" -PSProvider "FileSystem" -Root $share -Credential $shareCreds -ErrorAction:SilentlyContinue
            }

            # copy artifacts from common share
            Copy-Item "K:\*" $path -Recurse -Force 
            
        
        } -Args $targetPath, $stagingShare, $stagingShareUser, $shrsecpass

    } catch {
        throw $_.Exception    
    } finally {
        Remove-PSSession $stgsess
        $log = $return -join "`r`n"
    }
}

Function Remove-PaceRepo
(
    [Parameter(Mandatory=$true)]
    [string]$targetHost,
    [Parameter(Mandatory=$true)]
    [string]$targetPath = "c:\appzero-sco",
    [Parameter(Mandatory=$true)]
    [string]$targetHostUser = "Administrator",
    [Parameter(Mandatory=$false)]
    [string]$targetHostPassword
)
{

    $ErrorActionPreference = "Stop"
    $Trace = "Remove-PaceRepo $targetHost $targetHostUser $targetPath `r`n"

    if([string]::IsNullOrEmpty($targetHostPassword))
    {
        $stgsecpass = Read-Host -Prompt "Enter Password for user $targetHostUser on server $targetHost" -AsSecureString
    }
    else
    {
        $stgsecpass = ($targetHostPassword | ConvertTo-SecureString -AsPlainText -Force)
    }

    $stgcreds = New-Object System.Management.Automation.PSCredential( $targetHostUser, $stgsecpass )
    $stgsess = New-PSSession -cn $targetHost -Credential $stgcreds

    if( $Error.Count -gt 0 )
    {
        $Trace += "Error Establishing PSSession to $targetHost`r`n"
        $Trace += "$Error`r`n"
    }

    try {
        $return = Invoke-Command -Session $stgsess -ScriptBlock { Param($path)
        
            if( (Test-Path $path) -eq $true ) {
                Remove-Item -Path $path -Recurse -Force
            }
        
        } -Args $targetPath
    
    } catch {
        throw $_.Exception    
    } finally {
        Remove-PSSession $stgsess
        $log = $return -join "`r`n"
    }
}

Function New-StagingSession
(
    [Parameter(Mandatory=$true)]
    [string]$stagingHost,
    [Parameter(Mandatory=$true)]
    [string]$stagingPassword,
    [Parameter(Mandatory=$true)]
    [string]$stagingUser
)
{
    $stgpasssec = $stagingPassword | ConvertTo-SecureString -AsPlainText -Force
    $stagingCreds = New-Object System.Management.Automation.PSCredential( $stagingUser, $stgpasssec )
    $sess = New-PSSession -cn $stagingHost -Credential $stagingCreds
    
    $result = Invoke-Command -Session $sess -ScriptBlock {
        Param($stgpath,$stghost)
        Import-Module $stgpath\psh\AppZero.psm1 -ArgumentList $stgpath,$stghost
        Import-Module $stgpath\psh\AppZeroTag.psm1
    } -ArgumentList $stagingPath,$stagingHost
    
    return $sess
}

Function Import-StagingSession
(
    [Parameter(Mandatory=$true)]
    [string]$stagingHost,
    [Parameter(Mandatory=$true)]
    [string]$stagingPassword,
    [Parameter(Mandatory=$true)]
    [string]$stagingUser
)
{
    $sess = New-StagingSession $stagingHost $stagingPassword $stagingUser
    $initscript = 
    "
        Import-Module $stagingPath\psh\AppZero.psm1 -ArgumentList $stagingPath,$stagingHost
        cd $stagingPath
    "
    Invoke-Staging $stagingPath $stagingHost $sess $initscript
    . Import-PSSession $sess -Module AppZero -AllowClobber
}

Function Invoke-Staging
(
    [Parameter(Mandatory=$true)]
    [string]$stagingPath,
    [Parameter(Mandatory=$true)]
    [string]$stagingHost,
    [Parameter(Mandatory=$true)]
    $stagingSession,
    [Parameter(Mandatory=$true)]
    [string]$script 
)
{
    $result = Invoke-Command -Session $stagingSession -ScriptBlock {
        Param($stgpath, $stghost, $stgcmd)
        Import-Module "$stgpath\psh\AppZero.psm1" -ArgumentList $stgpath,$stghost |
            Out-Null
        Import-Module "$stgpath\psh\AppZeroTag.psm1"
        $scriptObj = [scriptblock]::Create($stgcmd)
        & ($scriptObj)
    } -Args $stagingPath, $stagingHost, $script
    return $result
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
    





