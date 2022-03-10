$workingDirectory="$env:USERPROFILE\Downloads"
$confPath="$workingDirectory\asa.conf"
$script2Path="$workingDirectory\Script2.ps1"
$rulesetPath="$workingDirectory\customRules.json"
$pythonFilterScript="$workingDirectory\filterExport.py"

# Test config and script2 path
if (-NOT(Test-Path $confPath -pathType leaf)) {Write-Warning "Config file not found. Please make sure the file exists and set the correct path!";Return}
if (-NOT(Test-Path $script2Path -pathType leaf)) {Write-Warning "Script2 not found. Please make sure the file exists and set the correct path!";Return}

# Create variables from config
Foreach ($i in $(Get-Content $confPath)){
    Set-Variable -Name $i.split("=")[0] -Value $i.split("=")[1]
}

# Test extract path
if (-NOT(Test-Path $extractPath -pathType container)) {Write-Warning "Extract path not found. Please make sure the directory exists and set the correct path!";Return}

# Check for custom ruleset file
if (-NOT(Test-Path $rulesetPath -pathType leaf)) {Write-Warning "Custom ruleset file not found. Please make sure the file exists and set the correct path!";Return}

# Check for python filter script
if (-NOT(Test-Path $pythonFilterScript -pathType leaf)) {Write-Warning "Python filter script not found. Please make sure the file exists and set the correct path!";Return}