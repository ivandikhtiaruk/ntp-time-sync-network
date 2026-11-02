# ntp-time-sync-network
Розгортання корпоративного сервера точного часу NTPv4 (Stratum 2) на базі Windows та автоматизоване налаштування клієнтів (PowerShell, Linux, Cisco)
# Корпоративна система синхронізації часу за протоколом NTPv4

[![PowerShell](https://img.shields.io/badge/PowerShell-5.1%20%7C%207%2B-blue.svg)](https://microsoft.com/PowerShell)
[![Protocol](https://img.shields.io/badge/Protocol-NTPv4%20(RFC%205905)-green.svg)](https://datatracker.ietf.org/doc/html/rfc5905)
[![Platform](https://img.shields.io/badge/Platform-Windows%20%7C%20Linux%20%7C%20Cisco-orange.svg)](#)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

Практична реалізація системи централізованої синхронізації часу на базі протоколу **NTPv4 (Network Time Protocol)** у корпоративній локальній мережі. Проєкт включає конфігурацію виділеного сервера часу рівня **Stratum 2** на платформі Windows, автоматизацію налаштувань за парадигмою Infrastructure as Code (IaC) за допомогою **PowerShell**, а також інтеграцію гетерогенних клієнтів (Windows, Linux, активне мережеве обладнання Cisco).

> **Курсова робота з дисципліни:** «Комп'ютерні системи і мережі»  
> **Освітньо-професійна програма:** «Комп'ютерна інженерія» (Спеціальність 123)  
> **Заклад освіти:** ВСП «Ірпінський фаховий коледж НУБіП України»  
> **Керівник:** викладач Кумейко В. О.

---

##  Архітектура мережі та розподілу часу

Сервер точного часу отримує мітки від пулу авторитетних джерел першого рівня (Stratum 1), стабілізує шкалу часу й транслює її у внутрішні віртуальні підмережі підприємства:

```text
                  [ Зовнішні еталони Stratum 1 ]
   (0.ua.pool.ntp.org | time.cloudflare.com | time.google.com)
                               │
                               ▼ UDP 123 (режим iburst)
                 [ Граничний міжмережевий екран ]
                               │
                               ▼
              [ Локальний NTP-сервер Stratum 2 ]
                   IP-адреса: 192.168.10.10
         (Windows Time w32time + Local Clock Fallback)
                               │
       ┌───────────────────────┼───────────────────────┐
       ▼                       ▼                       ▼
   [ VLAN 20 ]             [ VLAN 30 ]             [ VLAN 99 ]
 Робочі станції          Клієнти Linux         Мережеві комутатори
    Windows           (systemd-timesyncd)        (Cisco Catalyst)
  192.168.20.0/24         192.168.30.0/24         192.168.99.0/24
