# 01_promover_controlador_de_dominio_atackcorp.ps1
# Maquina: DC-01 (Windows Server 2025)
# Version: 2.0 | Junio 2026
# PREREQUISITO MANUAL: Renombrar equipo a DC-01, reiniciar, luego ejecutar

if ($env:COMPUTERNAME -ne "DC-01") { Write-Warning "Ejecutar en DC-01"; exit 1 }

Write-Host "================================================" -ForegroundColor DarkCyan
Write-Host "  DC-01: Promocion a Controlador de Dominio" -ForegroundColor DarkCyan
Write-Host "  Dominio: atackcorp.local" -ForegroundColor DarkCyan
Write-Host "================================================" -ForegroundColor DarkCyan

$adapter = Get-NetAdapter | Where-Object {$_.Status -eq "Up"} | Select-Object -First 1
New-NetIPAddress -InterfaceIndex $adapter.InterfaceIndex -IPAddress 10.0.2.10 -PrefixLength 24 -DefaultGateway 10.0.2.1 -ErrorAction SilentlyContinue
Set-DnsClientServerAddress -InterfaceIndex $adapter.InterfaceIndex -ServerAddresses 127.0.0.1
Write-Host "[+] IP estatica: 10.0.2.10/24" -ForegroundColor Green

Install-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools | Out-Null
Write-Host "[+] AD DS instalado" -ForegroundColor Green

$safePass = ConvertTo-SecureString "NuevaPassword2026!" -AsPlainText -Force
Install-ADDSForest `
    -DomainName "atackcorp.local" `
    -DomainNetbiosName "ATACKCORP" `
    -SafeModeAdministratorPassword $safePass `
    -DomainMode WinThreshold `
    -ForestMode WinThreshold `
    -InstallDns `
    -Force

Write-Host "[OK] DC-01 promovido — reiniciando..." -ForegroundColor Green
Write-Host "     Continuar con 02_crear_usuarios_ous_atackcorp.ps1 tras el reinicio" -ForegroundColor Yellow
