# Spec MVP

## Cel
Udostepnic endpoint read-only, ktory po podaniu funduszu, klasy jednostek i daty zwraca `NavPerUnit` oraz 5 najwiekszych pozycji funduszu.

## Wejscie/wyjscie
- Endpoint: `GET /funds/{fundId}/nav?date=YYYY-MM-DD&shareClass={shareClassId}`
- Sukces: JSON zgodny semantycznie z `db/samples/expected-nav.json`.
- Brak danych: HTTP 404 z kontrolowanym komunikatem.

## Reguly domenowe
- `units_outstanding = SUM(subscription.units) - SUM(redemption.units)` do daty `D`.
- `NavPerUnit = NetAssetValue / units_outstanding`.
- `market_value = Holding.Quantity * PriceEOD.ClosePrice`; zwracane top 5 malejaco.

## Bezpieczenstwo
- Zapytania SQL parametryzowane.
- Brak sekretow w kodzie (tylko env).
- Konto read-only (`workshop_reader`).
- Walidacja formatu `fundId`, `shareClass`, `date`.

## Kryterium akceptacji
- Test endpointu przechodzi i potwierdza wartosci z happy path dla `FUND-A`, `FUND-A-ACC`, `2025-02-10`.
