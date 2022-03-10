$vulnerableFolder="C:\Vulnerable"

# Check and delete service
if (Get-Service SearchIndexerVuln -ErrorAction SilentlyContinue) {
	sc.exe delete SearchIndexerVuln
}

# Check and delete folder
if (Test-Path $vulnerableFolder -pathType container) {
	Remove-Item -Recurse -Force $vulnerableFolder
}

Write-Output "Everything removed."