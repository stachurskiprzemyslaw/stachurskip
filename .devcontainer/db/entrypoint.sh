#!/bin/bash
# Startuje SQL Server i równolegle (w tle) ładuje bazę funduszy.
set -e

# Inicjalizacja w tle — czeka aż serwer wstanie, potem ładuje schema + seed.
/usr/local/bin/init-db.sh &

# Serwer w pierwszym planie (proces główny kontenera).
exec /opt/mssql/bin/sqlservr
