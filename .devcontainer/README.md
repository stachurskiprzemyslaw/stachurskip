# Środowisko „pod klucz" (Dev Container / Codespaces)

To repozytorium ma gotowe środowisko. Nie musisz ręcznie instalować bazy ani konfigurować
połączenia — wystarczy je otworzyć.

## Jak uruchomić

### Wariant A — GitHub Codespaces (w przeglądarce, najprościej)
1. Na stronie repozytorium kliknij **Code → Codespaces → Create codespace**.
2. Poczekaj, aż środowisko się zbuduje (kilka minut przy pierwszym razie).
3. Baza funduszy wstaje automatycznie w tle (~30–60 s po starcie).

### Wariant B — VS Code lokalnie (Dev Container)
1. Zainstaluj **Docker Desktop** i rozszerzenie **Dev Containers** do VS Code.
2. Otwórz folder repozytorium w VS Code.
3. Kliknij **„Reopen in Container"** (lub: paleta poleceń → *Dev Containers: Reopen in Container*).

W obu wariantach dostajesz: Node.js 20, GitHub Copilot i połączenie z bazą — bez instalacji.

## Co startuje automatycznie

- **Kontener `app`** — Twoje środowisko pracy (Node 20, Copilot, klient SQL Server dla VS Code).
- **Kontener `db`** — SQL Server, który **sam ładuje** strukturę i dane syntetyczne
  (`db/schema.sql` + `db/seed.sql`) oraz zakłada konto tylko do odczytu `workshop_reader`.

Połączenie jest podane przez zmienne środowiskowe (host `db`, baza `baseFunds`,
użytkownik `workshop_reader`). Twoja aplikacja czyta je z `process.env` — **nie musisz**
tworzyć pliku `.env` w tym środowisku.

## Test, że działa

W terminalu kontenera:
```bash
sqlcmd -S db -d baseFunds -U workshop_reader -P "$DB_PASSWORD" -C \
  -Q "SELECT NavPerUnit FROM dbo.Valuation v JOIN dbo.ShareClass s ON s.ShareClassId=v.ShareClassId WHERE v.ShareClassId='FUND-A-ACC' AND v.ValuationDate='2025-02-10';"
```
Powinno zwrócić **103.120000**.

> Pierwszy `sqlcmd` może się nie połączyć, jeśli baza jeszcze się ładuje — odczekaj minutę.

## O hasłach w tym środowisku (ważne)

Hasła w `docker-compose.yml` (`MSSQL_SA_PASSWORD`, `READER_PASSWORD`) to **wyłącznie lokalne
wartości startowe** dla bazy z danymi **zmyślonymi**, działającej tylko w tym kontenerze.
To **nie są** prawdziwe sekrety i nigdy nie używaj ich poza warsztatem.

To **nie kłóci się** z zasadą „zero sekretów w kodzie", której uczymy: w swojej aplikacji
**nie wpisujesz** żadnych haseł do kodu źródłowego — czytasz je ze zmiennych środowiskowych
(`process.env.DB_PASSWORD`). Dev container tylko dostarcza te zmienne za Ciebie.

W prawdziwym projekcie te wartości pochodziłyby z menedżera sekretów, a nie z pliku w repo.

## Dla prowadzącego

- Dev container działa też z katalogiem `/facilitator/` (gdy masz go lokalnie) — możesz odpalić
  wzorcową aplikację: `cd facilitator/reference-impl && npm install && npm run dev`, a potem `npm test`.
- Uczestnik dostaje repo **bez** `/facilitator/` (jest w `.gitignore`), ale z pełnym dev containerem
  i bazą — czyli wszystkim, czego potrzebuje.
