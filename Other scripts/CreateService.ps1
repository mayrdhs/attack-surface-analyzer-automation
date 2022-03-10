# Create new vulnerable service
New-Item -Path 'C:\Vulnerable\' -ItemType Directory > $null # Create new directory and redirect output to $null
Copy-Item -path C:\Windows\System32\SearchIndexer.exe -destination C:\Vulnerable\ # Copy service binary
Rename-Item -Path "C:\Vulnerable\SearchIndexer.exe" -NewName "SearchIndexerVuln.exe"
New-Service -Name "SearchIndexerVuln" -BinaryPathName "C:\Vulnerable\SearchIndexerVuln.exe" > $null # Create new service and redirect output to $null
Write-Output "Created vulnerable service."