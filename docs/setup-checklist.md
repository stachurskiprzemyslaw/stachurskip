# Lista pre-flight — przygotuj się przed warsztatem

> Wykonaj **przed** warsztatem (ok. 20–30 minut). Dzięki temu zaczniemy od razu od pracy,
> a nie od instalacji. Jeśli coś nie działa — napisz do prowadzącego **przed** spotkaniem.

> 🚀 **Wariant „pod klucz" (zalecany dla nietechnicznych):** jeśli prowadzący włączył
> **GitHub Codespaces**, możesz pominąć instalację bazy i środowiska. Wystarczy konto GitHub
> i przeglądarka — patrz [.devcontainer/README.md](../.devcontainer/README.md). Wtedy z poniższej
> listy zostają Ci tylko punkty **1** i **2** (narzędzia i lektura).

## 1. Narzędzia

- [ ] **Visual Studio Code** zainstalowany.
- [ ] **GitHub Copilot** (rozszerzenie) zainstalowane i **zalogowane** (lub odpowiednik:
      Factory.ai / Augment Code). Sprawdź, że podpowiedzi działają w dowolnym pliku.

## 2. Lektura (15 minut, bez kodu)

- [ ] Przeczytany [README.md](../README.md) — po co ten warsztat i jak wygląda.
- [ ] Przeczytany [docs/brief.md](brief.md) — **co** budujemy (podaj fundusz i datę →
      wartość jednostki + 5 największych pozycji).

> Nie musisz znać się na funduszach. Wszystko, co potrzebne, wyjaśnimy na miejscu.

## 3. Dostęp do bazy funduszy

- [ ] Mam parametry połączenia (patrz [db/README.md](../db/README.md)):
      host `localhost`, port `1433`, baza `baseFunds`, użytkownik `workshop_reader`.
- [ ] **Hasło** otrzymam od prowadzącego (na początku dnia — nie ma go w repo).
- [ ] Mam czym podejrzeć bazę: *Azure Data Studio*, wtyczka *SQL Server* do VS Code, lub `sqlcmd`.
- [ ] **Test połączenia się udaje** (gdy mam już hasło) — np.:
      ```bash
      sqlcmd -S localhost,1433 -d baseFunds -U workshop_reader -P "$DB_PASSWORD" \
        -Q "SELECT TOP 3 FundId, Name FROM dbo.Fund;"
      ```

> Jeśli prowadzący prosił, byś uruchomił(a) bazę lokalnie — zrób to wg [db/README.md](../db/README.md)
> (skrypty `db/schema.sql` i `db/seed.sql` są w repo).

## 4. Środowisko programistyczne (opcjonalnie przed startem)

Stack wybierzemy w Laboratorium 1. Jeśli wiesz, w czym chcesz pracować, zainstaluj wcześniej:

- [ ] **Node.js 20+** (jeśli TypeScript/JavaScript), albo
- [ ] **.NET SDK** (jeśli C#), albo
- [ ] **Python 3.11+** (jeśli Python).

Nie wiesz? Nic nie szkodzi — zdecydujemy wspólnie na warsztacie.

## 5. Gotowość

- [ ] Mam stabilny internet (asystent AI działa w chmurze).
- [ ] Mam ~3,5 godziny bez przerw na inne zadania.

---

**Gotowe?** Świetnie — do zobaczenia na warsztacie. W razie problemów z setupem odezwij się
do prowadzącego **wcześniej**, żebyśmy zaczęli punktualnie.
