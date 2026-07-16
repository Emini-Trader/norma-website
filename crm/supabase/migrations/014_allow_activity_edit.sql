-- Migracja 014: mozliwosc edycji istniejacych wpisow Historikk (dotychczas mozna bylo tylko
-- dodawac nowe i usuwac calosc firmy - pojedynczych wpisow Historikk nie dalo sie poprawic).
-- Uruchom w Supabase Dashboard -> SQL Editor -> Run.

alter table public.contact_activities
  add column if not exists updated_at timestamptz,
  add column if not exists updated_by uuid references public.profiles(id);

-- Ta sama audytowa funkcja co dla contacts/contact_people: przy UPDATE zachowuje created_at/
-- created_by, ustawia updated_at/updated_by. Dodawanie nowych wpisow nadal obsluguje osobny,
-- insert-only trigger trg_activities_audit - updated_at/updated_by zostaja NULL, dopoki wpis
-- nie zostanie po raz pierwszy edytowany.
drop trigger if exists trg_activities_audit_update on public.contact_activities;
create trigger trg_activities_audit_update
  before update on public.contact_activities
  for each row execute function public.set_contact_audit_fields();

drop policy if exists "authenticated can update activities" on public.contact_activities;
create policy "authenticated can update activities" on public.contact_activities
  for update to authenticated using (true) with check (true);
