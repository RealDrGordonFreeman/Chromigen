<h1 align="center">
  <br>
    <img src="chromigen.png" alt="Chromigen Logo" width=400>
  <br>
  <br>
</h1>

# Chromigen #

Chromigen is a PowerShell script to download, install, and update the latest build of Chromium for Windows **directly from the Chromium Project.**

Download it here: https://github.com/RealDrGordonFreeman/Chromigen/releases/download/v1.0/chromigen.ps1

Chromigen is most useful to developers who need the very latest Chromium build but can also be used in an enterprise or at home. Chromigen currently runs interactively and requires user input. An automated version which uses an answer file will be released later. Full commenting within the script will also be added at a later time. 

Chromigen is designed to work best with Windows 10, and requires **PowerShell v6.0 or higher**. 

If PowerShell scripting has been restricted on your system (the default), Chromigen can still be run by assigning temporary bypass permissions to the script to allow it to execute, with the following command within PowerShell:

`powershell -ExecutionPolicy ByPass -File chromigen.ps1`

If this does not work, the current user account's PowerShell script execution policy can be set to allow the execution of scripts with the following command within PowerShell:

`Set-ExecutionPolicy RemoteSigned -Scope CurrentUser`

This would allow all local unsigned scripts to run with user level permissions on the local system, but still require remote scripts to be signed. When finished, this can be undone with the following command within PowerShell:

`Set-ExecutionPolicy Restricted -Scope CurrentUser`

For further information on PowerShell script restrictions see the following:

[Microsoft PowerShell - About Execution Policies](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_execution_policies)

and

[Microsoft PowerShell - Set-ExecutionPolicy](https://docs.microsoft.com/powershell/module/microsoft.powershell.security/set-executionpolicy)

## How Chromigen Works ##

1. Chromigen works by first directly querying the Chromium Project for the latest build of the Chromium browser based on the platform's architecture (AMD64 or x86). This is done via JSON. Be sure Chromium is not running during this process.

2. Next, the user is presented with the details of the latest build and then offered the option to download Chromium using PowerShell's built-in web request feature, or through Windows BITS. Windows BITS is set to priority ‘Normal’ by default. It is slower, uses idle bandwidth, but is very reliable over slow or bad internet connections and can continue even after multiple disconnects.

3. After the file is downloaded, the user is asked to either install Chromium or update an existing version. Since Chromium is portable, it is expanded into the user's local folder under an \Application\Chromium directory. Updates are done in-place and preserve all browser data, including extensions, favorites, and settings.

4. If installing, the user is presented with the option to add batch file launchers for Chromium to permit the automatic inclusion of command line switches. Some typical switches are already included, including disabling of weak cipher suites and hardening mixed content rules. These can later be removed or adjusted if the Chromium Project ever decides to include all command line switch options in a Chrome://Flags style configuration page.

5. Shortcuts for a normal and incognito window are then placed on the desktop which a user can then pin to their Windows Start menu or taskbar.

6. The script will check the success of its own procedures at various points and will notify the user if there is an error.

7. Upon completion, the script will remove the downloaded Chromium file from the user’s system.

## Known Issues ##

**Issue 1:** When launching Chromium via the batch file option, a command line terminal window will briefly flash on screen. To mitigate this annoyance, go into the properties of each of the two Chromium shortcuts and for the ‘Run’ option, select ‘Minimized’. This should be before pinning the shortcuts to the Start menu or the taskbar. A solution is being sought to automate the 'Minimized' option and there may be a PowerShell bug in '.WindowStyle = 1' which is preventing the option from being set properly.

**Issue 2:** If Chromium is selected as the default browser on a Windows system and Chromium launches without a shortcut, the batch file customizations will not be loaded. This is a limitation in the Windows 10 system where default programs cannot be launched from a specific file, in this case the batch file. There are various registry hacks which can be done as a workaround to fix this, so if this is very important for your environment search the internet for how this can be done. 
