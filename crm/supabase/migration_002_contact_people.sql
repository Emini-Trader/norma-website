-- Migracja 002: osoby kontaktowe (jedna firma -> wiele osób) + poprawka 3NF
-- Uruchom w Supabase Dashboard -> SQL Editor -> Run.
-- Zakłada, że schema.sql (migracja 001) już był wcześniej uruchomiony.
--
-- Ta migracja robi dwie rzeczy naraz (celowo w jednym kroku, żeby nie migrować dwa razy):
--   A) dodaje encję "osoba kontaktowa" (contact_people) zamiast pola contacts.contact_person,
--   B) usuwa redundancję created_by_email/updated_by_email z contacts i contact_activities
--      (łamały 3NF - e-mail zależał przechodnio od created_by/updated_by, nie od PK tabeli)
--      wprowadzając tabelę profiles jako jedyne źródło e-maila dla danego usera.

-- ============================================================
-- A) profiles: publiczna, odpytywalna kopia (id, email) z auth.users
-- ============================================================
create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  email text not null
);

alter table public.profiles enable row level security;

drop policy if exists "authenticated can read profiles" on public.profiles;
create policy "authenticated can read profiles" on public.profiles
  for select to authenticated using (true);

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

-- Backfill: konta, które już istnieją (Ty i pozostali zaproszeni użytkownicy)
insert into public.profiles (id, email)
select id, email from auth.users
on conflict (id) do nothing;

-- ============================================================
-- B) Uproszczenie funkcji audytowych — bez kolumn *_email (redefinicja PRZED
--    zmianami w tabelach, żeby żaden trigger po drodze nie odwołał się do
--    kolumny, która zaraz przestanie istnieć)
-- ============================================================
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

-- ============================================================
-- C) contacts: FK created_by/updated_by -> profiles zamiast auth.users,
--    usunięcie zdenormalizowanych kolumn *_email
-- ============================================================
alter table public.contacts drop constraint if exists contacts_created_by_fkey;
alter table public.contacts drop constraint if exists contacts_updated_by_fkey;
alter table public.contacts
  add constraint contacts_created_by_fkey foreign key (created_by) references public.profiles(id),
  add constraint contacts_updated_by_fkey foreign key (updated_by) references public.profiles(id);

alter table public.contacts drop column if exists created_by_email;
alter table public.contacts drop column if exists updated_by_email;

-- ============================================================
-- D) contact_activities: to samo co wyżej
-- ============================================================
alter table public.contact_activities drop constraint if exists contact_activities_created_by_fkey;
alter table public.contact_activities
  add constraint contact_activities_created_by_fkey foreign key (created_by) references public.profiles(id);

alter table public.contact_activities drop column if exists created_by_email;

-- ============================================================
-- E) Nowa tabela: kontaktpersoner. Sztuczny PK (id), FK do contacts.
--    Bez historii zatrudnienia — jeśli osoba zmienia firmę, robimy UPDATE contact_id.
-- ============================================================
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

drop trigger if exists trg_contact_people_audit on public.contact_people;
create trigger trg_contact_people_audit
  before insert or update on public.contact_people
  for each row execute function public.set_contact_audit_fields();

alter table public.contact_people enable row level security;

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

-- ============================================================
-- F) Migracja istniejących danych: contacts.contact_person (jedno pole tekstowe)
--    -> po jednym wierszu w contact_people, oznaczonym jako hovedkontakt (is_primary).
--    Jeśli w polu było kilka nazwisk naraz (np. "Anders X and Gustav Y"), trafi to jako
--    jeden wpis - popraw ręcznie w aplikacji na osobne osoby, jeśli chcesz.
-- ============================================================
insert into public.contact_people (contact_id, full_name, is_primary)
select id, contact_person, true
from public.contacts
where contact_person is not null and trim(contact_person) <> '';

alter table public.contacts drop column if exists contact_person;
