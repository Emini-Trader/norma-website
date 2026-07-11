-- Migracja 004: rozbudowa Historikk o osobne kolumny (Data, Z kim, Rodzaj kontaktu)
-- Uruchom w Supabase Dashboard -> SQL Editor -> Run.

alter table public.contact_activities
  add column if not exists occurred_at date not null default current_date,
  add column if not exists person_id uuid references public.contact_people(id) on delete set null,
  add column if not exists contact_type text not null default 'annet'
    check (contact_type in ('epost', 'telefon', 'mote', 'annet'));

comment on column public.contact_activities.contact_type is 'epost=E-post, telefon=Telefon, mote=Møte, annet=Annet';
comment on column public.contact_activities.person_id is 'Hvilken kontaktperson (contact_people) kontakten var med - kan være NULL for eldre/generelle notater';

-- Backfill dla istniejących 40 zaimportowanych notatek: w tekście notatki jest już
-- prawdziwa data ("mail 17.06.2026") - wyciągamy ją zamiast zostawiać dzisiejszą datę.
update public.contact_activities
set occurred_at = to_date(substring(note from '\d{2}\.\d{2}\.\d{4}'), 'DD.MM.YYYY')
where note ~ '\d{2}\.\d{2}\.\d{4}';

-- Te zaimportowane notatki były korespondencją mailową
update public.contact_activities
set contact_type = 'epost'
where note ilike 'mail%';
