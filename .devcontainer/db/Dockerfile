# SQL Server z automatycznym załadowaniem bazy funduszy (schema + seed)
# oraz konta tylko do odczytu (workshop_reader).
# Kontekst budowania = korzeń repo (patrz docker-compose.yml), więc kopiujemy db/.

FROM mcr.microsoft.com/mssql/server:2022-latest

USER root

# Skrypty SQL (struktura + dane syntetyczne) z toru uczestnika.
COPY db/schema.sql /usr/src/db/schema.sql
COPY db/seed.sql   /usr/src/db/seed.sql

# Skrypty startowe.
COPY .devcontainer/db/entrypoint.sh /usr/local/bin/entrypoint.sh
COPY .devcontainer/db/init-db.sh    /usr/local/bin/init-db.sh
RUN chmod +x /usr/local/bin/entrypoint.sh /usr/local/bin/init-db.sh

USER mssql

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
