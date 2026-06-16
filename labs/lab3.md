# Lab 3 — Kontrolowana budowa end-to-end (spec-driven)

**Stacja 3 z 3 · czas: ~60 min**

> 🎯 **Twoje zadanie:** w pętli spec → plan → zadania → implementacja dowieź **działający
> endpoint odczytu NAV** + **przechodzący test e2e** (zgodny z `expected-nav.json`) i przejdź
> przegląd bezpieczeństwa. Co dokładnie oddajesz — patrz checklista **„Definicja ukończenia"** na dole.

> Cel: zbudować **działający przepływ MVP** w pętli sterowanej specyfikacją:
> **Spec → Plan → Zadania → Implementacja** w trybie **Plan→Agent z akceptacją**.
> Efekt: szkielet + **jeden działający endpoint odczytu NAV** + **test e2e** + przegląd bezpieczeństwa.

To najważniejsza stacja. Tempo nadaje agent, ale **bramki akceptacji są Twoje**.

---

## Zasada pracy: spec-driven

Nie zaczynaj od kodu. Zaczynasz od **krótkiej specyfikacji**, potem **plan**, potem **zadania**,
i dopiero wtedy **implementacja** — każdy etap akceptujesz, zanim agent przejdzie dalej.

### Krok 1 — Napisz `spec.md` (co i dlaczego)

Krótki dokument (`docs/spec.md` lub `spec.md`). Powinien zawierać:

- **Cel:** jedno zdanie z briefu (podaj fundusz i datę → `NavPerUnit` + 5 największych pozycji).
- **Wejście / Wyjście:** kontrakt endpointu, np.
  `GET /funds/{fundId}/nav?date=YYYY-MM-DD&shareClass={shareClassId}` →
  JSON jak w [../db/samples/expected-nav.json](../db/samples/expected-nav.json).
- **Reguły domenowe:** odniesienie do `docs/domain-model.md` (jednostki w obrocie, `NavPerUnit`, wartość pozycji).
- **Przypadki brzegowe:** nieznany fundusz, brak wyceny na datę, zła data → **kontrolowany komunikat**, nie 500.
- **Bezpieczeństwo:** zapytania parametryzowane, zero sekretów, konto tylko do odczytu, walidacja wejścia.
- **Kryterium akceptacji:** test e2e zwraca wynik zgodny z `expected-nav.json`.

> Trzymaj `spec.md` krótkim (1 strona). Spec to kontrakt, nie dokumentacja.

### Krok 2 — Plan (tryb Plan, BEZ pisania kodu)

Poproś agenta o **plan** realizacji specyfikacji: jakie pliki powstaną, jaka kolejność,
jakie zapytania SQL (parametryzowane!), gdzie walidacja, jak test e2e zweryfikuje wynik.
**Przejrzyj plan. Popraw. Zaakceptuj.** Dopiero potem dalej.

### Krok 3 — Zadania

Rozbij plan na **małe zadania** (np. 5–8), każde z jasnym „done". Sugerowana kolejność:

1. Warstwa dostępu do danych: połączenie z bazą ze zmiennych środowiskowych (zero sekretów).
2. Zapytanie: jednostki w obrocie dla klasy na datę (parametryzowane).
3. Zapytanie: odczyt `NetAssetValue` / `NavPerUnit` z `Valuation` (parametryzowane).
4. Zapytanie: 5 największych pozycji funduszu na datę (parametryzowane, `ORDER BY` malejąco, `TOP 5`).
5. Endpoint składający wynik + walidacja wejścia + kontrolowane błędy.
6. Test e2e głównego przepływu względem `expected-nav.json`.
7. (opcjonalnie) drobny frontend: formularz fundusz + data → wynik.

### Krok 4 — Implementacja w trybie Agent (z akceptacją)

Realizuj zadania **po jednym**, w trybie Agent. Po każdym:
- przejrzyj diff,
- uruchom kompilację/test,
- **zaakceptuj lub odrzuć** — nie pozwól agentowi „lecieć" przez wiele zadań bez przeglądu.

**Minimum do zaliczenia:** szkielet + **endpoint odczytu NAV** zwracający `NavPerUnit`
i 5 największych pozycji, oraz **przechodzący test e2e**.

### Krok 5 — Test e2e

Test musi:
- wywołać przepływ dla `FUND-A` / `FUND-A-ACC` / `2025-02-10`,
- sprawdzić `navPerUnit == 103.12`, `unitsOutstanding == 175000`,
- sprawdzić, że `topHoldings` ma 5 pozycji, posortowanych malejąco, z `INSTR-003` na szczycie.

(Wartości pochodzą z [../db/samples/expected-nav.json](../db/samples/expected-nav.json).)

---

## Krok 6 — Przegląd bezpieczeństwa (obowiązkowy)

Przejdź listę i **popraw, co trzeba**:

- [ ] **Parametryzacja:** każde zapytanie używa parametrów, **zero** konkatenacji wejścia do SQL.
- [ ] **Walidacja wejścia:** `fundId`/`shareClassId` dopasowane do oczekiwanego formatu; `date` to poprawna data.
- [ ] **Zero sekretów:** brak haseł/connection stringów w kodzie i w repo; tylko zmienne środowiskowe; `.env` w `.gitignore`.
- [ ] **Najmniejsze uprawnienia:** łączysz się kontem `workshop_reader` (tylko `SELECT`).
- [ ] **Kontrolowane błędy:** brak danych → czytelny komunikat, nie ślad stosu / 500.

> Poproś agenta o **samodzielny przegląd** kodu pod te punkty, a potem zweryfikuj sam(a).

---

## Definicja ukończenia (lab 3)

- [ ] `spec.md` (co i dlaczego) zaakceptowany przed kodem.
- [ ] Plan i zadania przeglądnięte i zatwierdzone.
- [ ] Szkielet + endpoint odczytu NAV działa na realnych danych z bazy.
- [ ] Test e2e przechodzi i odpowiada `expected-nav.json`.
- [ ] Lista bezpieczeństwa odhaczona.

---

## W Twoim narzędziu

### GitHub Copilot
- **Spec Kit:** użyj komend `/specify` → `/plan` → `/tasks` → `/implement`, by sformalizować
  pętlę spec-driven. Trzymaj `spec.md` jako wejście.
- Bez Spec Kit: pracuj w **trybie Plan** (krok 2), zatwierdź plan, potem przełącz na **tryb Agent**
  (krok 4) i realizuj zadania pojedynczo, przeglądając każdy diff.
- `AGENTS.md` + `.github/copilot-instructions.md` pilnują zasad bezpieczeństwa w tle.

### Factory.ai
- Użyj **Spec Mode**: opisz `spec.md`, pozwól wygenerować plan i zadania, akceptuj etapami.
- Trzymaj `AGENTS.md` jako reguły; wymuszaj bramki akceptacji przed scaleniem zmian.

### Augment Code
- Zacznij od **Intent** opartego o `spec.md`; pozwól zaproponować plan, zatwierdź, potem implementuj.
- Reguły `.augment` (z labu 1) wymuszają parametryzację i zero sekretów na każdym kroku.

> Wspólny mianownik: **najpierw spec, potem plan, na końcu kod — a Ty trzymasz bramki akceptacji.**
