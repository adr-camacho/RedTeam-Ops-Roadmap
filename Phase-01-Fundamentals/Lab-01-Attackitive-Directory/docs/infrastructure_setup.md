# Configuración de la Infraestructura y Vulnerabilidades

Para emular un entorno real, se ejecutó un script de provisionamiento en el **DC-01** que inyectó las siguientes configuraciones inseguras:

## 👤 Identidades y Grupos
* **Localización**: El sistema está en español. Grupos clave identificados:
    * `Admins. del dominio` (Equivalente a Domain Admins).
    * `Usuarios de administración remota` (Permite acceso vía WinRM).
    * `Todos` (Equivalente a Everyone para permisos SMB).

## 🎯 Vectores de Ataque Inyectados
| Vector | Objetivo | Configuración Técnica |
| :--- | :--- | :--- |
| **AS-REP Roasting** | `jgarcia` | Atributo `DoesNotRequirePreAuth` habilitado. |
| **Kerberoasting** | `sql_svc` | Service Principal Name (SPN) configurado en la cuenta. |
| **Info Leak** | `alberto` | Contraseña en texto claro en el campo "Descripción" de AD. |
| **Privesc (LPE)** | Local | Servicio con "Unquoted Service Path" en `C:\Program Files\Servicio Critico`. |
| **SMB Share** | Red | Recurso compartido `\\DC-01\Publico` con acceso total para `Todos`. |

## 🛠️ Script de Provisionamiento (PowerShell)
```powershell
# 1. Crear Estructura de Unidades Organizativas
$OUs = @("Comercial", "Recursos Humanos", "IT", "Cuentas de Servicio")
foreach ($ou in $OUs) {
    if (-not (Get-ADOrganizationalUnit -Filter "Name -eq '$ou'")) {
        New-ADOrganizationalUnit -Name $ou -Path "DC=attackitivedirectory,DC=local"
    }
}

# 2. Crear usuario para AS-REP Roasting (jgarcia)
$pass1 = ConvertTo-SecureString "Password123!" -AsPlainText -Force
if (-not (Get-ADUser -Filter "SamAccountName -eq 'jgarcia'")) {
    New-ADUser -Name "Juan Garcia" -SamAccountName "jgarcia" `
    -UserPrincipalName "jgarcia@attackitivedirectory.local" `
    -Path "OU=Comercial,DC=attackitivedirectory,DC=local" `
    -AccountPassword $pass1 -Enabled $true
}
Set-ADAccountControl -Identity jgarcia -DoesNotRequirePreAuth $true

# 3. Crear usuario para Kerberoasting (sql_svc) con SPN corregido
$pass2 = ConvertTo-SecureString "SqlAdmin789!" -AsPlainText -Force
if (-not (Get-ADUser -Filter "SamAccountName -eq 'sql_svc'")) {
    New-ADUser -Name "SQL Service Account" -SamAccountName "sql_svc" `
    -Path "OU=Cuentas de Servicio,DC=attackitivedirectory,DC=local" `
    -AccountPassword $pass2 -Enabled $true
}
# Corregido: Uso de tabla hash para el SPN
Set-ADUser -Identity sql_svc -ServicePrincipalName @{Add="MSSQLSvc/db01.attackitivedirectory.local:1433"}

# 4. Simular pistas en descripciones
Set-ADUser -Identity "alberto" -Description "Contraseña temporal de bienvenida: Welcome2026!"

# 5. Vulnerabilidad de Escalada Local (Rutas sin comillas)
if (-not (Test-Path "C:\Program Files\Servicio Critico")) {
    New-Item -Path "C:\Program Files\Servicio Critico" -ItemType Directory
    New-Item -Path "C:\Program Files\Servicio Critico\Monitor v1.exe" -ItemType File
}

# 6. Recurso compartido inseguro (Corregido para idioma español)
if (-not (Test-Path "C:\Publico")) {
    New-Item -Path "C:\Publico" -ItemType Directory
}
# Nota: Usamos "Todos" en lugar de "Everyone"
if (-not (Get-SmbShare -Name "Publico" -ErrorAction SilentlyContinue)) {
    New-SmbShare -Name "Publico" -Path "C:\Publico" -FullAccess "Todos"
}
```