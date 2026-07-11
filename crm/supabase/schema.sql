-- CRM Norma GS — schemat bazy danych dla Supabase
-- Wklej cały ten plik w Supabase Dashboard -> SQL Editor -> Run
-- (dla instalacji od zera; dla istniejącej bazy zobacz migration_002_contact_people.sql)

-- 1) profiles: publiczna, odpytywalna kopia (id, email) z auth.users.
--    auth.users NIE jest dostępne z API/RLS dla zwykłych klientów, więc żeby móc
--    pokazać "kto edytował" bez duplikowania e-maila w każdej tabeli (co łamałoby 3NF -
--    e-mail zależałby przechodnio od created_by/updated_by, a nie od PK danej tabeli),
--    trzymamy jedną tabelę profiles i do niej robimy JOIN z poziomu frontendu.
create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  email text not null,
  first_name text,  -- ustaw ręcznie w Table Editor po dodaniu użytkownika; pokazuje się zamiast e-maila w CRM
  last_name text
);

alter table public.profiles enable row level security;

drop policy if exists "authenticated can read profiles" on public.profiles;
create policy "authenticated can read profiles" on public.profiles
  for select to authenticated using (true);

-- Synchronizacja profiles z auth.users: przy tworzeniu konta i przy zmianie e-maila.
create or replace function public.handle_auth_user_upsert()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profiles (id, email)
  values (new.id, new.email)
  on conflict (id) do update set email = excluded.email;
  return new;
end;
$$;

drop trigger if exists trg_auth_user_upsert on auth.users;
create trigger trg_auth_user_upsert
  after insert or update of email on auth.users
  for each row execute function public.handle_auth_user_upsert();

-- Backfill: konta utworzone przed dodaniem tego triggera (bez efektu przy świeżej instalacji).
insert into public.profiles (id, email)
select id, email from auth.users
on conflict (id) do nothing;

-- 2) Tabela firm/kontaktów (odpowiednik arkusza "Ark1")
create table if not exists public.contacts (
  id uuid primary key default gen_random_uuid(),
  company_name text not null,
  phone text,
  email text,
  website text,
  address text,
  status text not null default 'ny' check (status in ('ny', 'kontaktet', 'venter_svar', 'kunde', 'avslatt')),
  created_at timestamptz not null default now(),
  created_by uuid references public.profiles(id),
  updated_at timestamptz not null default now(),
  updated_by uuid references public.profiles(id)
);

comment on column public.contacts.status is 'ny=Ny, kontaktet=Kontaktet, venter_svar=Venter på svar, kunde=Kunde, avslatt=Avslått';

-- 3) Kontaktpersoner: jedna firma może mieć wiele osób kontaktowych.
--    Sztuczny PK (id), FK do contacts. Bez historii zatrudnienia — zmiana firmy = UPDATE contact_id.
create table if not exists public.contact_people (
  id uuid primary key default gen_random_uuid(),
  contact_id uuid not null references public.contacts(id) on delete cascade,
  full_name text not null,
  role text,
  phone text,
  email text,
  is_primary boolean not null default false,
  created_at timestamptz not null default now(),
  created_by uuid references public.profiles(id),
  updated_at timestamptz not null default now(),
  updated_by uuid references public.profiles(id)
);

create index if not exists contact_people_contact_id_idx on public.contact_people(contact_id);

-- 4) Historia kontaktów per firma (odpowiednik kolumny "Kommentarer", ale jako log wpisów zamiast jednego pola)
create table if not exists public.contact_activities (
  id uuid primary key default gen_random_uuid(),
  contact_id uuid not null references public.contacts(id) on delete cascade,
  note text not null,
  created_at timestamptz not null default now(),
  created_by uuid references public.profiles(id)
);

create index if not exists contact_activities_contact_id_idx on public.contact_activities(contact_id);

-- 5) Automatyczne ustawianie "kto i kiedy edytował" — niezależnie od tego co wyśle frontend
create or replace function public.set_contact_audit_fields()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  if tg_op = 'INSERT' then
    new.created_at := now();
    new.created_by := auth.uid();
    new.updated_at := now();
    new.updated_by := auth.uid();
  elsif tg_op = 'UPDATE' then
    new.created_at := old.created_at;
    new.created_by := old.created_by;
    new.updated_at := now();
    new.updated_by := auth.uid();
  end if;
  return new;
end;
$$;

drop trigger if exists trg_contacts_audit on public.contacts;
create trigger trg_contacts_audit
  before insert or update on public.contacts
  for each row execute function public.set_contact_audit_fields();

-- Ta sama funkcja audytowa nadaje się dla contact_people (te same nazwy kolumn)
drop trigger if exists trg_contact_people_audit on public.contact_people;
create trigger trg_contact_people_audit
  before insert or update on public.contact_people
  for each row execute function public.set_contact_audit_fields();

create or replace function public.set_activity_audit_fields()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  new.created_at := now();
  new.created_by := auth.uid();
  return new;
end;
$$;

drop trigger if exists trg_activities_audit on public.contact_activities;
create trigger trg_activities_audit
  before insert on public.contact_activities
  for each row execute function public.set_activity_audit_fields();

-- 6) Row Level Security: tylko zalogowani użytkownicy (zaproszeni przez admina) mają dostęp.
--    Brak ról — każdy zalogowany może odczytywać i edytować wszystko.
alter table public.contacts enable row level security;
alter table public.contact_people enable row level security;
alter table public.contact_activities enable row level security;

drop policy if exists "authenticated can read contacts" on public.contacts;
create policy "authenticated can read contacts" on public.contacts
  for select to authenticated using (true);

drop policy if exists "authenticated can insert contacts" on public.contacts;
create policy "authenticated can insert contacts" on public.contacts
  for insert to authenticated with check (true);

drop policy if exists "authenticated can update contacts" on public.contacts;
create policy "authenticated can update contacts" on public.contacts
  for update to authenticated using (true) with check (true);

drop policy if exists "authenticated can delete contacts" on public.contacts;
create policy "authenticated can delete contacts" on public.contacts
  for delete to authenticated using (true);

drop policy if exists "authenticated can read people" on public.contact_people;
create policy "authenticated can read people" on public.contact_people
  for select to authenticated using (true);

drop policy if exists "authenticated can insert people" on public.contact_people;
create policy "authenticated can insert people" on public.contact_people
  for insert to authenticated with check (true);

drop policy if exists "authenticated can update people" on public.contact_people;
create policy "authenticated can update people" on public.contact_people
  for update to authenticated using (true) with check (true);

drop policy if exists "authenticated can delete people" on public.contact_people;
create policy "authenticated can delete people" on public.contact_people
  for delete to authenticated using (true);

drop policy if exists "authenticated can read activities" on public.contact_activities;
create policy "authenticated can read activities" on public.contact_activities
  for select to authenticated using (true);

drop policy if exists "authenticated can insert activities" on public.contact_activities;
create policy "authenticated can insert activities" on public.contact_activities
  for insert to authenticated with check (true);

drop policy if exists "authenticated can delete activities" on public.contact_activities;
create policy "authenticated can delete activities" on public.contact_activities
  for delete to authenticated using (true);
