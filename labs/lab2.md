# Lab 2 — Wiedza domenowa: słownik i model domeny

**Stacja 2 z 3 · czas: ~40 min**

> 🎯 **Twoje zadanie:** utwórz `docs/glossary.md` i `docs/domain-model.md` (z regułami
> NAV i jednostek), zweryfikuj je na danych i podepnij w `AGENTS.md`. Co dokładnie oddajesz —
> patrz checklista **„Definicja ukończenia"** na dole tego labu.

> Cel: zamienić brief i bazę w **artefakty wiedzy domenowej** — `docs/glossary.md`
> i `docs/domain-model.md` — do których agent będzie się odwoływać podczas budowy.
> Bez tego agent „zgaduje" domenę; z tym — działa na Twoich definicjach.

---

## Dlaczego to robimy

Domena funduszy ma słowa, które brzmią znajomo, ale mają precyzyjne znaczenie
(„wycena", „jednostki w obrocie", „NAV na jednostkę"). Jeśli zapiszesz je raz, jasno,
to:
- agent generuje kod zgodny z domeną, a nie z domysłami,
- Ty i recenzent macie wspólny język,
- reguła `NavPerUnit` jest jednoznaczna i testowalna.

---

## Krok 1 — Słownik (`docs/glossary.md`)

Dla **każdej** encji kanonu i kluczowych pojęć podaj: nazwę (PL + identyfikator EN),
definicję jednym zdaniem oraz powiązania. Encje kanonu (użyj **dokładnie** tych nazw):

`Fund`, `ShareClass`, `Investor`, `Instrument`, `PriceEOD`, `Holding`,
`Subscription`, `Redemption`, `Valuation` (NAV), `FeeAccrual`.

Uwzględnij też pojęcia wyliczane:
- **jednostki w obrocie** (units outstanding),
- **NAV** (`NetAssetValue`) vs **NAV na jednostkę** (`NavPerUnit`),
- **wycena** (`Valuation` / `ValuationDate`),
- atrybuty opłat: `ManagementFeeBps`, `PerformanceFeeBps`, `HurdleRateBps`, `Currency`
  (punkty bazowe = bps; 100 bps = 1%).

> Wskazówka: poproś agenta, by **wygenerował szkic słownika z `db/schema.sql` i briefu**,
> a następnie zweryfikuj każdą definicję względem danych (zrób `SELECT`-y).

## Krok 2 — Model domeny (`docs/domain-model.md`)

Opisz związki między encjami i — co najważniejsze — **reguły wyliczeń**:

1. **Jednostki w obrocie** dla klasy jednostek na datę `D`:
   ```
   units_outstanding(class, D) = Σ Subscription.Units(class, ≤ D) − Σ Redemption.Units(class, ≤ D)
   ```
2. **NAV na jednostkę**:
   ```
   NavPerUnit = NetAssetValue / units_outstanding
   ```
   gdzie `NetAssetValue` pochodzi z `Valuation` dla danej `ShareClassId` i `ValuationDate`.
3. **Wartość pozycji (do „5 największych")**:
   ```
   market_value(holding, D) = Holding.Quantity × PriceEOD.ClosePrice(InstrumentId, D)
   ```
   „5 największych pozycji" = top 5 wg `market_value` malejąco dla funduszu na datę `D`.

Dodaj prosty diagram związków (może być tekstowy/Mermaid) i zaznacz:
- `Fund` 1—N `ShareClass`; `ShareClass` 1—N `Valuation`/`Subscription`/`Redemption`,
- `Fund` 1—N `Holding`; `Holding` N—1 `Instrument`; `Instrument` 1—N `PriceEOD`.

> Zwróć uwagę: NAV i pozycje wiszą na **różnych poziomach** — NAV/jednostki na poziomie
> **klasy jednostek** (`ShareClass`), a pozycje na poziomie **funduszu** (`Fund`).
> To częsta pułapka — opisz ją jawnie w modelu.

## Krok 3 — Zapis jako artefakty + podpięcie do `AGENTS.md`

- Zapisz oba pliki w `docs/`.
- Upewnij się, że sekcja **Wiedza domenowa (odnośniki)** w `AGENTS.md` wskazuje
  `docs/glossary.md` i `docs/domain-model.md`.

---

## Definicja ukończenia (lab 2)

- [ ] `docs/glossary.md` pokrywa wszystkie 10 encji + pojęcia wyliczane.
- [ ] `docs/domain-model.md` zawiera 3 reguły wyliczeń i związki encji.
- [ ] Rozróżnienie poziomów (klasa vs fundusz) opisane jawnie.
- [ ] `AGENTS.md` odsyła do obu artefaktów.
- [ ] Definicje **zweryfikowane** względem danych (`SELECT`-y), nie tylko wygenerowane.

---

## W Twoim narzędziu

### GitHub Copilot
- Poproś Copilota (tryb Chat/Agent) o szkic słownika i modelu z `db/schema.sql` + briefu.
  Trzymaj pliki w `docs/`. Dopisz je do `.github/copilot-instructions.md` jako materiały referencyjne.
- W trybie **Plan** poproś o weryfikację: „które definicje wymagają potwierdzenia w danych?".

### Factory.ai
- Wygeneruj artefakty domeny i zapisz w repo; w **Spec Mode** (lab 3) będą wejściem do specyfikacji.
- Wskaż `AGENTS.md` → sekcję Wiedza domenowa, by Factory traktował je jako kontekst.

### Augment Code
- Dodaj odnośniki do `docs/glossary.md` i `docs/domain-model.md` w regułach `.augment`.
- Użyj **Intent** „zbuduj słownik domeny z schematu i briefu", potem zrecenzuj ręcznie.

> Artefakt > rozmowa. Wiedza w pliku w repo jest trwała i wersjonowana; wiedza w czacie znika.
