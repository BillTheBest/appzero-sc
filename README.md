AppZero Integration Pack for SCO
================================

By [AppZero](http://appzero.com)

AppZero Integration Pack for SCO is an add-on for System Center 2012 Orchestrator which provides pre-built Runbook Activities for AppZero application discovery and migration operations.  The Orchestrator activities are in turn built from a set of custom PowerShell Cmdlet functions (AppZero Cmdlets for PowerShell) which implement the operations by wrapping the AppZero engine CLIs.

You can use it a few different ways:

- Use the AppZero Integration Pack Activities directly in your runbooks
- Use the AppZero Cmdlets for PowerShell in Orchestrator .NET Script Activities
- Use the AppZero Cmdlets for PowerShell in other System Center products, or other automation environments

---

Getting Started
---------------

First clone this repo to the Orchestrator Runbook Server machine, or a file share available to it

    git clone git@github.com:appzeroinc/appzero-sc.git
    

---
### Install the PowerShell Modules    
Install the powershell modules - open a powershell console and run

    appzero-sc\install\Install-AppZeroModules.ps1 <path-to-this-repo>

Alternately, you can manually copy the Modules subdirectory to a location of your choice on the `$PSModulePath`

---
### Install the Orchestrator Integration Pack
Follow [the usual instructions](http://technet.microsoft.com/en-us/library/hh420346.aspx) for installing Orchestrator Integration Packs.  Browse to the AppZero OIP binary in the directory

    appzero-sc\oip
    
---
### Provide the AppZero Installer
The framework automates the installation of AppZero on discovery, staging or destination machines remotely.  You need to provide the AppZero Cloud Edition installer executable, and a setup.iss installer reponse file to guide the installation.

See the [AppZero Documentation](http://docs.appzero.com/Installation/silent_installation_option.htm) for instructions how to generate a Silent Installation response file.

Copy the AppZero Installer and response file to `appzero-sc\install\AppZero64-BitSetup.exe` and `appzero-sc\install\setup.iss`, respectively.

---

Runbook Activities
------------------
The Orchestrator Integration Pack contains the following activities:
- Install AppZero
- Uninstall AppZero
- Setup Migration Repository
- Discover Installed Programs
- Classify Installed Programs
- Select Apps By Tag
- Generate MAPP file
- Pre-Populate VAA
- Start VAA
- Stop VAA
- Publish VAA
- Install VAA


