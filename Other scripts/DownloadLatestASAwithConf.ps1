# Download latest Microsoft/AttackSurfaceAnalyzer release from github
Foreach ($i in $(Get-Content C:\Users\User\Downloads\asaL.conf)){
    Set-Variable -Name $i.split("=")[0] -Value $i.split("=")[1]
}

$releasesUri = "https://api.github.com/repos/$repo/releases/latest"
$downloadUri = ((Invoke-RestMethod -Method GET -Uri $releasesUri).assets | Where-Object name -like $filenamePattern ).browser_download_url
# $downloadUri = z.B. "https://github.com/microsoft/AttackSurfaceAnalyzer/releases/download/v2.3.274/ASA_win_2.3.274.zip"

$zipPath = Join-Path -Path $extractPath -ChildPath $(Split-Path -Path $downloadUri -Leaf)
# $zipPath = C:\Users\User\Downloads\ASA_win_2.3.274.zip

Invoke-WebRequest -Uri $downloadUri -Out $zipPath

Expand-Archive -Path $zipPath -DestinationPath $extractPath -Force

Remove-Item $zipPath -Force