Write-Host "Checking for elevated permissions..."
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

Write-Output "Success!"