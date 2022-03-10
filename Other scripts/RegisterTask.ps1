$Trigger=New-ScheduledTaskTrigger -AtLogon
$User="User"
$Action=New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument "$env:USERPROFILE\Downloads\Script2.ps1"
Register-ScheduledTask -TaskName "ASATask" -Trigger $Trigger -User $User -Action $Action -RunLevel Highest