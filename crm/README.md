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
- **Klik na wiersz** — otwiera popup z podsumowaniem firmy (tylko do odczytu): dane kontaktowe,
  osoby kontaktowe i historia (Historikk) jako tabela: Data / Kontaktet av / Med hvem / Type /
  Kommentar. Na desktopie (≥860px) podsumowanie+historia są w lewej kolumnie, kontaktpersoner w
  prawej; na telefonie wszystko jest pod sobą.
- **Ikona ✎ w rogu popupu** — przełącza w tryb edycji: edytowalny formularz firmy, zarządzanie
  osobami kontaktowymi (dodaj/edytuj/usuń/przenieś do innej firmy) i dodawanie nowych wpisów do
  Historikk (data, z kim, rodzaj kontaktu — e-post/telefon/møte/annet, komentarz).
- **+ Ny firma** — od razu otwiera pusty formularz edycji (nie ma jeszcze czego podsumowywać).
- Każda zmiana automatycznie zapisuje, kto i kiedy jej dokonał (widoczne w podsumowaniu firmy oraz
  przy każdym wpisie w Historikk) — ustawia to baza danych (trigger), więc nie da się tego
  sfałszować z poziomu przeglądarki. Lista firm pokazuje tylko datę ostatniej zmiany, żeby nie była
  przeładowana.

## Kontaktpersoner (jedna firma, wiele osób)

Firma ma teraz osobną listę kontaktpersonów (tabela `contact_people`), a nie jedno pole tekstowe —
każda osoba ma własny telefon/e-mail/stanowisko i może być oznaczona jako „Hovedkontakt" (główny
kontakt, widoczny w tabeli firm). Jeśli osoba zmienia firmę, w jej wierszu zmień pole „Firma"
(select w sekcji „Kontaktpersoner" w modalu) — to zwykły `UPDATE`, nie zapisujemy historii
zatrudnienia.

## Historia migracji bazy (`supabase/migrations/`)

`schema.sql` zawiera **pełny, aktualny schemat** — używaj go tylko przy zakładaniu zupełnie nowego
projektu Supabase od zera (patrz krok 2 wyżej).

Folder [`supabase/migrations/`](supabase/migrations/) to już zastosowane, historyczne kroki, którymi
dotychczasowa (żyjąca na `crm.norma-gs.no`) baza doszła do obecnego stanu — nie trzeba ich ponownie
uruchamiać. Trzymane są jako dokumentacja tego, jak i dlaczego zmieniał się schemat (standardowa
praktyka przy migracjach bazy danych), na wypadek gdyby trzeba było kiedyś odtworzyć historię zmian
albo założyć drugie środowisko (np. staging) startujące od starszego stanu:

- `002_contact_people.sql` — dodanie encji „osoba kontaktowa" (zamiast jednego pola tekstowego) oraz
  poprawka 3NF (tabela `profiles` zamiast zdenormalizowanych `*_email` w każdej tabeli).
- `003_profile_names.sql` — dodanie `first_name`/`last_name` do `profiles`, żeby w CRM pokazywać imię
  zamiast e-maila.
- `004_activity_details.sql` — rozbudowa Historikk o `occurred_at` (data kontaktu, wyciągnięta z
  treści starych notatek), `person_id` (z kim) i `contact_type` (rodzaj kontaktu).
- `005_data_cleanup.sql` — poprawki dwóch niechlujnych rekordów z importu Excela (rozbity zapis
  dwóch osób w jednym polu, ujednolicona kapitalizacja jednego nazwiska).

## Dlaczego jest tabela `profiles` (i 3NF)

Baza jest zaprojektowana pod kątem 3NF: żadna kolumna nie duplikuje danych, które da się
jednoznacznie wyprowadzić z klucza głównego innej tabeli. Jedyne miejsce, gdzie kusiło, żeby to
złamać, to pokazywanie „kto edytował" — `auth.users` (gdzie Supabase trzyma e-maile kont) nie jest
odpytywalne z poziomu zwykłego zapytania frontendu (ze względów bezpieczeństwa). Zamiast kopiować
e-mail do każdej tabeli (`created_by_email`, `updated_by_email` — co byłoby zależnością przechodnią
i psuło 3NF, a przy zmianie e-maila konta zostawiałoby nieaktualne kopie), jest jedna tabela
`public.profiles` (id, email), zsynchronizowana triggerem z `auth.users`, do której `contacts`,
`contact_people` i `contact_activities` robią zwykły FK + JOIN po `created_by`/`updated_by`.

`profiles` ma też kolumny `first_name`/`last_name` — w CRM przy „kto edytował" pokazuje się samo
imię (np. „Tomasz"), jeśli jest ustawione, w przeciwnym razie e-mail jako zapasowa opcja. Dla nowej
osoby: po dodaniu konta w **Authentication → Users**, wejdź w **Table Editor → profiles**, znajdź
wiersz po e-mailu i wpisz `first_name`/`last_name` — nie trzeba do tego SQL-a.

## Dodawanie/usuwanie użytkowników później

Wykonuje się to wyłącznie w panelu Supabase (**Authentication → Users**), nie w kodzie aplikacji —
dodanie nowej osoby to dodanie jej e-maila w tym panelu, usunięcie dostępu to usunięcie/wyłączenie
konta tamże.
