<#
================================================================================
 Скрипт: 03-test-and-diagnostics.ps1
 Призначення: Перевірка статусу пірів, фазового зміщення та мережевої затримки
================================================================================
#>

[CmdletBinding()]
param(
    [string]$TargetServer = "192.168.10.10"
)

Clear-Host
Write-Host "========================================================================" -ForegroundColor Cyan
Write-Host "          КОМПЛЕКСНА ДІАГНОСТИКА СЛУЖБИ ЧАСУ (NTP DIAGNOSTICS)          " -ForegroundColor White
Write-Host "========================================================================" -ForegroundColor Cyan

Write-Host "`n>>> [1/3] Перевірка поточного стану та стратуму (w32tm /query /status):" -ForegroundColor Yellow
w32tm /query /status

Write-Host "`n>>> [2/3] Стан зв'язку із серверами часу (w32tm /query /peers):" -ForegroundColor Yellow
w32tm /query /peers

Write-Host "`n>>> [3/3] Вимірювання фазового зміщення (Offset) та затримки (Delay):" -ForegroundColor Yellow
Write-Host "Зняття 5 контрольних вимірів через stripchart до $TargetServer..." -ForegroundColor Gray
w32tm /stripchart /computer:$TargetServer /samples:5 /dataonly

Write-Host "`n========================================================================" -ForegroundColor Green
Write-Host " Діагностику завершено успішно!" -ForegroundColor Green
Write-Host "========================================================================" -ForegroundColor Green
