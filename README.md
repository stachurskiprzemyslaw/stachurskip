# Warsztat: Podgląd NAV i pozycji funduszu (tor *greenfield*)

Witaj w torze **greenfield** warsztatu z budowania oprogramowania z agentem AI
(GitHub Copilot i pokrewne). W ciągu warsztatu zbudujesz **od zera** lekkie
narzędzie wewnętrzne nad bazą funduszy: **Podgląd NAV i pozycji funduszu**.

> To repozytorium jest **celowo niekompletne**. Nie znajdziesz tu wybranego
> stacku, pliku `AGENTS.md`, słownika domeny ani żadnej implementacji.
> **To są właśnie produkty, które stworzysz w trakcie laboratoriów** —
> z pomocą agenta AI, świadomie i pod kontrolą.

---

## 🚀 Zacznij tutaj

1. **Uruchom środowisko.** Najprościej: **Code → Codespaces → Create codespace** —
   baza funduszy wstanie sama (patrz [.devcontainer/README.md](.devcontainer/README.md)).
   Alternatywnie pracuj lokalnie wg [listy pre-flight](docs/setup-checklist.md).
2. **Zrozum cel.** Przeczytaj [docs/brief.md](docs/brief.md) (~10 min) — *co* budujesz i dla kogo.
3. **Rób laby po kolei:** [lab1](labs/lab1.md) → [lab2](labs/lab2.md) → [lab3](labs/lab3.md).
   Każdy lab to Twoje **zadanie**: ma kroki do wykonania i na dole checklistę
   **„Definicja ukończenia"** — to ona mówi, co masz oddać.

| Lab | Czas | Twoje zadanie (co oddajesz) |
|-----|------|------------------------------|
| [Lab 1](labs/lab1.md) | ~45 min | Wybór stacku + szkielet repo + `AGENTS.md` |
| [Lab 2](labs/lab2.md) | ~40 min | `docs/glossary.md` + `docs/domain-model.md` (reguły NAV) |
| [Lab 3](labs/lab3.md) | ~60 min | Działający endpoint odczytu NAV + przechodzący test e2e |

---

## Cel toru

Nauczyć się **kontrolowanej, sterowanej specyfikacją (spec-driven) pracy z agentem AI**
na realistycznym, ale bezpiecznym przykładzie domeny funduszy inwestycyjnych.
Po warsztacie będziesz umieć:

- skonfigurować repozytorium pod pracę z agentem (`AGENTS.md`, konwencje, zasady bezpieczeństwa),
- przełożyć wiedzę domenową na **artefakty w repo** (słownik, model domeny),
- prowadzić agenta w pętli **Spec → Plan → Zadania → Implementacja** z punktami akceptacji,
- dowieźć **działający przepływ end-to-end** z jednym przechodzącym testem,
- robić to **bezpiecznie**: parametryzacja zapytań, zero sekretów w kodzie, najmniejsze uprawnienia.

**Cel produktowy (MVP):** *podaj fundusz i datę → zobacz `NavPerUnit` oraz 5 największych pozycji funduszu.*
Szczegóły w [docs/brief.md](docs/brief.md).

---

## Trzy stacje

Warsztat prowadzi przez trzy stacje. Każda kończy się **artefaktami w repo**, nie tylko wiedzą w głowie.

### Stacja 1 — Orientacja i setup
Poznajesz brief produktowy i bazę funduszy. **Wybierasz stack**, ustalasz konwencje
i piszesz `AGENTS.md` — kontrakt współpracy z agentem.
→ [labs/lab1.md](labs/lab1.md)

### Stacja 2 — Wiedza domenowa
Zamieniasz brief i bazę w **słownik domeny** i **model domeny** (NAV, jednostki w obrocie, wycena).
Zapisujesz je jako artefakty, do których agent będzie się odwoływać.
→ [labs/lab2.md](labs/lab2.md)

### Stacja 3 — Kontrolowana budowa end-to-end
Pracą sterowaną specyfikacją budujesz szkielet aplikacji i **jeden działający endpoint**
(odczyt NAV), a następnie **test e2e**. Na koniec robisz przegląd bezpieczeństwa.
→ [labs/lab3.md](labs/lab3.md)

---

## Wymagania wstępne

- **Visual Studio Code** z rozszerzeniem **GitHub Copilot** (lub odpowiednikiem: Factory.ai, Augment Code).
- **Dostęp do bazy funduszy** uruchomionej w kontenerze (SQL Server).
  Instrukcja połączenia: [db/README.md](db/README.md).

> 💡 **Najprościej:** to repo ma gotowe środowisko (Dev Container / GitHub Codespaces) —
> baza funduszy wstaje sama, bez instalacji. Patrz [.devcontainer/README.md](.devcontainer/README.md).
- Klient SQL do podglądu danych (np. *Azure Data Studio*, wtyczka *SQL Server* do VS Code, lub `sqlcmd`).
- Środowisko uruchomieniowe wybranego przez Ciebie stacku (np. Node.js, .NET, Python) — instalujesz w laboratorium 1.

> Nie potrzebujesz wcześniejszej wiedzy o funduszach inwestycyjnych —
> wszystko, czego potrzebujesz, wyprowadzisz z briefu i danych w laboratorium 2.

**Przed warsztatem** przejdź [listę pre-flight](docs/setup-checklist.md) — zajmie ~20 minut
i sprawi, że zaczniemy od razu od pracy, a nie od instalacji.

---

## Struktura repozytorium

```
.
├── README.md            ← jesteś tutaj
├── docs/
│   └── brief.md         ← brief produktowy (CO budujemy i dla kogo)
├── db/
│   ├── README.md        ← jak połączyć się z bazą funduszy
│   ├── schema.sql       ← struktura bazy (kanon domeny)
│   ├── seed.sql         ← dane syntetyczne
│   └── samples/
│       └── expected-nav.json   ← przykładowy wynik MVP
└── labs/
    ├── lab1.md
    ├── lab2.md
    └── lab3.md
```

Pliki, które **wytworzysz** w trakcie warsztatu (np. `AGENTS.md`, `docs/glossary.md`,
`docs/domain-model.md`, kod aplikacji), pojawią się w repo dzięki Twojej pracy z agentem.

---

## Jak pracować

1. Przeczytaj [docs/brief.md](docs/brief.md) — zrozum, **co** budujesz.
2. Uruchom bazę i połącz się wg [db/README.md](db/README.md).
3. Przejdź laboratoria po kolei: [lab1](labs/lab1.md) → [lab2](labs/lab2.md) → [lab3](labs/lab3.md).
4. Po każdym laboratorium sprawdź sekcję **„W Twoim narzędziu"** — pokazuje, jak
   wykonać dane kroki w Copilocie, Factory.ai i Augment Code.

Powodzenia — i pamiętaj: **agent jest szybki, ale to Ty akceptujesz każdy krok.**
