# Brief produktowy — Podgląd NAV i pozycji funduszu

> Ten dokument opisuje **CO** budujemy i **dla kogo** — celowo **nie** rozstrzyga
> o stacku technologicznym ani o szczegółach implementacji. Te decyzje podejmiesz
> w laboratoriach. Trzymaj ten brief jako „źródło prawdy" o celu produktu.

---

## 1. Kontekst

W firmie zarządzającej funduszami zespół **operacji / middle-office** codziennie
odpowiada na to samo pytanie: *„jaka była wartość jednostki danego funduszu na dany dzień
i co siedzi w portfelu?"*. Dziś odpowiedź wymaga ręcznego grzebania w bazie i arkuszach —
wolno, podatnie na błędy, trudno powtarzalnie.

Dane już istnieją w bazie funduszy (`baseFunds`): wyceny, ceny instrumentów, pozycje,
subskrypcje i umorzenia. Brakuje **prostego, zaufanego widoku**, który składa to w jedną odpowiedź.

---

## 2. Dla kogo (persona)

**Ola — analityk operacji funduszowych.**
- Zna domenę funduszy, ale nie pisze zapytań SQL na co dzień.
- Potrzebuje **szybkiej, jednoznacznej** odpowiedzi na konkretny dzień wyceny.
- Pracuje pod presją czasu (zamknięcie dnia, zapytania od klientów i audytu).
- Ceni sobie **wynik, któremu można zaufać** i który da się szybko zweryfikować.

---

## 3. Problem

> Ola nie ma jednego miejsca, w którym po podaniu **funduszu** i **daty** zobaczy
> **wartość jednostki (`NavPerUnit`)** oraz **największe pozycje** w portfelu na ten dzień.

Skutki: ręczne, niepowtarzalne wyliczenia; ryzyko pomyłki; czas tracony na każde zapytanie.

---

## 4. Co budujemy (zakres MVP)

Lekkie narzędzie wewnętrzne — **tylko do odczytu** — które realizuje jeden przepływ:

> **Podaj fundusz i datę → pokaż `NavPerUnit` oraz 5 największych pozycji funduszu na ten dzień.**

Minimalny zakres:

1. **Wejście:** identyfikator funduszu (np. `FUND-A`) oraz data wyceny (`ValuationDate`).
2. **Wyjście:**
   - `NavPerUnit` dla wskazanej klasy jednostek funduszu na podaną datę,
   - **5 największych pozycji** (holdings) wg wartości rynkowej na ten dzień,
   - kontekst: nazwa/identyfikator funduszu, data, waluta.
3. **Sposób dostępu:** prosty widok (UI lub odpowiedź API) — *jak* go zrealizujesz, decydujesz w laboratorium.

### Reguła domenowa (kanon)

Te reguły są **wiążące** — Twoja implementacja musi je odtwarzać:

- **Jednostki w obrocie** (na datę `D`, dla danej klasy jednostek) =
  `Σ Subscription.Units − Σ Redemption.Units` do daty `D` włącznie.
- **`NavPerUnit`** = `NetAssetValue / jednostki w obrocie`
  (gdzie `NetAssetValue` pochodzi z encji `Valuation` dla danej klasy i daty).

Pełne nazwy encji i atrybutów wyprowadzisz z bazy i opiszesz w laboratorium 2.

---

## 5. Poza zakresem (świadomie)

Aby MVP był osiągalny w czasie warsztatu, **NIE** robimy:

- naliczania i prognozy opłat (`FeeAccrual`, performance fee, hurdle) — dane są w bazie, ale ich nie liczymy,
- zapisu/modyfikacji danych (narzędzie jest **read-only**),
- uwierzytelniania użytkowników, ról, wielojęzyczności,
- historii zmian, eksportów, raportów PDF,
- obsługi wielu walut z przeliczeniami kursowymi (pokazujemy walutę klasy jednostek „as is").

---

## 6. Kryteria sukcesu

MVP uznajemy za gotowe, gdy:

1. Dla istniejącego funduszu i daty narzędzie zwraca **poprawny `NavPerUnit`**,
   zgodny z regułą domenową (zweryfikowany względem [../db/samples/expected-nav.json](../db/samples/expected-nav.json)).
2. Narzędzie zwraca **5 największych pozycji** wg wartości na ten dzień, malejąco.
3. Dla **nieistniejącego** funduszu lub daty bez wyceny narzędzie zwraca **czytelny, kontrolowany komunikat** (nie błąd serwera).
4. Istnieje **co najmniej jeden przechodzący test e2e** pokrywający główny przepływ.
5. Przegląd bezpieczeństwa przechodzi: **zapytania parametryzowane**, **zero sekretów w kodzie**, dostęp do bazy na **najmniejszych uprawnieniach** (tylko odczyt).

---

## 7. Sygnały jakości (miłe, nieobowiązkowe)

- Walidacja wejścia (format daty, znany identyfikator funduszu).
- Czytelny komunikat, gdy na dany dzień nie ma wyceny.
- Krótki `README` aplikacji: jak uruchomić i jak odpytać.

---

*Ten brief jest stabilny. Jeśli w trakcie pracy z agentem pojawi się pokusa rozszerzenia
zakresu — wróć tutaj i sprawdź, czy to nadal MVP.*
