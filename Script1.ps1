$workingDirectory="$env:USERPROFILE\Downloads"
$confPath="$workingDirectory\asa.conf"
$script2Path="$workingDirectory\Script2.ps1"

# Test for administrator privileges
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
	[Security.Principal.WindowsBuiltInRole] "Administrator")) {
	try {
		Write-Warning "Insufficient permissions to run this script. Requesting administrator privilege..."
		Start-Process powershell -verb RunAs -ArgumentList ".\CheckAdmin.ps1"
	} catch {
		Write-Warning "Could not run as administrator!"
		Return
	}
}

# Test network connection
Write-Output "Checking network connection..."
if (-NOT(Test-Connection -Quiet www.github.com)) {Write-Warning "Please check your network connection!";Return} Else {Write-Output "Network connection works."}

# Test config and script2 path
if (-NOT(Test-Path $confPath -pathType leaf)) {Write-Warning "Config file not found. Please make sure the file exists and set the correct path!";Return}
if (-NOT(Test-Path $script2Path -pathType leaf)) {Write-Warning "Script2 not found. Please make sure the file exists and set the correct path!";Return}

# Create variables from config
Foreach ($i in $(Get-Content $confPath)){
    Set-Variable -Name $i.split("=")[0] -Value $i.split("=")[1]
}

# Test extract path
if (-NOT(Test-Path $extractPath -pathType container)) {Write-Warning "Extract path not found. Please make sure the directory exists and set the correct path!";Return}

# Create and register new Task Scheduler task and reboot if $reboot is set to true
function Check-Reboot {
	if ($reboot -eq "true") {
		$Trigger=New-ScheduledTaskTrigger -AtLogon
		$User="User"
		$Action=New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument "$env:USERPROFILE\Downloads\Script2.ps1"
		Register-ScheduledTask -TaskName "ASATask" -Trigger $Trigger -User $User -Action $Action -RunLevel Highest
		Restart-Computer
	}
	else {
		powershell -noexit $script2Path # Continue with script2 without rebooting
	}
}

# Set system time and language as specified in config
if ($setTimeAndLanguage -eq "true") {
    Set-TimeZone -Id $timezone
    Set-WinUserLanguageList -LanguageList $language -Force
}

# Install Chocolatey and Python according to config
if ($installChocoAndPython -eq "true") {
	# Redirect standard error (2) into standard output (1) to use ErrorRecord in the if clauses
	$chocoVersion = &{choco -V} 2>&1
	$pythonVersion = &{python -V} 2>&1
	if ($chocoVersion -is [System.Management.Automation.ErrorRecord]) { # Check if Chocolatey is already installed
		Write-Output "Chocolatey is not installed! Installing latest Chocolatey version..."
		iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1')) # Install latest Chocolatey
		if ($pythonVersion -is [System.Management.Automation.ErrorRecord]) { # Check if Python is already installed
			Write-Output "`nPython is not installed! Installing latest Python 3 version..."
			choco install -y python3 # Install latest Python 3
		}
		else {
			Write-Output "`n$pythonVersion is already installed! Skipping the installation..."
		}
		Check-Reboot # Check whether a reboot should be performed
	}
	else {
		if ($pythonVersion -is [System.Management.Automation.ErrorRecord]) { # Check if Python is already installed
			Write-Output "Python is not installed! Installing latest Python 3 version..."
			choco install -y python3 # Install latest Python 3
			Check-Reboot # Check whether a reboot should be performed
		}
		else {
			Write-Output "Chocolatey $chocoVersion and $pythonVersion are already installed! Skipping the installation..."
			powershell -noexit $script2Path # Continue with script2 without rebooting
		}
	}
}
else {
	powershell -noexit $script2Path # Continue with script2 without rebooting
}
