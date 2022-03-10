# Download latest Microsoft/AttackSurfaceAnalyzer release from github
Foreach ($i in $(Get-Content C:\Users\User\Downloads\asaV.conf)){
    Set-Variable -Name $i.split("=")[0] -Value $i.split("=")[1]
}

$downloadUri = "https://github.com/microsoft/AttackSurfaceAnalyzer/releases/download/v$version/ASA_win_$version.zip"
# $downloadUri = e.g. "https://github.com/microsoft/AttackSurfaceAnalyzer/releases/download/v2.3.272/ASA_win_2.3.272.zip"

$zipPath = Join-Path -Path $extractPath -ChildPath $(Split-Path -Path $downloadUri -Leaf)
# $zipPath = e.g. "C:\Users\User\Downloads\ASA_win_2.3.272.zip"

Invoke-WebRequest -Uri $downloadUri -Out $zipPath

Expand-Archive -Path $zipPath -DestinationPath $extractPath -Force

Remove-Item $zipPath -Force