<#
================================================================================
 Скрипт: 01-setup-ntp-server.ps1
 Призначення: Розгортання локального сервера NTPv4 рівня Stratum 2 на базі Windows
================================================================================
#>

[CmdletBinding()]
param()

$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Error "Помилка: Запустіть цей скрипт від імені Адміністратора!"
    exit 1
}

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host " [1/5] Зупинка служби Windows Time (w32time)... " -ForegroundColor Yellow
Write-Host "==========================================================" -ForegroundColor Cyan
Stop-Service -Name w32time -Force -ErrorAction SilentlyContinue

Write-Host "`n[2/5] Налаштування системного реєстру W32Time..." -ForegroundColor Yellow
$regPath = "HKLM:\SYSTEM\CurrentControlSet\Services\W32Time"

Set-ItemProperty -Path "$regPath\Parameters" -Name "Type" -Value "NTP" -Type String
$ntpPools = "0.ua.pool.ntp.org,0x9 time.cloudflare.com,0x9 time.google.com,0x9"
Set-ItemProperty -Path "$regPath\Parameters" -Name "NtpServer" -Value $ntpPools -Type String

Set-ItemProperty -Path "$regPath\TimeProviders\NtpServer" -Name "Enabled" -Value 1 -Type DWord
Set-ItemProperty -Path "$regPath\Config" -Name "AnnounceFlags" -Value 5 -Type DWord
Set-ItemProperty -Path "$regPath\Config" -Name "LocalClockDispersion" -Value 0 -Type DWord
Set-ItemProperty -Path "$regPath\Config" -Name "MaxPosPhaseCorrection" -Value 172800 -Type DWord
Set-ItemProperty -Path "$regPath\Config" -Name "MaxNegPhaseCorrection" -Value 172800 -Type DWord

Write-Host "`n[3/5] Налаштування брандмауера Windows Defender Firewall..." -ForegroundColor Yellow
$firewallRule = "NTP-Server-Inbound-UDP123"
Remove-NetFirewallRule -DisplayName $firewallRule -ErrorAction SilentlyContinue

$trustedVlans = @("192.168.10.0/24", "192.168.20.0/24", "192.168.30.0/24", "192.168.99.0/24")
New-NetFirewallRule -DisplayName $firewallRule `
                    -Direction Inbound `
                    -Action Allow `
                    -Protocol UDP `
                    -LocalPort 123 `
                    -RemoteAddress $trustedVlans `
                    -Description "Дозвіл вхідного NTP-трафіку з локальних підмереж" | Out-Null

Write-Host "`n[4/5] Запуск та переведення служби в автоматичний режим..." -ForegroundColor Yellow
Set-Service -Name w32time -StartupType Automatic
Start-Service -Name w32time

Write-Host "`n[5/5] Оновлення конфігурації та примусова синхронізація..." -ForegroundColor Yellow
w32tm /config /update | Out-Null
Start-Sleep -Seconds 2
w32tm /resync /rediscover | Out-Null

Write-Host "`n==========================================================" -ForegroundColor Green
Write-Host " [УСПІХ] Сервер точного часу Stratum 2 успішно запущено!" -ForegroundColor Green
Write-Host " Локальна адреса сервера: 192.168.10.10" -ForegroundColor White
Write-Host "==========================================================" -ForegroundColor Green
