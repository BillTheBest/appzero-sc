
. .\psh\AppZeroWorkflow.ps1

Remove-PaceRepo -targetHost staging1 -targetPath c:\appzero-sco -targetHostUser Administrator
restart-computer -cn staging1 -force -wait -For WinRM
New-PaceRepo -targetHost staging1 -targetHostUser Administrator -targetPath c:\appzero-sco -stagingShare "\\sco\appzero-field" -stagingShareUser Administrator

