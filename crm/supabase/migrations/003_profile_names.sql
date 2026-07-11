-- Migracja 003: imię i nazwisko w profiles (osobne kolumny), zamiast pokazywania e-maila w CRM
-- STATUS: już zastosowane na crm.norma-gs.no (2026-07-11) - nie uruchamiaj ponownie.
-- Trzymane jako historyczny zapis zmiany schematu, patrz README.md.
-- Zakłada, że 002_contact_people.sql (tabela profiles) już był uruchomiony.

alter table public.profiles add column if not exists first_name text;
alter table public.profiles add column if not exists last_name text;

update public.profiles set first_name = 'Tomasz', last_name = 'Radomski' where email = 'tomasz@norma-gs.no';
update public.profiles set first_name = 'Joanna', last_name = 'Radomska' where email = 'joanna@norma-gs.no';

-- Dla kolejnych zapraszanych osób: po dodaniu konta w Authentication -> Users,
-- wejdź w Table Editor -> profiles, znajdź wiersz po e-mailu i wpisz first_name/last_name
-- ręcznie (nie trzeba już SQL-a — profiles to zwykła, edytowalna tabela).
