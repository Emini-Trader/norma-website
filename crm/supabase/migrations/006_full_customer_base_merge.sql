-- Migracja 006: pelna baza klientow z drugiego arkusza Excel
-- (Kopi_av_Company_customer_base_konsulent.xlsx, Ark1)
-- Uruchom w Supabase Dashboard -> SQL Editor -> Run.
--
-- Dodaje: kraj (country) na contacts, oraz branze/Fagomrade jako wlasciwa relacja
-- wiele-do-wielu (specialties + contact_specialties), zamiast wolnego tekstu -
-- 'Bygg, Anlegg' i 'Anlegg, Bygg' to te same dwie etykiety, nie jeden ciag znakow.
--
-- 13 firm z tego arkusza juz istnieje w bazie (ten sam klient, wczesniejszy import) -
-- dla nich dogrywamy tylko kraj/branze, NIE dublujemy osob ani historii kontaktu.
-- 71 firm jest nowych - pelny import (firma + osoby + historia + branze).

-- ============================================================
-- A) Schema: country + specialties (wiele-do-wielu)
-- ============================================================
alter table public.contacts add column if not exists country text;

create table if not exists public.specialties (
  id uuid primary key default gen_random_uuid(),
  name text not null unique
);

create table if not exists public.contact_specialties (
  contact_id uuid not null references public.contacts(id) on delete cascade,
  specialty_id uuid not null references public.specialties(id) on delete cascade,
  created_at timestamptz not null default now(),
  created_by uuid references public.profiles(id),
  primary key (contact_id, specialty_id)
);

drop trigger if exists trg_contact_specialties_audit on public.contact_specialties;
create trigger trg_contact_specialties_audit
  before insert on public.contact_specialties
  for each row execute function public.set_activity_audit_fields();

alter table public.specialties enable row level security;
alter table public.contact_specialties enable row level security;

drop policy if exists "authenticated can read specialties" on public.specialties;
create policy "authenticated can read specialties" on public.specialties for select to authenticated using (true);
drop policy if exists "authenticated can insert specialties" on public.specialties;
create policy "authenticated can insert specialties" on public.specialties for insert to authenticated with check (true);

drop policy if exists "authenticated can read contact_specialties" on public.contact_specialties;
create policy "authenticated can read contact_specialties" on public.contact_specialties for select to authenticated using (true);
drop policy if exists "authenticated can insert contact_specialties" on public.contact_specialties;
create policy "authenticated can insert contact_specialties" on public.contact_specialties for insert to authenticated with check (true);
drop policy if exists "authenticated can delete contact_specialties" on public.contact_specialties;
create policy "authenticated can delete contact_specialties" on public.contact_specialties for delete to authenticated using (true);

-- ============================================================
-- B) Kanoniczna lista branz (Fagomrade)
-- ============================================================
insert into public.specialties (name) values
  ('Anlegg'),
  ('Arkitekt'),
  ('Bane'),
  ('Betong'),
  ('Boring'),
  ('Bygg'),
  ('Eiendom'),
  ('Energi'),
  ('Flyfotografering'),
  ('Fundamentering'),
  ('Gartner'),
  ('Grunnborring'),
  ('Hytte'),
  ('Kai'),
  ('Konsulent'),
  ('Landskap'),
  ('Masseutskifting'),
  ('Offshore'),
  ('Oil'),
  ('Riving'),
  ('Stål Bygg'),
  ('Telekomunikasjon'),
  ('Tunnel'),
  ('Vei')
on conflict (name) do nothing;

-- ============================================================
-- C) 13 juz istniejacych firm: dograj kraj + branze (bez duplikatow osob/historii)
-- ============================================================
DO $$
DECLARE v_id uuid;
BEGIN
  SELECT id INTO v_id FROM public.contacts WHERE lower(company_name) = lower('Riise Consulting');
  IF v_id IS NOT NULL THEN
    UPDATE public.contacts SET country = 'Norge', website = COALESCE(website, NULL) WHERE id = v_id;
    INSERT INTO public.contact_specialties (contact_id, specialty_id)
      SELECT v_id, s.id FROM public.specialties s WHERE s.name IN ('Arkitekt')
      ON CONFLICT DO NOTHING;
  END IF;
END $$;

DO $$
DECLARE v_id uuid;
BEGIN
  SELECT id INTO v_id FROM public.contacts WHERE lower(company_name) = lower('Arkitektur og Byggsøk M Johansen');
  IF v_id IS NOT NULL THEN
    UPDATE public.contacts SET country = 'Norge', website = COALESCE(website, NULL) WHERE id = v_id;
    INSERT INTO public.contact_specialties (contact_id, specialty_id)
      SELECT v_id, s.id FROM public.specialties s WHERE s.name IN ('Arkitekt')
      ON CONFLICT DO NOTHING;
  END IF;
END $$;

DO $$
DECLARE v_id uuid;
BEGIN
  SELECT id INTO v_id FROM public.contacts WHERE lower(company_name) = lower('Smolovic Arkitektur');
  IF v_id IS NOT NULL THEN
    UPDATE public.contacts SET country = 'Norge', website = COALESCE(website, NULL) WHERE id = v_id;
    INSERT INTO public.contact_specialties (contact_id, specialty_id)
      SELECT v_id, s.id FROM public.specialties s WHERE s.name IN ('Arkitekt')
      ON CONFLICT DO NOTHING;
  END IF;
END $$;

DO $$
DECLARE v_id uuid;
BEGIN
  SELECT id INTO v_id FROM public.contacts WHERE lower(company_name) = lower('Fredrikstad Arkitekttjenester AS');
  IF v_id IS NOT NULL THEN
    UPDATE public.contacts SET country = 'Norge', website = COALESCE(website, NULL) WHERE id = v_id;
    INSERT INTO public.contact_specialties (contact_id, specialty_id)
      SELECT v_id, s.id FROM public.specialties s WHERE s.name IN ('Arkitekt')
      ON CONFLICT DO NOTHING;
  END IF;
END $$;

DO $$
DECLARE v_id uuid;
BEGIN
  SELECT id INTO v_id FROM public.contacts WHERE lower(company_name) = lower('MO Byggservice AS');
  IF v_id IS NOT NULL THEN
    UPDATE public.contacts SET country = 'Norge', website = COALESCE(website, 'www.mobyggservice.no') WHERE id = v_id;
    INSERT INTO public.contact_specialties (contact_id, specialty_id)
      SELECT v_id, s.id FROM public.specialties s WHERE s.name IN ('Arkitekt')
      ON CONFLICT DO NOTHING;
  END IF;
END $$;

DO $$
DECLARE v_id uuid;
BEGIN
  SELECT id INTO v_id FROM public.contacts WHERE lower(company_name) = lower('STRÅ Arkitekter AS');
  IF v_id IS NOT NULL THEN
    UPDATE public.contacts SET country = 'Norge', website = COALESCE(website, 'https://www.straaa.com/') WHERE id = v_id;
    INSERT INTO public.contact_specialties (contact_id, specialty_id)
      SELECT v_id, s.id FROM public.specialties s WHERE s.name IN ('Arkitekt')
      ON CONFLICT DO NOTHING;
  END IF;
END $$;

DO $$
DECLARE v_id uuid;
BEGIN
  SELECT id INTO v_id FROM public.contacts WHERE lower(company_name) = lower('Bygg Design Moldoveanu');
  IF v_id IS NOT NULL THEN
    UPDATE public.contacts SET country = 'Norge', website = COALESCE(website, NULL) WHERE id = v_id;
    INSERT INTO public.contact_specialties (contact_id, specialty_id)
      SELECT v_id, s.id FROM public.specialties s WHERE s.name IN ('Arkitekt')
      ON CONFLICT DO NOTHING;
  END IF;
END $$;

DO $$
DECLARE v_id uuid;
BEGIN
  SELECT id INTO v_id FROM public.contacts WHERE lower(company_name) = lower('UPROXO AS');
  IF v_id IS NOT NULL THEN
    UPDATE public.contacts SET country = 'Norge', website = COALESCE(website, NULL) WHERE id = v_id;
    INSERT INTO public.contact_specialties (contact_id, specialty_id)
      SELECT v_id, s.id FROM public.specialties s WHERE s.name IN ('Arkitekt')
      ON CONFLICT DO NOTHING;
  END IF;
END $$;

DO $$
DECLARE v_id uuid;
BEGIN
  SELECT id INTO v_id FROM public.contacts WHERE lower(company_name) = lower('Byggingeniøren AS');
  IF v_id IS NOT NULL THEN
    UPDATE public.contacts SET country = 'Norge', website = COALESCE(website, 'https://www.byggingenioren.no/') WHERE id = v_id;
    INSERT INTO public.contact_specialties (contact_id, specialty_id)
      SELECT v_id, s.id FROM public.specialties s WHERE s.name IN ('Arkitekt')
      ON CONFLICT DO NOTHING;
  END IF;
END $$;

DO $$
DECLARE v_id uuid;
BEGIN
  SELECT id INTO v_id FROM public.contacts WHERE lower(company_name) = lower('Fjell Byggconsult AS');
  IF v_id IS NOT NULL THEN
    UPDATE public.contacts SET country = 'Norge', website = COALESCE(website, 'www.runefjell.no') WHERE id = v_id;
    INSERT INTO public.contact_specialties (contact_id, specialty_id)
      SELECT v_id, s.id FROM public.specialties s WHERE s.name IN ('Arkitekt')
      ON CONFLICT DO NOTHING;
  END IF;
END $$;

DO $$
DECLARE v_id uuid;
BEGIN
  SELECT id INTO v_id FROM public.contacts WHERE lower(company_name) = lower('Arkitektfirma Siv.ar. Agata Suchecka');
  IF v_id IS NOT NULL THEN
    UPDATE public.contacts SET country = 'Norge', website = COALESCE(website, NULL) WHERE id = v_id;
    INSERT INTO public.contact_specialties (contact_id, specialty_id)
      SELECT v_id, s.id FROM public.specialties s WHERE s.name IN ('Arkitekt')
      ON CONFLICT DO NOTHING;
  END IF;
END $$;

DO $$
DECLARE v_id uuid;
BEGIN
  SELECT id INTO v_id FROM public.contacts WHERE lower(company_name) = lower('Kove Arkitektur AS');
  IF v_id IS NOT NULL THEN
    UPDATE public.contacts SET country = 'Norge', website = COALESCE(website, NULL) WHERE id = v_id;
    INSERT INTO public.contact_specialties (contact_id, specialty_id)
      SELECT v_id, s.id FROM public.specialties s WHERE s.name IN ('Arkitekt')
      ON CONFLICT DO NOTHING;
  END IF;
END $$;

DO $$
DECLARE v_id uuid;
BEGIN
  SELECT id INTO v_id FROM public.contacts WHERE lower(company_name) = lower('Nes Bygg og Prosjektering AS');
  IF v_id IS NOT NULL THEN
    UPDATE public.contacts SET country = 'Norge', website = COALESCE(website, NULL) WHERE id = v_id;
    INSERT INTO public.contact_specialties (contact_id, specialty_id)
      SELECT v_id, s.id FROM public.specialties s WHERE s.name IN ('Arkitekt')
      ON CONFLICT DO NOTHING;
  END IF;
END $$;

-- ============================================================
-- D) 71 nowych firm: pelny import (firma + osoby + historia + branze)
--    Zabezpieczone przez NOT EXISTS - bezpieczne w razie ponownego uruchomienia.
-- ============================================================
DO $$
DECLARE
  v_contact_id uuid;
  v_person_1 uuid;
  v_person_2 uuid;
BEGIN
  IF NOT EXISTS (SELECT 1 FROM public.contacts WHERE lower(company_name) = lower('NCC')) THEN
    INSERT INTO public.contacts (company_name, phone, email, website, country, status)
      VALUES ('NCC', '466 30 466', 'maria.melfald@ncc.no', 'https://www.ncc.no/', 'Norge', 'kontaktet')
      RETURNING id INTO v_contact_id;

    INSERT INTO public.contact_people (contact_id, full_name, phone, email, is_primary)
      VALUES (v_contact_id, 'Maria Melfald', '466 30 466', 'maria.melfald@ncc.no', true)
      RETURNING id INTO v_person_1;
    INSERT INTO public.contact_people (contact_id, full_name, phone, email, is_primary)
      VALUES (v_contact_id, 'Dirk Niemann', '916 51 372', 'dirk.niemann@ncc.no', false)
      RETURNING id INTO v_person_2;

    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2020-08-17', v_person_1, 'epost', 'hils');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2020-10-29', v_person_1, 'epost', 'standard tilbud');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2020-11-13', v_person_1, 'telefon', 'hils');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2021-01-06', v_person_1, 'telefon', 'hils');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2021-02-23', v_person_1, 'epost', 'standard tilbud');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2021-03-25', v_person_1, 'epost', 'standard tilbud');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2022-01-20', v_person_1, 'telefon', 'Drammen prosjekt - oppdatering');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2022-03-07', v_person_1, 'telefon', 'oppdatering - fortsetter med rekruttering');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2023-01-04', v_person_1, 'telefon', 'oppdatering');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2026-02-06', v_person_2, 'epost', 'oppdatering');

    INSERT INTO public.contact_specialties (contact_id, specialty_id)
      SELECT v_contact_id, s.id FROM public.specialties s WHERE s.name IN ('Bygg', 'Anlegg')
      ON CONFLICT DO NOTHING;
  END IF;
END $$;

DO $$
DECLARE
  v_contact_id uuid;
  v_person_1 uuid;
  v_person_2 uuid;
  v_person_3 uuid;
BEGIN
  IF NOT EXISTS (SELECT 1 FROM public.contacts WHERE lower(company_name) = lower('SKANSKA Skanska Surwey')) THEN
    INSERT INTO public.contacts (company_name, phone, email, website, country, status)
      VALUES ('SKANSKA Skanska Surwey', '982 10 920', 'trond.petter.eide@skanska.no', 'https://www.skanskasurvey.no/', 'Norge', 'kontaktet')
      RETURNING id INTO v_contact_id;

    INSERT INTO public.contact_people (contact_id, full_name, phone, email, is_primary)
      VALUES (v_contact_id, 'Trond Petter Eide', '982 10 920', 'trond.petter.eide@skanska.no', true)
      RETURNING id INTO v_person_1;
    INSERT INTO public.contact_people (contact_id, full_name, phone, email, is_primary)
      VALUES (v_contact_id, 'Rolf Christian Kværnæs', '466 20 588', 'rolf-christian.kvernes@skanska.no', false)
      RETURNING id INTO v_person_2;
    INSERT INTO public.contact_people (contact_id, full_name, phone, email, is_primary)
      VALUES (v_contact_id, 'Markus Karlson', '982 10 533', 'markus.karlsson@skanska.no', false)
      RETURNING id INTO v_person_3;

    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2020-08-18', v_person_1, 'epost', 'hils');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2020-11-09', NULL, 'annet', '1, 2, 3/mail/standard tilbud');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2020-11-13', NULL, 'annet', '1, 2, 3/mail/standard tilbud');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2020-11-19', v_person_3, 'epost', 'Tilbud Northen Lights');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2020-11-24', v_person_3, 'epost', 'Tilbud Northen Lights');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2021-02-23', NULL, 'annet', '1, 2, 3/mail/standard tilbud');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2021-03-05', NULL, 'annet', '1, 2, 3/mail/standard tilbud');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2021-03-25', NULL, 'annet', '1, 2, 3/mail/standard tilbud');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2021-10-18', NULL, 'annet', '1, 2, 3/mail/standard tilbud');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2022-01-31', NULL, 'annet', 'https://www.finn.no/job/fulltime/ad.html?finnkode=232792476');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2022-03-09', v_person_3, 'epost', 'oppfølgning');

    INSERT INTO public.contact_specialties (contact_id, specialty_id)
      SELECT v_contact_id, s.id FROM public.specialties s WHERE s.name IN ('Bygg', 'Anlegg')
      ON CONFLICT DO NOTHING;
  END IF;
END $$;

DO $$
DECLARE
  v_contact_id uuid;
  v_person_1 uuid;
BEGIN
  IF NOT EXISTS (SELECT 1 FROM public.contacts WHERE lower(company_name) = lower('Park - Anlegg')) THEN
    INSERT INTO public.contacts (company_name, phone, email, website, country, status)
      VALUES ('Park - Anlegg', '917 10 286', 'martin@park-anlegg.no', 'https://www.park-anlegg.no/', 'Norge', 'kontaktet')
      RETURNING id INTO v_contact_id;

    INSERT INTO public.contact_people (contact_id, full_name, phone, email, is_primary)
      VALUES (v_contact_id, 'Martin Karlsson', '917 10 286', 'martin@park-anlegg.no', true)
      RETURNING id INTO v_person_1;

    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2020-08-19', v_person_1, 'epost', 'hils');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2020-11-24', v_person_1, 'telefon', 'hils');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2021-01-06', v_person_1, 'epost', 'standard tilbud');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2021-02-23', v_person_1, 'epost', 'standard tilbud');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2021-03-05', v_person_1, 'epost', 'oppdatering');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2021-10-18', v_person_1, 'epost', 'oppdatering');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2022-03-09', v_person_1, 'epost', 'oppfølgning');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2024-01-04', v_person_1, 'epost', 'oppfølgning');

    INSERT INTO public.contact_specialties (contact_id, specialty_id)
      SELECT v_contact_id, s.id FROM public.specialties s WHERE s.name IN ('Anlegg')
      ON CONFLICT DO NOTHING;
  END IF;
END $$;

DO $$
DECLARE
  v_contact_id uuid;
  v_person_1 uuid;
  v_person_2 uuid;
BEGIN
  IF NOT EXISTS (SELECT 1 FROM public.contacts WHERE lower(company_name) = lower('Metacon AS')) THEN
    INSERT INTO public.contacts (company_name, phone, email, website, country, status)
      VALUES ('Metacon AS', '922 47 755', 'tony.ovrevik@metacon.no', 'https://www.metacon.no/', 'Norge', 'kontaktet')
      RETURNING id INTO v_contact_id;

    INSERT INTO public.contact_people (contact_id, full_name, phone, email, is_primary)
      VALUES (v_contact_id, 'Tony Øvrevik', '922 47 755', 'tony.ovrevik@metacon.no', true)
      RETURNING id INTO v_person_1;
    INSERT INTO public.contact_people (contact_id, full_name, phone, email, is_primary)
      VALUES (v_contact_id, 'Bjørn Arild Hansen', '46 44 52 40', 'bjorn.hansen@metacon.no', false)
      RETURNING id INTO v_person_2;

    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2020-08-21', NULL, 'annet', '1, 2/mail/standard tilbud');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, current_date, NULL, 'annet', '1, 2/mail/standard tilbud');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2021-03-05', NULL, 'annet', '1, 2/mail/oppdatering');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2022-03-09', NULL, 'annet', '1,2/mail/standard tilbud til ny daglig leder og markedssjef');

    INSERT INTO public.contact_specialties (contact_id, specialty_id)
      SELECT v_contact_id, s.id FROM public.specialties s WHERE s.name IN ('Stål Bygg')
      ON CONFLICT DO NOTHING;
  END IF;
END $$;

DO $$
DECLARE
  v_contact_id uuid;
  v_person_1 uuid;
  v_person_2 uuid;
BEGIN
  IF NOT EXISTS (SELECT 1 FROM public.contacts WHERE lower(company_name) = lower('Agro Anlegg AS')) THEN
    INSERT INTO public.contacts (company_name, phone, email, website, country, status)
      VALUES ('Agro Anlegg AS', '916 02 110', 'torerik@agroas.no', 'https://www.agroas.no/', 'Norge', 'kontaktet')
      RETURNING id INTO v_contact_id;

    INSERT INTO public.contact_people (contact_id, full_name, phone, email, is_primary)
      VALUES (v_contact_id, 'Tor Erik Staw', '916 02 110', 'torerik@agroas.no', true)
      RETURNING id INTO v_person_1;
    INSERT INTO public.contact_people (contact_id, full_name, phone, email, is_primary)
      VALUES (v_contact_id, 'Lasse Staw', '452 86 350', 'lasse.staw@agroas.no', false)
      RETURNING id INTO v_person_2;

    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2020-09-01', v_person_1, 'epost', 'hils');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2020-11-13', NULL, 'annet', '1, 2/mail/standard tilbud');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2020-11-03', NULL, 'annet', '1, 2/mail/standard tilbud');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2020-11-27', NULL, 'annet', '1, 2/mail/standard tilbud');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2020-11-30', NULL, 'annet', '1, 2/mail/Asker Kirkevien-Drammensveien');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2021-02-23', NULL, 'annet', '1, 2/mail/oppdatering');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2021-10-18', NULL, 'annet', '1, 2/mail/oppdatering');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2022-03-09', NULL, 'annet', '1,2/mail/oppfølgning');

    INSERT INTO public.contact_specialties (contact_id, specialty_id)
      SELECT v_contact_id, s.id FROM public.specialties s WHERE s.name IN ('Anlegg')
      ON CONFLICT DO NOTHING;
  END IF;
END $$;

DO $$
DECLARE
  v_contact_id uuid;
  v_person_1 uuid;
  v_person_2 uuid;
  v_person_3 uuid;
  v_person_4 uuid;
BEGIN
  IF NOT EXISTS (SELECT 1 FROM public.contacts WHERE lower(company_name) = lower('Isachsen Anlegg AS')) THEN
    INSERT INTO public.contacts (company_name, phone, email, website, country, status)
      VALUES ('Isachsen Anlegg AS', '943 33 333', 'espen.snipen@isachsenas.no', 'https://isachsenanlegg.no/', 'Norge', 'kontaktet')
      RETURNING id INTO v_contact_id;

    INSERT INTO public.contact_people (contact_id, full_name, phone, email, is_primary)
      VALUES (v_contact_id, 'Espen Snipen', '943 33 333', 'espen.snipen@isachsenas.no', true)
      RETURNING id INTO v_person_1;
    INSERT INTO public.contact_people (contact_id, full_name, phone, email, is_primary)
      VALUES (v_contact_id, 'Ole Terje Letmolie', '975 55 004', 'oleterje.letmolie@isachsenas.no', false)
      RETURNING id INTO v_person_2;
    INSERT INTO public.contact_people (contact_id, full_name, phone, email, is_primary)
      VALUES (v_contact_id, 'Ole Holth', NULL, 'ole.holth@isachsenas.no', false)
      RETURNING id INTO v_person_3;
    INSERT INTO public.contact_people (contact_id, full_name, phone, email, is_primary)
      VALUES (v_contact_id, 'Terje Kjetil Gillebo', '466 21 332', 'terje.gillebo@isachsenas.no', false)
      RETURNING id INTO v_person_4;

    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2020-09-01', NULL, 'annet', '1, 2/mail/hils');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2020-11-13', NULL, 'annet', '1, 2/mail/Asker Kirkevien-Drammensveien');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2020-11-27', NULL, 'annet', '1,2/mail, tel/standard tilbud');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2021-02-23', NULL, 'annet', '1,2/mail, tel/oppdatering');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2021-03-06', v_person_3, 'epost', 'standard tilbud');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2022-03-09', NULL, 'annet', '1,2,3/mail/oppfølgning');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2026-02-06', v_person_4, 'epost', 'oppdatering');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2026-03-10', v_person_4, 'epost', 'fasmerker');

    INSERT INTO public.contact_specialties (contact_id, specialty_id)
      SELECT v_contact_id, s.id FROM public.specialties s WHERE s.name IN ('Anlegg')
      ON CONFLICT DO NOTHING;
  END IF;
END $$;

DO $$
DECLARE
  v_contact_id uuid;
  v_person_1 uuid;
BEGIN
  IF NOT EXISTS (SELECT 1 FROM public.contacts WHERE lower(company_name) = lower('All Grunn')) THEN
    INSERT INTO public.contacts (company_name, phone, email, website, country, status)
      VALUES ('All Grunn', '45 41 18 01', 'jan-arne@allgrunn.no', 'https://www.allgrunn.no/kontakt', 'Norge', 'kontaktet')
      RETURNING id INTO v_contact_id;

    INSERT INTO public.contact_people (contact_id, full_name, phone, email, is_primary)
      VALUES (v_contact_id, 'Jan-Arne Svendsen', '45 41 18 01', 'jan-arne@allgrunn.no', true)
      RETURNING id INTO v_person_1;

    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2026-02-06', v_person_1, 'epost', 'oppdatering');

    INSERT INTO public.contact_specialties (contact_id, specialty_id)
      SELECT v_contact_id, s.id FROM public.specialties s WHERE s.name IN ('Anlegg', 'Tunnel', 'Masseutskifting')
      ON CONFLICT DO NOTHING;
  END IF;
END $$;

DO $$
DECLARE
  v_contact_id uuid;
  v_person_1 uuid;
  v_person_2 uuid;
  v_person_3 uuid;
BEGIN
  IF NOT EXISTS (SELECT 1 FROM public.contacts WHERE lower(company_name) = lower('NRC')) THEN
    INSERT INTO public.contacts (company_name, phone, email, website, country, status)
      VALUES ('NRC', '415 67 632', 'martin.olsen@nrcgroup.no', 'https://nrcgroup.no/', 'Norge', 'kontaktet')
      RETURNING id INTO v_contact_id;

    INSERT INTO public.contact_people (contact_id, full_name, phone, email, is_primary)
      VALUES (v_contact_id, 'Martin Olsen', '415 67 632', 'martin.olsen@nrcgroup.no', true)
      RETURNING id INTO v_person_1;
    INSERT INTO public.contact_people (contact_id, full_name, phone, email, is_primary)
      VALUES (v_contact_id, 'Stig Svendsen', '908 21 866', 'stig.svendsen@nrcgroup.no', false)
      RETURNING id INTO v_person_2;
    INSERT INTO public.contact_people (contact_id, full_name, phone, email, is_primary)
      VALUES (v_contact_id, 'Geir Nordbø', '908 79 160', 'geir.nordbo@nrcgroup.no', false)
      RETURNING id INTO v_person_3;

    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2020-08-26', NULL, 'annet', '1, 2/tel, mail/Kai Statnet Skien');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2020-09-03', NULL, 'annet', '1, 3/mail/oppdatering');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2020-10-28', NULL, 'annet', '1, 3/mail/standard tilbud');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2020-11-27', NULL, 'annet', '1, 3/mail/oppdatering');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2021-02-23', NULL, 'annet', '1, 3/mail/oppdatering');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2021-03-05', NULL, 'annet', '1, 3/mail/oppdatering');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2021-03-24', NULL, 'annet', '1, 3/mail/oppdatering');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2021-07-01', NULL, 'annet', '1, 3/mail/oppdatering');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2021-10-27', NULL, 'annet', '1, 3/mail/oppdatering');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2022-03-09', NULL, 'annet', '1,2,3/mail/oppfølgning');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2026-03-10', NULL, 'annet', '1,2,3/mail/oppdatering og fastmerker');

    INSERT INTO public.contact_specialties (contact_id, specialty_id)
      SELECT v_contact_id, s.id FROM public.specialties s WHERE s.name IN ('Anlegg', 'Bane')
      ON CONFLICT DO NOTHING;
  END IF;
END $$;

DO $$
DECLARE
  v_contact_id uuid;
  v_person_1 uuid;
  v_person_2 uuid;
BEGIN
  IF NOT EXISTS (SELECT 1 FROM public.contacts WHERE lower(company_name) = lower('Marthinsen & Duvholt')) THEN
    INSERT INTO public.contacts (company_name, phone, email, website, country, status)
      VALUES ('Marthinsen & Duvholt', '917 80 174', 'steinar@mogd.no', 'https://www.md.no/', 'Norge', 'kontaktet')
      RETURNING id INTO v_contact_id;

    INSERT INTO public.contact_people (contact_id, full_name, phone, email, is_primary)
      VALUES (v_contact_id, 'Steinar Langås', '917 80 174', 'steinar@mogd.no', true)
      RETURNING id INTO v_person_1;
    INSERT INTO public.contact_people (contact_id, full_name, phone, email, is_primary)
      VALUES (v_contact_id, 'Joacim Holte Sveberg', NULL, 'joacim.sveberg@mogd.no', false)
      RETURNING id INTO v_person_2;

    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2020-09-21', NULL, 'annet', '1, 2/mail/standard tilbud');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2020-10-23', NULL, 'annet', '1, 2/mail/rammeavtale tilbud');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2020-11-17', NULL, 'annet', '1, 2/tel./oppdatering');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2021-02-23', NULL, 'annet', '1, 2/mail/oppdatering');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2021-03-05', NULL, 'annet', '1, 2/mail/oppdatering');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2021-10-18', NULL, 'annet', '1, 2/mail/oppdatering');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2022-01-31', NULL, 'annet', 'https://www.finn.no/job/fulltime/ad.html?finnkode=242533275');

    INSERT INTO public.contact_specialties (contact_id, specialty_id)
      SELECT v_contact_id, s.id FROM public.specialties s WHERE s.name IN ('Anlegg', 'Bygg')
      ON CONFLICT DO NOTHING;
  END IF;
END $$;

DO $$
DECLARE
  v_contact_id uuid;
  v_person_1 uuid;
BEGIN
  IF NOT EXISTS (SELECT 1 FROM public.contacts WHERE lower(company_name) = lower('RailCom')) THEN
    INSERT INTO public.contacts (company_name, phone, email, website, country, status)
      VALUES ('RailCom', '904 02 705', 'knut.syversen@railcom.as', 'http://www.railcom.as/', 'Norge', 'kontaktet')
      RETURNING id INTO v_contact_id;

    INSERT INTO public.contact_people (contact_id, full_name, phone, email, is_primary)
      VALUES (v_contact_id, 'Knut Syversen', '904 02 705', 'knut.syversen@railcom.as', true)
      RETURNING id INTO v_person_1;

    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2020-10-21', v_person_1, 'epost', 'hils');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2020-11-27', v_person_1, 'epost', 'standard tilbud');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2021-02-23', v_person_1, 'epost', 'oppdatering');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2021-03-05', v_person_1, 'epost', 'oppdatering');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2021-10-19', v_person_1, 'epost', 'oppdatering');

    INSERT INTO public.contact_specialties (contact_id, specialty_id)
      SELECT v_contact_id, s.id FROM public.specialties s WHERE s.name IN ('Bane', 'Telekomunikasjon')
      ON CONFLICT DO NOTHING;
  END IF;
END $$;

DO $$
DECLARE
  v_contact_id uuid;
  v_person_1 uuid;
  v_person_2 uuid;
BEGIN
  IF NOT EXISTS (SELECT 1 FROM public.contacts WHERE lower(company_name) = lower('OHLA (OHL) Norge')) THEN
    INSERT INTO public.contacts (company_name, phone, email, website, country, status)
      VALUES ('OHLA (OHL) Norge', '401 80 588', 'kamel@ohlnorge.no', 'https://ohla-group.com/en/portfolio-item/epc-ski-contract-2/', 'Spania, Norge', 'kontaktet')
      RETURNING id INTO v_contact_id;

    INSERT INTO public.contact_people (contact_id, full_name, phone, email, is_primary)
      VALUES (v_contact_id, 'Kamel Choucair', '401 80 588', 'kamel@ohlnorge.no', true)
      RETURNING id INTO v_person_1;
    INSERT INTO public.contact_people (contact_id, full_name, phone, email, is_primary)
      VALUES (v_contact_id, 'Jeronimo Gutierrez', NULL, 'jeronimo.gutierrez@ohlnorge.no', false)
      RETURNING id INTO v_person_2;

    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2021-10-14', v_person_1, 'epost', 'Ny E18 forbi Posgrun');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2022-01-20', NULL, 'annet', '1, 2/besøk/Ny E18 Sandvika Asker');

    INSERT INTO public.contact_specialties (contact_id, specialty_id)
      SELECT v_contact_id, s.id FROM public.specialties s WHERE s.name IN ('Anlegg', 'Bane')
      ON CONFLICT DO NOTHING;
  END IF;
END $$;

DO $$
DECLARE
  v_contact_id uuid;
  v_person_1 uuid;
BEGIN
  IF NOT EXISTS (SELECT 1 FROM public.contacts WHERE lower(company_name) = lower('Strøm Gundersen AS')) THEN
    INSERT INTO public.contacts (company_name, phone, email, website, country, status)
      VALUES ('Strøm Gundersen AS', '401 00 223', 'atle.moller@stroemgundersen.no', 'http://www.stromgundersen.no/', 'Norge', 'kontaktet')
      RETURNING id INTO v_contact_id;

    INSERT INTO public.contact_people (contact_id, full_name, phone, email, is_primary)
      VALUES (v_contact_id, 'Atle Møller', '401 00 223', 'atle.moller@stroemgundersen.no', true)
      RETURNING id INTO v_person_1;

    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2020-10-21', v_person_1, 'epost', 'standard tilbud');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2020-11-27', v_person_1, 'epost', 'oppdatering');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2021-02-25', v_person_1, 'epost', 'oppdatering');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2021-03-05', v_person_1, 'epost', 'oppdatering');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2021-07-01', v_person_1, 'epost', 'oppdatering');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2021-10-27', v_person_1, 'epost', 'oppdatering');

    INSERT INTO public.contact_specialties (contact_id, specialty_id)
      SELECT v_contact_id, s.id FROM public.specialties s WHERE s.name IN ('Bygg', 'Anlegg')
      ON CONFLICT DO NOTHING;
  END IF;
END $$;

DO $$
DECLARE
  v_contact_id uuid;
  v_person_1 uuid;
  v_person_2 uuid;
BEGIN
  IF NOT EXISTS (SELECT 1 FROM public.contacts WHERE lower(company_name) = lower('BACKE Østfold, BACKE AS')) THEN
    INSERT INTO public.contacts (company_name, phone, email, website, country, status)
      VALUES ('BACKE Østfold, BACKE AS', '952 33 016', 'ines.haga@backe.no', 'https://backe.no/', 'Norge', 'kontaktet')
      RETURNING id INTO v_contact_id;

    INSERT INTO public.contact_people (contact_id, full_name, phone, email, is_primary)
      VALUES (v_contact_id, 'Ines Haga', '952 33 016', 'ines.haga@backe.no', true)
      RETURNING id INTO v_person_1;
    INSERT INTO public.contact_people (contact_id, full_name, phone, email, is_primary)
      VALUES (v_contact_id, 'Mårten Skållenås', NULL, 'marten.skallenas@backe.no', false)
      RETURNING id INTO v_person_2;

    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2020-10-21', v_person_1, 'epost', 'standard tilbud');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2020-10-22', v_person_1, 'epost', 'oppdatering');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2021-03-05', v_person_1, 'epost', 'oppdatering');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2021-03-24', v_person_1, 'epost', 'oppdatering');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2021-10-19', v_person_1, 'epost', 'oppdatering');

    INSERT INTO public.contact_specialties (contact_id, specialty_id)
      SELECT v_contact_id, s.id FROM public.specialties s WHERE s.name IN ('Bygg', 'Anlegg')
      ON CONFLICT DO NOTHING;
  END IF;
END $$;

DO $$
DECLARE
  v_contact_id uuid;
  v_person_1 uuid;
  v_person_2 uuid;
  v_person_3 uuid;
BEGIN
  IF NOT EXISTS (SELECT 1 FROM public.contacts WHERE lower(company_name) = lower('ANLEGG ØST')) THEN
    INSERT INTO public.contacts (company_name, phone, email, website, country, status)
      VALUES ('ANLEGG ØST', '995 18 611', 'jan.kvarberg@anlegg-ost.no', 'https://anlegg-ost.no/', 'Norge', 'kontaktet')
      RETURNING id INTO v_contact_id;

    INSERT INTO public.contact_people (contact_id, full_name, phone, email, is_primary)
      VALUES (v_contact_id, 'Jan Erik Kvarberg', '995 18 611', 'jan.kvarberg@anlegg-ost.no', true)
      RETURNING id INTO v_person_1;
    INSERT INTO public.contact_people (contact_id, full_name, phone, email, is_primary)
      VALUES (v_contact_id, 'Hans Bjørnstad', '468 93 304', 'hans@bga.no', false)
      RETURNING id INTO v_person_2;
    INSERT INTO public.contact_people (contact_id, full_name, phone, email, is_primary)
      VALUES (v_contact_id, 'Lisbet Lunde Gjermundshaug', '908 97 412', 'lisbeth@bga.no', false)
      RETURNING id INTO v_person_3;

    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2020-10-13', NULL, 'annet', '1, 2/mail/Bruer RV3 i Rendalen');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2020-11-27', NULL, 'annet', '1, 2/mail/standard tilbud');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2021-03-05', NULL, 'annet', '1, 2/mail/oppdatering');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2022-03-02', v_person_1, 'epost', 'svar: ønsker å ansette egne, tar kontakt ved behov');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2026-02-06', v_person_1, 'epost', 'oppdatering');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2026-03-10', v_person_1, 'epost', 'fastmerker');

    INSERT INTO public.contact_specialties (contact_id, specialty_id)
      SELECT v_contact_id, s.id FROM public.specialties s WHERE s.name IN ('Anlegg')
      ON CONFLICT DO NOTHING;
  END IF;
END $$;

DO $$
DECLARE
  v_contact_id uuid;
  v_person_1 uuid;
  v_person_2 uuid;
  v_person_3 uuid;
BEGIN
  IF NOT EXISTS (SELECT 1 FROM public.contacts WHERE lower(company_name) = lower('IMPLENIA Norge AS')) THEN
    INSERT INTO public.contacts (company_name, phone, email, website, country, status)
      VALUES ('IMPLENIA Norge AS', '478 53 848', 'marius.svendsen@implenia.com', 'https://implenia.com/no-no/', 'Norge', 'kontaktet')
      RETURNING id INTO v_contact_id;

    INSERT INTO public.contact_people (contact_id, full_name, phone, email, is_primary)
      VALUES (v_contact_id, 'Marius Skram Svendsen', '478 53 848', 'marius.svendsen@implenia.com', true)
      RETURNING id INTO v_person_1;
    INSERT INTO public.contact_people (contact_id, full_name, phone, email, is_primary)
      VALUES (v_contact_id, 'Ole Alexander Vanebo', '997 48 876', 'ole.vanebo@implenia.com', false)
      RETURNING id INTO v_person_2;
    INSERT INTO public.contact_people (contact_id, full_name, phone, email, is_primary)
      VALUES (v_contact_id, 'Terje Gilde', '906 65 128', 'terje.gilde@implenia.com', false)
      RETURNING id INTO v_person_3;

    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2020-08-18', NULL, 'annet', '1, 2/mail/standard tilbud');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2020-08-20', NULL, 'annet', '1, 2/mail/oppdatering');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2020-11-26', NULL, 'annet', '1, 2/mail/oppdatering');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2021-02-23', NULL, 'annet', '1, 2/mail/oppdatering');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2021-03-25', NULL, 'annet', '1, 2/mail/oppdatering');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2021-10-19', NULL, 'annet', '1, 2/mail/oppdatering');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2022-01-20', NULL, 'annet', '1, 2/mail/oppdatering - tunnel arbeid');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2022-01-31', NULL, 'annet', 'https://www.finn.no/job/fulltime/ad.html?finnkode=243988735');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2022-03-01', v_person_2, 'telefon', 'for mars ingen behov, ta kontakt igjen på slutten av mars');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2024-01-14', v_person_1, 'epost', 'oppdatering');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2026-03-10', v_person_3, 'epost', 'oppdatering og fastmerker');

    INSERT INTO public.contact_specialties (contact_id, specialty_id)
      SELECT v_contact_id, s.id FROM public.specialties s WHERE s.name IN ('Bygg', 'Anlegg')
      ON CONFLICT DO NOTHING;
  END IF;
END $$;

DO $$
DECLARE
  v_contact_id uuid;
  v_person_1 uuid;
  v_person_2 uuid;
BEGIN
  IF NOT EXISTS (SELECT 1 FROM public.contacts WHERE lower(company_name) = lower('HENT AS')) THEN
    INSERT INTO public.contacts (company_name, phone, email, website, country, status)
      VALUES ('HENT AS', '908 15 068', 'carl.thuresson@hent.no', 'https://www.hent.no/', 'Norge', 'kontaktet')
      RETURNING id INTO v_contact_id;

    INSERT INTO public.contact_people (contact_id, full_name, phone, email, is_primary)
      VALUES (v_contact_id, 'Carl Rasmus Thuresson', '908 15 068', 'carl.thuresson@hent.no', true)
      RETURNING id INTO v_person_1;
    INSERT INTO public.contact_people (contact_id, full_name, phone, email, is_primary)
      VALUES (v_contact_id, 'Pål Inge Larsen', '932 42 011', 'pal.inge.larsen@hent.no', false)
      RETURNING id INTO v_person_2;

    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2020-10-27', NULL, 'annet', '1, 2/mail/standard tilbud');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2020-11-01', NULL, 'annet', '1, 2/mail/wpis na liste kontrachentow');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2020-11-09', NULL, 'annet', '1, 2/mail/oppdatering');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2021-02-25', NULL, 'annet', '1, 2/mail/oppdatering');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2021-03-25', NULL, 'annet', '1, 2/mail/oppdatering');

    INSERT INTO public.contact_specialties (contact_id, specialty_id)
      SELECT v_contact_id, s.id FROM public.specialties s WHERE s.name IN ('Bygg', 'Anlegg')
      ON CONFLICT DO NOTHING;
  END IF;
END $$;

DO $$
DECLARE
  v_contact_id uuid;
  v_person_1 uuid;
  v_person_2 uuid;
BEGIN
  IF NOT EXISTS (SELECT 1 FROM public.contacts WHERE lower(company_name) = lower('Bygg & HytteService')) THEN
    INSERT INTO public.contacts (company_name, phone, email, website, country, status)
      VALUES ('Bygg & HytteService', '479 44 020', 'knut.brentebraaten@norhusnorge.no', 'https://www.byggoghytte.no/', 'Norge', 'kontaktet')
      RETURNING id INTO v_contact_id;

    INSERT INTO public.contact_people (contact_id, full_name, phone, email, is_primary)
      VALUES (v_contact_id, 'Knut Magnus Brentebråten', '479 44 020', 'knut.brentebraaten@norhusnorge.no', true)
      RETURNING id INTO v_person_1;
    INSERT INTO public.contact_people (contact_id, full_name, phone, email, is_primary)
      VALUES (v_contact_id, NULL, NULL, 'post@byggoghytte.no', false)
      RETURNING id INTO v_person_2;

    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2020-10-28', v_person_1, 'epost', 'standard tilbud');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2021-03-05', v_person_1, 'epost', 'oppdatering');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2021-07-01', v_person_1, 'epost', 'oppdatering');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2021-10-27', v_person_1, 'epost', 'oppdatering');

    INSERT INTO public.contact_specialties (contact_id, specialty_id)
      SELECT v_contact_id, s.id FROM public.specialties s WHERE s.name IN ('Bygg', 'Hytte')
      ON CONFLICT DO NOTHING;
  END IF;
END $$;

DO $$
DECLARE
  v_contact_id uuid;
  v_person_1 uuid;
  v_person_2 uuid;
  v_person_3 uuid;
BEGIN
  IF NOT EXISTS (SELECT 1 FROM public.contacts WHERE lower(company_name) = lower('VEIDEKKE ASA')) THEN
    INSERT INTO public.contacts (company_name, phone, email, website, country, status)
      VALUES ('VEIDEKKE ASA', NULL, 'melih.yasar@veidekke.no', 'http://veidekke.no/', 'Norge', 'kontaktet')
      RETURNING id INTO v_contact_id;

    INSERT INTO public.contact_people (contact_id, full_name, phone, email, is_primary)
      VALUES (v_contact_id, 'Melih Yasar', NULL, 'melih.yasar@veidekke.no', true)
      RETURNING id INTO v_person_1;
    INSERT INTO public.contact_people (contact_id, full_name, phone, email, is_primary)
      VALUES (v_contact_id, 'Frode Sjøen', '977 53 339', 'frode.sjoen@veidekke.no', false)
      RETURNING id INTO v_person_2;
    INSERT INTO public.contact_people (contact_id, full_name, phone, email, is_primary)
      VALUES (v_contact_id, 'Jan Steinar Stein', '996 34 741', 'jan.Stein@veidekke.no', false)
      RETURNING id INTO v_person_3;

    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2020-10-21', NULL, 'annet', '1, 2/mail/standard tilbud etter E6 leveranse');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2020-11-16', NULL, 'annet', '1, 2/mail/oppdatering');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2021-02-25', NULL, 'annet', '1, 2/mail/oppdatering');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2021-11-03', NULL, 'annet', '1, 2/mail/oppdatering');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2022-01-20', v_person_3, 'telefon', 'hils, oppdatering');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2024-01-14', v_person_1, 'epost', 'oppdatering');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2026-02-06', v_person_3, 'epost', 'oppdatering');

    INSERT INTO public.contact_specialties (contact_id, specialty_id)
      SELECT v_contact_id, s.id FROM public.specialties s WHERE s.name IN ('Bygg', 'Anlegg')
      ON CONFLICT DO NOTHING;
  END IF;
END $$;

DO $$
DECLARE
  v_contact_id uuid;
  v_person_1 uuid;
  v_person_2 uuid;
  v_person_3 uuid;
  v_person_4 uuid;
BEGIN
  IF NOT EXISTS (SELECT 1 FROM public.contacts WHERE lower(company_name) = lower('Hagen Maskin AS')) THEN
    INSERT INTO public.contacts (company_name, phone, email, website, country, status)
      VALUES ('Hagen Maskin AS', '951 54 315', 'Anders@hagen-maskin.no', 'https://hagen-maskin.no/', 'Norge', 'kontaktet')
      RETURNING id INTO v_contact_id;

    INSERT INTO public.contact_people (contact_id, full_name, phone, email, is_primary)
      VALUES (v_contact_id, 'Anders Hagen', '951 54 315', 'Anders@hagen-maskin.no', true)
      RETURNING id INTO v_person_1;
    INSERT INTO public.contact_people (contact_id, full_name, phone, email, is_primary)
      VALUES (v_contact_id, 'Steffen Brevig', '481 77 709', 'Steffen@hagen-maskin.no', false)
      RETURNING id INTO v_person_2;
    INSERT INTO public.contact_people (contact_id, full_name, phone, email, is_primary)
      VALUES (v_contact_id, 'Simen Fjellheim', '402 09 494', 'Simen@hagen-maskin.no', false)
      RETURNING id INTO v_person_3;
    INSERT INTO public.contact_people (contact_id, full_name, phone, email, is_primary)
      VALUES (v_contact_id, 'Morten Fjeld Viken', '327 93 274', 'Morten@hagen-maskin.no', false)
      RETURNING id INTO v_person_4;

    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2020-11-02', v_person_1, 'epost', 'standerd tilbud');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2020-11-25', NULL, 'annet', '1, 2, 3, 4/mail/standard tilbud');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2021-02-25', NULL, 'annet', '1, 2, 3, 4/mail/oppdatering');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2021-10-19', NULL, 'annet', '1, 2, 3, 4/mail/oppdatering');

    INSERT INTO public.contact_specialties (contact_id, specialty_id)
      SELECT v_contact_id, s.id FROM public.specialties s WHERE s.name IN ('Anlegg')
      ON CONFLICT DO NOTHING;
  END IF;
END $$;

DO $$
DECLARE
  v_contact_id uuid;
  v_person_1 uuid;
  v_person_2 uuid;
  v_person_3 uuid;
  v_person_4 uuid;
  v_person_5 uuid;
  v_person_6 uuid;
  v_person_7 uuid;
BEGIN
  IF NOT EXISTS (SELECT 1 FROM public.contacts WHERE lower(company_name) = lower('ASKER Entreprenør Ø.M. FJELD')) THEN
    INSERT INTO public.contacts (company_name, phone, email, website, country, status)
      VALUES ('ASKER Entreprenør Ø.M. FJELD', '915 39 848‬', 'kbk@omfjeld.no', 'https://omfjeld.no/', 'Norge', 'kontaktet')
      RETURNING id INTO v_contact_id;

    INSERT INTO public.contact_people (contact_id, full_name, phone, email, is_primary)
      VALUES (v_contact_id, 'Kjell Bjarte Kvinge', '915 39 848‬', 'kbk@omfjeld.no', true)
      RETURNING id INTO v_person_1;
    INSERT INTO public.contact_people (contact_id, full_name, phone, email, is_primary)
      VALUES (v_contact_id, 'Stian Lauvålien', '951 51 373', 'stla@omfjeld.no', false)
      RETURNING id INTO v_person_2;
    INSERT INTO public.contact_people (contact_id, full_name, phone, email, is_primary)
      VALUES (v_contact_id, 'Lars Christian Stømner', '404 29 127', 'last@omfjeld.no', false)
      RETURNING id INTO v_person_3;
    INSERT INTO public.contact_people (contact_id, full_name, phone, email, is_primary)
      VALUES (v_contact_id, 'Ole Martin Bjerke', '404 29 102', 'olbj@omfjeld.no', false)
      RETURNING id INTO v_person_4;
    INSERT INTO public.contact_people (contact_id, full_name, phone, email, is_primary)
      VALUES (v_contact_id, 'Ole Johan Krog', '459 06 813', 'olkr@omfjeld.no', false)
      RETURNING id INTO v_person_5;
    INSERT INTO public.contact_people (contact_id, full_name, phone, email, is_primary)
      VALUES (v_contact_id, 'Øyvind Velsand', '412 77 988', 'ov@asent.no', false)
      RETURNING id INTO v_person_6;
    INSERT INTO public.contact_people (contact_id, full_name, phone, email, is_primary)
      VALUES (v_contact_id, 'Trond Berget-Ausland', '404 29 127', 'tba@asent.no', false)
      RETURNING id INTO v_person_7;

    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2020-11-02', NULL, 'annet', '1-7/mail/standard tilbud');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2020-11-27', NULL, 'annet', '1-7/mail/oppdatering');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2020-11-30', NULL, 'annet', '1-7/mail/oppdatering');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2020-12-09', NULL, 'annet', '1-7/mail/oppdatering');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2021-01-29', NULL, 'annet', '1-7/mail/oppdatering');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2021-02-18', NULL, 'annet', '1-7/mail/oppdatering');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2021-02-25', NULL, 'annet', '1-7/mail/oppdatering');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2021-03-05', NULL, 'annet', '1-7/mail/oppdatering');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2021-03-12', NULL, 'annet', '1-7/mail/oppdatering');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2021-10-19', NULL, 'annet', '1-7/mail/oppdatering');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2022-01-20', NULL, 'annet', '1-7/mail/oppdatering');

    INSERT INTO public.contact_specialties (contact_id, specialty_id)
      SELECT v_contact_id, s.id FROM public.specialties s WHERE s.name IN ('Bygg', 'Anlegg')
      ON CONFLICT DO NOTHING;
  END IF;
END $$;

DO $$
DECLARE
  v_contact_id uuid;
  v_person_1 uuid;
BEGIN
  IF NOT EXISTS (SELECT 1 FROM public.contacts WHERE lower(company_name) = lower('INSENTI')) THEN
    INSERT INTO public.contacts (company_name, phone, email, website, country, status)
      VALUES ('INSENTI', NULL, 'karoline.hasselgard@insenti.no', 'https://insenti.no/', 'Norge', 'kontaktet')
      RETURNING id INTO v_contact_id;

    INSERT INTO public.contact_people (contact_id, full_name, phone, email, is_primary)
      VALUES (v_contact_id, 'Karoline Hasselgård', NULL, 'karoline.hasselgard@insenti.no', true)
      RETURNING id INTO v_person_1;

    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2020-11-04', v_person_1, 'epost', 'standard tilbud');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2020-11-27', v_person_1, 'epost', 'oppdatering');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2021-02-25', v_person_1, 'epost', 'oppdatering');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2021-03-05', v_person_1, 'epost', 'oppdatering');

    INSERT INTO public.contact_specialties (contact_id, specialty_id)
      SELECT v_contact_id, s.id FROM public.specialties s WHERE s.name IN ('Bygg')
      ON CONFLICT DO NOTHING;
  END IF;
END $$;

DO $$
DECLARE
  v_contact_id uuid;
  v_person_1 uuid;
BEGIN
  IF NOT EXISTS (SELECT 1 FROM public.contacts WHERE lower(company_name) = lower('Steen & Lund AGAIA')) THEN
    INSERT INTO public.contacts (company_name, phone, email, website, country, status)
      VALUES ('Steen & Lund AGAIA', NULL, 'fridtjof.myhrene@steen-lund.no', 'https://www.agaia.no/', 'Norge', 'kontaktet')
      RETURNING id INTO v_contact_id;

    INSERT INTO public.contact_people (contact_id, full_name, phone, email, is_primary)
      VALUES (v_contact_id, 'Fridtjof Myhrene', NULL, 'fridtjof.myhrene@steen-lund.no', true)
      RETURNING id INTO v_person_1;

    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2020-11-04', v_person_1, 'epost', 'standard tilbud');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2020-11-27', v_person_1, 'epost', 'oppdatering');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2021-02-25', v_person_1, 'epost', 'oppdatering');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2021-03-05', v_person_1, 'epost', 'oppdatering');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2021-10-19', v_person_1, 'epost', 'oppdatering');

    INSERT INTO public.contact_specialties (contact_id, specialty_id)
      SELECT v_contact_id, s.id FROM public.specialties s WHERE s.name IN ('Anlegg', 'Landskap', 'Gartner')
      ON CONFLICT DO NOTHING;
  END IF;
END $$;

DO $$
DECLARE
  v_contact_id uuid;
  v_person_1 uuid;
BEGIN
  IF NOT EXISTS (SELECT 1 FROM public.contacts WHERE lower(company_name) = lower('Øst byggentreprenør')) THEN
    INSERT INTO public.contacts (company_name, phone, email, website, country, status)
      VALUES ('Øst byggentreprenør', NULL, 'ragnar@ost.as', 'https://www.ost.as/', 'Norge', 'kontaktet')
      RETURNING id INTO v_contact_id;

    INSERT INTO public.contact_people (contact_id, full_name, phone, email, is_primary)
      VALUES (v_contact_id, 'Ragnar Jensen', NULL, 'ragnar@ost.as', true)
      RETURNING id INTO v_person_1;

    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2020-11-04', v_person_1, 'epost', 'standard tilbud');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2020-11-27', v_person_1, 'epost', 'oppdatering');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2021-02-25', v_person_1, 'epost', 'oppdatering');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2021-03-05', v_person_1, 'epost', 'oppdatering');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2021-10-19', v_person_1, 'epost', 'oppdatering');

    INSERT INTO public.contact_specialties (contact_id, specialty_id)
      SELECT v_contact_id, s.id FROM public.specialties s WHERE s.name IN ('Bygg', 'Anlegg', 'Energi')
      ON CONFLICT DO NOTHING;
  END IF;
END $$;

DO $$
DECLARE
  v_contact_id uuid;
  v_person_1 uuid;
  v_person_2 uuid;
  v_person_3 uuid;
BEGIN
  IF NOT EXISTS (SELECT 1 FROM public.contacts WHERE lower(company_name) = lower('Baneservice')) THEN
    INSERT INTO public.contacts (company_name, phone, email, website, country, status)
      VALUES ('Baneservice', NULL, 'bsk@baneservice.no', 'https://baneservice.no/', 'Norge', 'kontaktet')
      RETURNING id INTO v_contact_id;

    INSERT INTO public.contact_people (contact_id, full_name, phone, email, is_primary)
      VALUES (v_contact_id, 'Bjørn Skaudal', NULL, 'bsk@baneservice.no', true)
      RETURNING id INTO v_person_1;
    INSERT INTO public.contact_people (contact_id, full_name, phone, email, is_primary)
      VALUES (v_contact_id, 'Daniel Hatcher', NULL, 'dha@baneservice.no', false)
      RETURNING id INTO v_person_2;
    INSERT INTO public.contact_people (contact_id, full_name, phone, email, is_primary)
      VALUES (v_contact_id, 'Emma Maurud', NULL, 'maurud@baneservice.no', false)
      RETURNING id INTO v_person_3;

    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2020-11-05', NULL, 'annet', '1, 2, 3/mail/standard tilbud');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2020-11-27', NULL, 'annet', '1, 2, 3/mail/oppdatering');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2021-02-25', NULL, 'annet', '1, 2, 3/mail/oppdatering');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2021-03-05', NULL, 'annet', '1, 2, 3/mail/oppdatering');

    INSERT INTO public.contact_specialties (contact_id, specialty_id)
      SELECT v_contact_id, s.id FROM public.specialties s WHERE s.name IN ('Anlegg', 'Bane')
      ON CONFLICT DO NOTHING;
  END IF;
END $$;

DO $$
DECLARE
  v_contact_id uuid;
  v_person_1 uuid;
BEGIN
  IF NOT EXISTS (SELECT 1 FROM public.contacts WHERE lower(company_name) = lower('Topaas og Haug')) THEN
    INSERT INTO public.contacts (company_name, phone, email, website, country, status)
      VALUES ('Topaas og Haug', '900 46 473', 'joar@topaasoghaug.no', 'https://topaasoghaug.no/', 'Norge', 'kontaktet')
      RETURNING id INTO v_contact_id;

    INSERT INTO public.contact_people (contact_id, full_name, phone, email, is_primary)
      VALUES (v_contact_id, 'Joar Baartvedt Olsen', '900 46 473', 'joar@topaasoghaug.no', true)
      RETURNING id INTO v_person_1;

    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2020-11-05', v_person_1, 'epost', 'standard tilbud');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2020-11-27', v_person_1, 'epost', 'oppdatering');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2021-02-25', v_person_1, 'epost', 'oppdatering');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2021-03-05', v_person_1, 'epost', 'oppdatering');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2021-07-01', v_person_1, 'epost', 'oppdatering');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2021-10-27', v_person_1, 'epost', 'oppdatering');

    INSERT INTO public.contact_specialties (contact_id, specialty_id)
      SELECT v_contact_id, s.id FROM public.specialties s WHERE s.name IN ('Anlegg')
      ON CONFLICT DO NOTHING;
  END IF;
END $$;

DO $$
DECLARE
  v_contact_id uuid;
  v_person_1 uuid;
BEGIN
  IF NOT EXISTS (SELECT 1 FROM public.contacts WHERE lower(company_name) = lower('Bundebygg')) THEN
    INSERT INTO public.contacts (company_name, phone, email, website, country, status)
      VALUES ('Bundebygg', '905 94 085', 'aksel.ruden@bundebygg.no', 'https://www.bundegruppen.no/', 'Norge', 'kontaktet')
      RETURNING id INTO v_contact_id;

    INSERT INTO public.contact_people (contact_id, full_name, phone, email, is_primary)
      VALUES (v_contact_id, 'Aksel Ruden', '905 94 085', 'aksel.ruden@bundebygg.no', true)
      RETURNING id INTO v_person_1;

    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2020-11-05', v_person_1, 'epost', 'standard tilbud');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2020-11-27', v_person_1, 'epost', 'oppdatering');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2021-02-25', v_person_1, 'epost', 'oppdatering');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2021-03-05', v_person_1, 'epost', 'oppdatering');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2021-07-01', v_person_1, 'epost', 'oppdatering');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2021-10-27', v_person_1, 'epost', 'oppdatering');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2022-01-20', v_person_1, 'epost', 'oppdatering');

    INSERT INTO public.contact_specialties (contact_id, specialty_id)
      SELECT v_contact_id, s.id FROM public.specialties s WHERE s.name IN ('Bygg')
      ON CONFLICT DO NOTHING;
  END IF;
END $$;

DO $$
DECLARE
  v_contact_id uuid;
  v_person_1 uuid;
  v_person_2 uuid;
BEGIN
  IF NOT EXISTS (SELECT 1 FROM public.contacts WHERE lower(company_name) = lower('Askim Entreprenør')) THEN
    INSERT INTO public.contacts (company_name, phone, email, website, country, status)
      VALUES ('Askim Entreprenør', '99 03 91 03', 'simen@askimentreprenor.no', 'https://www.askimentreprenor.no/', 'Norge', 'kontaktet')
      RETURNING id INTO v_contact_id;

    INSERT INTO public.contact_people (contact_id, full_name, phone, email, is_primary)
      VALUES (v_contact_id, 'Simen Berg Klemmetsen', '99 03 91 03', 'simen@askimentreprenor.no', true)
      RETURNING id INTO v_person_1;
    INSERT INTO public.contact_people (contact_id, full_name, phone, email, is_primary)
      VALUES (v_contact_id, 'Hans Lundgård Ekeren', NULL, 'hans@askimentreprenor.no', false)
      RETURNING id INTO v_person_2;

    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2020-11-05', NULL, 'annet', '1, 2/mail/standard tilbud');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2020-11-27', NULL, 'annet', '1, 2/mail/oppdatering');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2021-02-25', NULL, 'annet', '1, 2/mail/oppdatering');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2021-03-05', NULL, 'annet', '1, 2/mail/oppdatering');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2021-10-19', NULL, 'annet', '1, 2/mail/oppdatering');

    INSERT INTO public.contact_specialties (contact_id, specialty_id)
      SELECT v_contact_id, s.id FROM public.specialties s WHERE s.name IN ('Anlegg', 'Bygg')
      ON CONFLICT DO NOTHING;
  END IF;
END $$;

DO $$
DECLARE
  v_contact_id uuid;
  v_person_1 uuid;
  v_person_2 uuid;
BEGIN
  IF NOT EXISTS (SELECT 1 FROM public.contacts WHERE lower(company_name) = lower('Con-Form')) THEN
    INSERT INTO public.contacts (company_name, phone, email, website, country, status)
      VALUES ('Con-Form', NULL, 'erik.sanni@con-form.no', 'https://www.con-form.no/', 'Norge', 'kontaktet')
      RETURNING id INTO v_contact_id;

    INSERT INTO public.contact_people (contact_id, full_name, phone, email, is_primary)
      VALUES (v_contact_id, 'Erik Sanni', NULL, 'erik.sanni@con-form.no', true)
      RETURNING id INTO v_person_1;
    INSERT INTO public.contact_people (contact_id, full_name, phone, email, is_primary)
      VALUES (v_contact_id, 'Reuben Johnson', NULL, 'reuben.johnson@con-form.no', false)
      RETURNING id INTO v_person_2;

    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2020-11-05', NULL, 'annet', '1, 2/mail/standard tilbud');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2020-11-27', NULL, 'annet', '1, 2/mail/oppdatering');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2020-11-27', NULL, 'annet', '1, 2/mail/oppdatering');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2021-02-25', NULL, 'annet', '1, 2/mail/oppdatering');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2021-03-05', NULL, 'annet', '1, 2/mail/oppdatering');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2021-07-01', NULL, 'annet', '1, 2/mail/oppdatering');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2021-10-27', NULL, 'annet', '1, 2/mail/oppdatering');

    INSERT INTO public.contact_specialties (contact_id, specialty_id)
      SELECT v_contact_id, s.id FROM public.specialties s WHERE s.name IN ('Bygg')
      ON CONFLICT DO NOTHING;
  END IF;
END $$;

DO $$
DECLARE
  v_contact_id uuid;
  v_person_1 uuid;
  v_person_2 uuid;
BEGIN
  IF NOT EXISTS (SELECT 1 FROM public.contacts WHERE lower(company_name) = lower('Norconsult')) THEN
    INSERT INTO public.contacts (company_name, phone, email, website, country, status)
      VALUES ('Norconsult', '406 29 260', 'hogne.opperud@norconsult.com', 'https://www.norconsult.no/', 'Norge', 'kontaktet')
      RETURNING id INTO v_contact_id;

    INSERT INTO public.contact_people (contact_id, full_name, phone, email, is_primary)
      VALUES (v_contact_id, 'Hogne Opperud', '406 29 260', 'hogne.opperud@norconsult.com', true)
      RETURNING id INTO v_person_1;
    INSERT INTO public.contact_people (contact_id, full_name, phone, email, is_primary)
      VALUES (v_contact_id, 'Ida Karoline Andresen', '915 34 778', 'ida.karoline.andresen@norconsult.com', false)
      RETURNING id INTO v_person_2;

    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2020-11-09', NULL, 'annet', '1, 2/mail/standard tilbud');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2020-11-27', NULL, 'annet', '1, 2/mail/oppdatering');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2021-02-25', NULL, 'annet', '1, 2/mail/oppdatering');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2021-03-05', NULL, 'annet', '1, 2/mail/oppdatering');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2021-07-01', NULL, 'annet', '1, 2/mail/oppdatering');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2021-10-27', NULL, 'annet', '1, 2/mail/oppdatering');

    INSERT INTO public.contact_specialties (contact_id, specialty_id)
      SELECT v_contact_id, s.id FROM public.specialties s WHERE s.name IN ('Konsulent', 'Bygg', 'Anlegg')
      ON CONFLICT DO NOTHING;
  END IF;
END $$;

DO $$
DECLARE
  v_contact_id uuid;
  v_person_1 uuid;
BEGIN
  IF NOT EXISTS (SELECT 1 FROM public.contacts WHERE lower(company_name) = lower('Råbygg AS')) THEN
    INSERT INTO public.contacts (company_name, phone, email, website, country, status)
      VALUES ('Råbygg AS', '484 03 025', 'jarle.haugo@rabygg.as', 'https://rabygg.as/', 'Norge', 'kontaktet')
      RETURNING id INTO v_contact_id;

    INSERT INTO public.contact_people (contact_id, full_name, phone, email, is_primary)
      VALUES (v_contact_id, 'Jarle Haugo', '484 03 025', 'jarle.haugo@rabygg.as', true)
      RETURNING id INTO v_person_1;

    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2020-11-09', v_person_1, 'epost', 'standard tilbud');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2020-11-27', v_person_1, 'epost', 'oppdatering');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2021-02-25', v_person_1, 'epost', 'oppdatering');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2021-03-05', v_person_1, 'epost', 'oppdatering');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2021-07-01', v_person_1, 'epost', 'oppdatering');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2021-10-27', v_person_1, 'epost', 'oppdatering');

    INSERT INTO public.contact_specialties (contact_id, specialty_id)
      SELECT v_contact_id, s.id FROM public.specialties s WHERE s.name IN ('Bygg')
      ON CONFLICT DO NOTHING;
  END IF;
END $$;

DO $$
DECLARE
  v_contact_id uuid;
  v_person_1 uuid;
  v_person_2 uuid;
  v_person_3 uuid;
BEGIN
  IF NOT EXISTS (SELECT 1 FROM public.contacts WHERE lower(company_name) = lower('GEO fundamentering & berboring AS')) THEN
    INSERT INTO public.contacts (company_name, phone, email, website, country, status)
      VALUES ('GEO fundamentering & berboring AS', '917 09 105', 'geir.berntsen@kynningsrud.no', 'https://geofb.no/', 'Norge', 'kontaktet')
      RETURNING id INTO v_contact_id;

    INSERT INTO public.contact_people (contact_id, full_name, phone, email, is_primary)
      VALUES (v_contact_id, 'Geir Berntsen', '917 09 105', 'geir.berntsen@kynningsrud.no', true)
      RETURNING id INTO v_person_1;
    INSERT INTO public.contact_people (contact_id, full_name, phone, email, is_primary)
      VALUES (v_contact_id, 'Anders Haaland', '901 28 720', 'anders.haaland@geofb.no', false)
      RETURNING id INTO v_person_2;
    INSERT INTO public.contact_people (contact_id, full_name, phone, email, is_primary)
      VALUES (v_contact_id, 'Erling Omre', '905 40 869', 'erling.omre@geofb.no', false)
      RETURNING id INTO v_person_3;

    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2020-11-09', v_person_1, 'epost', 'standard tilbud');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2020-11-27', v_person_1, 'epost', 'oppdatering');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2021-02-25', v_person_1, 'epost', 'oppdatering');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2021-03-05', v_person_1, 'epost', 'oppdatering');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2021-07-01', v_person_1, 'epost', 'oppdatering');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2021-10-27', v_person_1, 'epost', 'oppdatering');

    INSERT INTO public.contact_specialties (contact_id, specialty_id)
      SELECT v_contact_id, s.id FROM public.specialties s WHERE s.name IN ('Anlegg')
      ON CONFLICT DO NOTHING;
  END IF;
END $$;

DO $$
DECLARE
  v_contact_id uuid;
  v_person_1 uuid;
  v_person_2 uuid;
BEGIN
  IF NOT EXISTS (SELECT 1 FROM public.contacts WHERE lower(company_name) = lower('Vassbakk & Stol AS')) THEN
    INSERT INTO public.contacts (company_name, phone, email, website, country, status)
      VALUES ('Vassbakk & Stol AS', '406 45 082', 'dina-elise.oftedal@vassbakk.no', 'https://vassbakk.no/', 'Norge', 'kontaktet')
      RETURNING id INTO v_contact_id;

    INSERT INTO public.contact_people (contact_id, full_name, phone, email, is_primary)
      VALUES (v_contact_id, 'Dina Elise Oftedal', '406 45 082', 'dina-elise.oftedal@vassbakk.no', true)
      RETURNING id INTO v_person_1;
    INSERT INTO public.contact_people (contact_id, full_name, phone, email, is_primary)
      VALUES (v_contact_id, 'Stein Helge Trohaug', '908 81 229', 'stein.helge.trohaug@vassbakk.no', false)
      RETURNING id INTO v_person_2;

    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2020-11-12', v_person_1, 'epost', 'standard tilbud');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2020-11-13', v_person_1, 'epost', 'Fv 635 Helgøy-Mosens');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2020-11-30', v_person_1, 'epost', 'oppdatering');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2021-02-26', v_person_1, 'epost', 'oppdatering');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2021-07-01', v_person_1, 'epost', 'oppdatering');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2021-10-28', v_person_1, 'epost', 'oppdatering');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2024-01-04', v_person_1, 'epost', 'oppdatering');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2026-02-06', v_person_1, 'epost', 'oppdatering');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2026-03-10', v_person_2, 'epost', 'fastmerker');

    INSERT INTO public.contact_specialties (contact_id, specialty_id)
      SELECT v_contact_id, s.id FROM public.specialties s WHERE s.name IN ('Anlegg', 'Kai')
      ON CONFLICT DO NOTHING;
  END IF;
END $$;

DO $$
DECLARE
  v_contact_id uuid;
  v_person_1 uuid;
  v_person_2 uuid;
  v_person_3 uuid;
BEGIN
  IF NOT EXISTS (SELECT 1 FROM public.contacts WHERE lower(company_name) = lower('Hitra Anleggservice AS')) THEN
    INSERT INTO public.contacts (company_name, phone, email, website, country, status)
      VALUES ('Hitra Anleggservice AS', '469 16 202', 'tor.magne@hitraanleggservice.no', 'https://www.hitra-anleggservice.no/', 'Norge', 'kontaktet')
      RETURNING id INTO v_contact_id;

    INSERT INTO public.contact_people (contact_id, full_name, phone, email, is_primary)
      VALUES (v_contact_id, 'Tor Magne Langø', '469 16 202', 'tor.magne@hitraanleggservice.no', true)
      RETURNING id INTO v_person_1;
    INSERT INTO public.contact_people (contact_id, full_name, phone, email, is_primary)
      VALUES (v_contact_id, 'Anders Glørstad', '976 46 863', 'anders@hitraanleggservice.no', false)
      RETURNING id INTO v_person_2;
    INSERT INTO public.contact_people (contact_id, full_name, phone, email, is_primary)
      VALUES (v_contact_id, 'Sindre Kvakland', '478 41 933', 'sindre@hitraanleggservice.no', false)
      RETURNING id INTO v_person_3;

    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2020-11-12', NULL, 'annet', '1, 2/mail/standard tilbud');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2020-11-13', NULL, 'annet', '1, 2/mail/oppdatering');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2020-11-30', NULL, 'annet', '1, 2/mail/oppdatering');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2021-02-26', NULL, 'annet', '1, 2/mail/oppdatering');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2021-07-01', NULL, 'annet', '1, 2/mail/oppdatering');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2021-10-28', NULL, 'annet', '1, 2/mail/oppdatering');

    INSERT INTO public.contact_specialties (contact_id, specialty_id)
      SELECT v_contact_id, s.id FROM public.specialties s WHERE s.name IN ('Anlegg')
      ON CONFLICT DO NOTHING;
  END IF;
END $$;

DO $$
DECLARE
  v_contact_id uuid;
  v_person_1 uuid;
BEGIN
  IF NOT EXISTS (SELECT 1 FROM public.contacts WHERE lower(company_name) = lower('Hæhre, HI gruppen AS')) THEN
    INSERT INTO public.contacts (company_name, phone, email, website, country, status)
      VALUES ('Hæhre, HI gruppen AS', '488 98 486', 'tor.kleiven@akh.no', 'https://hi-gruppen.no/', 'Norge', 'kontaktet')
      RETURNING id INTO v_contact_id;

    INSERT INTO public.contact_people (contact_id, full_name, phone, email, is_primary)
      VALUES (v_contact_id, 'Tor Kleiven', '488 98 486', 'tor.kleiven@akh.no', true)
      RETURNING id INTO v_person_1;

    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2020-11-18', v_person_1, 'epost', 'standard tilbud');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2020-11-30', v_person_1, 'epost', 'oppdatering');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2021-02-26', v_person_1, 'epost', 'oppdatering');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2021-07-01', v_person_1, 'epost', 'oppdatering');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2021-10-28', v_person_1, 'epost', 'oppdatering');

    INSERT INTO public.contact_specialties (contact_id, specialty_id)
      SELECT v_contact_id, s.id FROM public.specialties s WHERE s.name IN ('Bygg', 'Anlegg')
      ON CONFLICT DO NOTHING;
  END IF;
END $$;

DO $$
DECLARE
  v_contact_id uuid;
  v_person_1 uuid;
BEGIN
  IF NOT EXISTS (SELECT 1 FROM public.contacts WHERE lower(company_name) = lower('R3 Entreprenør AS')) THEN
    INSERT INTO public.contacts (company_name, phone, email, website, country, status)
      VALUES ('R3 Entreprenør AS', '982 82 344', 'thorleif@r3.no', 'https://r3.no/', 'Norge', 'kontaktet')
      RETURNING id INTO v_contact_id;

    INSERT INTO public.contact_people (contact_id, full_name, phone, email, is_primary)
      VALUES (v_contact_id, 'Thorleif Østmoe', '982 82 344', 'thorleif@r3.no', true)
      RETURNING id INTO v_person_1;

    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2020-11-18', v_person_1, 'epost', 'standard tilbud');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2020-11-30', v_person_1, 'epost', 'oppdatering');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2021-02-26', v_person_1, 'epost', 'oppdatering');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2021-03-12', v_person_1, 'epost', 'oppdatering');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2021-07-01', v_person_1, 'epost', 'oppdatering');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2021-10-28', v_person_1, 'epost', 'oppdatering');

    INSERT INTO public.contact_specialties (contact_id, specialty_id)
      SELECT v_contact_id, s.id FROM public.specialties s WHERE s.name IN ('Bygg', 'Riving')
      ON CONFLICT DO NOTHING;
  END IF;
END $$;

DO $$
DECLARE
  v_contact_id uuid;
  v_person_1 uuid;
BEGIN
  IF NOT EXISTS (SELECT 1 FROM public.contacts WHERE lower(company_name) = lower('Øst-Riv')) THEN
    INSERT INTO public.contacts (company_name, phone, email, website, country, status)
      VALUES ('Øst-Riv', '920 44 302', 'thomas@ost-riv.no', 'https://ost-riv.no/', 'Norge', 'kontaktet')
      RETURNING id INTO v_contact_id;

    INSERT INTO public.contact_people (contact_id, full_name, phone, email, is_primary)
      VALUES (v_contact_id, 'Thomas Lindseth', '920 44 302', 'thomas@ost-riv.no', true)
      RETURNING id INTO v_person_1;

    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2020-11-18', v_person_1, 'epost', 'standard tilbud');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2020-11-30', v_person_1, 'epost', 'oppdatering');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2021-02-26', v_person_1, 'epost', 'oppdatering');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2021-03-12', v_person_1, 'epost', 'oppdatering');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2021-07-01', v_person_1, 'epost', 'oppdatering');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2021-10-28', v_person_1, 'epost', 'oppdatering');

    INSERT INTO public.contact_specialties (contact_id, specialty_id)
      SELECT v_contact_id, s.id FROM public.specialties s WHERE s.name IN ('Bygg', 'Riving')
      ON CONFLICT DO NOTHING;
  END IF;
END $$;

DO $$
DECLARE
  v_contact_id uuid;
  v_person_1 uuid;
BEGIN
  IF NOT EXISTS (SELECT 1 FROM public.contacts WHERE lower(company_name) = lower('Hersleth Entreprenør AS')) THEN
    INSERT INTO public.contacts (company_name, phone, email, website, country, status)
      VALUES ('Hersleth Entreprenør AS', NULL, 'post@hersleth.no', 'https://www.hersleth.no/', 'Norge', 'kontaktet')
      RETURNING id INTO v_contact_id;

    INSERT INTO public.contact_people (contact_id, full_name, phone, email, is_primary)
      VALUES (v_contact_id, 'Reinert Hersleth', NULL, 'post@hersleth.no', true)
      RETURNING id INTO v_person_1;

    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2020-11-18', v_person_1, 'epost', 'standard tilbud');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, current_date, v_person_1, 'epost', 'oppdatering');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2021-02-26', v_person_1, 'epost', 'oppdatering');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2021-03-12', v_person_1, 'epost', 'oppdatering');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2021-07-01', v_person_1, 'epost', 'oppdatering');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2021-10-28', v_person_1, 'epost', 'oppdatering');

    INSERT INTO public.contact_specialties (contact_id, specialty_id)
      SELECT v_contact_id, s.id FROM public.specialties s WHERE s.name IN ('Bygg')
      ON CONFLICT DO NOTHING;
  END IF;
END $$;

DO $$
DECLARE
  v_contact_id uuid;
  v_person_1 uuid;
  v_person_2 uuid;
BEGIN
  IF NOT EXISTS (SELECT 1 FROM public.contacts WHERE lower(company_name) = lower('Sør-Norsk Boring')) THEN
    INSERT INTO public.contacts (company_name, phone, email, website, country, status)
      VALUES ('Sør-Norsk Boring', '918 35 168', 'lars@boring.no', 'https://www.boring.no/', 'Norge', 'kontaktet')
      RETURNING id INTO v_contact_id;

    INSERT INTO public.contact_people (contact_id, full_name, phone, email, is_primary)
      VALUES (v_contact_id, 'Lars Oddvar Aulesjord', '918 35 168', 'lars@boring.no', true)
      RETURNING id INTO v_person_1;
    INSERT INTO public.contact_people (contact_id, full_name, phone, email, is_primary)
      VALUES (v_contact_id, 'Ståle Bærland', '971 85 707', 'staale@boring.no', false)
      RETURNING id INTO v_person_2;

    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2020-11-18', NULL, 'annet', '1, 2/mail/standard tilbud');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2020-11-30', NULL, 'annet', '1, 2/mail/oppdatering');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2021-02-26', NULL, 'annet', '1, 2/mail/oppdatering');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2021-03-12', NULL, 'annet', '1, 2/mail/oppdatering');

    INSERT INTO public.contact_specialties (contact_id, specialty_id)
      SELECT v_contact_id, s.id FROM public.specialties s WHERE s.name IN ('Boring', 'Fundamentering')
      ON CONFLICT DO NOTHING;
  END IF;
END $$;

DO $$
DECLARE
  v_contact_id uuid;
  v_person_1 uuid;
  v_person_2 uuid;
BEGIN
  IF NOT EXISTS (SELECT 1 FROM public.contacts WHERE lower(company_name) = lower('Seabrokers Fundamentering AS')) THEN
    INSERT INTO public.contacts (company_name, phone, email, website, country, status)
      VALUES ('Seabrokers Fundamentering AS', '916 65 890', 'siggi@seabrokers.no', 'https://www.seabrokers.no/', 'Norge', 'kontaktet')
      RETURNING id INTO v_contact_id;

    INSERT INTO public.contact_people (contact_id, full_name, phone, email, is_primary)
      VALUES (v_contact_id, 'Sigurdur Andri Sigurdsson', '916 65 890', 'siggi@seabrokers.no', true)
      RETURNING id INTO v_person_1;
    INSERT INTO public.contact_people (contact_id, full_name, phone, email, is_primary)
      VALUES (v_contact_id, 'Regine Obrestad Kverme', '452 02 420', 'regine@seabrokers.no', false)
      RETURNING id INTO v_person_2;

    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2020-11-19', NULL, 'annet', '1, 2/mail/standard tilbud');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2020-11-30', NULL, 'annet', '1, 2/mail/oppdatering');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2021-02-26', NULL, 'annet', '1, 2/mail/oppdatering');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2021-03-12', NULL, 'annet', '1, 2/mail/oppdatering');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2021-07-01', NULL, 'annet', '1, 2/mail/oppdatering');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2021-10-29', NULL, 'annet', '1, 2/mail/oppdatering');

    INSERT INTO public.contact_specialties (contact_id, specialty_id)
      SELECT v_contact_id, s.id FROM public.specialties s WHERE s.name IN ('Bygg', 'Fundamentering')
      ON CONFLICT DO NOTHING;
  END IF;
END $$;

DO $$
DECLARE
  v_contact_id uuid;
  v_person_1 uuid;
BEGIN
  IF NOT EXISTS (SELECT 1 FROM public.contacts WHERE lower(company_name) = lower('Thunberg Entreprenør AS')) THEN
    INSERT INTO public.contacts (company_name, phone, email, website, country, status)
      VALUES ('Thunberg Entreprenør AS', '957 07 277', 'lars@thunberg.no', 'https://thunberg.no/', 'Norge', 'kontaktet')
      RETURNING id INTO v_contact_id;

    INSERT INTO public.contact_people (contact_id, full_name, phone, email, is_primary)
      VALUES (v_contact_id, 'Lars Thunberg', '957 07 277', 'lars@thunberg.no', true)
      RETURNING id INTO v_person_1;

    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2020-11-19', v_person_1, 'epost', 'standard tilbud');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2020-11-30', v_person_1, 'epost', 'oppdatering');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2021-02-26', v_person_1, 'epost', 'oppdatering');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2021-03-12', v_person_1, 'epost', 'oppdatering');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2021-07-01', v_person_1, 'epost', 'oppdatering');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2021-10-29', v_person_1, 'epost', 'oppdatering');

    INSERT INTO public.contact_specialties (contact_id, specialty_id)
      SELECT v_contact_id, s.id FROM public.specialties s WHERE s.name IN ('Betong', 'Fundamentering')
      ON CONFLICT DO NOTHING;
  END IF;
END $$;

DO $$
DECLARE
  v_contact_id uuid;
  v_person_1 uuid;
BEGIN
  IF NOT EXISTS (SELECT 1 FROM public.contacts WHERE lower(company_name) = lower('Dobloug Entreprenør AS')) THEN
    INSERT INTO public.contacts (company_name, phone, email, website, country, status)
      VALUES ('Dobloug Entreprenør AS', '412 97 567', 'sindre.lien@doblougentreprenor.no', 'https://www.doblougentreprenor.no/', 'Norge', 'kontaktet')
      RETURNING id INTO v_contact_id;

    INSERT INTO public.contact_people (contact_id, full_name, phone, email, is_primary)
      VALUES (v_contact_id, 'Sindre Lien', '412 97 567', 'sindre.lien@doblougentreprenor.no', true)
      RETURNING id INTO v_person_1;

    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2020-11-23', v_person_1, 'epost', 'standard tilbud');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2020-11-30', v_person_1, 'epost', 'oppdatering');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2021-02-26', v_person_1, 'epost', 'oppdatering');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2021-03-12', v_person_1, 'epost', 'oppdatering');

    INSERT INTO public.contact_specialties (contact_id, specialty_id)
      SELECT v_contact_id, s.id FROM public.specialties s WHERE s.name IN ('Bygg', 'Anlegg', 'Fundamentering')
      ON CONFLICT DO NOTHING;
  END IF;
END $$;

DO $$
DECLARE
  v_contact_id uuid;
  v_person_1 uuid;
BEGIN
  IF NOT EXISTS (SELECT 1 FROM public.contacts WHERE lower(company_name) = lower('REIERSEN ENTREPRENØR')) THEN
    INSERT INTO public.contacts (company_name, phone, email, website, country, status)
      VALUES ('REIERSEN ENTREPRENØR', '909 92 015', 'firmapost@reiersen.as', 'https://reiersen.as/', 'Norge', 'kontaktet')
      RETURNING id INTO v_contact_id;

    INSERT INTO public.contact_people (contact_id, full_name, phone, email, is_primary)
      VALUES (v_contact_id, 'Audun Reiersen', '909 92 015', 'firmapost@reiersen.as', true)
      RETURNING id INTO v_person_1;

    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2020-11-30', v_person_1, 'epost', 'standard tilbud');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2021-01-29', v_person_1, 'epost', 'oppdatering');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2021-02-26', v_person_1, 'epost', 'oppdatering');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2021-03-12', v_person_1, 'epost', 'oppdatering');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2021-07-01', v_person_1, 'epost', 'oppdatering');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2021-10-29', v_person_1, 'epost', 'oppdatering');

    INSERT INTO public.contact_specialties (contact_id, specialty_id)
      SELECT v_contact_id, s.id FROM public.specialties s WHERE s.name IN ('Bygg', 'Anlegg')
      ON CONFLICT DO NOTHING;
  END IF;
END $$;

DO $$
DECLARE
  v_contact_id uuid;
  v_person_1 uuid;
  v_person_2 uuid;
BEGIN
  IF NOT EXISTS (SELECT 1 FROM public.contacts WHERE lower(company_name) = lower('STENSETH & RS Betongentreprenør AS')) THEN
    INSERT INTO public.contacts (company_name, phone, email, website, country, status)
      VALUES ('STENSETH & RS Betongentreprenør AS', '416 55 055', 'jon.aune@stenseth-rs.no', 'https://www.stensethrs.no/', 'Norge', 'kontaktet')
      RETURNING id INTO v_contact_id;

    INSERT INTO public.contact_people (contact_id, full_name, phone, email, is_primary)
      VALUES (v_contact_id, 'Jon Aune', '416 55 055', 'jon.aune@stenseth-rs.no', true)
      RETURNING id INTO v_person_1;
    INSERT INTO public.contact_people (contact_id, full_name, phone, email, is_primary)
      VALUES (v_contact_id, 'Daniel Pedersen', '464 42 165', 'daniel@stenseth-rs.no', false)
      RETURNING id INTO v_person_2;

    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2020-11-30', NULL, 'annet', '1, 2/mail/standard tilbud');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2021-01-29', NULL, 'annet', '1, 2/mail/oppdatering');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2021-02-26', NULL, 'annet', '1, 2/mail/oppdatering');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2021-03-12', NULL, 'annet', '1, 2/mail/oppdatering');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2021-07-01', NULL, 'annet', '1, 2/mail/oppdatering');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2021-10-29', NULL, 'annet', '1, 2/mail/oppdatering');

    INSERT INTO public.contact_specialties (contact_id, specialty_id)
      SELECT v_contact_id, s.id FROM public.specialties s WHERE s.name IN ('Bygg', 'Betong')
      ON CONFLICT DO NOTHING;
  END IF;
END $$;

DO $$
DECLARE
  v_contact_id uuid;
  v_person_1 uuid;
  v_person_2 uuid;
  v_person_3 uuid;
BEGIN
  IF NOT EXISTS (SELECT 1 FROM public.contacts WHERE lower(company_name) = lower('KAARE MORTENSEN AS')) THEN
    INSERT INTO public.contacts (company_name, phone, email, website, country, status)
      VALUES ('KAARE MORTENSEN AS', NULL, 'stein-inge@kaare-mortensen.as', 'http://www.kaare-mortensen.as/', 'Norge', 'kontaktet')
      RETURNING id INTO v_contact_id;

    INSERT INTO public.contact_people (contact_id, full_name, phone, email, is_primary)
      VALUES (v_contact_id, 'Stein-Inge Eriksen', NULL, 'stein-inge@kaare-mortensen.as', true)
      RETURNING id INTO v_person_1;
    INSERT INTO public.contact_people (contact_id, full_name, phone, email, is_primary)
      VALUES (v_contact_id, 'Pål Stenberg', '970 59 402', 'pal@kaare-mortensen.as', false)
      RETURNING id INTO v_person_2;
    INSERT INTO public.contact_people (contact_id, full_name, phone, email, is_primary)
      VALUES (v_contact_id, 'Flavia Pop', '970 59 427', 'flavia@kaare-mortensen.as', false)
      RETURNING id INTO v_person_3;

    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, current_date, NULL, 'annet', '1, 2, 3/mail/standard tilbud');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2021-01-29', NULL, 'annet', '1, 2, 3/mail/oppdatering');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2021-02-26', NULL, 'annet', '1, 2, 3/mail/oppdatering');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2021-03-12', NULL, 'annet', '1, 2, 3/mail/oppdatering');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2021-07-01', NULL, 'annet', '1, 2, 3/mail/oppdatering');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2021-10-29', NULL, 'annet', '1, 2, 3/mail/oppdatering');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2022-01-31', NULL, 'annet', 'https://www.finn.no/job/fulltime/ad.html?finnkode=243743186');

    INSERT INTO public.contact_specialties (contact_id, specialty_id)
      SELECT v_contact_id, s.id FROM public.specialties s WHERE s.name IN ('Bygg', 'Anlegg')
      ON CONFLICT DO NOTHING;
  END IF;
END $$;

DO $$
DECLARE
  v_contact_id uuid;
  v_person_1 uuid;
  v_person_2 uuid;
  v_person_3 uuid;
BEGIN
  IF NOT EXISTS (SELECT 1 FROM public.contacts WHERE lower(company_name) = lower('VEDAL AS')) THEN
    INSERT INTO public.contacts (company_name, phone, email, website, country, status)
      VALUES ('VEDAL AS', '918 70 076', 'reidar.wulfsberg@vedal.no', 'https://www.vedal.no/', 'Norge', 'kontaktet')
      RETURNING id INTO v_contact_id;

    INSERT INTO public.contact_people (contact_id, full_name, phone, email, is_primary)
      VALUES (v_contact_id, 'Reidar Wulfsberg', '918 70 076', 'reidar.wulfsberg@vedal.no', true)
      RETURNING id INTO v_person_1;
    INSERT INTO public.contact_people (contact_id, full_name, phone, email, is_primary)
      VALUES (v_contact_id, 'Karen Cecilie Møller', '924 30 041', 'karen.cecilie.moller@vedal.no', false)
      RETURNING id INTO v_person_2;
    INSERT INTO public.contact_people (contact_id, full_name, phone, email, is_primary)
      VALUES (v_contact_id, 'Bjørn Vedal', '416 02 966', 'bjorn.vedal@vedal.no', false)
      RETURNING id INTO v_person_3;

    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2020-11-30', NULL, 'annet', '1, 2, 3/mail/standard tilbud');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2021-01-29', NULL, 'annet', '1, 2, 3/mail/oppdatering');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2021-02-26', NULL, 'annet', '1, 2, 3/mail/oppdatering');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2021-03-12', NULL, 'annet', '1, 2, 3/mail/oppdatering');

    INSERT INTO public.contact_specialties (contact_id, specialty_id)
      SELECT v_contact_id, s.id FROM public.specialties s WHERE s.name IN ('Bygg')
      ON CONFLICT DO NOTHING;
  END IF;
END $$;

DO $$
DECLARE
  v_contact_id uuid;
  v_person_1 uuid;
  v_person_2 uuid;
  v_person_3 uuid;
BEGIN
  IF NOT EXISTS (SELECT 1 FROM public.contacts WHERE lower(company_name) = lower('VARDEN ENTREPRENØR')) THEN
    INSERT INTO public.contacts (company_name, phone, email, website, country, status)
      VALUES ('VARDEN ENTREPRENØR', '951 20 161', 'tor.unneland@varden-entreprenor.no', 'https://www.varden-entreprenor.no/', 'Norge', 'kontaktet')
      RETURNING id INTO v_contact_id;

    INSERT INTO public.contact_people (contact_id, full_name, phone, email, is_primary)
      VALUES (v_contact_id, 'Tor G. Unneland', '951 20 161', 'tor.unneland@varden-entreprenor.no', true)
      RETURNING id INTO v_person_1;
    INSERT INTO public.contact_people (contact_id, full_name, phone, email, is_primary)
      VALUES (v_contact_id, 'Bjarne Brenden', '951 20 000', 'bjarne.brenden@varden-entreprenor.no', false)
      RETURNING id INTO v_person_2;
    INSERT INTO public.contact_people (contact_id, full_name, phone, email, is_primary)
      VALUES (v_contact_id, 'Martin Stuge Bånerud', '477 18 505', 'msb@varden-entreprenor.no', false)
      RETURNING id INTO v_person_3;

    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2020-11-30', NULL, 'annet', '1, 2, 3/mail/standard tilbud');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2021-01-29', NULL, 'annet', '1, 2, 3/mail/oppdatering');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2021-02-26', NULL, 'annet', '1, 2, 3/mail/oppdatering');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2021-03-12', NULL, 'annet', '1, 2, 3/mail/oppdatering');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2021-07-01', NULL, 'annet', '1, 2, 3/mail/oppdatering');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2021-10-29', NULL, 'annet', '1, 2, 3/mail/oppdatering');

    INSERT INTO public.contact_specialties (contact_id, specialty_id)
      SELECT v_contact_id, s.id FROM public.specialties s WHERE s.name IN ('Bygg')
      ON CONFLICT DO NOTHING;
  END IF;
END $$;

DO $$
DECLARE
  v_contact_id uuid;
  v_person_1 uuid;
  v_person_2 uuid;
BEGIN
  IF NOT EXISTS (SELECT 1 FROM public.contacts WHERE lower(company_name) = lower('SWECO')) THEN
    INSERT INTO public.contacts (company_name, phone, email, website, country, status)
      VALUES ('SWECO', '977 75 581', 'annelise.schei@sweco.no', 'https://www.sweco.no/', 'Norge', 'kontaktet')
      RETURNING id INTO v_contact_id;

    INSERT INTO public.contact_people (contact_id, full_name, phone, email, is_primary)
      VALUES (v_contact_id, 'Anne Lise Haakaas-Schei', '977 75 581', 'annelise.schei@sweco.no', true)
      RETURNING id INTO v_person_1;
    INSERT INTO public.contact_people (contact_id, full_name, phone, email, is_primary)
      VALUES (v_contact_id, 'Trond Erling Vindenes', NULL, 'trond.erling.vindenes@sweco.no', false)
      RETURNING id INTO v_person_2;

    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2020-12-02', NULL, 'annet', '1, 2/mail/standard tilbud');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2021-01-29', NULL, 'annet', '1, 2/mail/oppdatering');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2021-02-01', NULL, 'annet', '1, 2/mail/oppdatering');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2021-02-26', NULL, 'annet', '1, 2/mail/oppdatering');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2021-03-12', NULL, 'annet', '1, 2/mail/oppdatering');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2021-07-01', NULL, 'annet', '1, 2/mail/oppdatering');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2021-10-29', NULL, 'annet', '1, 2/mail/oppdatering');

    INSERT INTO public.contact_specialties (contact_id, specialty_id)
      SELECT v_contact_id, s.id FROM public.specialties s WHERE s.name IN ('Konsulent')
      ON CONFLICT DO NOTHING;
  END IF;
END $$;

DO $$
DECLARE
  v_contact_id uuid;
  v_person_1 uuid;
  v_person_2 uuid;
  v_person_3 uuid;
  v_person_4 uuid;
BEGIN
  IF NOT EXISTS (SELECT 1 FROM public.contacts WHERE lower(company_name) = lower('Johs. J. Syltern')) THEN
    INSERT INTO public.contacts (company_name, phone, email, website, country, status)
      VALUES ('Johs. J. Syltern', '926 06 752', 'heidi.butli@syltern.no', 'https://syltern.no/', 'Norge', 'kontaktet')
      RETURNING id INTO v_contact_id;

    INSERT INTO public.contact_people (contact_id, full_name, phone, email, is_primary)
      VALUES (v_contact_id, 'Heidi Butli', '926 06 752', 'heidi.butli@syltern.no', true)
      RETURNING id INTO v_person_1;
    INSERT INTO public.contact_people (contact_id, full_name, phone, email, is_primary)
      VALUES (v_contact_id, 'Monica Fossum', '992 87 787', 'monica.fossum@syltern.no', false)
      RETURNING id INTO v_person_2;
    INSERT INTO public.contact_people (contact_id, full_name, phone, email, is_primary)
      VALUES (v_contact_id, 'Jostien Syltern', '992 87 807', 'jostein@syltern.no', false)
      RETURNING id INTO v_person_3;
    INSERT INTO public.contact_people (contact_id, full_name, phone, email, is_primary)
      VALUES (v_contact_id, 'Renate Winsnes Fagerbekk', '992 87 794', 'renate.winsnes@syltern.no', false)
      RETURNING id INTO v_person_4;

    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2020-12-03', NULL, 'annet', '1, 2, 3, 4/mail/standard tilbud');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2021-01-29', NULL, 'annet', '1, 2, 3, 4/mail/oppdatering');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2021-02-26', NULL, 'annet', '1, 2, 3, 4/mail/oppdatering');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2021-07-01', NULL, 'annet', '1, 2, 3, 4/mail/oppdatering');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2021-10-29', NULL, 'annet', '1, 2, 3, 4/mail/oppdatering');

    INSERT INTO public.contact_specialties (contact_id, specialty_id)
      SELECT v_contact_id, s.id FROM public.specialties s WHERE s.name IN ('Anlegg')
      ON CONFLICT DO NOTHING;
  END IF;
END $$;

DO $$
DECLARE
  v_contact_id uuid;
  v_person_1 uuid;
  v_person_2 uuid;
BEGIN
  IF NOT EXISTS (SELECT 1 FROM public.contacts WHERE lower(company_name) = lower('Ulefos AS')) THEN
    INSERT INTO public.contacts (company_name, phone, email, website, country, status)
      VALUES ('Ulefos AS', '468 30 075', 'mikko.nilsen@ulefos.com', 'https://ulefos.com/', 'Norge', 'kontaktet')
      RETURNING id INTO v_contact_id;

    INSERT INTO public.contact_people (contact_id, full_name, phone, email, is_primary)
      VALUES (v_contact_id, 'Mikko Nilsen', '468 30 075', 'mikko.nilsen@ulefos.com', true)
      RETURNING id INTO v_person_1;
    INSERT INTO public.contact_people (contact_id, full_name, phone, email, is_primary)
      VALUES (v_contact_id, 'Kristian Svarstad', '930 05 954', 'kristian.svarstad@ulefos.com', false)
      RETURNING id INTO v_person_2;

    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2020-12-04', NULL, 'annet', '1, 2/mail/standard tilbud');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2021-01-29', NULL, 'annet', '1, 2/mail/oppdatering');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2021-02-26', NULL, 'annet', '1, 2/mail/oppdatering');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2021-03-12', NULL, 'annet', '1, 2/mail/oppdatering');

    INSERT INTO public.contact_specialties (contact_id, specialty_id)
      SELECT v_contact_id, s.id FROM public.specialties s WHERE s.name IN ('Bygg', 'Anlegg')
      ON CONFLICT DO NOTHING;
  END IF;
END $$;

DO $$
DECLARE
  v_contact_id uuid;
  v_person_1 uuid;
  v_person_2 uuid;
BEGIN
  IF NOT EXISTS (SELECT 1 FROM public.contacts WHERE lower(company_name) = lower('A Bygg Entreprenør AS')) THEN
    INSERT INTO public.contacts (company_name, phone, email, website, country, status)
      VALUES ('A Bygg Entreprenør AS', '482 93 558', 'martin.ihler@abygg.no', 'https://www.abygg.no/', 'Norge', 'kontaktet')
      RETURNING id INTO v_contact_id;

    INSERT INTO public.contact_people (contact_id, full_name, phone, email, is_primary)
      VALUES (v_contact_id, 'Martin Lyngstad Ihler', '482 93 558', 'martin.ihler@abygg.no', true)
      RETURNING id INTO v_person_1;
    INSERT INTO public.contact_people (contact_id, full_name, phone, email, is_primary)
      VALUES (v_contact_id, 'Morten Raugstad', '996 91 928', 'morten.raugstad@abygg.no', false)
      RETURNING id INTO v_person_2;

    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2020-12-07', NULL, 'annet', '1, 2/mail/standard tilbud');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2021-01-29', NULL, 'annet', '1, 2/mail/oppdatering');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2021-02-26', NULL, 'annet', '1, 2/mail/oppdatering');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2021-03-12', NULL, 'annet', '1, 2/mail/oppdatering');

    INSERT INTO public.contact_specialties (contact_id, specialty_id)
      SELECT v_contact_id, s.id FROM public.specialties s WHERE s.name IN ('Bygg')
      ON CONFLICT DO NOTHING;
  END IF;
END $$;

DO $$
DECLARE
  v_contact_id uuid;
  v_person_1 uuid;
BEGIN
  IF NOT EXISTS (SELECT 1 FROM public.contacts WHERE lower(company_name) = lower('Råde Graveservice AS')) THEN
    INSERT INTO public.contacts (company_name, phone, email, website, country, status)
      VALUES ('Råde Graveservice AS', '996 48 490', 'L.R.ARNESEN@GMAIL.COM', 'https://www.rgs.no/', 'Norge', 'kontaktet')
      RETURNING id INTO v_contact_id;

    INSERT INTO public.contact_people (contact_id, full_name, phone, email, is_primary)
      VALUES (v_contact_id, 'Rune Arnesen', '996 48 490', 'L.R.ARNESEN@GMAIL.COM', true)
      RETURNING id INTO v_person_1;

    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2020-12-07', v_person_1, 'epost', 'standard tilbud');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2021-01-29', v_person_1, 'epost', 'oppdatering');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2021-02-26', v_person_1, 'epost', 'oppdatering');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2021-03-12', v_person_1, 'epost', 'oppdatering');

    INSERT INTO public.contact_specialties (contact_id, specialty_id)
      SELECT v_contact_id, s.id FROM public.specialties s WHERE s.name IN ('Bygg', 'Anlegg')
      ON CONFLICT DO NOTHING;
  END IF;
END $$;

DO $$
DECLARE
  v_contact_id uuid;
  v_person_1 uuid;
  v_person_2 uuid;
BEGIN
  IF NOT EXISTS (SELECT 1 FROM public.contacts WHERE lower(company_name) = lower('Braathen Landskapsentreprenør AS')) THEN
    INSERT INTO public.contacts (company_name, phone, email, website, country, status)
      VALUES ('Braathen Landskapsentreprenør AS', '916 79 164', 'tommy.lintho@landskap.no', 'https://www.landskap.as/', 'Norge', 'kontaktet')
      RETURNING id INTO v_contact_id;

    INSERT INTO public.contact_people (contact_id, full_name, phone, email, is_primary)
      VALUES (v_contact_id, 'Tommy Lintho', '916 79 164', 'tommy.lintho@landskap.no', true)
      RETURNING id INTO v_person_1;
    INSERT INTO public.contact_people (contact_id, full_name, phone, email, is_primary)
      VALUES (v_contact_id, 'Mateusz Paw', '462 13 858', 'mateusz@landskap.as', false)
      RETURNING id INTO v_person_2;

    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2020-12-07', NULL, 'annet', '1, 2/mail/standard tilbud');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2021-01-29', NULL, 'annet', '1, 2/mail/oppdatering');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2021-02-26', NULL, 'annet', '1, 2/mail/oppdatering');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2021-03-12', NULL, 'annet', '1, 2/mail/oppdatering');

    INSERT INTO public.contact_specialties (contact_id, specialty_id)
      SELECT v_contact_id, s.id FROM public.specialties s WHERE s.name IN ('Bygg', 'Anlegg')
      ON CONFLICT DO NOTHING;
  END IF;
END $$;

DO $$
DECLARE
  v_contact_id uuid;
  v_person_1 uuid;
BEGIN
  IF NOT EXISTS (SELECT 1 FROM public.contacts WHERE lower(company_name) = lower('JR Anlegg AS')) THEN
    INSERT INTO public.contacts (company_name, phone, email, website, country, status)
      VALUES ('JR Anlegg AS', '909 49 063', 'jar@jranlegg.no', 'https://jranlegg.no/', 'Norge', 'kontaktet')
      RETURNING id INTO v_contact_id;

    INSERT INTO public.contact_people (contact_id, full_name, phone, email, is_primary)
      VALUES (v_contact_id, 'Jon Arve Rognerud', '909 49 063', 'jar@jranlegg.no', true)
      RETURNING id INTO v_person_1;

    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2020-12-07', v_person_1, 'epost', 'standard tilbud');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2021-01-29', v_person_1, 'epost', 'oppdatering');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2021-02-26', v_person_1, 'epost', 'oppdatering');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2021-03-12', v_person_1, 'epost', 'oppdatering');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2022-03-02', v_person_1, 'epost', 'svar: ønsker å ansette egne, tar kontakt ved behov');

    INSERT INTO public.contact_specialties (contact_id, specialty_id)
      SELECT v_contact_id, s.id FROM public.specialties s WHERE s.name IN ('Anlegg')
      ON CONFLICT DO NOTHING;
  END IF;
END $$;

DO $$
DECLARE
  v_contact_id uuid;
  v_person_1 uuid;
BEGIN
  IF NOT EXISTS (SELECT 1 FROM public.contacts WHERE lower(company_name) = lower('ROMERIKE GRUNNBORRING AS')) THEN
    INSERT INTO public.contacts (company_name, phone, email, website, country, status)
      VALUES ('ROMERIKE GRUNNBORRING AS', '400 93 233', 'christian@rgb.as', 'https://rgb.as/', 'Norge', 'kontaktet')
      RETURNING id INTO v_contact_id;

    INSERT INTO public.contact_people (contact_id, full_name, phone, email, is_primary)
      VALUES (v_contact_id, 'Christian Rustberggard', '400 93 233', 'christian@rgb.as', true)
      RETURNING id INTO v_person_1;

    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2020-12-09', v_person_1, 'epost', 'standard tilbud');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2021-01-29', v_person_1, 'epost', 'oppdatering');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2021-02-18', v_person_1, 'epost', 'oppdatering');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2021-03-12', v_person_1, 'epost', 'oppdatering');

    INSERT INTO public.contact_specialties (contact_id, specialty_id)
      SELECT v_contact_id, s.id FROM public.specialties s WHERE s.name IN ('Grunnborring')
      ON CONFLICT DO NOTHING;
  END IF;
END $$;

DO $$
DECLARE
  v_contact_id uuid;
  v_person_1 uuid;
  v_person_2 uuid;
  v_person_3 uuid;
BEGIN
  IF NOT EXISTS (SELECT 1 FROM public.contacts WHERE lower(company_name) = lower('LNS AS')) THEN
    INSERT INTO public.contacts (company_name, phone, email, website, country, status)
      VALUES ('LNS AS', '465 59 619', NULL, 'https://lns.no/', 'Norge', 'kontaktet')
      RETURNING id INTO v_contact_id;

    INSERT INTO public.contact_people (contact_id, full_name, phone, email, is_primary)
      VALUES (v_contact_id, 'Maciej Szarek', '465 59 619', NULL, true)
      RETURNING id INTO v_person_1;
    INSERT INTO public.contact_people (contact_id, full_name, phone, email, is_primary)
      VALUES (v_contact_id, 'Maciej Warczak', '477 00 734', NULL, false)
      RETURNING id INTO v_person_2;
    INSERT INTO public.contact_people (contact_id, full_name, phone, email, is_primary)
      VALUES (v_contact_id, NULL, NULL, 'firmapost@lns.no', false)
      RETURNING id INTO v_person_3;

    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2020-12-09', NULL, 'annet', '1, 2/mail/standard tilbud');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2021-01-29', NULL, 'annet', '1, 2/mail/oppdatering');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2021-02-18', NULL, 'annet', '1, 2/mail/oppdatering');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2021-03-12', NULL, 'annet', '1, 2/mail/oppdatering');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2026-03-10', NULL, 'annet', '1.2/mail/fastmerker og oppdatering');

    INSERT INTO public.contact_specialties (contact_id, specialty_id)
      SELECT v_contact_id, s.id FROM public.specialties s WHERE s.name IN ('Anlegg', 'Tunnel')
      ON CONFLICT DO NOTHING;
  END IF;
END $$;

DO $$
DECLARE
  v_contact_id uuid;
  v_person_1 uuid;
BEGIN
  IF NOT EXISTS (SELECT 1 FROM public.contacts WHERE lower(company_name) = lower('Aktiv Veidrift AS')) THEN
    INSERT INTO public.contacts (company_name, phone, email, website, country, status)
      VALUES ('Aktiv Veidrift AS', '941 74 257', 'ks@aktivveidrift.no', 'https://aktivveidrift.no/', 'Norge', 'kontaktet')
      RETURNING id INTO v_contact_id;

    INSERT INTO public.contact_people (contact_id, full_name, phone, email, is_primary)
      VALUES (v_contact_id, 'Krzystof Sabiszewski', '941 74 257', 'ks@aktivveidrift.no', true)
      RETURNING id INTO v_person_1;

    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2021-01-28', NULL, 'annet', '1, 2/mail/standard tilbud');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2021-02-18', v_person_1, 'telefon', 'oppdatering');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2021-03-12', v_person_1, 'epost', 'oppdatering');

    INSERT INTO public.contact_specialties (contact_id, specialty_id)
      SELECT v_contact_id, s.id FROM public.specialties s WHERE s.name IN ('Anlegg', 'Vei')
      ON CONFLICT DO NOTHING;
  END IF;
END $$;

DO $$
DECLARE
  v_contact_id uuid;
  v_person_1 uuid;
  v_person_2 uuid;
  v_person_3 uuid;
  v_person_4 uuid;
BEGIN
  IF NOT EXISTS (SELECT 1 FROM public.contacts WHERE lower(company_name) = lower('EIQON Anlegg AS')) THEN
    INSERT INTO public.contacts (company_name, phone, email, website, country, status)
      VALUES ('EIQON Anlegg AS', '971 17 199', 'henry.nordhagen@eiqon.no', 'https://eiqon.no/', 'Norge', 'kontaktet')
      RETURNING id INTO v_contact_id;

    INSERT INTO public.contact_people (contact_id, full_name, phone, email, is_primary)
      VALUES (v_contact_id, 'Henry Nordhagen', '971 17 199', 'henry.nordhagen@eiqon.no', true)
      RETURNING id INTO v_person_1;
    INSERT INTO public.contact_people (contact_id, full_name, phone, email, is_primary)
      VALUES (v_contact_id, 'Roy Brynjulfsen', '916 81 317', 'roy.brynjulfsen@eiqon.no', false)
      RETURNING id INTO v_person_2;
    INSERT INTO public.contact_people (contact_id, full_name, phone, email, is_primary)
      VALUES (v_contact_id, 'Edgaras Ramazauskas', '483 20 487', 'edgaras.ramazauskas@eiqon.no', false)
      RETURNING id INTO v_person_3;
    INSERT INTO public.contact_people (contact_id, full_name, phone, email, is_primary)
      VALUES (v_contact_id, 'Teresa Ariann Miranda Baptista', '459 06 646', 'teresa.baptista@eiqon.no', false)
      RETURNING id INTO v_person_4;

    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2021-02-18', NULL, 'annet', '1, 2, 3, 4/mail/standard tilbud');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2021-03-12', NULL, 'annet', '1, 2, 3, 4/mail/oppdatering');

    INSERT INTO public.contact_specialties (contact_id, specialty_id)
      SELECT v_contact_id, s.id FROM public.specialties s WHERE s.name IN ('Anlegg')
      ON CONFLICT DO NOTHING;
  END IF;
END $$;

DO $$
DECLARE
  v_contact_id uuid;
  v_person_1 uuid;
BEGIN
  IF NOT EXISTS (SELECT 1 FROM public.contacts WHERE lower(company_name) = lower('KN Entreprenør AS')) THEN
    INSERT INTO public.contacts (company_name, phone, email, website, country, status)
      VALUES ('KN Entreprenør AS', '905 25 300', 'post@kn-entreprenor.no', 'https://kn-entreprenor.no/', 'Norge', 'kontaktet')
      RETURNING id INTO v_contact_id;

    INSERT INTO public.contact_people (contact_id, full_name, phone, email, is_primary)
      VALUES (v_contact_id, 'Kåre Oversen', '905 25 300', 'post@kn-entreprenor.no', true)
      RETURNING id INTO v_person_1;

    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2021-02-25', v_person_1, 'epost', 'standard tilbud');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2021-03-12', v_person_1, 'epost', 'oppdatering');

    INSERT INTO public.contact_specialties (contact_id, specialty_id)
      SELECT v_contact_id, s.id FROM public.specialties s WHERE s.name IN ('Anlegg')
      ON CONFLICT DO NOTHING;
  END IF;
END $$;

DO $$
DECLARE
  v_contact_id uuid;
  v_person_1 uuid;
  v_person_2 uuid;
BEGIN
  IF NOT EXISTS (SELECT 1 FROM public.contacts WHERE lower(company_name) = lower('KRUSE SMITH')) THEN
    INSERT INTO public.contacts (company_name, phone, email, website, country, status)
      VALUES ('KRUSE SMITH', '970 50 154', 'tommy.jahnsen@kruse-smith.no', 'https://www.kruse-smith.no/', 'Norge', 'kontaktet')
      RETURNING id INTO v_contact_id;

    INSERT INTO public.contact_people (contact_id, full_name, phone, email, is_primary)
      VALUES (v_contact_id, 'Tommy Jahnsen', '970 50 154', 'tommy.jahnsen@kruse-smith.no', true)
      RETURNING id INTO v_person_1;
    INSERT INTO public.contact_people (contact_id, full_name, phone, email, is_primary)
      VALUES (v_contact_id, 'Bjørn Velken', '918 21 425', 'bjorn.velken@kruse-smith.no', false)
      RETURNING id INTO v_person_2;

    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2021-03-10', NULL, 'annet', '1, 2/mail/standard tilbud');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2022-01-20', NULL, 'annet', '1, 2/mail/oppdatering');

    INSERT INTO public.contact_specialties (contact_id, specialty_id)
      SELECT v_contact_id, s.id FROM public.specialties s WHERE s.name IN ('Bygg')
      ON CONFLICT DO NOTHING;
  END IF;
END $$;

DO $$
DECLARE
  v_contact_id uuid;
  v_person_1 uuid;
  v_person_2 uuid;
BEGIN
  IF NOT EXISTS (SELECT 1 FROM public.contacts WHERE lower(company_name) = lower('PS Anlegg AS')) THEN
    INSERT INTO public.contacts (company_name, phone, email, website, country, status)
      VALUES ('PS Anlegg AS', '915 20 498', 'olaf@psanlegg.no', 'https://www.psanlegg.no/', 'Norge', 'kontaktet')
      RETURNING id INTO v_contact_id;

    INSERT INTO public.contact_people (contact_id, full_name, phone, email, is_primary)
      VALUES (v_contact_id, 'Olaf Olsen', '915 20 498', 'olaf@psanlegg.no', true)
      RETURNING id INTO v_person_1;
    INSERT INTO public.contact_people (contact_id, full_name, phone, email, is_primary)
      VALUES (v_contact_id, 'John Røinås', '466 13 672', 'john@psanlegg.no', false)
      RETURNING id INTO v_person_2;

    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2021-03-10', NULL, 'annet', '1, 2/mail/standard tilbud');

    INSERT INTO public.contact_specialties (contact_id, specialty_id)
      SELECT v_contact_id, s.id FROM public.specialties s WHERE s.name IN ('Anlegg')
      ON CONFLICT DO NOTHING;
  END IF;
END $$;

DO $$
DECLARE
  v_contact_id uuid;
  v_person_1 uuid;
BEGIN
  IF NOT EXISTS (SELECT 1 FROM public.contacts WHERE lower(company_name) = lower('ZENITH Survey')) THEN
    INSERT INTO public.contacts (company_name, phone, email, website, country, status)
      VALUES ('ZENITH Survey', '954 72 155', 'per.heines@zenithsurvey.no', 'https://zenithsurvey.no/', 'Norge', 'kontaktet')
      RETURNING id INTO v_contact_id;

    INSERT INTO public.contact_people (contact_id, full_name, phone, email, is_primary)
      VALUES (v_contact_id, 'Per Christian Heines', '954 72 155', 'per.heines@zenithsurvey.no', true)
      RETURNING id INTO v_person_1;

    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2026-02-06', v_person_1, 'epost', 'oppdatering');

    INSERT INTO public.contact_specialties (contact_id, specialty_id)
      SELECT v_contact_id, s.id FROM public.specialties s WHERE s.name IN ('Anlegg')
      ON CONFLICT DO NOTHING;
  END IF;
END $$;

DO $$
DECLARE
  v_contact_id uuid;
  v_person_1 uuid;
BEGIN
  IF NOT EXISTS (SELECT 1 FROM public.contacts WHERE lower(company_name) = lower('Busengdal')) THEN
    INSERT INTO public.contacts (company_name, phone, email, website, country, status)
      VALUES ('Busengdal', '907 78 266', 'Bjorn@busengdal.no', 'https://www.busengdal.no/', 'Norge', 'kontaktet')
      RETURNING id INTO v_contact_id;

    INSERT INTO public.contact_people (contact_id, full_name, phone, email, is_primary)
      VALUES (v_contact_id, 'Bjørn Busengdal', '907 78 266', 'Bjorn@busengdal.no', true)
      RETURNING id INTO v_person_1;

    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2022-01-20', v_person_1, 'telefon', 'hils');

    INSERT INTO public.contact_specialties (contact_id, specialty_id)
      SELECT v_contact_id, s.id FROM public.specialties s WHERE s.name IN ('Anlegg')
      ON CONFLICT DO NOTHING;
  END IF;
END $$;

DO $$
DECLARE
  v_contact_id uuid;
  v_person_1 uuid;
BEGIN
  IF NOT EXISTS (SELECT 1 FROM public.contacts WHERE lower(company_name) = lower('Trase AS')) THEN
    INSERT INTO public.contacts (company_name, phone, email, website, country, status)
      VALUES ('Trase AS', '936 68 530', 'post@traseas.no', 'http://traseas.no/', 'Norge, Polen', 'kontaktet')
      RETURNING id INTO v_contact_id;

    INSERT INTO public.contact_people (contact_id, full_name, phone, email, is_primary)
      VALUES (v_contact_id, 'Rafal Superson', '936 68 530', 'post@traseas.no', true)
      RETURNING id INTO v_person_1;

    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2021-03-19', v_person_1, 'epost', 'standard tilbud');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2021-03-19', v_person_1, 'epost', 'oppdatering');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2022-01-20', v_person_1, 'epost', 'oppdatering');

    INSERT INTO public.contact_specialties (contact_id, specialty_id)
      SELECT v_contact_id, s.id FROM public.specialties s WHERE s.name IN ('Anlegg', 'Bane')
      ON CONFLICT DO NOTHING;
  END IF;
END $$;

DO $$
DECLARE
  v_contact_id uuid;
  v_person_1 uuid;
BEGIN
  IF NOT EXISTS (SELECT 1 FROM public.contacts WHERE lower(company_name) = lower('BSF Swissphoto')) THEN
    INSERT INTO public.contacts (company_name, phone, email, website, country, status)
      VALUES ('BSF Swissphoto', '471 72 318', 'Jens.Skonnord@bsf-swissphoto.com', 'https://en.bsf-swissphoto.com/', 'Norge, Sveits', 'kontaktet')
      RETURNING id INTO v_contact_id;

    INSERT INTO public.contact_people (contact_id, full_name, phone, email, is_primary)
      VALUES (v_contact_id, 'Jens Olav Skonnord', '471 72 318', 'Jens.Skonnord@bsf-swissphoto.com', true)
      RETURNING id INTO v_person_1;

    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2021-11-04', v_person_1, 'epost', 'standard tilbud');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2022-01-20', v_person_1, 'epost', 'Tilbud Nord Møre');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2022-01-28', v_person_1, 'epost', 'Informacja o pierwszym przetargu z naszym udzialem');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2022-02-06', v_person_1, 'epost', 'dostarczenie dokumentacji pod BSF Vegårdshei og Åmili');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2022-02-09', v_person_1, 'mote', '1/møte');

    INSERT INTO public.contact_specialties (contact_id, specialty_id)
      SELECT v_contact_id, s.id FROM public.specialties s WHERE s.name IN ('Konsulent', 'Flyfotografering')
      ON CONFLICT DO NOTHING;
  END IF;
END $$;

DO $$
DECLARE
  v_contact_id uuid;
  v_person_1 uuid;
BEGIN
  IF NOT EXISTS (SELECT 1 FROM public.contacts WHERE lower(company_name) = lower('Salcef')) THEN
    INSERT INTO public.contacts (company_name, phone, email, website, country, status)
      VALUES ('Salcef', NULL, 'stig.sorgard@salcef.com', 'https://www.salcef.com/', 'Italia, Norge', 'kontaktet')
      RETURNING id INTO v_contact_id;

    INSERT INTO public.contact_people (contact_id, full_name, phone, email, is_primary)
      VALUES (v_contact_id, 'Stig Sorgard', NULL, 'stig.sorgard@salcef.com', true)
      RETURNING id INTO v_person_1;

    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2021-11-04', v_person_1, 'epost', 'standard tilbud');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2022-01-20', v_person_1, 'epost', 'oppdatering, dobry kontakt, czekamy na start 2022');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2022-02-07', v_person_1, 'epost', 'follow up');

    INSERT INTO public.contact_specialties (contact_id, specialty_id)
      SELECT v_contact_id, s.id FROM public.specialties s WHERE s.name IN ('Anlegg', 'Bane')
      ON CONFLICT DO NOTHING;
  END IF;
END $$;

DO $$
DECLARE
  v_contact_id uuid;
  v_person_1 uuid;
  v_person_2 uuid;
BEGIN
  IF NOT EXISTS (SELECT 1 FROM public.contacts WHERE lower(company_name) = lower('Sartor & Drange AS')) THEN
    INSERT INTO public.contacts (company_name, phone, email, website, country, status)
      VALUES ('Sartor & Drange AS', '415 11 104', 'post@sartormaskin.no', 'https://www.sartormaskin.no/', 'Norge', 'kontaktet')
      RETURNING id INTO v_contact_id;

    INSERT INTO public.contact_people (contact_id, full_name, phone, email, is_primary)
      VALUES (v_contact_id, 'Arild Bøthun', '415 11 104', 'post@sartormaskin.no', true)
      RETURNING id INTO v_person_1;
    INSERT INTO public.contact_people (contact_id, full_name, phone, email, is_primary)
      VALUES (v_contact_id, 'Kay Lokøy', '940 01 844', 'kay.lokoy@sartordrange.no', false)
      RETURNING id INTO v_person_2;

    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2022-01-31', NULL, 'annet', 'https://www.finn.no/job/fulltime/ad.html?finnkode=246385387');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2022-02-07', v_person_1, 'epost', 'standard tilbud');

    INSERT INTO public.contact_specialties (contact_id, specialty_id)
      SELECT v_contact_id, s.id FROM public.specialties s WHERE s.name IN ('Anlegg')
      ON CONFLICT DO NOTHING;
  END IF;
END $$;

DO $$
DECLARE
  v_contact_id uuid;
  v_person_1 uuid;
BEGIN
  IF NOT EXISTS (SELECT 1 FROM public.contacts WHERE lower(company_name) = lower('RISA AS')) THEN
    INSERT INTO public.contacts (company_name, phone, email, website, country, status)
      VALUES ('RISA AS', '928 33 554', 'ruben.rosland@risa.no', 'https://risa.no/', 'Norge', 'kontaktet')
      RETURNING id INTO v_contact_id;

    INSERT INTO public.contact_people (contact_id, full_name, phone, email, is_primary)
      VALUES (v_contact_id, 'Ruben Rosland', '928 33 554', 'ruben.rosland@risa.no', true)
      RETURNING id INTO v_person_1;

    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2022-01-31', NULL, 'annet', 'https://www.finn.no/job/fulltime/ad.html?finnkode=243831262');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2022-02-01', NULL, 'annet', 'konkret tilbud, venter tilbakemelding');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2022-02-02', NULL, 'annet', 'svar fra kunden ''veldig interessant'', avventer endelig bekreftelse');

    INSERT INTO public.contact_specialties (contact_id, specialty_id)
      SELECT v_contact_id, s.id FROM public.specialties s WHERE s.name IN ('Anlegg')
      ON CONFLICT DO NOTHING;
  END IF;
END $$;

DO $$
DECLARE
  v_contact_id uuid;
  v_person_1 uuid;
BEGIN
  IF NOT EXISTS (SELECT 1 FROM public.contacts WHERE lower(company_name) = lower('Aker Solutions')) THEN
    INSERT INTO public.contacts (company_name, phone, email, website, country, status)
      VALUES ('Aker Solutions', NULL, 'https://www.finn.no/kontakt/245497816?ci=0', 'https://www.akersolutions.com/contact/offices/europe/norway/stavanger/', 'Norge', 'kontaktet')
      RETURNING id INTO v_contact_id;

    INSERT INTO public.contact_people (contact_id, full_name, phone, email, is_primary)
      VALUES (v_contact_id, 'Hilde Dahl', NULL, 'https://www.finn.no/kontakt/245497816?ci=0', true)
      RETURNING id INTO v_person_1;

    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2022-01-31', NULL, 'annet', 'https://www.finn.no/job/fulltime/ad.html?finnkode=245497816');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2022-01-31', NULL, 'annet', 'https://www.akersolutions.com/careers/job-search/?jobPostId=8643');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2022-02-07', NULL, 'annet', 'kontakty jedynie do rekruterow, mala szansa na odp');

    INSERT INTO public.contact_specialties (contact_id, specialty_id)
      SELECT v_contact_id, s.id FROM public.specialties s WHERE s.name IN ('Oil', 'Offshore')
      ON CONFLICT DO NOTHING;
  END IF;
END $$;

DO $$
DECLARE
  v_contact_id uuid;
  v_person_1 uuid;
BEGIN
  IF NOT EXISTS (SELECT 1 FROM public.contacts WHERE lower(company_name) = lower('Holthe Anlegg')) THEN
    INSERT INTO public.contacts (company_name, phone, email, website, country, status)
      VALUES ('Holthe Anlegg', '951 76 277', 'nils@holtheanlegg.no', 'https://holtheanlegg.no/', 'Norge', 'kontaktet')
      RETURNING id INTO v_contact_id;

    INSERT INTO public.contact_people (contact_id, full_name, phone, email, is_primary)
      VALUES (v_contact_id, 'Nils Kristian Naug', '951 76 277', 'nils@holtheanlegg.no', true)
      RETURNING id INTO v_person_1;

    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2022-02-07', v_person_1, 'epost', 'firmapresentasjon');

    INSERT INTO public.contact_specialties (contact_id, specialty_id)
      SELECT v_contact_id, s.id FROM public.specialties s WHERE s.name IN ('Anlegg')
      ON CONFLICT DO NOTHING;
  END IF;
END $$;

DO $$
DECLARE
  v_contact_id uuid;
  v_person_1 uuid;
  v_person_2 uuid;
BEGIN
  IF NOT EXISTS (SELECT 1 FROM public.contacts WHERE lower(company_name) = lower('Dpend')) THEN
    INSERT INTO public.contacts (company_name, phone, email, website, country, status)
      VALUES ('Dpend', '926 37 107', 'ot@dpend.no', 'https://dpend.no/', 'Norge', 'kontaktet')
      RETURNING id INTO v_contact_id;

    INSERT INTO public.contact_people (contact_id, full_name, phone, email, is_primary)
      VALUES (v_contact_id, 'Øyvind Telum', '926 37 107', 'ot@dpend.no', true)
      RETURNING id INTO v_person_1;
    INSERT INTO public.contact_people (contact_id, full_name, phone, email, is_primary)
      VALUES (v_contact_id, 'Hans Petter Skott-Myhre', '-', 'hmyhre@dpend.no', false)
      RETURNING id INTO v_person_2;

    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2021-09-27', v_person_1, 'mote', 'firmapresentasjon');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2021-10-12', NULL, 'annet', '1,2/mail/produkteksempler');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2022-03-02', v_person_1, 'epost', 'oppfølgning');

    INSERT INTO public.contact_specialties (contact_id, specialty_id)
      SELECT v_contact_id, s.id FROM public.specialties s WHERE s.name IN ('Eiendom', 'Bygg')
      ON CONFLICT DO NOTHING;
  END IF;
END $$;

DO $$
DECLARE
  v_contact_id uuid;
  v_person_1 uuid;
BEGIN
  IF NOT EXISTS (SELECT 1 FROM public.contacts WHERE lower(company_name) = lower('Ingeniørservice AS')) THEN
    INSERT INTO public.contacts (company_name, phone, email, website, country, status)
      VALUES ('Ingeniørservice AS', '950 80 180', 'ai@ingserv.no', 'https://www.ingserv.no/', 'Norge', 'kontaktet')
      RETURNING id INTO v_contact_id;

    INSERT INTO public.contact_people (contact_id, full_name, phone, email, is_primary)
      VALUES (v_contact_id, 'Arild Iversen', '950 80 180', 'ai@ingserv.no', true)
      RETURNING id INTO v_person_1;

    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2022-03-02', v_person_1, 'epost', 'firmapresentasjon');

    INSERT INTO public.contact_specialties (contact_id, specialty_id)
      SELECT v_contact_id, s.id FROM public.specialties s WHERE s.name IN ('Anlegg')
      ON CONFLICT DO NOTHING;
  END IF;
END $$;
