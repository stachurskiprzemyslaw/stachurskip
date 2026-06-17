---
name: fund-nav-workflow
description: 'Buduj i dopracowuj workflow MVP fund NAV. Uzyj, gdy implementujesz lub recenzujesz read-only endpoint dla NavPerUnit, units outstanding, top 5 holdings, zapytania SQL, planowanie spec-driven albo artefakty warsztatowe w tym repozytorium.'
argument-hint: 'Opisz zadanie MVP, artefakt albo zmiane endpointu, ktora chcesz wykonac.'
user-invocable: true
---

# Workflow Fund NAV

Uzyj tego skilla podczas pracy nad warsztatowym MVP: podglad NAV funduszu i top holdings.

## Kiedy Uzywac
- Implementacja lub dopracowanie przeplywu `GET /funds/{fundId}/nav`
- Pisanie albo review SQL dla `Valuation`, `Subscription`, `Redemption`, `Holding`, `PriceEOD`
- Weryfikacja, czy zmiana nadal zgadza sie z briefem i modelem domenowym
- Tworzenie lub aktualizacja artefaktow warsztatowych (`spec.md`, testy, modele odpowiedzi API)

## Wymagane Referencje
- [brief](../../../docs/brief.md)
- [glossary](../../../docs/glossary.md)
- [domain model](../../../docs/domain-model.md)
- [sample expected result](../../../db/samples/expected-nav.json)
- [database README](../../../db/README.md)

## Procedura
1. Potwierdz, ze zadanie miesci sie w zakresie MVP z `docs/brief.md`.
2. Okresl, czy zadanie dotyczy sciezki `ShareClass` (`Valuation`, `Subscription`, `Redemption`) czy sciezki `Fund` (`Holding`, `PriceEOD`).
3. Przed zmiana kodu zapisz ponownie regule biznesowa:
   - `units_outstanding = subscriptions - redemptions`
   - `NavPerUnit = NetAssetValue / units_outstanding`
   - `top holdings = top 5 by market_value`
4. Preferuj parametryzowany SQL i jawna liste kolumn.
5. Przy zmianach API utrzymuj odpowiedz zgodna z `db/samples/expected-nav.json`.
6. Po edycjach uruchom najpierw waska walidacje:
   - test endpointu
   - waski `pytest`
   - dopiero potem szersze sprawdzenia

## Guardrails
- Traktuj narzedzie jako read-only wobec bazy danych.
- Nie wprowadzaj sekretow do kodu, testow, dokumentacji ani przykladow.
- Nie rozszerzaj zakresu o fees, FX, auth, exporty ani operacje zapisu, chyba ze prosba jest jawna.
- Jesli granica reguly miedzy `Fund` a `ShareClass` staje sie niejednoznaczna, zatrzymaj sie i zapytaj.
