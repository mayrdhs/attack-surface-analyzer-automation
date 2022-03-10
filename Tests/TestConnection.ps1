# Test network connections towards GitHub

if (-NOT(Test-Connection -Quiet www.github.com)) {
	Write-Warning "Please check your network connection!"
	Return
} Else {
	Write-Output "Network connection works."
}
