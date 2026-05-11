# =============================================================
# SCRIPT 05 — Configuración MSSQL vulnerable
# Ejecutar: PowerShell como Administrador
# Máquina: DC-01
# Prerequisito: SQL Server Express 2019 instalado manualmente
# Descarga: https://www.microsoft.com/en-us/sql-server/sql-server-downloads
# =============================================================

Write-Host "`n[*] Configurando SQL Server Express..." -ForegroundColor Cyan

# Verificar que sqlcmd está disponible
if (-not (Get-Command sqlcmd -ErrorAction SilentlyContinue)) {
    Write-Host "[!] sqlcmd no encontrado. Instala SQL Server Express primero." -ForegroundColor Red
    Write-Host "    Descarga: https://www.microsoft.com/en-us/sql-server/sql-server-downloads" -ForegroundColor Yellow
    exit 1
}

$query = @"
-- Habilitar opciones avanzadas
EXEC sp_configure 'show advanced options', 1;
RECONFIGURE;

-- Habilitar xp_cmdshell (vector de ejecucion de comandos OS)
EXEC sp_configure 'xp_cmdshell', 1;
RECONFIGURE;

-- Crear login sql_svc con privilegios de sysadmin
IF NOT EXISTS (SELECT * FROM sys.server_principals WHERE name = 'sql_svc')
BEGIN
    CREATE LOGIN [sql_svc] WITH PASSWORD = 'SqlService123', CHECK_POLICY = OFF;
    EXEC sp_addsrvrolemember 'sql_svc', 'sysadmin';
    PRINT '[+] Login sql_svc creado con rol sysadmin';
END
ELSE
BEGIN
    PRINT '[!] Login sql_svc ya existe';
END

-- Habilitar SA con contrasena debil
ALTER LOGIN [sa] WITH PASSWORD = 'Sa_Admin2024!', CHECK_POLICY = OFF;
ALTER LOGIN [sa] ENABLE;
PRINT '[!] Login SA habilitado con contrasena debil';

-- Crear base de datos corporativa
IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = 'CorpDB')
BEGIN
    CREATE DATABASE CorpDB;
    PRINT '[+] Base de datos CorpDB creada';
END

USE CorpDB;

-- Crear tabla de empleados con datos sensibles
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Empleados')
BEGIN
    CREATE TABLE Empleados (
        ID INT PRIMARY KEY,
        Nombre NVARCHAR(100),
        Email NVARCHAR(100),
        Departamento NVARCHAR(50),
        Salario DECIMAL(10,2)
    );

    INSERT INTO Empleados VALUES
        (1, 'Carlos Martinez', 'ceo.martinez@atackcorp.local', 'Direccion', 85000),
        (2, 'Laura Lopez',     'rrhh.lopez@atackcorp.local',   'RRHH',      45000),
        (3, 'Fernando Garcia', 'fin.garcia@atackcorp.local',   'Finanzas',  52000),
        (4, 'IT Admin',        'it.admin@atackcorp.local',     'IT',        60000),
        (5, 'Helpdesk Ruiz',   'helpdesk.ruiz@atackcorp.local','IT',        38000);

    PRINT '[+] Tabla Empleados creada con datos de muestra';
END
"@

# Ejecutar contra la instancia local
sqlcmd -S "localhost\SQLEXPRESS" -Q $query -E
if ($LASTEXITCODE -eq 0) {
    Write-Host "[+] MSSQL configurado correctamente" -ForegroundColor Green
    Write-Host "[!] xp_cmdshell habilitado" -ForegroundColor Red
    Write-Host "[!] SA habilitado con contrasena debil" -ForegroundColor Red
} else {
    Write-Host "[!] Error al configurar MSSQL. Verifica el nombre de la instancia." -ForegroundColor Red
    Write-Host "    Prueba con: sqlcmd -S localhost -Q 'SELECT @@VERSION' -E" -ForegroundColor Yellow
}

Write-Host "`n[+] Script 05 completado." -ForegroundColor Green
