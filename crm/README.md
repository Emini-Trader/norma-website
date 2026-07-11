# CRM Norma GS

Prosta aplikacja webowa do zarządzania kontaktami (firmy, kontakty, historia korespondencji),
zastępująca dotychczasowy arkusz Excel. Logowanie wymagane, każdy zalogowany użytkownik może
edytować wszystko, a każda zmiana zapisuje kto i kiedy jej dokonał.

Stack: czysty HTML/CSS/JS (bez buildu, jak reszta strony norma-gs.no) + [Supabase](https://supabase.com)
jako gotowa baza danych + logowanie. Nie piszemy własnego backendu ani zarządzania hasłami —
Supabase załatwia to za darmo w swoim darmowym planie.

## 1. Załóż projekt Supabase

1. Wejdź na [supabase.com](https://supabase.com) → **Start your project** → zaloguj się (np. przez GitHub).
2. **New project** → nazwa np. `norma-crm`, wybierz region (najbliższy Norwegii, np. Frankfurt/EU), ustaw hasło bazy (zapisz je gdzieś bezpiecznie, nie jest potrzebne w aplikacji).
3. Poczekaj ok. 2 minuty, aż projekt się utworzy.

## 2. Utwórz tabele i zabezpieczenia (RLS)

1. W panelu projektu wejdź w **SQL Editor** → **New query**.
2. Wklej całą zawartość pliku [`supabase/schema.sql`](supabase/schema.sql) i kliknij **Run**.
   Utworzy to tabele `contacts` i `contact_activities`, automatyczne pola „kto i kiedy edytował”
   oraz reguły dostępu (Row Level Security): **tylko zalogowani użytkownicy** mogą cokolwiek
   czytać/zapisywać, nikt anonimowy nie ma dostępu.
3. (Opcjonalnie, ale polecane) Aby od razu przenieść dotychczasowe 40 firm z Excela, wklej
   i uruchom też [`supabase/seed.sql`](supabase/seed.sql) — **po** wykonaniu `schema.sql`.

## 3. Wyłącz otwartą rejestrację i zaproś użytkowników

Dostęp ma być tylko na zaproszenie — nikt nie może sam się zarejestrować.

1. **Authentication → Providers → Email**: upewnij się, że *Email* jest włączony. Wyłącz
   „Allow new users to sign up” (Authentication → Settings → User Signups), jeśli tam widnieje —
   to blokuje samodzielną rejestrację przez API/formularz.
2. **Authentication → Users → Add user → Create new user** — dodaj e-mail i tymczasowe hasło
   dla każdej osoby, która ma mieć dostęp (siebie i współpracowników). Możesz zaznaczyć
   „Auto Confirm User”, żeby nie czekać na link potwierdzający.
3. Przekaż każdej osobie jej e-mail i hasło (poproś, żeby zmieniła hasło po pierwszym logowaniu —
   można to zrobić w tym samym panelu: **Users → wybierz użytkownika → Reset password**).

## 4. Podepnij frontend do Twojego projektu

1. W Supabase: **Project Settings → API**.
2. Skopiuj **Project URL** oraz klucz **anon public**.
3. Wklej je w pliku [`config.js`](config.js):

   ```js
   window.SUPABASE_URL = "https://xxxxxxxx.supabase.co";
   window.SUPABASE_ANON_KEY = "eyJ...";
   ```

   Klucz `anon` jest bezpieczny do trzymania w kodzie frontendu (jest publiczny z założenia) —
   realne zabezpieczenie danych zapewnia RLS ustawione w `schema.sql`, nie ten klucz.

## 5. Wdrożenie na crm.norma-gs.no

Cały folder `crm/` to statyczna strona — wystarczy ją wystawić przez Netlify, Vercel albo
Cloudflare Pages (darmowe plany).

**Netlify (przykład):**

1. Załóż konto na [netlify.com](https://netlify.com) i połącz je z tym repozytorium GitHub.
2. **Add new site → Import an existing project** → wybierz repo `norma-website`.
3. Ustaw **Base directory / Publish directory** na `crm` (bez kroku budowania — *Build command* zostaw puste).
4. Po wdrożeniu: **Site settings → Domain management → Add a custom domain** → wpisz
   `crm.norma-gs.no`.
5. Netlify pokaże rekord CNAME do dodania. U dostawcy DNS domeny `norma-gs.no` dodaj:

   ```
   Typ:   CNAME
   Nazwa: crm
   Wartość: <adres wskazany przez Netlify, np. twoja-nazwa.netlify.app>
   ```

6. Po propagacji DNS (zwykle kilka minut do godziny) strona będzie dostępna pod
   `https://crm.norma-gs.no` z automatycznym certyfikatem SSL.

Vercel i Cloudflare Pages działają analogicznie (wskaż katalog `crm` jako katalog publikowany,
dodaj subdomenę jako custom domain, dodaj wskazany rekord CNAME w DNS).

## Jak to działa na co dzień

- **Logowanie** — e-mail + hasło nadane przez administratora (patrz krok 3).
- **Lista firm** — szukaj po nazwie/kontakcie/e-mailu, filtruj po statusie (Ny / Kontaktet /
  Venter på svar / Kunde / Avslått).
- **Klik na wiersz** — otwiera szczegóły firmy do edycji oraz historię notatek (kto i kiedy
  dodał wpis — to jest odpowiednik dotychczasowej kolumny „Kommentarer”, ale jako pełna historia
  zamiast jednego pola).
- **+ Ny firma** — dodaje nową firmę do listy.
- Każda zmiana automatycznie zapisuje, kto i kiedy jej dokonał (widoczne w kolumnie „Sist endret”
  oraz przy każdym wpisie w historii) — ustawia to baza danych (trigger), więc nie da się tego
  sfałszować z poziomu przeglądarki.

## Kontaktpersoner (jedna firma, wiele osób)

Firma ma teraz osobną listę kontaktpersonów (tabela `contact_people`), a nie jedno pole tekstowe —
każda osoba ma własny telefon/e-mail/stanowisko i może być oznaczona jako „Hovedkontakt" (główny
kontakt, widoczny w tabeli firm). Jeśli osoba zmienia firmę, w jej wierszu zmień pole „Firma"
(select w sekcji „Kontaktpersoner" w modalu) — to zwykły `UPDATE`, nie zapisujemy historii
zatrudnienia.

**Jeśli aktualizujesz istniejące wdrożenie CRM** (baza już ma dane z wcześniejszej wersji z jednym
polem „Kontaktperson"): uruchom w Supabase SQL Editor plik
[`supabase/migration_002_contact_people.sql`](supabase/migration_002_contact_people.sql) **zanim**
wdrożysz nową wersję frontendu — przenosi on istniejące dane do nowej tabeli i usuwa stare pole.
Kolejność ma znaczenie: nowy frontend zakłada, że tabela `contact_people` już istnieje.

## Dodawanie/usuwanie użytkowników później

Wykonuje się to wyłącznie w panelu Supabase (**Authentication → Users**), nie w kodzie aplikacji —
dodanie nowej osoby to dodanie jej e-maila w tym panelu, usunięcie dostępu to usunięcie/wyłączenie
konta tamże.
