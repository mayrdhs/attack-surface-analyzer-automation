$workingDirectory="$env:USERPROFILE\Downloads"
$rulesetPath="$workingDirectory\customRules.json"
$pythonFilterScript="$workingDirectory\filterExport.py"
$folderPath="$workingDirectory\ASA_win_2.3.276"

# Run first scan
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

# Compare and evaluate scans
Write-Output "Collecting results..."
.\asa export-collect --filename $rulesetPath

# Check if result file already exists and rename export if not
if (Test-Path "$folderPath\result.json" -pathType leaf) {Write-Warning "Result file already exists. Please make sure to rename or remove it and the run the script again.";Return}
if (Test-Path "$workingDirectory\filteredResult.json" -pathType leaf) {Write-Warning "Filtered result file already exists. Please make sure to rename or remove it and the run the script again.";Return}
Get-Childitem -Path "$folderPath\*.json.txt" | Rename-Item -NewName "result.json"

# Check for python filter script and copy it into ASA folder
if (-NOT(Test-Path $pythonFilterScript -pathType leaf)) {Write-Warning "Python filter script not found. Please make sure the file exists and set the correct path!";Return}
Copy-Item "$workingDirectory\filterExport.py" $folderPath

# Filter json result file
python filterExport.py

# Move filtered result to working directory
Move-Item "$folderPath\resultFiltered.json" $workingDirectory

Write-Output "Everything done! The filtered json result file is at $workingDirectory\resultFiltered.json"