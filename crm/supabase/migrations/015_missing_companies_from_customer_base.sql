-- Migracja 015: 13 firm z Kopi_av_Company_customer_base.xlsx (Ark1) pominietych przy
-- pierwotnym imporcie (migracja 006) - zweryfikowano ze uploadowany plik jest tym samym
-- zrodlem co wtedy (identyczne literowki w danych: "23.022021", "30.11.0202", te same
-- 84 firmy w Ark1, te same ostatnie daty kontaktu do 2026-03-10), wiec caly plik poza tymi
-- 13 firmami jest juz w bazie. Zadnych nowszych wpisow Historikk (po marcu 2026) w pliku nie ma.
-- Uruchom w Supabase Dashboard -> SQL Editor -> Run. Bezpieczna do ponownego uruchomienia
-- (kazdy blok sprawdza NOT EXISTS po nazwie firmy przed importem, jak w migracji 006).
--
-- Brakujace firmy: Eiqon, Sapinor, Acciona, Peab, AF Gruppen, J.I.Bygg AS,
-- Betonmast Romerike AS, Furulund-Maskin, Oslo Byggentreprenør AS, Ingeniørfirma Big AS,
-- Dala Infra Group AB, STØ Entreprenør, MA Totalbygg.
--
-- Nazwy firm zapisane w zrodle WIELKIMI LITERAMI ujednolicono do normalnej wielkosci liter
-- (ta sama konwencja co migracja 008), z zachowaniem krotkich inicjalow/akronimow tam gdzie
-- pasuje do istniejacego wzorca w bazie (np. "MA Totalbygg", "STØ Entreprenør" - por.
-- "KN Entreprenør AS", "PS Anlegg AS", "R3 Entreprenør AS"). "PEAB" (Land: "Swerige, Norge"
-- w zrodle - literowka) poprawiono na "Peab" / "Sverige, Norge" (poprawna pisownia "Sverige"
-- wystepuje juz gdzie indziej w tym samym pliku, dla Dala Infra Group AB).
--
-- Kazdy wpis Historikk przypisany jest do glownej osoby kontaktowej firmy (is_primary),
-- niezaleznie od tego, ktory numer ID podano w zrodlowym "Kontakt: ID/TYPE/KOMMENTAR" -
-- ta sama konwencja co poprawka w migracji 007. Typ kontaktu wyprowadzony z metody
-- ("mail"->epost, "tel"->telefon, "møte"/"besøk"->mote).
--
-- Pominieto: dla Eiqon drugi wpis "kontaktowy" bez imienia (tylko e-mail
-- ragnar.reitan@implenia.com - najpewniej ta sama osoba po zmianie pracodawcy, ale bez
-- imienia nie da sie tego wstawic jako pelnoprawnej osoby kontaktowej: full_name jest
-- wymagane). Dla Oslo Byggentreprenør AS pominieto duplikat 4. wiersza (to samo imie i
-- nazwisko co osoba 1, bez dodatkowych danych).
--
-- Nowa branza (Fagområde) dla Ingeniørfirma Big AS: "Landmåling" (Geodesy/Surveying) -
-- nie bylo jej jeszcze w kanonicznej liscie z migracji 006.
insert into public.specialties (name) values
  ('Landmåling')
on conflict (name) do nothing;

DO $$
DECLARE
  v_contact_id uuid;
  v_person_1 uuid;
BEGIN
  IF NOT EXISTS (SELECT 1 FROM public.contacts WHERE lower(company_name) = lower('Eiqon')) THEN
    INSERT INTO public.contacts (company_name, phone, email, website, country)
      VALUES ('Eiqon', '951 20 105', 'ragnar.reitan@eiqon.no', 'https://www.eiqon.no/kontakt/', 'Norge')
      RETURNING id INTO v_contact_id;

    INSERT INTO public.contact_people (contact_id, full_name, phone, email, is_primary)
      VALUES (v_contact_id, 'Ragnar Reitan', '951 20 105', 'ragnar.reitan@eiqon.no', true)
      RETURNING id INTO v_person_1;

    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2020-08-17', v_person_1, 'epost', 'hils');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2020-10-13', v_person_1, 'epost', 'standard tilbud');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2020-11-24', v_person_1, 'epost', 'standard tilbud');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2021-01-05', v_person_1, 'epost', 'hils');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2026-02-06', v_person_1, 'epost', 'hils');

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
  IF NOT EXISTS (SELECT 1 FROM public.contacts WHERE lower(company_name) = lower('Sapinor')) THEN
    INSERT INTO public.contacts (company_name, phone, email, website, country)
      VALUES ('Sapinor', '484 00 682', 'f.picin@sapinorjv.no', 'https://www.banenor.no/nykirke-barkaker/', 'Italia')
      RETURNING id INTO v_contact_id;

    INSERT INTO public.contact_people (contact_id, full_name, phone, email, is_primary)
      VALUES (v_contact_id, 'Francesca Picin', '484 00 682', 'f.picin@sapinorjv.no', true)
      RETURNING id INTO v_person_1;
    INSERT INTO public.contact_people (contact_id, full_name, phone, email, is_primary)
      VALUES (v_contact_id, 'Alexandra Tomkova', '412 66 787', 'a.tomkova@sapinorjv.no', false)
      RETURNING id INTO v_person_2;
    INSERT INTO public.contact_people (contact_id, full_name, phone, email, is_primary)
      VALUES (v_contact_id, 'Michelangelo Costanzo', '467 41 428', 'm.costanzo@sapinorjv.no', false)
      RETURNING id INTO v_person_3;

    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2020-09-09', v_person_1, 'epost', 'hils');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2020-09-16', v_person_1, 'epost', 'BaneNor ny kirkeveien');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2020-10-08', v_person_1, 'epost', 'BaneNor ny kirkeveien');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2020-10-29', v_person_1, 'epost', 'oppdatering');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2020-11-17', v_person_1, 'telefon', 'oppdatering');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2020-11-27', v_person_1, 'epost', 'oferta na drona');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2021-02-04', v_person_1, 'epost', 'oferta na tunnel skanning');

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
  v_person_3 uuid;
BEGIN
  IF NOT EXISTS (SELECT 1 FROM public.contacts WHERE lower(company_name) = lower('Acciona')) THEN
    INSERT INTO public.contacts (company_name, phone, email, website, country)
      VALUES ('Acciona', '465 48 430', 'arturo.miguel.gallego@acciona.com', 'https://www.acciona.no/no/prosjekter', 'Spania, Norge')
      RETURNING id INTO v_contact_id;

    INSERT INTO public.contact_people (contact_id, full_name, phone, email, is_primary)
      VALUES (v_contact_id, 'Arturo Miguel Gallego', '465 48 430', 'arturo.miguel.gallego@acciona.com', true)
      RETURNING id INTO v_person_1;
    INSERT INTO public.contact_people (contact_id, full_name, phone, email, is_primary)
      VALUES (v_contact_id, 'Rafael Rodriguez', '904 79 940', 'rrodrigu@outlook.com', false)
      RETURNING id INTO v_person_2;
    INSERT INTO public.contact_people (contact_id, full_name, phone, email, is_primary)
      VALUES (v_contact_id, 'Carlos Maldonado', '920 57 745', NULL, false)
      RETURNING id INTO v_person_3;

    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2020-09-09', v_person_1, 'epost', 'hils');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2020-09-16', v_person_1, 'epost', 'E6 Ranheim-Værnes');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2020-08-10', v_person_1, 'epost', 'oppdatering');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2021-02-23', v_person_1, 'epost', 'standard tilbud');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2022-03-11', v_person_1, 'epost', 'oppdatering');

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
  IF NOT EXISTS (SELECT 1 FROM public.contacts WHERE lower(company_name) = lower('Peab')) THEN
    INSERT INTO public.contacts (company_name, phone, email, website, country)
      VALUES ('Peab', '455 12 855', 'goran.fossmo@peab.no', 'https://peab.no/', 'Sverige, Norge')
      RETURNING id INTO v_contact_id;

    INSERT INTO public.contact_people (contact_id, full_name, phone, email, is_primary)
      VALUES (v_contact_id, 'Gøran Fossmo', '455 12 855', 'goran.fossmo@peab.no', true)
      RETURNING id INTO v_person_1;
    INSERT INTO public.contact_people (contact_id, full_name, phone, email, is_primary)
      VALUES (v_contact_id, 'Petter Johansen', NULL, 'petter.johansen@peab.no', false)
      RETURNING id INTO v_person_2;

    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2020-10-13', v_person_1, 'epost', 'Grong kommune - bru');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2020-10-16', v_person_1, 'epost', 'oppdatering');

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
  IF NOT EXISTS (SELECT 1 FROM public.contacts WHERE lower(company_name) = lower('AF Gruppen')) THEN
    INSERT INTO public.contacts (company_name, phone, email, website, country)
      VALUES ('AF Gruppen', '922 24 148', 'jon.braten@afgruppen.no', 'https://afgruppen.no/', 'Norge')
      RETURNING id INTO v_contact_id;

    INSERT INTO public.contact_people (contact_id, full_name, phone, email, is_primary)
      VALUES (v_contact_id, 'Jon Bråten', '922 24 148', 'jon.braten@afgruppen.no', true)
      RETURNING id INTO v_person_1;

    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2020-10-15', v_person_1, 'epost', 'Grefsen base');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2020-11-27', v_person_1, 'epost', 'standard tilbud');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2021-02-25', v_person_1, 'epost', 'oppdatering');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2024-01-06', v_person_1, 'epost', 'oppdatering');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2026-02-06', v_person_1, 'epost', 'oppdatering');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2026-03-10', v_person_1, 'epost', 'fastmerker');

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
  IF NOT EXISTS (SELECT 1 FROM public.contacts WHERE lower(company_name) = lower('J.I.Bygg AS')) THEN
    INSERT INTO public.contacts (company_name, phone, email, website, country)
      VALUES ('J.I.Bygg AS', '908 44 960', 'lars@jibygg.no', 'https://www.jibygg.no/', 'Norge')
      RETURNING id INTO v_contact_id;

    INSERT INTO public.contact_people (contact_id, full_name, phone, email, is_primary)
      VALUES (v_contact_id, 'Lars Edvardsen', '908 44 960', 'lars@jibygg.no', true)
      RETURNING id INTO v_person_1;
    INSERT INTO public.contact_people (contact_id, full_name, phone, email, is_primary)
      VALUES (v_contact_id, 'Lasse Syversen', '916 50 847', 'lasse@jibygg.no', false)
      RETURNING id INTO v_person_2;

    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2020-11-02', v_person_1, 'epost', 'standard tilbud');
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
  v_person_2 uuid;
  v_person_3 uuid;
  v_person_4 uuid;
  v_person_5 uuid;
BEGIN
  IF NOT EXISTS (SELECT 1 FROM public.contacts WHERE lower(company_name) = lower('Betonmast Romerike AS')) THEN
    INSERT INTO public.contacts (company_name, phone, email, website, country)
      VALUES ('Betonmast Romerike AS', '911 51 003', 'olav.tveit@betonmast.no', 'https://www.betonmast.no/selskaper/betonmast-romerike/', 'Norge')
      RETURNING id INTO v_contact_id;

    INSERT INTO public.contact_people (contact_id, full_name, phone, email, is_primary)
      VALUES (v_contact_id, 'Olav Tveit', '911 51 003', 'olav.tveit@betonmast.no', true)
      RETURNING id INTO v_person_1;
    INSERT INTO public.contact_people (contact_id, full_name, phone, email, is_primary)
      VALUES (v_contact_id, 'Per Anders Muri', '911 16 121', 'per.anders.muri@betonmast.no', false)
      RETURNING id INTO v_person_2;
    INSERT INTO public.contact_people (contact_id, full_name, phone, email, is_primary)
      VALUES (v_contact_id, 'Audun Vonen', '951 45 380', 'audun.vonen@betonmast.no', false)
      RETURNING id INTO v_person_3;
    INSERT INTO public.contact_people (contact_id, full_name, phone, email, is_primary)
      VALUES (v_contact_id, 'Thomas Brasen', '928 39 338', 'thomas.brasen@betonmast.no', false)
      RETURNING id INTO v_person_4;
    INSERT INTO public.contact_people (contact_id, full_name, phone, email, is_primary)
      VALUES (v_contact_id, 'Jasjeet Singh Saluja', '464 00 044', 'jasjeet.singh@betonmast.no', false)
      RETURNING id INTO v_person_5;

    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2020-11-02', v_person_1, 'epost', 'standerd tilbud');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2020-11-27', v_person_1, 'epost', 'oppdatering');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2021-02-18', v_person_1, 'epost', 'oppdatering');

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
  IF NOT EXISTS (SELECT 1 FROM public.contacts WHERE lower(company_name) = lower('Furulund-Maskin')) THEN
    INSERT INTO public.contacts (company_name, phone, email, website, country)
      VALUES ('Furulund-Maskin', '948 88 666', 'sindre@furulund-maskin.no', 'https://furulund-maskin.no/', 'Norge')
      RETURNING id INTO v_contact_id;

    INSERT INTO public.contact_people (contact_id, full_name, phone, email, is_primary)
      VALUES (v_contact_id, 'Sindre Tobias Furulund', '948 88 666', 'sindre@furulund-maskin.no', true)
      RETURNING id INTO v_person_1;

    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2020-11-03', v_person_1, 'epost', 'FINN.no søker landmålere');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2020-11-17', v_person_1, 'epost', 'standard tilbud');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2021-02-25', v_person_1, 'epost', 'oppdatering');

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
  IF NOT EXISTS (SELECT 1 FROM public.contacts WHERE lower(company_name) = lower('Oslo Byggentreprenør AS')) THEN
    INSERT INTO public.contacts (company_name, phone, email, website, country)
      VALUES ('Oslo Byggentreprenør AS', '982 17 050', 'jhs@obe.no', 'https://obe.no/', 'Norge')
      RETURNING id INTO v_contact_id;

    INSERT INTO public.contact_people (contact_id, full_name, phone, email, is_primary)
      VALUES (v_contact_id, 'Jens Herman Svartdahl', '982 17 050', 'jhs@obe.no', true)
      RETURNING id INTO v_person_1;
    INSERT INTO public.contact_people (contact_id, full_name, phone, email, is_primary)
      VALUES (v_contact_id, 'Marius Taftø Petersen', '982 17 083', 'mtp@obe.no', false)
      RETURNING id INTO v_person_2;
    INSERT INTO public.contact_people (contact_id, full_name, phone, email, is_primary)
      VALUES (v_contact_id, 'Merete Syrdahl Steen', '900 84 042', 'mss@obe.no', false)
      RETURNING id INTO v_person_3;

    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2020-11-30', v_person_1, 'epost', 'standard tilbud');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2021-01-29', v_person_1, 'epost', 'oppdatering');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2021-02-03', v_person_1, 'epost', 'godtkjent tilbud');

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
  IF NOT EXISTS (SELECT 1 FROM public.contacts WHERE lower(company_name) = lower('Ingeniørfirma Big AS')) THEN
    INSERT INTO public.contacts (company_name, phone, email, website, country)
      VALUES ('Ingeniørfirma Big AS', '905 50 305', 'kenneth@bigas.no', 'https://bigas.no/', 'Norge')
      RETURNING id INTO v_contact_id;

    INSERT INTO public.contact_people (contact_id, full_name, phone, email, is_primary)
      VALUES (v_contact_id, 'Kenneth Høiom', '905 50 305', 'kenneth@bigas.no', true)
      RETURNING id INTO v_person_1;

    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2020-12-04', v_person_1, 'epost', 'standard tilbud');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2021-01-29', v_person_1, 'epost', 'oppdatering');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2021-02-26', v_person_1, 'epost', 'oppdatering');

    INSERT INTO public.contact_specialties (contact_id, specialty_id)
      SELECT v_contact_id, s.id FROM public.specialties s WHERE s.name IN ('Landmåling')
      ON CONFLICT DO NOTHING;
  END IF;
END $$;

DO $$
DECLARE
  v_contact_id uuid;
  v_person_1 uuid;
BEGIN
  IF NOT EXISTS (SELECT 1 FROM public.contacts WHERE lower(company_name) = lower('Dala Infra Group AB')) THEN
    INSERT INTO public.contacts (company_name, phone, email, website, country)
      VALUES ('Dala Infra Group AB', '+46 730 40 025', 'mattias@dalaconsulting.se', 'https://www.dalainfragroup.se/', 'Sverige')
      RETURNING id INTO v_contact_id;

    INSERT INTO public.contact_people (contact_id, full_name, phone, email, is_primary)
      VALUES (v_contact_id, 'Mattias Lundmark', '+46 730 40 025', 'mattias@dalaconsulting.se', true)
      RETURNING id INTO v_person_1;

    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2021-02-02', v_person_1, 'epost', 'UDK05 Drammen Kobbervikdalen');
    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2021-02-03', v_person_1, 'epost', 'oppdatering');

    INSERT INTO public.contact_specialties (contact_id, specialty_id)
      SELECT v_contact_id, s.id FROM public.specialties s WHERE s.name IN ('Bane')
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
  IF NOT EXISTS (SELECT 1 FROM public.contacts WHERE lower(company_name) = lower('STØ Entreprenør')) THEN
    INSERT INTO public.contacts (company_name, phone, email, website, country)
      VALUES ('STØ Entreprenør', '472 55 226', 'jan.martin.smordal@stoent.no', 'https://www.stoent.no/', 'Norge')
      RETURNING id INTO v_contact_id;

    INSERT INTO public.contact_people (contact_id, full_name, phone, email, is_primary)
      VALUES (v_contact_id, 'Jan Martin Smordal', '472 55 226', 'jan.martin.smordal@stoent.no', true)
      RETURNING id INTO v_person_1;
    INSERT INTO public.contact_people (contact_id, full_name, phone, email, is_primary)
      VALUES (v_contact_id, 'Per Kristian Østbye', '994 65 383', 'per.kristian.ostbye@stoent.no', false)
      RETURNING id INTO v_person_2;
    INSERT INTO public.contact_people (contact_id, full_name, phone, email, is_primary)
      VALUES (v_contact_id, 'Ole Kristian Ruud', '934 18 529', 'ole.kristian.ruud@stoent.no', false)
      RETURNING id INTO v_person_3;

    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2021-03-04', v_person_1, 'epost', 'standard tilbud');

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
  IF NOT EXISTS (SELECT 1 FROM public.contacts WHERE lower(company_name) = lower('MA Totalbygg')) THEN
    INSERT INTO public.contacts (company_name, phone, email, website, country)
      VALUES ('MA Totalbygg', '951 90 034', 'lasse@matotalbygg.no', 'https://matotalbygg.no/', 'Norge')
      RETURNING id INTO v_contact_id;

    INSERT INTO public.contact_people (contact_id, full_name, phone, email, is_primary)
      VALUES (v_contact_id, 'Lasse Meuche', '951 90 034', 'lasse@matotalbygg.no', true)
      RETURNING id INTO v_person_1;
    INSERT INTO public.contact_people (contact_id, full_name, phone, email, is_primary)
      VALUES (v_contact_id, 'Roy A. Allesøe', '951 90 065', 'roy@matotalbygg.no', false)
      RETURNING id INTO v_person_2;
    INSERT INTO public.contact_people (contact_id, full_name, phone, email, is_primary)
      VALUES (v_contact_id, 'Mariusz Keska', '936 49 959', 'mariusz@matotalbygg.no', false)
      RETURNING id INTO v_person_3;

    INSERT INTO public.contact_activities (contact_id, occurred_at, person_id, contact_type, note)
      VALUES (v_contact_id, '2021-03-04', v_person_1, 'epost', 'standard tilbud');

    INSERT INTO public.contact_specialties (contact_id, specialty_id)
      SELECT v_contact_id, s.id FROM public.specialties s WHERE s.name IN ('Bygg')
      ON CONFLICT DO NOTHING;
  END IF;
END $$;
