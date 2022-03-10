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
}
else {
	if ($pythonVersion -is [System.Management.Automation.ErrorRecord]) { # Check if Python is already installed
		Write-Output "Python is not installed! Installing latest Python 3 version..."
		choco install -y python3 # Install latest Python 3
	}
	else {
		Write-Output "Chocolatey $chocoVersion and $pythonVersion are already installed! Skipping the installation..."
	}
}
