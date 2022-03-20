$workingDirectory="$env:USERPROFILE\Downloads"
$rulesetPath="$workingDirectory\customRules.json"
$pythonFilterScript="$workingDirectory\filterExport.py"

# Create variables from config
Foreach ($i in $(Get-Content $env:USERPROFILE\Downloads\asa.conf)){
    Set-Variable -Name $i.split("=")[0] -Value $i.split("=")[1]
}

# Set download URI and ASA version name
if ($downloadLatestASA -eq "true") {
	$downloadUri = ((Invoke-RestMethod -Method GET -Uri https://api.github.com/repos/$repo/releases/latest).assets | Where-Object name -like $filenamePattern ).browser_download_url
	$asaName = (Invoke-RestMethod -Method GET -Uri https://api.github.com/repos/$repo/releases/latest).name
}
else {
	$downloadUri = "https://github.com/$repo/releases/download/v$version/ASA_win_$version.zip"
	$asaName = "v$version"
}

# Set path for zip and ASA folder name
$zipPath = Join-Path -Path $extractPath -ChildPath (Split-Path -Path $downloadUri -Leaf)
$asaFolderPath = Join-Path -Path $extractPath -ChildPath ("ASA_win_$asaName".replace('v',''))

# Check if version is already installed
if (Test-Path $asaFolderPath -pathType container) {Write-Warning "This version is already installed! Quitting the setup...";Return}

Write-Output "This version is not installed yet."