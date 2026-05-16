# =============================================================
# SCRIPT 01 — Instalación AD DS y promoción del dominio
# Ejecutar: PowerShell como Administrador (antes del reinicio)
# Máquina: DC-01
# =============================================================

# 1. Instalar rol AD DS
Write-Host "[*] Instalando rol AD DS..." -ForegroundColor Cyan
Install-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools

# 2. Promocionar como Domain Controller
Write-Host "[*] Promoviendo como Domain Controller..." -ForegroundColor Cyan
Import-Module ADDSDeployment
Install-ADDSForest `
    -DomainName "atackcorp.local" `
    -DomainNetbiosName "ATACKCORP" `
    -ForestMode "WinThreshold" `
    -DomainMode "WinThreshold" `
    -InstallDns:$true `
    -SafeModeAdministratorPassword (ConvertTo-SecureString "Admin1234!" -AsPlainText -Force) `
    -Force:$true

# El servidor se reiniciará automáticamente tras la promoción
