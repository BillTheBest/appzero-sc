# Copyright (c) 2013-2014 AppZero Software Corporation.  All Rights Reserved.
#

# this is the documented path for user-installed modules
$userModulesPath = "$Home\Documents\WindowsPowerShell\Modules"

# Delete the AppZero modules from the user-installed modules path
Remove-Item -Path "$userModulesPath\AppZero" -Recurse
Remove-Item -Path "$userModulesPath\AppZeroTag" -Recurse
Remove-Item -Path "$userModulesPath\AppZeroWorkflow" -Recurse
Remove-Item -Path "$userModulesPath\AppZeroActivity" -Recurse




