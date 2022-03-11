# Microsoft Attack Surface Analyzer 2.0 Automation
This repository provides scripts to automate [Microsoft Attack Surface Analyzer 2.0](https://github.com/microsoft/AttackSurfaceAnalyzer) (ASA). Please feel free to use and modify these scripts in any form you want.  
*Script1.ps1*, *Script2.ps1*, *asa.conf* and *filterExport.py* represent the main function of this project. By running *Script1.ps1* (and automatically *Script2.ps1*) on a newly set up system, you can modify the system's settings, install additional software, install a specific or the latest ASA version and perform ASA functionality all in one pass.  
The JSON file *resultFilteredExample.json* is an example for a possible output after running the scripts as they are configured right now.  
The folder "Other scripts" includes scripts for parts of the main functionality.  
As the folder name "Tests" suggests, these are some tests to check whether everything on the system works as intended.

## How to setup the scripts?
First you need to check the execution policy of your system by running `Get-ExecutionPolicy`. If it's set to "Default" and the scripts aren't whitelisted you can set it to "Unrestricted" by running `Set-ExecutionPolicy Unrestricted`. There is a parameter in the config file you can set to "true" so the execution policy will be set back to "Default" after running the second script.  
Then you may also need to change the parameters in the config file (*asa.conf* or *asaL.conf*/*asaV.conf* in the "Other scripts" folder) and in the script headers.  
- `repo`: This is the repository's name you can get from the URL in GitHub (e.g. microsoft/AttackSurfaceAnalyzer).
- `filenamePattern`: This is the naming convention of the releases so if the ASA releases are named like "ASA_win_2.3.275.zip" and "ASA_win_2.3.276.zip" and so on the wildcard would be "ASA_win_*.zip". You can find the release names at the [release page](https://github.com/Microsoft/AttackSurfaceAnalyzer/releases/) of the repository you wish to download.
- `extractPath`: Path where the repository should be extracted to.
- `downloadLatestASA`: Downloads the latest ASA version if set to "true", otherwise tries to download the specified version in the version parameter.
- `version`: This ASA version gets downloaded if downloadLatestASA isn't set to "true".
- `setTimeAndLanguage`: This sets the specified time and language if set to "true".
- `timezone`: This specifies the timezone to be set if the above parameter is true. You can get a list of available timezones by running `Get-TimeZone – ListAvailable`.
- `language`: This is the language pack including the keyboard layout the system should use. The language pack gets installed if *setTimeAndLanguage* is true and if it's not already installed on the system. To see the language change you need to sign out and then sign in again or perform a reboot (see the *reboot* parameter). The keyboard layout will be changed immediately.
- `installChocoAndPython`: With this boolean parameter you can set whether to install the latest versions of the package manager Chocolatey and Python 3. The installation will be skipped if `choco` and/or `python` can already be used within the shell.
- `reboot`: This specifies whether to reboot after the first script because of language and/or software changes. Script2.ps1 will continue automatically after the reboot. It will only reboot if Chocolatey and/or Python got installed.
- `setExecutionPolicy`: This sets the execution policy to "Default" after running the scripts.  

These "boolean" parameters are just pseudo-implemented so if you set a parameter to anything other than "true" it is considered to be "false" later in the if clause.

## Parameters to modify
Apart from the *config file* there are also some parameters in the headers of the scripts since they cannot be put inside of the config. These are:
- `workingDirectory`: The most important directory. Here should be all relevant files to be able to run the scripts.
- `confPath`: Path to *config file*.
- `script2Path`: Path to *Script2.ps1*
- `rulesetPath`: Path to custom ruleset (*customRules.json* in this case).
- `pythonFilterScript`: Path to the Python filter script (*filterExport.py*). The standard ASA json export consists of dictionaries and lists, so you need to be aware of that when you modify this script.
- `ASA parameters`: You can modify the ASA parameters in *Script2.ps1* to perform other actions. All available commands can be seen by running `.\asa.exe --help`. Then you can get more information about a command by running `.\asa.exe --help command` e.g. `.\asa.exe --help collect`.

## Using custom rules for analysis
You can find a guide on how to handle custom analysis rules in the [wiki](https://github.com/microsoft/AttackSurfaceAnalyzer/wiki/Authoring-Analysis-Rules) of ASA. Then you need to set the parameter `--filename` to point to your custom rules file e.g. `.\asa export-collect --filename Path\to\customRules.json`.
