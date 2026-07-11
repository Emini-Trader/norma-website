-- Migracja 002: osoby kontaktowe jako osobna encja (jedna firma -> wiele osób)
-- Uruchom w Supabase Dashboard -> SQL Editor -> Run.
-- Zakłada, że schema.sql (migracja 001) już był wcześniej uruchomiony.

-- 1) Nowa tabela: kontaktpersoner. Sztuczny PK (id), FK do contacts.
--    Brak historii zatrudnienia — jeśli osoba zmienia firmę, robimy UPDATE contact_id.
create table if not exists public.contact_people (
  id uuid primary key default gen_random_uuid(),
  contact_id uuid not null references public.contacts(id) on delete cascade,
  full_name text not null,
  role text,
  phone text,
  email text,
  is_primary boolean not null default false,
  created_at timestamptz not null default now(),
  created_by uuid references auth.users(id),
  created_by_email text,
  updated_at timestamptz not null default now(),
  updated_by uuid references auth.users(id),
  updated_by_email text
);

create index if not exists contact_people_contact_id_idx on public.contact_people(contact_id);

-- 2) Ten sam trigger audytowy co przy contacts (funkcja jest generyczna, nie firma-specyficzna)
drop trigger if exists trg_contact_people_audit on public.contact_people;
create trigger trg_contact_people_audit
  before insert or update on public.contact_people
  for each row execute function public.set_contact_audit_fields();

-- 3) RLS: te same zasady co reszta - tylko zalogowani, bez ról
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

-- 4) Migracja istniejących danych: contacts.contact_person (jedno pole tekstowe)
--    -> po jednym wierszu w contact_people, oznaczonym jako hovedkontakt (is_primary).
--    Jeśli w polu było kilka nazwisk naraz (np. "Anders X and Gustav Y"), trafi to jako
--    jeden wpis - popraw ręcznie w aplikacji na osobne osoby, jeśli chcesz.
insert into public.contact_people (contact_id, full_name, is_primary)
select id, contact_person, true
from public.contacts
where contact_person is not null and trim(contact_person) <> '';

-- 5) Usunięcie starego pola tekstowego z contacts (zastąpione przez contact_people)
alter table public.contacts drop column if exists contact_person;
