# AGENTS.md

## Projekt
Budujemy lekkie narzedzie wewnetrzne read-only dla operacji funduszowych.
MVP: po podaniu funduszu i daty zwracamy NavPerUnit oraz 5 najwiekszych pozycji funduszu.
Zrodlo celu i zakresu: docs/brief.md.

## Stack (z wersjami)
- Python 3.11+
- API: FastAPI 0.115+
- ASGI server: Uvicorn 0.30+
- SQL Server driver: pyodbc 5.1+
- Testy: pytest 8+
- Testy e2e HTTP: httpx 0.27+
- Walidacja danych: Pydantic 2+
- Lint/format: ruff 0.6+

## Setup
- Zaleznosci: zainstaluj pakiety z requirements.txt (lub pyproject.toml, jesli zostanie wybrany ten wariant).
- Konfiguracja: wszystkie dane polaczenia do SQL Server trzymamy w zmiennych srodowiskowych.
- Lokalny plik .env moze byc uzywany tylko lokalnie i musi byc w .gitignore.
- Uruchomienie aplikacji: przez Uvicorn (entrypoint aplikacji w src/).
- Uruchomienie testow: pytest.
- Instrukcje bazy i parametry polaczenia: db/README.md.

## Konwencje
- Struktura katalogow:
	- src/ - kod aplikacji
	- tests/ - testy jednostkowe i integracyjne/e2e
	- docs/ - artefakty domenowe i dokumentacja
- Nazewnictwo:
	- identyfikatory techniczne, nazwy klas/funkcji i pola API po angielsku
	- komentarze i opisowe teksty moga byc po polsku
- SQL:
	- czytelne aliasy tabel i jawne nazwy kolumn (bez SELECT *)
	- daty przekazywane jako parametry, nie jako konkatenacja stringow
- Styl i jakosc:
	- formatowanie i lintowanie przez ruff
	- kod ma byc prosty, bez przedwczesnej abstrakcji
- Commity:
	- krotkie, opisowe, w trybie rozkazujacym
	- preferowane prefixy: feat:, fix:, docs:, test:, refactor:

## Bezpieczenstwo
- Zapytania do bazy wylacznie parametryzowane (nigdy konkatenacja SQL).
- Zero sekretow w kodzie i repo.
- Sekrety tylko przez zmienne srodowiskowe/.env lokalnie (plik .env ignorowany przez git).
- Najmniejsze uprawnienia: laczymy sie kontem read-only (workshop_reader).
- Walidacja wejscia: poprawny format daty i dozwolony identyfikator funduszu.
- Bledy API nie moga ujawniac szczegolow polaczenia, hasel ani surowych stack trace.

## Zapytaj najpierw
Agent ma sie zatrzymac i zapytac zamiast zgadywac, gdy:
- zmiana wykracza poza MVP opisane w docs/brief.md
- trzeba dodac nowa zaleznosc lub zmienic stack
- zmiana obejmuje zapis do bazy, migracje albo DDL/DML
- zadanie dotyczy sekretow, danych produkcyjnych lub uprawnien
- regula domenowa jest niejednoznaczna
- brakuje danych wejsciowych do podjecia bezpiecznej decyzji

## Wiedza domenowa (odnosniki)
- docs/brief.md
- db/README.md
- db/schema.sql
- db/samples/expected-nav.json
- docs/glossary.md
- docs/domain-model.md