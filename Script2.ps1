$workingDirectory="$env:USERPROFILE\Downloads"
$confPath="$workingDirectory\asa.conf"
$rulesetPath="$workingDirectory\customRules.json"
$pythonFilterScript="$workingDirectory\filterExport.py"

# Create variables from config
Foreach ($i in $(Get-Content $confPath)){
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
$asaFolderName = Join-Path -Path $extractPath -ChildPath ("ASA_win_$asaName".replace('v',''))

# Check if version is already installed
if (Test-Path $asaFolderName -pathType container) {Write-Warning "This version is already installed! Quitting the setup...";Return}

# Download ASA
Write-Output "Downloading Microsoft Attack Surface Analyzer $asaName..."
try {
	Invoke-WebRequest -Uri $downloadUri -Out $zipPath
} catch {
	Write-Warning "The specified version ($asaName) is not available! Please make sure to set an existing version in the config file."
	do {
		Write-Output "Would you like to download the latest available version? Type 'no' to quit. [yes/no]"
		$choice = Read-Host "`nEnter Choice"
	} until (($choice -eq 'yes') -or ($choice -eq 'no'))
	switch ($choice) {
	   'yes'{
		   $asaName = (Invoke-RestMethod -Method GET -Uri https://api.github.com/repos/$repo/releases/latest).name
		   $downloadUri = ((Invoke-RestMethod -Method GET -Uri https://api.github.com/repos/$repo/releases/latest).assets | Where-Object name -like $filenamePattern).browser_download_url
		   $zipPath = Join-Path -Path $extractPath -ChildPath (Split-Path -Path $downloadUri -Leaf)
		   $asaFolderName = Join-Path -Path $extractPath -ChildPath ("ASA_win_$asaName".replace('v',''))
		   if (Test-Path $asaFolderName -pathType container) {
			   Write-Warning "The latest Microsoft ASA version ($asaName) is already installed! Quitting the setup..."
			   Return
		   }
		   Write-Output "Downloading Microsoft Attack Surface Analyzer $asaName..."
		   Invoke-WebRequest -Uri $downloadUri -Out $zipPath
	   }
	   'no'{
		   Write-Output "`nYou have selected to quit the setup."
		   Return
	   }
	}
}

# Extract archive and clear up
Write-Output "Extracting Microsoft Attack Surface Analyzer $asaName..."
Expand-Archive -Path $zipPath -DestinationPath $extractPath
Remove-Item $zipPath -Force
Write-Output "Microsoft Attack Surface Analyzer $asaName was successfully installed!"

# Add Windows Defender rule
$folderPath =  $zipPath.Substring(0, $zipPath.LastIndexOf('.'))
$asaPath = Join-Path -Path $folderPath -ChildPath asa.exe
Add-MpPreference -ExclusionProcess $asaPath

# Set execution policy
if ($setExecutionPolicy -eq "true") {Set-ExecutionPolicy Default}

# Unregister scheduled Task
$scheduledTask = Get-ScheduledTask -TaskName "ASATask" -ErrorAction SilentlyContinue
if ($scheduledTask) {Unregister-ScheduledTask -TaskName "ASATask" -Confirm:$false}

# Change directory and run first scan
cd $folderPath
Write-Output "Running first scan..."
.\asa.exe collect -fs

# Create new vulnerable service (modify the system between the scans)
New-Item -Path 'C:\Vulnerable\' -ItemType Directory > $null # Create new directory and redirect output to $null
Copy-Item -path C:\Windows\System32\SearchIndexer.exe -destination C:\Vulnerable\ # Copy service binary
Rename-Item -Path "C:\Vulnerable\SearchIndexer.exe" -NewName "SearchIndexerVuln.exe"
New-Service -Name "SearchIndexerVuln" -BinaryPathName "C:\Vulnerable\SearchIndexerVuln.exe" > $null # Create new service and redirect output to $null
Write-Output "Created vulnerable service."

# Run second scan
Write-Output "Running second scan..."
.\asa.exe collect -fs

# Check for custom ruleset file
if (-NOT(Test-Path $rulesetPath -pathType leaf)) {Write-Warning "Custom ruleset file not found. Please make sure the file exists and set the correct path!";Return}

# Compare and evaluate scans
Write-Output "Collecting results..."
.\asa export-collect --filename $rulesetPath

# Check if result file already exists and rename export if not
if (Test-Path "$folderPath\result.json" -pathType leaf) {Write-Warning "Result file already exists. Please make sure to rename or remove it and the run the script again.";Return}
if (Test-Path "$workingDirectory\filteredResult.json" -pathType leaf) {Write-Warning "Filtered result file already exists. Please make sure to rename or remove it and the run the script again.";Return}
Get-Childitem -Path "$folderPath\*.json.txt" | Rename-Item -NewName "result.json"

# Check for Python filter script and copy it into ASA folder
if (-NOT(Test-Path $pythonFilterScript -pathType leaf)) {Write-Warning "Python filter script not found. Please make sure the file exists and set the correct path!";Return}
Copy-Item "$workingDirectory\filterExport.py" $folderPath

# Filter json result file using Python
python filterExport.py

# Move filtered result to working directory
Move-Item "$folderPath\resultFiltered.json" $workingDirectory

Write-Output "Everything done! The filtered json result file is at $workingDirectory\resultFiltered.json"