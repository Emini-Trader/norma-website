-- Migracja 010: Status på hovedsiden skal følge Type i Historikk, i stedet for å være
-- et eget, ukoblet felt.
-- Uruchom w Supabase Dashboard -> SQL Editor -> Run.
--
-- Bakgrunn: contacts.status (Ny/Kontaktet/Venter på svar/Kunde/Avslått) ble satt manuelt,
-- helt uavhengig av contact_activities.contact_type (E-post/Telefon/Møte/Annet) i Historikk.
-- To ukoblede felt for "hvor firmaet står" var forvirrende. Fra nå av vises Status på
-- hovedsiden som typen til siste Historikk-oppføring (utledet i frontend, ikke lagret
-- separat - se app.js) - "Ny" hvis firmaet ennå ikke har noen Historikk-oppføring.
-- Dette gjør contacts.status overflødig og duplisert data, så den fjernes.

-- A) Utvid contact_type med de to nye verdiene "Avslått" og "Svar fra kunden"
alter table public.contact_activities drop constraint if exists contact_activities_contact_type_check;
alter table public.contact_activities add constraint contact_activities_contact_type_check
  check (contact_type in ('epost', 'telefon', 'mote', 'annet', 'avslatt', 'svar_fra_kunden'));

comment on column public.contact_activities.contact_type is
  'epost=E-post, telefon=Telefon, mote=Møte, annet=Annet, avslatt=Avslått, svar_fra_kunden=Svar fra kunden';

-- B) Fjern det nå overflødige, ukoblede statusfeltet på contacts
alter table public.contacts drop column if exists status;
