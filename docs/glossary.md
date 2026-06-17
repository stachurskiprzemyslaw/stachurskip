# Slownik domenowy (Glossary)

Dokument definiuje wspolny jezyk domeny dla MVP: podaj fundusz i date, zwroc NavPerUnit oraz 5 najwiekszych pozycji.

## Encje kanonu

### Fund (Fundusz)
- Identyfikator: `FundId`
- Definicja: fundusz inwestycyjny, nadrzedna jednostka biznesowa grupujaca klasy jednostek i portfel instrumentow.
- Kluczowe atrybuty: `Name`, `BaseCurrency`, `InceptionDate`.
- Powiazania: 1:N do `ShareClass`, 1:N do `Holding`.

### ShareClass (Klasa jednostek)
- Identyfikator: `ShareClassId`
- Definicja: klasa jednostek uczestnictwa nalezaca do funduszu; na jej poziomie liczone sa jednostki w obrocie i NAV na jednostke.
- Kluczowe atrybuty: `FundId`, `Name`, `Currency`, `ManagementFeeBps`, `PerformanceFeeBps`, `HurdleRateBps`.
- Powiazania: N:1 do `Fund`, 1:N do `Subscription`, `Redemption`, `Valuation`, `FeeAccrual`.

### Investor (Inwestor)
- Identyfikator: `InvestorId`
- Definicja: podmiot nabywajacy i umarzajacy jednostki uczestnictwa.
- Kluczowe atrybuty: `Name`, `Country`.
- Powiazania: 1:N do `Subscription`, 1:N do `Redemption`.

### Instrument (Instrument finansowy)
- Identyfikator: `InstrumentId`
- Definicja: papier/instrument finansowy utrzymywany w portfelu funduszu.
- Kluczowe atrybuty: `Name`, `AssetClass`, `Currency`.
- Powiazania: 1:N do `PriceEOD`, 1:N do `Holding`.

### PriceEOD (Cena koniec dnia)
- Klucz glowny: (`InstrumentId`, `PriceDate`)
- Definicja: cena zamkniecia instrumentu na dany dzien wyceny.
- Kluczowe atrybuty: `ClosePrice`.
- Powiazania: N:1 do `Instrument`.

### Holding (Pozycja funduszu)
- Identyfikator: `HoldingId`
- Definicja: liczba jednostek/nominal instrumentu utrzymywana przez fundusz na date `AsOfDate`.
- Kluczowe atrybuty: `FundId`, `InstrumentId`, `AsOfDate`, `Quantity`.
- Powiazania: N:1 do `Fund`, N:1 do `Instrument`.
- Uwagi: wartosc pozycji wyznaczamy przez polaczenie z `PriceEOD` po `InstrumentId` i dacie.

### Subscription (Nabycie)
- Identyfikator: `SubscriptionId`
- Definicja: transakcja nabycia jednostek klasy przez inwestora.
- Kluczowe atrybuty: `ShareClassId`, `InvestorId`, `TradeDate`, `Units`.
- Powiazania: N:1 do `ShareClass`, N:1 do `Investor`.

### Redemption (Umorzenie)
- Identyfikator: `RedemptionId`
- Definicja: transakcja umorzenia jednostek klasy przez inwestora.
- Kluczowe atrybuty: `ShareClassId`, `InvestorId`, `TradeDate`, `Units`.
- Powiazania: N:1 do `ShareClass`, N:1 do `Investor`.

### Valuation (Wycena)
- Identyfikator: `ValuationId`
- Definicja: wycena klasy jednostek na dany dzien, zawierajaca laczny NAV i NAV na jednostke.
- Kluczowe atrybuty: `ShareClassId`, `ValuationDate`, `NetAssetValue`, `NavPerUnit`.
- Powiazania: N:1 do `ShareClass`.
- Uwagi: para (`ShareClassId`, `ValuationDate`) jest unikalna.

### FeeAccrual (Naliczenie oplat)
- Identyfikator: `FeeAccrualId`
- Definicja: naliczenie oplaty dla klasy jednostek na dany dzien.
- Kluczowe atrybuty: `ShareClassId`, `AccrualDate`, `FeeType`, `Amount`.
- Powiazania: N:1 do `ShareClass`.
- Status w MVP: poza zakresem kalkulacji i endpointu (read-only, bez liczenia oplat).

## Pojecia wyliczane

### Units Outstanding (Jednostki w obrocie)
- Definicja: liczba jednostek pozostajacych w obrocie dla danej klasy jednostek na date `D`.
- Formula:
  `units_outstanding(ShareClassId, D) = SUM(Subscription.Units do D) - SUM(Redemption.Units do D)`
- Zakres dat: sumowanie transakcji z `TradeDate <= D`.

### NetAssetValue (NAV)
- Definicja: laczna wartosc aktywow netto klasy jednostek na date wyceny.
- Zrodlo: `Valuation.NetAssetValue` dla pary (`ShareClassId`, `ValuationDate`).

### NavPerUnit (NAV na jednostke)
- Definicja: wartosc jednej jednostki uczestnictwa klasy na date wyceny.
- Formula:
  `NavPerUnit = NetAssetValue / units_outstanding`
- Zrodlo danych: wartosc moze byc pobrana z `Valuation.NavPerUnit`, ale semantycznie musi byc zgodna z formula domenowa.

### ValuationDate (Data wyceny)
- Definicja: data biznesowa, dla ktorej pobieramy wycene klasy jednostek i ceny instrumentow.
- Uzycie: parametr wejsciowy MVP obok identyfikatora funduszu.

### Market Value (Wartosc pozycji)
- Definicja: wartosc rynkowa pojedynczej pozycji funduszu na date `D`.
- Formula:
  `market_value = Holding.Quantity * PriceEOD.ClosePrice`
  (dla zgodnych `InstrumentId` i daty wyceny).

### Top 5 Holdings (5 najwiekszych pozycji)
- Definicja: piec pozycji funduszu o najwyzszej wartosci rynkowej na dana date.
- Kryterium sortowania: malejaco po `market_value`.

## Pojecia jednostek i stawek

### Currency
- Definicja: waluta klasy jednostek lub instrumentu, kod ISO 4217 (np. EUR).
- W MVP: prezentujemy walute klasy jednostek bez przeliczen FX.

### Bps (Basis Points, punkty bazowe)
- Definicja: jednostka opisu stawek procentowych.
- Przeliczenie: `100 bps = 1%`.
- Pola: `ManagementFeeBps`, `PerformanceFeeBps`, `HurdleRateBps`.

## Ważne rozroznienie poziomow

- Poziom klasy jednostek (`ShareClass`): `Subscription`, `Redemption`, `Valuation`, `NetAssetValue`, `NavPerUnit`, `units_outstanding`.
- Poziom funduszu (`Fund`): `Holding` i ranking top 5 pozycji.

To rozroznienie jest krytyczne dla poprawnosci odpowiedzi MVP.
