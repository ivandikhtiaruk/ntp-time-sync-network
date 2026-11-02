<#
================================================================================
 Скрипт: 02-configure-client.ps1
 Призначення: Налаштування клієнтських станцій Windows на локальний сервер
================================================================================
#>

[CmdletBinding()]
param(
    [string]$ServerIP = "192.168.10.10"
)

$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Error "Помилка: Запустіть PowerShell від імені Адміністратора!"
    exit 1
}

Write-Host "Підключення клієнта до локального NTP-сервера $ServerIP..." -ForegroundColor Cyan

Stop-Service -Name w32time -Force -ErrorAction SilentlyContinue

w32tm /config /syncfromflags:manual /manualpeerlist:"$ServerIP,0x9" /reliable:yes /update

Set-Service -Name w32time -StartupType Automatic
Start-Service -Name w32time

Start-Sleep -Seconds 2
w32tm /resync /force

Write-Host "`n[УСПІХ] Клієнтська операційна система синхронізована з $ServerIP!" -ForegroundColor Green
