# Lab 1 — Orientacja, setup i kontrakt z agentem (`AGENTS.md`)

**Stacja 1 z 3 · czas: ~45 min**

> 🎯 **Twoje zadanie:** wybierz stack (z wersjami), utwórz minimalny szkielet repo
> i napisz `AGENTS.md` wg podanego szkieletu. Co dokładnie oddajesz — patrz checklista
> **„Definicja ukończenia"** na dole tego labu.

> Cel: zrozumieć zadanie, **wybrać stack**, ustalić konwencje i napisać `AGENTS.md` —
> dokument, który mówi agentowi AI, jak ma z Tobą pracować w tym repo.

---

## Zanim zaczniesz

1. Przeczytaj [../docs/brief.md](../docs/brief.md) — to **źródło prawdy** o celu produktu.
2. Połącz się z bazą funduszy wg [../db/README.md](../db/README.md) i obejrzyj dane.
   Wykonaj kilka `SELECT`, żeby poczuć strukturę (`Fund`, `ShareClass`, `Valuation`, `Holding`).
3. Otwórz [../db/samples/expected-nav.json](../db/samples/expected-nav.json) — tak ma wyglądać wynik MVP.

---

## Krok 1 — Wybór stacku

Brief **nie narzuca** technologii. Wybierz świadomie. Twój stack musi:

- połączyć się z **SQL Server** (sterownik / ORM),
- wystawić **prosty odczyt** (HTTP API i/lub UI),
- dać się **przetestować** (framework testowy).

Rozsądne opcje (wybierz jedną):

| Stack                       | Sterownik SQL Server | Dlaczego                            |
|-----------------------------|----------------------|-------------------------------------|
| **TypeScript / Node.js**    | `mssql` (tedious)    | Szybki start, jeden język FE+BE     |
| **C# / .NET**               | `Microsoft.Data.SqlClient` | Naturalny dla SQL Server      |
| **Python / FastAPI**        | `pyodbc` / `pymssql` | Czytelny, dobry do prototypów       |

> Zapisz wybór — za chwilę trafi do `AGENTS.md`. **Podaj konkretne wersje** (np. Node 20, TypeScript 5.x).

## Krok 2 — Konwencje

Ustal i zanotuj krótkie konwencje, np.:
- struktura katalogów (`src/`, `test/`, `web/`),
- nazewnictwo (identyfikatory w kodzie **po angielsku**; komentarze możesz pisać po polsku),
- styl (formatter/linter), sposób uruchamiania, sposób testowania,
- jak trzymasz parametry połączenia (**zmienne środowiskowe**, plik `.env` poza repo).

## Krok 3 — Szkielet repo

Z pomocą agenta utwórz **minimalny szkielet** wybranego stacku (manifesty zależności,
konfiguracja, pusty `src/`, pusty `test/`, `.env.example` **bez** prawdziwych sekretów).
Jeszcze **bez logiki** — to przyjdzie w labie 3.

## Krok 4 — Napisz `AGENTS.md`

`AGENTS.md` w korzeniu repo to kontrakt: stały kontekst, który agent czyta przy każdym zadaniu.
Napisz go **wg poniższych sekcji** (to obowiązkowy szkielet warsztatu):

```markdown
# AGENTS.md

## Projekt
Krótko: co budujemy i dla kogo (1–3 zdania, odsyłka do docs/brief.md).

## Stack (z wersjami)
Język, runtime, framework API, sterownik SQL Server, framework testowy — z numerami wersji.

## Setup
Jak zainstalować zależności, skąd brać parametry połączenia (zmienne środowiskowe),
jak uruchomić aplikację i testy. Wskaż db/README.md.

## Konwencje
Struktura katalogów, nazewnictwo (ID po angielsku), styl, format commitów.

## Bezpieczeństwo
- Zapytania do bazy WYŁĄCZNIE parametryzowane (nigdy konkatenacja stringów).
- Zero sekretów w kodzie i w repo — tylko zmienne środowiskowe / .env (gitignore).
- Najmniejsze uprawnienia: łączymy się kontem tylko do odczytu (workshop_reader).
- Walidacja wejścia (format daty, znany identyfikator funduszu).

## Zapytaj najpierw
Sytuacje, w których agent ma SIĘ ZATRZYMAĆ i zapytać, zamiast zgadywać:
- zmiana zakresu poza MVP z briefu,
- dodanie nowej zależności / zmiana stacku,
- cokolwiek, co zapisuje do bazy lub dotyka sekretów,
- niejednoznaczna reguła domenowa.

## Wiedza domenowa (odnośniki)
Odnośniki do artefaktów domeny (powstaną w labie 2):
- docs/glossary.md
- docs/domain-model.md
oraz do docs/brief.md i db/README.md.
```

> Wskazówka: poproś agenta o **szkic** `AGENTS.md` na podstawie briefu i Twoich decyzji,
> a potem **przejrzyj i popraw** każdą sekcję. To Ty jesteś właścicielem tego dokumentu.

---

## Definicja ukończenia (lab 1)

- [ ] Wybrany stack z konkretnymi wersjami.
- [ ] Minimalny szkielet repo (kompiluje się / uruchamia „hello").
- [ ] `.env.example` bez prawdziwych sekretów; `.env` w `.gitignore`.
- [ ] `AGENTS.md` z **wszystkimi** sekcjami szkieletu, przejrzany przez Ciebie.

---

## W Twoim narzędziu

To samo zadanie w różnych asystentach — użyj tego, którym pracujesz:

### GitHub Copilot
- Umieść `AGENTS.md` w korzeniu repo. Dodatkowo utwórz
  `.github/copilot-instructions.md` z **krótkim** wskazaniem: „Stosuj się do `AGENTS.md`"
  plus najważniejsze zasady bezpieczeństwa (parametryzacja, zero sekretów).
- Pracuj w **trybie Plan** (Copilot Chat → tryb planowania) przy projektowaniu, a w **trybie Agent**
  przy zmianach w plikach. Jeśli używasz **Spec Kit**, tu zaczyna się jego konfiguracja.

### Factory.ai
- Trzymaj `AGENTS.md` jako główny plik kontekstu — Factory czyta go jako reguły projektu.
- Skonfiguruj sesję tak, by korzystała z `AGENTS.md`; **Spec Mode** wykorzystasz w pełni w labie 3.

### Augment Code
- Dodaj reguły do katalogu `.augment` (reguły projektu), odzwierciedlając sekcje `AGENTS.md`,
  zwłaszcza **Bezpieczeństwo** i **Zapytaj najpierw**.
- Użyj **Intent**, by opisać cel; trzymaj reguły zwięzłe i wskazuj artefakty domeny.

> We wszystkich narzędziach zasada jest ta sama: **jeden kontrakt (`AGENTS.md`), Ty akceptujesz każdą zmianę.**
