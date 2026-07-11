-- Migracja 003: imię i nazwisko w profiles (zamiast pokazywania samego e-maila w CRM)
-- Uruchom w Supabase Dashboard -> SQL Editor -> Run.
-- Zakłada, że migration_002_contact_people.sql (tabela profiles) już był uruchomiony.

alter table public.profiles add column if not exists full_name text;

update public.profiles set full_name = 'Tomasz Radomski' where email = 'tomasz@norma-gs.no';
update public.profiles set full_name = 'Joanna Radomska' where email = 'joanna@norma-gs.no';

-- Dla kolejnych zapraszanych osób: po dodaniu konta w Authentication -> Users,
-- wejdź w Table Editor -> profiles, znajdź wiersz po e-mailu i wpisz full_name ręcznie
-- (nie trzeba już SQL-a — profiles to zwykła, edytowalna tabela).
