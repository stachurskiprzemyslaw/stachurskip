# Baza funduszy (`baseFunds`) — połączenie i dane

Narzędzie, które budujesz, **czyta** dane z bazy funduszy uruchomionej w kontenerze
**SQL Server**. Ten dokument opisuje, jak się z nią połączyć i jak wygląda struktura danych.

> **Zasada nadrzędna:** Twoje narzędzie łączy się z bazą **tylko do odczytu**,
> na koncie o **najmniejszych uprawnieniach** i z **zapytaniami parametryzowanymi**.
> Żadnych sekretów w kodzie — parametry połączenia trzymaj w zmiennych środowiskowych.

---

## 1. Parametry połączenia

| Parametr            | Wartość                        |
|---------------------|--------------------------------|
| Host                | `localhost`                    |
| Port                | `1433`                         |
| Baza danych         | `baseFunds`                    |
| Użytkownik (RO)     | `workshop_reader`              |
| Hasło               | *(otrzymasz od prowadzącego — NIE wpisuj do kodu)* |
| Szyfrowanie         | `Encrypt=true`, `TrustServerCertificate=true` (środowisko lokalne) |

> Konto `workshop_reader` ma **wyłącznie prawo `SELECT`** na bazie `baseFunds`.
> To celowe — Twoje narzędzie nie ma prawa modyfikować danych.

### Connection string (przykład — wartości wstaw ze zmiennych środowiskowych)

```
Server=localhost,1433;Database=baseFunds;User Id=workshop_reader;Password=${DB_PASSWORD};Encrypt=true;TrustServerCertificate=true;
```

### Szybki test połączenia (`sqlcmd`)

```bash
sqlcmd -S localhost,1433 -d baseFunds -U workshop_reader -P "$DB_PASSWORD" \
  -Q "SELECT TOP 3 FundId, Name FROM dbo.Fund;"
```

W *Azure Data Studio* lub wtyczce *SQL Server* dla VS Code użyj tych samych parametrów.

---

## 2. Uruchomienie kontenera (jeśli prowadzący nie uruchomił go za Ciebie)

Prowadzący zwykle udostępnia gotowy kontener. Gdybyś musiał(a) uruchomić go lokalnie,
typowy schemat to obraz `mssql/server`, port `1433`, a następnie wczytanie skryptów:

```bash
# 1) Struktura
sqlcmd -S localhost,1433 -U sa -P "$SA_PASSWORD" -i db/schema.sql

# 2) Dane syntetyczne
sqlcmd -S localhost,1433 -U sa -P "$SA_PASSWORD" -d baseFunds -i db/seed.sql
```

> Skrypty [schema.sql](schema.sql) i [seed.sql](seed.sql) są w tym repo, więc bazę
> da się odtworzyć w każdej chwili. **Wszystkie dane są syntetyczne** (zmyślone) —
> nie zawierają żadnych realnych informacji.

---

## 3. Struktura danych (kanon domeny)

Pełny DDL znajdziesz w [schema.sql](schema.sql). Encje:

| Encja          | Po co                                                                 |
|----------------|-----------------------------------------------------------------------|
| `Fund`         | Fundusz (np. `FUND-A`).                                               |
| `ShareClass`   | Klasa jednostek funduszu; opłaty i waluta.                           |
| `Investor`     | Inwestor (kontrahent).                                                |
| `Instrument`   | Instrument finansowy (np. `INSTR-001`).                              |
| `PriceEOD`     | Cena instrumentu na koniec dnia.                                     |
| `Holding`      | Pozycja funduszu w instrumencie na datę (liczba jednostek/nominału). |
| `Subscription` | Wpłata inwestora (nabycie jednostek).                                |
| `Redemption`   | Umorzenie jednostek przez inwestora.                                 |
| `Valuation`    | Wycena (NAV) klasy jednostek na datę: `NetAssetValue`, `NavPerUnit`. |
| `FeeAccrual`   | Naliczenie opłat (poza zakresem MVP).                                |

Najważniejsze atrybuty:

- `ShareClass(ManagementFeeBps, PerformanceFeeBps, HurdleRateBps, Currency)`
- `Valuation(ValuationDate, NetAssetValue, NavPerUnit)`

### Reguła domenowa (przypomnienie z briefu)

- **Jednostki w obrocie** na datę `D` = `Σ Subscription.Units − Σ Redemption.Units` do `D` włącznie.
- **`NavPerUnit`** = `NetAssetValue / jednostki w obrocie`.

> `Valuation.NavPerUnit` jest w bazie **wyliczone i zapisane** — możesz go odczytać
> wprost, ale **musisz umieć go odtworzyć** z reguły (to jest sprawdzane w laboratorium 3).

---

## 4. Skala danych

- **3 fundusze**: `FUND-A`, `FUND-B`, `FUND-C`.
- **2–3 klasy jednostek** na fundusz.
- **~20 inwestorów**.
- **~90 dni** cen (`PriceEOD`) i wycen (`Valuation`).

Przykładowy oczekiwany wynik MVP: [samples/expected-nav.json](samples/expected-nav.json).
