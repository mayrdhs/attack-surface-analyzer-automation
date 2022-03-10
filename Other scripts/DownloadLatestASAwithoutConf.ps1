# Download latest Microsoft/AttackSurfaceAnalyzer release from github

$repo = "microsoft/AttackSurfaceAnalyzer"
$filenamePattern = "ASA_win_*.zip"
$extractPath = "C:\Users\User\Downloads"

$releasesUri = "https://api.github.com/repos/$repo/releases/latest"
$downloadUri = ((Invoke-RestMethod -Method GET -Uri $releasesUri).assets | Where-Object name -like $filenamePattern ).browser_download_url

$zipPath = Join-Path -Path $extractPath -ChildPath $(Split-Path -Path $downloadUri -Leaf)

Invoke-WebRequest -Uri $downloadUri -Out $zipPath

Expand-Archive -Path $zipPath -DestinationPath $extractPath -Force

Remove-Item $zipPath -Force