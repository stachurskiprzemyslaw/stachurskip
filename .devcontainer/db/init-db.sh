#!/bin/bash
# Czeka na SQL Server, ładuje strukturę i dane (idempotentnie),
# zakłada konto tylko do odczytu workshop_reader.
set -euo pipefail

SQLCMD="/opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P ${MSSQL_SA_PASSWORD} -C -b"
READER_PASSWORD="${READER_PASSWORD:-Workshop!Reader1}"

echo "[init-db] Czekam na SQL Server..."
for i in {1..90}; do
  if $SQLCMD -Q "SELECT 1" >/dev/null 2>&1; then
    echo "[init-db] SQL Server gotowy."
    break
  fi
  sleep 2
  if [ "$i" -eq 90 ]; then
    echo "[init-db] BŁĄD: SQL Server nie wstał w czasie." >&2
    exit 1
  fi
done

# Idempotencja: jeśli dane już są, nie ładuj ponownie.
if $SQLCMD -d baseFunds -Q "SET NOCOUNT ON; SELECT COUNT(*) FROM dbo.Fund" >/dev/null 2>&1; then
  echo "[init-db] Baza baseFunds już zainicjalizowana — pomijam ładowanie."
else
  echo "[init-db] Ładuję strukturę (schema.sql)..."
  $SQLCMD -i /usr/src/db/schema.sql
  echo "[init-db] Ładuję dane syntetyczne (seed.sql)..."
  $SQLCMD -d baseFunds -i /usr/src/db/seed.sql
fi

echo "[init-db] Zakładam konto tylko do odczytu (workshop_reader)..."
$SQLCMD -Q "
IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'workshop_reader')
    CREATE LOGIN workshop_reader WITH PASSWORD = '${READER_PASSWORD}', CHECK_POLICY = OFF;
"
$SQLCMD -d baseFunds -Q "
IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'workshop_reader')
    CREATE USER workshop_reader FOR LOGIN workshop_reader;
ALTER ROLE db_datareader ADD MEMBER workshop_reader;
"

echo "[init-db] GOTOWE. Baza baseFunds dostępna, konto workshop_reader (tylko SELECT) utworzone."
