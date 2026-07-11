-- Migracja 007: poprawka parsowania Historikk dla wpisow z wieloma/zakresowymi ID kontaktow
-- (np. "1, 2/mail/oppdatering", "1-7/mail/...", "1.2/mail/...") - poprzedni parser
-- w migracji 006 rozpoznawal tylko pojedyncze ID przed pierwszym "/", wiec dla takich
-- wpisow typ kontaktu i komentarz nie zostaly poprawnie wyciagniete (caly surowy tekst
-- trafil jako komentarz, typ ustawiony na 'annet').
-- Uruchom w Supabase Dashboard -> SQL Editor -> Run. Bezpieczna do ponownego uruchomienia
-- (warunek 'contact_type = starego typu' przestaje pasowac po pierwszej poprawnej aktualizacji).

DO $$
DECLARE v_contact_id uuid; v_primary_person uuid;
BEGIN
  SELECT id INTO v_contact_id FROM public.contacts WHERE lower(company_name) = lower('SKANSKA Skanska Surwey');
  IF v_contact_id IS NOT NULL THEN
    SELECT id INTO v_primary_person FROM public.contact_people WHERE contact_id = v_contact_id AND is_primary = true LIMIT 1;
    UPDATE public.contact_activities
      SET note = 'standard tilbud', contact_type = 'epost', person_id = v_primary_person
      WHERE contact_id = v_contact_id AND occurred_at = '2020-11-09'
        AND note = '1, 2, 3/mail/standard tilbud' AND contact_type = 'annet';
    UPDATE public.contact_activities
      SET note = 'standard tilbud', contact_type = 'epost', person_id = v_primary_person
      WHERE contact_id = v_contact_id AND occurred_at = '2020-11-13'
        AND note = '1, 2, 3/mail/standard tilbud' AND contact_type = 'annet';
    UPDATE public.contact_activities
      SET note = 'standard tilbud', contact_type = 'epost', person_id = v_primary_person
      WHERE contact_id = v_contact_id AND occurred_at = '2021-02-23'
        AND note = '1, 2, 3/mail/standard tilbud' AND contact_type = 'annet';
    UPDATE public.contact_activities
      SET note = 'standard tilbud', contact_type = 'epost', person_id = v_primary_person
      WHERE contact_id = v_contact_id AND occurred_at = '2021-03-05'
        AND note = '1, 2, 3/mail/standard tilbud' AND contact_type = 'annet';
    UPDATE public.contact_activities
      SET note = 'standard tilbud', contact_type = 'epost', person_id = v_primary_person
      WHERE contact_id = v_contact_id AND occurred_at = '2021-03-25'
        AND note = '1, 2, 3/mail/standard tilbud' AND contact_type = 'annet';
    UPDATE public.contact_activities
      SET note = 'standard tilbud', contact_type = 'epost', person_id = v_primary_person
      WHERE contact_id = v_contact_id AND occurred_at = '2021-10-18'
        AND note = '1, 2, 3/mail/standard tilbud' AND contact_type = 'annet';
  END IF;
END $$;

DO $$
DECLARE v_contact_id uuid; v_primary_person uuid;
BEGIN
  SELECT id INTO v_contact_id FROM public.contacts WHERE lower(company_name) = lower('Metacon AS');
  IF v_contact_id IS NOT NULL THEN
    SELECT id INTO v_primary_person FROM public.contact_people WHERE contact_id = v_contact_id AND is_primary = true LIMIT 1;
    UPDATE public.contact_activities
      SET note = 'standard tilbud', contact_type = 'epost', person_id = v_primary_person
      WHERE contact_id = v_contact_id AND occurred_at = '2020-08-21'
        AND note = '1, 2/mail/standard tilbud' AND contact_type = 'annet';
    UPDATE public.contact_activities
      SET note = 'standard tilbud', contact_type = 'epost', person_id = v_primary_person
      WHERE contact_id = v_contact_id AND occurred_at = NULL
        AND note = '1, 2/mail/standard tilbud' AND contact_type = 'annet';
    UPDATE public.contact_activities
      SET note = 'oppdatering', contact_type = 'epost', person_id = v_primary_person
      WHERE contact_id = v_contact_id AND occurred_at = '2021-03-05'
        AND note = '1, 2/mail/oppdatering' AND contact_type = 'annet';
    UPDATE public.contact_activities
      SET note = 'standard tilbud til ny daglig leder og markedssjef', contact_type = 'epost', person_id = v_primary_person
      WHERE contact_id = v_contact_id AND occurred_at = '2022-03-09'
        AND note = '1,2/mail/standard tilbud til ny daglig leder og markedssjef' AND contact_type = 'annet';
  END IF;
END $$;

DO $$
DECLARE v_contact_id uuid; v_primary_person uuid;
BEGIN
  SELECT id INTO v_contact_id FROM public.contacts WHERE lower(company_name) = lower('Agro Anlegg AS');
  IF v_contact_id IS NOT NULL THEN
    SELECT id INTO v_primary_person FROM public.contact_people WHERE contact_id = v_contact_id AND is_primary = true LIMIT 1;
    UPDATE public.contact_activities
      SET note = 'standard tilbud', contact_type = 'epost', person_id = v_primary_person
      WHERE contact_id = v_contact_id AND occurred_at = '2020-11-13'
        AND note = '1, 2/mail/standard tilbud' AND contact_type = 'annet';
    UPDATE public.contact_activities
      SET note = 'standard tilbud', contact_type = 'epost', person_id = v_primary_person
      WHERE contact_id = v_contact_id AND occurred_at = '2020-11-03'
        AND note = '1, 2/mail/standard tilbud' AND contact_type = 'annet';
    UPDATE public.contact_activities
      SET note = 'standard tilbud', contact_type = 'epost', person_id = v_primary_person
      WHERE contact_id = v_contact_id AND occurred_at = '2020-11-27'
        AND note = '1, 2/mail/standard tilbud' AND contact_type = 'annet';
    UPDATE public.contact_activities
      SET note = 'Asker Kirkevien-Drammensveien', contact_type = 'epost', person_id = v_primary_person
      WHERE contact_id = v_contact_id AND occurred_at = '2020-11-30'
        AND note = '1, 2/mail/Asker Kirkevien-Drammensveien' AND contact_type = 'annet';
    UPDATE public.contact_activities
      SET note = 'oppdatering', contact_type = 'epost', person_id = v_primary_person
      WHERE contact_id = v_contact_id AND occurred_at = '2021-02-23'
        AND note = '1, 2/mail/oppdatering' AND contact_type = 'annet';
    UPDATE public.contact_activities
      SET note = 'oppdatering', contact_type = 'epost', person_id = v_primary_person
      WHERE contact_id = v_contact_id AND occurred_at = '2021-10-18'
        AND note = '1, 2/mail/oppdatering' AND contact_type = 'annet';
    UPDATE public.contact_activities
      SET note = 'oppfølgning', contact_type = 'epost', person_id = v_primary_person
      WHERE contact_id = v_contact_id AND occurred_at = '2022-03-09'
        AND note = '1,2/mail/oppfølgning' AND contact_type = 'annet';
  END IF;
END $$;

DO $$
DECLARE v_contact_id uuid; v_primary_person uuid;
BEGIN
  SELECT id INTO v_contact_id FROM public.contacts WHERE lower(company_name) = lower('Isachsen Anlegg AS');
  IF v_contact_id IS NOT NULL THEN
    SELECT id INTO v_primary_person FROM public.contact_people WHERE contact_id = v_contact_id AND is_primary = true LIMIT 1;
    UPDATE public.contact_activities
      SET note = 'hils', contact_type = 'epost', person_id = v_primary_person
      WHERE contact_id = v_contact_id AND occurred_at = '2020-09-01'
        AND note = '1, 2/mail/hils' AND contact_type = 'annet';
    UPDATE public.contact_activities
      SET note = 'Asker Kirkevien-Drammensveien', contact_type = 'epost', person_id = v_primary_person
      WHERE contact_id = v_contact_id AND occurred_at = '2020-11-13'
        AND note = '1, 2/mail/Asker Kirkevien-Drammensveien' AND contact_type = 'annet';
    UPDATE public.contact_activities
      SET note = 'standard tilbud', contact_type = 'epost', person_id = v_primary_person
      WHERE contact_id = v_contact_id AND occurred_at = '2020-11-27'
        AND note = '1,2/mail, tel/standard tilbud' AND contact_type = 'annet';
    UPDATE public.contact_activities
      SET note = 'oppdatering', contact_type = 'epost', person_id = v_primary_person
      WHERE contact_id = v_contact_id AND occurred_at = '2021-02-23'
        AND note = '1,2/mail, tel/oppdatering' AND contact_type = 'annet';
    UPDATE public.contact_activities
      SET note = 'oppfølgning', contact_type = 'epost', person_id = v_primary_person
      WHERE contact_id = v_contact_id AND occurred_at = '2022-03-09'
        AND note = '1,2,3/mail/oppfølgning' AND contact_type = 'annet';
  END IF;
END $$;

DO $$
DECLARE v_contact_id uuid; v_primary_person uuid;
BEGIN
  SELECT id INTO v_contact_id FROM public.contacts WHERE lower(company_name) = lower('NRC');
  IF v_contact_id IS NOT NULL THEN
    SELECT id INTO v_primary_person FROM public.contact_people WHERE contact_id = v_contact_id AND is_primary = true LIMIT 1;
    UPDATE public.contact_activities
      SET note = 'Kai Statnet Skien', contact_type = 'epost', person_id = v_primary_person
      WHERE contact_id = v_contact_id AND occurred_at = '2020-08-26'
        AND note = '1, 2/tel, mail/Kai Statnet Skien' AND contact_type = 'annet';
    UPDATE public.contact_activities
      SET note = 'oppdatering', contact_type = 'epost', person_id = v_primary_person
      WHERE contact_id = v_contact_id AND occurred_at = '2020-09-03'
        AND note = '1, 3/mail/oppdatering' AND contact_type = 'annet';
    UPDATE public.contact_activities
      SET note = 'standard tilbud', contact_type = 'epost', person_id = v_primary_person
      WHERE contact_id = v_contact_id AND occurred_at = '2020-10-28'
        AND note = '1, 3/mail/standard tilbud' AND contact_type = 'annet';
    UPDATE public.contact_activities
      SET note = 'oppdatering', contact_type = 'epost', person_id = v_primary_person
      WHERE contact_id = v_contact_id AND occurred_at = '2020-11-27'
        AND note = '1, 3/mail/oppdatering' AND contact_type = 'annet';
    UPDATE public.contact_activities
      SET note = 'oppdatering', contact_type = 'epost', person_id = v_primary_person
      WHERE contact_id = v_contact_id AND occurred_at = '2021-02-23'
        AND note = '1, 3/mail/oppdatering' AND contact_type = 'annet';
    UPDATE public.contact_activities
      SET note = 'oppdatering', contact_type = 'epost', person_id = v_primary_person
      WHERE contact_id = v_contact_id AND occurred_at = '2021-03-05'
        AND note = '1, 3/mail/oppdatering' AND contact_type = 'annet';
    UPDATE public.contact_activities
      SET note = 'oppdatering', contact_type = 'epost', person_id = v_primary_person
      WHERE contact_id = v_contact_id AND occurred_at = '2021-03-24'
        AND note = '1, 3/mail/oppdatering' AND contact_type = 'annet';
    UPDATE public.contact_activities
      SET note = 'oppdatering', contact_type = 'epost', person_id = v_primary_person
      WHERE contact_id = v_contact_id AND occurred_at = '2021-07-01'
        AND note = '1, 3/mail/oppdatering' AND contact_type = 'annet';
    UPDATE public.contact_activities
      SET note = 'oppdatering', contact_type = 'epost', person_id = v_primary_person
      WHERE contact_id = v_contact_id AND occurred_at = '2021-10-27'
        AND note = '1, 3/mail/oppdatering' AND contact_type = 'annet';
    UPDATE public.contact_activities
      SET note = 'oppfølgning', contact_type = 'epost', person_id = v_primary_person
      WHERE contact_id = v_contact_id AND occurred_at = '2022-03-09'
        AND note = '1,2,3/mail/oppfølgning' AND contact_type = 'annet';
    UPDATE public.contact_activities
      SET note = 'oppdatering og fastmerker', contact_type = 'epost', person_id = v_primary_person
      WHERE contact_id = v_contact_id AND occurred_at = '2026-03-10'
        AND note = '1,2,3/mail/oppdatering og fastmerker' AND contact_type = 'annet';
  END IF;
END $$;

DO $$
DECLARE v_contact_id uuid; v_primary_person uuid;
BEGIN
  SELECT id INTO v_contact_id FROM public.contacts WHERE lower(company_name) = lower('Marthinsen & Duvholt');
  IF v_contact_id IS NOT NULL THEN
    SELECT id INTO v_primary_person FROM public.contact_people WHERE contact_id = v_contact_id AND is_primary = true LIMIT 1;
    UPDATE public.contact_activities
      SET note = 'standard tilbud', contact_type = 'epost', person_id = v_primary_person
      WHERE contact_id = v_contact_id AND occurred_at = '2020-09-21'
        AND note = '1, 2/mail/standard tilbud' AND contact_type = 'annet';
    UPDATE public.contact_activities
      SET note = 'rammeavtale tilbud', contact_type = 'epost', person_id = v_primary_person
      WHERE contact_id = v_contact_id AND occurred_at = '2020-10-23'
        AND note = '1, 2/mail/rammeavtale tilbud' AND contact_type = 'annet';
    UPDATE public.contact_activities
      SET note = 'oppdatering', contact_type = 'telefon', person_id = v_primary_person
      WHERE contact_id = v_contact_id AND occurred_at = '2020-11-17'
        AND note = '1, 2/tel./oppdatering' AND contact_type = 'annet';
    UPDATE public.contact_activities
      SET note = 'oppdatering', contact_type = 'epost', person_id = v_primary_person
      WHERE contact_id = v_contact_id AND occurred_at = '2021-02-23'
        AND note = '1, 2/mail/oppdatering' AND contact_type = 'annet';
    UPDATE public.contact_activities
      SET note = 'oppdatering', contact_type = 'epost', person_id = v_primary_person
      WHERE contact_id = v_contact_id AND occurred_at = '2021-03-05'
        AND note = '1, 2/mail/oppdatering' AND contact_type = 'annet';
    UPDATE public.contact_activities
      SET note = 'oppdatering', contact_type = 'epost', person_id = v_primary_person
      WHERE contact_id = v_contact_id AND occurred_at = '2021-10-18'
        AND note = '1, 2/mail/oppdatering' AND contact_type = 'annet';
  END IF;
END $$;

DO $$
DECLARE v_contact_id uuid; v_primary_person uuid;
BEGIN
  SELECT id INTO v_contact_id FROM public.contacts WHERE lower(company_name) = lower('OHLA (OHL) Norge');
  IF v_contact_id IS NOT NULL THEN
    SELECT id INTO v_primary_person FROM public.contact_people WHERE contact_id = v_contact_id AND is_primary = true LIMIT 1;
    UPDATE public.contact_activities
      SET note = 'Ny E18 Sandvika Asker', contact_type = 'mote', person_id = v_primary_person
      WHERE contact_id = v_contact_id AND occurred_at = '2022-01-20'
        AND note = '1, 2/besøk/Ny E18 Sandvika Asker' AND contact_type = 'annet';
  END IF;
END $$;

DO $$
DECLARE v_contact_id uuid; v_primary_person uuid;
BEGIN
  SELECT id INTO v_contact_id FROM public.contacts WHERE lower(company_name) = lower('ANLEGG ØST');
  IF v_contact_id IS NOT NULL THEN
    SELECT id INTO v_primary_person FROM public.contact_people WHERE contact_id = v_contact_id AND is_primary = true LIMIT 1;
    UPDATE public.contact_activities
      SET note = 'Bruer RV3 i Rendalen', contact_type = 'epost', person_id = v_primary_person
      WHERE contact_id = v_contact_id AND occurred_at = '2020-10-13'
        AND note = '1, 2/mail/Bruer RV3 i Rendalen' AND contact_type = 'annet';
    UPDATE public.contact_activities
      SET note = 'standard tilbud', contact_type = 'epost', person_id = v_primary_person
      WHERE contact_id = v_contact_id AND occurred_at = '2020-11-27'
        AND note = '1, 2/mail/standard tilbud' AND contact_type = 'annet';
    UPDATE public.contact_activities
      SET note = 'oppdatering', contact_type = 'epost', person_id = v_primary_person
      WHERE contact_id = v_contact_id AND occurred_at = '2021-03-05'
        AND note = '1, 2/mail/oppdatering' AND contact_type = 'annet';
  END IF;
END $$;

DO $$
DECLARE v_contact_id uuid; v_primary_person uuid;
BEGIN
  SELECT id INTO v_contact_id FROM public.contacts WHERE lower(company_name) = lower('IMPLENIA Norge AS');
  IF v_contact_id IS NOT NULL THEN
    SELECT id INTO v_primary_person FROM public.contact_people WHERE contact_id = v_contact_id AND is_primary = true LIMIT 1;
    UPDATE public.contact_activities
      SET note = 'standard tilbud', contact_type = 'epost', person_id = v_primary_person
      WHERE contact_id = v_contact_id AND occurred_at = '2020-08-18'
        AND note = '1, 2/mail/standard tilbud' AND contact_type = 'annet';
    UPDATE public.contact_activities
      SET note = 'oppdatering', contact_type = 'epost', person_id = v_primary_person
      WHERE contact_id = v_contact_id AND occurred_at = '2020-08-20'
        AND note = '1, 2/mail/oppdatering' AND contact_type = 'annet';
    UPDATE public.contact_activities
      SET note = 'oppdatering', contact_type = 'epost', person_id = v_primary_person
      WHERE contact_id = v_contact_id AND occurred_at = '2020-11-26'
        AND note = '1, 2/mail/oppdatering' AND contact_type = 'annet';
    UPDATE public.contact_activities
      SET note = 'oppdatering', contact_type = 'epost', person_id = v_primary_person
      WHERE contact_id = v_contact_id AND occurred_at = '2021-02-23'
        AND note = '1, 2/mail/oppdatering' AND contact_type = 'annet';
    UPDATE public.contact_activities
      SET note = 'oppdatering', contact_type = 'epost', person_id = v_primary_person
      WHERE contact_id = v_contact_id AND occurred_at = '2021-03-25'
        AND note = '1, 2/mail/oppdatering' AND contact_type = 'annet';
    UPDATE public.contact_activities
      SET note = 'oppdatering', contact_type = 'epost', person_id = v_primary_person
      WHERE contact_id = v_contact_id AND occurred_at = '2021-10-19'
        AND note = '1, 2/mail/oppdatering' AND contact_type = 'annet';
    UPDATE public.contact_activities
      SET note = 'oppdatering - tunnel arbeid', contact_type = 'epost', person_id = v_primary_person
      WHERE contact_id = v_contact_id AND occurred_at = '2022-01-20'
        AND note = '1, 2/mail/oppdatering - tunnel arbeid' AND contact_type = 'annet';
  END IF;
END $$;

DO $$
DECLARE v_contact_id uuid; v_primary_person uuid;
BEGIN
  SELECT id INTO v_contact_id FROM public.contacts WHERE lower(company_name) = lower('HENT AS');
  IF v_contact_id IS NOT NULL THEN
    SELECT id INTO v_primary_person FROM public.contact_people WHERE contact_id = v_contact_id AND is_primary = true LIMIT 1;
    UPDATE public.contact_activities
      SET note = 'standard tilbud', contact_type = 'epost', person_id = v_primary_person
      WHERE contact_id = v_contact_id AND occurred_at = '2020-10-27'
        AND note = '1, 2/mail/standard tilbud' AND contact_type = 'annet';
    UPDATE public.contact_activities
      SET note = 'wpis na liste kontrachentow', contact_type = 'epost', person_id = v_primary_person
      WHERE contact_id = v_contact_id AND occurred_at = '2020-11-01'
        AND note = '1, 2/mail/wpis na liste kontrachentow' AND contact_type = 'annet';
    UPDATE public.contact_activities
      SET note = 'oppdatering', contact_type = 'epost', person_id = v_primary_person
      WHERE contact_id = v_contact_id AND occurred_at = '2020-11-09'
        AND note = '1, 2/mail/oppdatering' AND contact_type = 'annet';
    UPDATE public.contact_activities
      SET note = 'oppdatering', contact_type = 'epost', person_id = v_primary_person
      WHERE contact_id = v_contact_id AND occurred_at = '2021-02-25'
        AND note = '1, 2/mail/oppdatering' AND contact_type = 'annet';
    UPDATE public.contact_activities
      SET note = 'oppdatering', contact_type = 'epost', person_id = v_primary_person
      WHERE contact_id = v_contact_id AND occurred_at = '2021-03-25'
        AND note = '1, 2/mail/oppdatering' AND contact_type = 'annet';
  END IF;
END $$;

DO $$
DECLARE v_contact_id uuid; v_primary_person uuid;
BEGIN
  SELECT id INTO v_contact_id FROM public.contacts WHERE lower(company_name) = lower('VEIDEKKE ASA');
  IF v_contact_id IS NOT NULL THEN
    SELECT id INTO v_primary_person FROM public.contact_people WHERE contact_id = v_contact_id AND is_primary = true LIMIT 1;
    UPDATE public.contact_activities
      SET note = 'standard tilbud etter E6 leveranse', contact_type = 'epost', person_id = v_primary_person
      WHERE contact_id = v_contact_id AND occurred_at = '2020-10-21'
        AND note = '1, 2/mail/standard tilbud etter E6 leveranse' AND contact_type = 'annet';
    UPDATE public.contact_activities
      SET note = 'oppdatering', contact_type = 'epost', person_id = v_primary_person
      WHERE contact_id = v_contact_id AND occurred_at = '2020-11-16'
        AND note = '1, 2/mail/oppdatering' AND contact_type = 'annet';
    UPDATE public.contact_activities
      SET note = 'oppdatering', contact_type = 'epost', person_id = v_primary_person
      WHERE contact_id = v_contact_id AND occurred_at = '2021-02-25'
        AND note = '1, 2/mail/oppdatering' AND contact_type = 'annet';
    UPDATE public.contact_activities
      SET note = 'oppdatering', contact_type = 'epost', person_id = v_primary_person
      WHERE contact_id = v_contact_id AND occurred_at = '2021-11-03'
        AND note = '1, 2/mail/oppdatering' AND contact_type = 'annet';
  END IF;
END $$;

DO $$
DECLARE v_contact_id uuid; v_primary_person uuid;
BEGIN
  SELECT id INTO v_contact_id FROM public.contacts WHERE lower(company_name) = lower('Hagen Maskin AS');
  IF v_contact_id IS NOT NULL THEN
    SELECT id INTO v_primary_person FROM public.contact_people WHERE contact_id = v_contact_id AND is_primary = true LIMIT 1;
    UPDATE public.contact_activities
      SET note = 'standard tilbud', contact_type = 'epost', person_id = v_primary_person
      WHERE contact_id = v_contact_id AND occurred_at = '2020-11-25'
        AND note = '1, 2, 3, 4/mail/standard tilbud' AND contact_type = 'annet';
    UPDATE public.contact_activities
      SET note = 'oppdatering', contact_type = 'epost', person_id = v_primary_person
      WHERE contact_id = v_contact_id AND occurred_at = '2021-02-25'
        AND note = '1, 2, 3, 4/mail/oppdatering' AND contact_type = 'annet';
    UPDATE public.contact_activities
      SET note = 'oppdatering', contact_type = 'epost', person_id = v_primary_person
      WHERE contact_id = v_contact_id AND occurred_at = '2021-10-19'
        AND note = '1, 2, 3, 4/mail/oppdatering' AND contact_type = 'annet';
  END IF;
END $$;

DO $$
DECLARE v_contact_id uuid; v_primary_person uuid;
BEGIN
  SELECT id INTO v_contact_id FROM public.contacts WHERE lower(company_name) = lower('ASKER Entreprenør Ø.M. FJELD');
  IF v_contact_id IS NOT NULL THEN
    SELECT id INTO v_primary_person FROM public.contact_people WHERE contact_id = v_contact_id AND is_primary = true LIMIT 1;
    UPDATE public.contact_activities
      SET note = 'standard tilbud', contact_type = 'epost', person_id = v_primary_person
      WHERE contact_id = v_contact_id AND occurred_at = '2020-11-02'
        AND note = '1-7/mail/standard tilbud' AND contact_type = 'annet';
    UPDATE public.contact_activities
      SET note = 'oppdatering', contact_type = 'epost', person_id = v_primary_person
      WHERE contact_id = v_contact_id AND occurred_at = '2020-11-27'
        AND note = '1-7/mail/oppdatering' AND contact_type = 'annet';
    UPDATE public.contact_activities
      SET note = 'oppdatering', contact_type = 'epost', person_id = v_primary_person
      WHERE contact_id = v_contact_id AND occurred_at = '2020-11-30'
        AND note = '1-7/mail/oppdatering' AND contact_type = 'annet';
    UPDATE public.contact_activities
      SET note = 'oppdatering', contact_type = 'epost', person_id = v_primary_person
      WHERE contact_id = v_contact_id AND occurred_at = '2020-12-09'
        AND note = '1-7/mail/oppdatering' AND contact_type = 'annet';
    UPDATE public.contact_activities
      SET note = 'oppdatering', contact_type = 'epost', person_id = v_primary_person
      WHERE contact_id = v_contact_id AND occurred_at = '2021-01-29'
        AND note = '1-7/mail/oppdatering' AND contact_type = 'annet';
    UPDATE public.contact_activities
      SET note = 'oppdatering', contact_type = 'epost', person_id = v_primary_person
      WHERE contact_id = v_contact_id AND occurred_at = '2021-02-18'
        AND note = '1-7/mail/oppdatering' AND contact_type = 'annet';
    UPDATE public.contact_activities
      SET note = 'oppdatering', contact_type = 'epost', person_id = v_primary_person
      WHERE contact_id = v_contact_id AND occurred_at = '2021-02-25'
        AND note = '1-7/mail/oppdatering' AND contact_type = 'annet';
    UPDATE public.contact_activities
      SET note = 'oppdatering', contact_type = 'epost', person_id = v_primary_person
      WHERE contact_id = v_contact_id AND occurred_at = '2021-03-05'
        AND note = '1-7/mail/oppdatering' AND contact_type = 'annet';
    UPDATE public.contact_activities
      SET note = 'oppdatering', contact_type = 'epost', person_id = v_primary_person
      WHERE contact_id = v_contact_id AND occurred_at = '2021-03-12'
        AND note = '1-7/mail/oppdatering' AND contact_type = 'annet';
    UPDATE public.contact_activities
      SET note = 'oppdatering', contact_type = 'epost', person_id = v_primary_person
      WHERE contact_id = v_contact_id AND occurred_at = '2021-10-19'
        AND note = '1-7/mail/oppdatering' AND contact_type = 'annet';
    UPDATE public.contact_activities
      SET note = 'oppdatering', contact_type = 'epost', person_id = v_primary_person
      WHERE contact_id = v_contact_id AND occurred_at = '2022-01-20'
        AND note = '1-7/mail/oppdatering' AND contact_type = 'annet';
  END IF;
END $$;

DO $$
DECLARE v_contact_id uuid; v_primary_person uuid;
BEGIN
  SELECT id INTO v_contact_id FROM public.contacts WHERE lower(company_name) = lower('Baneservice');
  IF v_contact_id IS NOT NULL THEN
    SELECT id INTO v_primary_person FROM public.contact_people WHERE contact_id = v_contact_id AND is_primary = true LIMIT 1;
    UPDATE public.contact_activities
      SET note = 'standard tilbud', contact_type = 'epost', person_id = v_primary_person
      WHERE contact_id = v_contact_id AND occurred_at = '2020-11-05'
        AND note = '1, 2, 3/mail/standard tilbud' AND contact_type = 'annet';
    UPDATE public.contact_activities
      SET note = 'oppdatering', contact_type = 'epost', person_id = v_primary_person
      WHERE contact_id = v_contact_id AND occurred_at = '2020-11-27'
        AND note = '1, 2, 3/mail/oppdatering' AND contact_type = 'annet';
    UPDATE public.contact_activities
      SET note = 'oppdatering', contact_type = 'epost', person_id = v_primary_person
      WHERE contact_id = v_contact_id AND occurred_at = '2021-02-25'
        AND note = '1, 2, 3/mail/oppdatering' AND contact_type = 'annet';
    UPDATE public.contact_activities
      SET note = 'oppdatering', contact_type = 'epost', person_id = v_primary_person
      WHERE contact_id = v_contact_id AND occurred_at = '2021-03-05'
        AND note = '1, 2, 3/mail/oppdatering' AND contact_type = 'annet';
  END IF;
END $$;

DO $$
DECLARE v_contact_id uuid; v_primary_person uuid;
BEGIN
  SELECT id INTO v_contact_id FROM public.contacts WHERE lower(company_name) = lower('Askim Entreprenør');
  IF v_contact_id IS NOT NULL THEN
    SELECT id INTO v_primary_person FROM public.contact_people WHERE contact_id = v_contact_id AND is_primary = true LIMIT 1;
    UPDATE public.contact_activities
      SET note = 'standard tilbud', contact_type = 'epost', person_id = v_primary_person
      WHERE contact_id = v_contact_id AND occurred_at = '2020-11-05'
        AND note = '1, 2/mail/standard tilbud' AND contact_type = 'annet';
    UPDATE public.contact_activities
      SET note = 'oppdatering', contact_type = 'epost', person_id = v_primary_person
      WHERE contact_id = v_contact_id AND occurred_at = '2020-11-27'
        AND note = '1, 2/mail/oppdatering' AND contact_type = 'annet';
    UPDATE public.contact_activities
      SET note = 'oppdatering', contact_type = 'epost', person_id = v_primary_person
      WHERE contact_id = v_contact_id AND occurred_at = '2021-02-25'
        AND note = '1, 2/mail/oppdatering' AND contact_type = 'annet';
    UPDATE public.contact_activities
      SET note = 'oppdatering', contact_type = 'epost', person_id = v_primary_person
      WHERE contact_id = v_contact_id AND occurred_at = '2021-03-05'
        AND note = '1, 2/mail/oppdatering' AND contact_type = 'annet';
    UPDATE public.contact_activities
      SET note = 'oppdatering', contact_type = 'epost', person_id = v_primary_person
      WHERE contact_id = v_contact_id AND occurred_at = '2021-10-19'
        AND note = '1, 2/mail/oppdatering' AND contact_type = 'annet';
  END IF;
END $$;

DO $$
DECLARE v_contact_id uuid; v_primary_person uuid;
BEGIN
  SELECT id INTO v_contact_id FROM public.contacts WHERE lower(company_name) = lower('Con-Form');
  IF v_contact_id IS NOT NULL THEN
    SELECT id INTO v_primary_person FROM public.contact_people WHERE contact_id = v_contact_id AND is_primary = true LIMIT 1;
    UPDATE public.contact_activities
      SET note = 'standard tilbud', contact_type = 'epost', person_id = v_primary_person
      WHERE contact_id = v_contact_id AND occurred_at = '2020-11-05'
        AND note = '1, 2/mail/standard tilbud' AND contact_type = 'annet';
    UPDATE public.contact_activities
      SET note = 'oppdatering', contact_type = 'epost', person_id = v_primary_person
      WHERE contact_id = v_contact_id AND occurred_at = '2020-11-27'
        AND note = '1, 2/mail/oppdatering' AND contact_type = 'annet';
    UPDATE public.contact_activities
      SET note = 'oppdatering', contact_type = 'epost', person_id = v_primary_person
      WHERE contact_id = v_contact_id AND occurred_at = '2020-11-27'
        AND note = '1, 2/mail/oppdatering' AND contact_type = 'annet';
    UPDATE public.contact_activities
      SET note = 'oppdatering', contact_type = 'epost', person_id = v_primary_person
      WHERE contact_id = v_contact_id AND occurred_at = '2021-02-25'
        AND note = '1, 2/mail/oppdatering' AND contact_type = 'annet';
    UPDATE public.contact_activities
      SET note = 'oppdatering', contact_type = 'epost', person_id = v_primary_person
      WHERE contact_id = v_contact_id AND occurred_at = '2021-03-05'
        AND note = '1, 2/mail/oppdatering' AND contact_type = 'annet';
    UPDATE public.contact_activities
      SET note = 'oppdatering', contact_type = 'epost', person_id = v_primary_person
      WHERE contact_id = v_contact_id AND occurred_at = '2021-07-01'
        AND note = '1, 2/mail/oppdatering' AND contact_type = 'annet';
    UPDATE public.contact_activities
      SET note = 'oppdatering', contact_type = 'epost', person_id = v_primary_person
      WHERE contact_id = v_contact_id AND occurred_at = '2021-10-27'
        AND note = '1, 2/mail/oppdatering' AND contact_type = 'annet';
  END IF;
END $$;

DO $$
DECLARE v_contact_id uuid; v_primary_person uuid;
BEGIN
  SELECT id INTO v_contact_id FROM public.contacts WHERE lower(company_name) = lower('Norconsult');
  IF v_contact_id IS NOT NULL THEN
    SELECT id INTO v_primary_person FROM public.contact_people WHERE contact_id = v_contact_id AND is_primary = true LIMIT 1;
    UPDATE public.contact_activities
      SET note = 'standard tilbud', contact_type = 'epost', person_id = v_primary_person
      WHERE contact_id = v_contact_id AND occurred_at = '2020-11-09'
        AND note = '1, 2/mail/standard tilbud' AND contact_type = 'annet';
    UPDATE public.contact_activities
      SET note = 'oppdatering', contact_type = 'epost', person_id = v_primary_person
      WHERE contact_id = v_contact_id AND occurred_at = '2020-11-27'
        AND note = '1, 2/mail/oppdatering' AND contact_type = 'annet';
    UPDATE public.contact_activities
      SET note = 'oppdatering', contact_type = 'epost', person_id = v_primary_person
      WHERE contact_id = v_contact_id AND occurred_at = '2021-02-25'
        AND note = '1, 2/mail/oppdatering' AND contact_type = 'annet';
    UPDATE public.contact_activities
      SET note = 'oppdatering', contact_type = 'epost', person_id = v_primary_person
      WHERE contact_id = v_contact_id AND occurred_at = '2021-03-05'
        AND note = '1, 2/mail/oppdatering' AND contact_type = 'annet';
    UPDATE public.contact_activities
      SET note = 'oppdatering', contact_type = 'epost', person_id = v_primary_person
      WHERE contact_id = v_contact_id AND occurred_at = '2021-07-01'
        AND note = '1, 2/mail/oppdatering' AND contact_type = 'annet';
    UPDATE public.contact_activities
      SET note = 'oppdatering', contact_type = 'epost', person_id = v_primary_person
      WHERE contact_id = v_contact_id AND occurred_at = '2021-10-27'
        AND note = '1, 2/mail/oppdatering' AND contact_type = 'annet';
  END IF;
END $$;

DO $$
DECLARE v_contact_id uuid; v_primary_person uuid;
BEGIN
  SELECT id INTO v_contact_id FROM public.contacts WHERE lower(company_name) = lower('Hitra Anleggservice AS');
  IF v_contact_id IS NOT NULL THEN
    SELECT id INTO v_primary_person FROM public.contact_people WHERE contact_id = v_contact_id AND is_primary = true LIMIT 1;
    UPDATE public.contact_activities
      SET note = 'standard tilbud', contact_type = 'epost', person_id = v_primary_person
      WHERE contact_id = v_contact_id AND occurred_at = '2020-11-12'
        AND note = '1, 2/mail/standard tilbud' AND contact_type = 'annet';
    UPDATE public.contact_activities
      SET note = 'oppdatering', contact_type = 'epost', person_id = v_primary_person
      WHERE contact_id = v_contact_id AND occurred_at = '2020-11-13'
        AND note = '1, 2/mail/oppdatering' AND contact_type = 'annet';
    UPDATE public.contact_activities
      SET note = 'oppdatering', contact_type = 'epost', person_id = v_primary_person
      WHERE contact_id = v_contact_id AND occurred_at = '2020-11-30'
        AND note = '1, 2/mail/oppdatering' AND contact_type = 'annet';
    UPDATE public.contact_activities
      SET note = 'oppdatering', contact_type = 'epost', person_id = v_primary_person
      WHERE contact_id = v_contact_id AND occurred_at = '2021-02-26'
        AND note = '1, 2/mail/oppdatering' AND contact_type = 'annet';
    UPDATE public.contact_activities
      SET note = 'oppdatering', contact_type = 'epost', person_id = v_primary_person
      WHERE contact_id = v_contact_id AND occurred_at = '2021-07-01'
        AND note = '1, 2/mail/oppdatering' AND contact_type = 'annet';
    UPDATE public.contact_activities
      SET note = 'oppdatering', contact_type = 'epost', person_id = v_primary_person
      WHERE contact_id = v_contact_id AND occurred_at = '2021-10-28'
        AND note = '1, 2/mail/oppdatering' AND contact_type = 'annet';
  END IF;
END $$;

DO $$
DECLARE v_contact_id uuid; v_primary_person uuid;
BEGIN
  SELECT id INTO v_contact_id FROM public.contacts WHERE lower(company_name) = lower('Sør-Norsk Boring');
  IF v_contact_id IS NOT NULL THEN
    SELECT id INTO v_primary_person FROM public.contact_people WHERE contact_id = v_contact_id AND is_primary = true LIMIT 1;
    UPDATE public.contact_activities
      SET note = 'standard tilbud', contact_type = 'epost', person_id = v_primary_person
      WHERE contact_id = v_contact_id AND occurred_at = '2020-11-18'
        AND note = '1, 2/mail/standard tilbud' AND contact_type = 'annet';
    UPDATE public.contact_activities
      SET note = 'oppdatering', contact_type = 'epost', person_id = v_primary_person
      WHERE contact_id = v_contact_id AND occurred_at = '2020-11-30'
        AND note = '1, 2/mail/oppdatering' AND contact_type = 'annet';
    UPDATE public.contact_activities
      SET note = 'oppdatering', contact_type = 'epost', person_id = v_primary_person
      WHERE contact_id = v_contact_id AND occurred_at = '2021-02-26'
        AND note = '1, 2/mail/oppdatering' AND contact_type = 'annet';
    UPDATE public.contact_activities
      SET note = 'oppdatering', contact_type = 'epost', person_id = v_primary_person
      WHERE contact_id = v_contact_id AND occurred_at = '2021-03-12'
        AND note = '1, 2/mail/oppdatering' AND contact_type = 'annet';
  END IF;
END $$;

DO $$
DECLARE v_contact_id uuid; v_primary_person uuid;
BEGIN
  SELECT id INTO v_contact_id FROM public.contacts WHERE lower(company_name) = lower('Seabrokers Fundamentering AS');
  IF v_contact_id IS NOT NULL THEN
    SELECT id INTO v_primary_person FROM public.contact_people WHERE contact_id = v_contact_id AND is_primary = true LIMIT 1;
    UPDATE public.contact_activities
      SET note = 'standard tilbud', contact_type = 'epost', person_id = v_primary_person
      WHERE contact_id = v_contact_id AND occurred_at = '2020-11-19'
        AND note = '1, 2/mail/standard tilbud' AND contact_type = 'annet';
    UPDATE public.contact_activities
      SET note = 'oppdatering', contact_type = 'epost', person_id = v_primary_person
      WHERE contact_id = v_contact_id AND occurred_at = '2020-11-30'
        AND note = '1, 2/mail/oppdatering' AND contact_type = 'annet';
    UPDATE public.contact_activities
      SET note = 'oppdatering', contact_type = 'epost', person_id = v_primary_person
      WHERE contact_id = v_contact_id AND occurred_at = '2021-02-26'
        AND note = '1, 2/mail/oppdatering' AND contact_type = 'annet';
    UPDATE public.contact_activities
      SET note = 'oppdatering', contact_type = 'epost', person_id = v_primary_person
      WHERE contact_id = v_contact_id AND occurred_at = '2021-03-12'
        AND note = '1, 2/mail/oppdatering' AND contact_type = 'annet';
    UPDATE public.contact_activities
      SET note = 'oppdatering', contact_type = 'epost', person_id = v_primary_person
      WHERE contact_id = v_contact_id AND occurred_at = '2021-07-01'
        AND note = '1, 2/mail/oppdatering' AND contact_type = 'annet';
    UPDATE public.contact_activities
      SET note = 'oppdatering', contact_type = 'epost', person_id = v_primary_person
      WHERE contact_id = v_contact_id AND occurred_at = '2021-10-29'
        AND note = '1, 2/mail/oppdatering' AND contact_type = 'annet';
  END IF;
END $$;

DO $$
DECLARE v_contact_id uuid; v_primary_person uuid;
BEGIN
  SELECT id INTO v_contact_id FROM public.contacts WHERE lower(company_name) = lower('STENSETH & RS Betongentreprenør AS');
  IF v_contact_id IS NOT NULL THEN
    SELECT id INTO v_primary_person FROM public.contact_people WHERE contact_id = v_contact_id AND is_primary = true LIMIT 1;
    UPDATE public.contact_activities
      SET note = 'standard tilbud', contact_type = 'epost', person_id = v_primary_person
      WHERE contact_id = v_contact_id AND occurred_at = '2020-11-30'
        AND note = '1, 2/mail/standard tilbud' AND contact_type = 'annet';
    UPDATE public.contact_activities
      SET note = 'oppdatering', contact_type = 'epost', person_id = v_primary_person
      WHERE contact_id = v_contact_id AND occurred_at = '2021-01-29'
        AND note = '1, 2/mail/oppdatering' AND contact_type = 'annet';
    UPDATE public.contact_activities
      SET note = 'oppdatering', contact_type = 'epost', person_id = v_primary_person
      WHERE contact_id = v_contact_id AND occurred_at = '2021-02-26'
        AND note = '1, 2/mail/oppdatering' AND contact_type = 'annet';
    UPDATE public.contact_activities
      SET note = 'oppdatering', contact_type = 'epost', person_id = v_primary_person
      WHERE contact_id = v_contact_id AND occurred_at = '2021-03-12'
        AND note = '1, 2/mail/oppdatering' AND contact_type = 'annet';
    UPDATE public.contact_activities
      SET note = 'oppdatering', contact_type = 'epost', person_id = v_primary_person
      WHERE contact_id = v_contact_id AND occurred_at = '2021-07-01'
        AND note = '1, 2/mail/oppdatering' AND contact_type = 'annet';
    UPDATE public.contact_activities
      SET note = 'oppdatering', contact_type = 'epost', person_id = v_primary_person
      WHERE contact_id = v_contact_id AND occurred_at = '2021-10-29'
        AND note = '1, 2/mail/oppdatering' AND contact_type = 'annet';
  END IF;
END $$;

DO $$
DECLARE v_contact_id uuid; v_primary_person uuid;
BEGIN
  SELECT id INTO v_contact_id FROM public.contacts WHERE lower(company_name) = lower('KAARE MORTENSEN AS');
  IF v_contact_id IS NOT NULL THEN
    SELECT id INTO v_primary_person FROM public.contact_people WHERE contact_id = v_contact_id AND is_primary = true LIMIT 1;
    UPDATE public.contact_activities
      SET note = 'standard tilbud', contact_type = 'epost', person_id = v_primary_person
      WHERE contact_id = v_contact_id AND occurred_at = NULL
        AND note = '1, 2, 3/mail/standard tilbud' AND contact_type = 'annet';
    UPDATE public.contact_activities
      SET note = 'oppdatering', contact_type = 'epost', person_id = v_primary_person
      WHERE contact_id = v_contact_id AND occurred_at = '2021-01-29'
        AND note = '1, 2, 3/mail/oppdatering' AND contact_type = 'annet';
    UPDATE public.contact_activities
      SET note = 'oppdatering', contact_type = 'epost', person_id = v_primary_person
      WHERE contact_id = v_contact_id AND occurred_at = '2021-02-26'
        AND note = '1, 2, 3/mail/oppdatering' AND contact_type = 'annet';
    UPDATE public.contact_activities
      SET note = 'oppdatering', contact_type = 'epost', person_id = v_primary_person
      WHERE contact_id = v_contact_id AND occurred_at = '2021-03-12'
        AND note = '1, 2, 3/mail/oppdatering' AND contact_type = 'annet';
    UPDATE public.contact_activities
      SET note = 'oppdatering', contact_type = 'epost', person_id = v_primary_person
      WHERE contact_id = v_contact_id AND occurred_at = '2021-07-01'
        AND note = '1, 2, 3/mail/oppdatering' AND contact_type = 'annet';
    UPDATE public.contact_activities
      SET note = 'oppdatering', contact_type = 'epost', person_id = v_primary_person
      WHERE contact_id = v_contact_id AND occurred_at = '2021-10-29'
        AND note = '1, 2, 3/mail/oppdatering' AND contact_type = 'annet';
  END IF;
END $$;

DO $$
DECLARE v_contact_id uuid; v_primary_person uuid;
BEGIN
  SELECT id INTO v_contact_id FROM public.contacts WHERE lower(company_name) = lower('VEDAL AS');
  IF v_contact_id IS NOT NULL THEN
    SELECT id INTO v_primary_person FROM public.contact_people WHERE contact_id = v_contact_id AND is_primary = true LIMIT 1;
    UPDATE public.contact_activities
      SET note = 'standard tilbud', contact_type = 'epost', person_id = v_primary_person
      WHERE contact_id = v_contact_id AND occurred_at = '2020-11-30'
        AND note = '1, 2, 3/mail/standard tilbud' AND contact_type = 'annet';
    UPDATE public.contact_activities
      SET note = 'oppdatering', contact_type = 'epost', person_id = v_primary_person
      WHERE contact_id = v_contact_id AND occurred_at = '2021-01-29'
        AND note = '1, 2, 3/mail/oppdatering' AND contact_type = 'annet';
    UPDATE public.contact_activities
      SET note = 'oppdatering', contact_type = 'epost', person_id = v_primary_person
      WHERE contact_id = v_contact_id AND occurred_at = '2021-02-26'
        AND note = '1, 2, 3/mail/oppdatering' AND contact_type = 'annet';
    UPDATE public.contact_activities
      SET note = 'oppdatering', contact_type = 'epost', person_id = v_primary_person
      WHERE contact_id = v_contact_id AND occurred_at = '2021-03-12'
        AND note = '1, 2, 3/mail/oppdatering' AND contact_type = 'annet';
  END IF;
END $$;

DO $$
DECLARE v_contact_id uuid; v_primary_person uuid;
BEGIN
  SELECT id INTO v_contact_id FROM public.contacts WHERE lower(company_name) = lower('VARDEN ENTREPRENØR');
  IF v_contact_id IS NOT NULL THEN
    SELECT id INTO v_primary_person FROM public.contact_people WHERE contact_id = v_contact_id AND is_primary = true LIMIT 1;
    UPDATE public.contact_activities
      SET note = 'standard tilbud', contact_type = 'epost', person_id = v_primary_person
      WHERE contact_id = v_contact_id AND occurred_at = '2020-11-30'
        AND note = '1, 2, 3/mail/standard tilbud' AND contact_type = 'annet';
    UPDATE public.contact_activities
      SET note = 'oppdatering', contact_type = 'epost', person_id = v_primary_person
      WHERE contact_id = v_contact_id AND occurred_at = '2021-01-29'
        AND note = '1, 2, 3/mail/oppdatering' AND contact_type = 'annet';
    UPDATE public.contact_activities
      SET note = 'oppdatering', contact_type = 'epost', person_id = v_primary_person
      WHERE contact_id = v_contact_id AND occurred_at = '2021-02-26'
        AND note = '1, 2, 3/mail/oppdatering' AND contact_type = 'annet';
    UPDATE public.contact_activities
      SET note = 'oppdatering', contact_type = 'epost', person_id = v_primary_person
      WHERE contact_id = v_contact_id AND occurred_at = '2021-03-12'
        AND note = '1, 2, 3/mail/oppdatering' AND contact_type = 'annet';
    UPDATE public.contact_activities
      SET note = 'oppdatering', contact_type = 'epost', person_id = v_primary_person
      WHERE contact_id = v_contact_id AND occurred_at = '2021-07-01'
        AND note = '1, 2, 3/mail/oppdatering' AND contact_type = 'annet';
    UPDATE public.contact_activities
      SET note = 'oppdatering', contact_type = 'epost', person_id = v_primary_person
      WHERE contact_id = v_contact_id AND occurred_at = '2021-10-29'
        AND note = '1, 2, 3/mail/oppdatering' AND contact_type = 'annet';
  END IF;
END $$;

DO $$
DECLARE v_contact_id uuid; v_primary_person uuid;
BEGIN
  SELECT id INTO v_contact_id FROM public.contacts WHERE lower(company_name) = lower('SWECO');
  IF v_contact_id IS NOT NULL THEN
    SELECT id INTO v_primary_person FROM public.contact_people WHERE contact_id = v_contact_id AND is_primary = true LIMIT 1;
    UPDATE public.contact_activities
      SET note = 'standard tilbud', contact_type = 'epost', person_id = v_primary_person
      WHERE contact_id = v_contact_id AND occurred_at = '2020-12-02'
        AND note = '1, 2/mail/standard tilbud' AND contact_type = 'annet';
    UPDATE public.contact_activities
      SET note = 'oppdatering', contact_type = 'epost', person_id = v_primary_person
      WHERE contact_id = v_contact_id AND occurred_at = '2021-01-29'
        AND note = '1, 2/mail/oppdatering' AND contact_type = 'annet';
    UPDATE public.contact_activities
      SET note = 'oppdatering', contact_type = 'epost', person_id = v_primary_person
      WHERE contact_id = v_contact_id AND occurred_at = '2021-02-01'
        AND note = '1, 2/mail/oppdatering' AND contact_type = 'annet';
    UPDATE public.contact_activities
      SET note = 'oppdatering', contact_type = 'epost', person_id = v_primary_person
      WHERE contact_id = v_contact_id AND occurred_at = '2021-02-26'
        AND note = '1, 2/mail/oppdatering' AND contact_type = 'annet';
    UPDATE public.contact_activities
      SET note = 'oppdatering', contact_type = 'epost', person_id = v_primary_person
      WHERE contact_id = v_contact_id AND occurred_at = '2021-03-12'
        AND note = '1, 2/mail/oppdatering' AND contact_type = 'annet';
    UPDATE public.contact_activities
      SET note = 'oppdatering', contact_type = 'epost', person_id = v_primary_person
      WHERE contact_id = v_contact_id AND occurred_at = '2021-07-01'
        AND note = '1, 2/mail/oppdatering' AND contact_type = 'annet';
    UPDATE public.contact_activities
      SET note = 'oppdatering', contact_type = 'epost', person_id = v_primary_person
      WHERE contact_id = v_contact_id AND occurred_at = '2021-10-29'
        AND note = '1, 2/mail/oppdatering' AND contact_type = 'annet';
  END IF;
END $$;

DO $$
DECLARE v_contact_id uuid; v_primary_person uuid;
BEGIN
  SELECT id INTO v_contact_id FROM public.contacts WHERE lower(company_name) = lower('Johs. J. Syltern');
  IF v_contact_id IS NOT NULL THEN
    SELECT id INTO v_primary_person FROM public.contact_people WHERE contact_id = v_contact_id AND is_primary = true LIMIT 1;
    UPDATE public.contact_activities
      SET note = 'standard tilbud', contact_type = 'epost', person_id = v_primary_person
      WHERE contact_id = v_contact_id AND occurred_at = '2020-12-03'
        AND note = '1, 2, 3, 4/mail/standard tilbud' AND contact_type = 'annet';
    UPDATE public.contact_activities
      SET note = 'oppdatering', contact_type = 'epost', person_id = v_primary_person
      WHERE contact_id = v_contact_id AND occurred_at = '2021-01-29'
        AND note = '1, 2, 3, 4/mail/oppdatering' AND contact_type = 'annet';
    UPDATE public.contact_activities
      SET note = 'oppdatering', contact_type = 'epost', person_id = v_primary_person
      WHERE contact_id = v_contact_id AND occurred_at = '2021-02-26'
        AND note = '1, 2, 3, 4/mail/oppdatering' AND contact_type = 'annet';
    UPDATE public.contact_activities
      SET note = 'oppdatering', contact_type = 'epost', person_id = v_primary_person
      WHERE contact_id = v_contact_id AND occurred_at = '2021-07-01'
        AND note = '1, 2, 3, 4/mail/oppdatering' AND contact_type = 'annet';
    UPDATE public.contact_activities
      SET note = 'oppdatering', contact_type = 'epost', person_id = v_primary_person
      WHERE contact_id = v_contact_id AND occurred_at = '2021-10-29'
        AND note = '1, 2, 3, 4/mail/oppdatering' AND contact_type = 'annet';
  END IF;
END $$;

DO $$
DECLARE v_contact_id uuid; v_primary_person uuid;
BEGIN
  SELECT id INTO v_contact_id FROM public.contacts WHERE lower(company_name) = lower('Ulefos AS');
  IF v_contact_id IS NOT NULL THEN
    SELECT id INTO v_primary_person FROM public.contact_people WHERE contact_id = v_contact_id AND is_primary = true LIMIT 1;
    UPDATE public.contact_activities
      SET note = 'standard tilbud', contact_type = 'epost', person_id = v_primary_person
      WHERE contact_id = v_contact_id AND occurred_at = '2020-12-04'
        AND note = '1, 2/mail/standard tilbud' AND contact_type = 'annet';
    UPDATE public.contact_activities
      SET note = 'oppdatering', contact_type = 'epost', person_id = v_primary_person
      WHERE contact_id = v_contact_id AND occurred_at = '2021-01-29'
        AND note = '1, 2/mail/oppdatering' AND contact_type = 'annet';
    UPDATE public.contact_activities
      SET note = 'oppdatering', contact_type = 'epost', person_id = v_primary_person
      WHERE contact_id = v_contact_id AND occurred_at = '2021-02-26'
        AND note = '1, 2/mail/oppdatering' AND contact_type = 'annet';
    UPDATE public.contact_activities
      SET note = 'oppdatering', contact_type = 'epost', person_id = v_primary_person
      WHERE contact_id = v_contact_id AND occurred_at = '2021-03-12'
        AND note = '1, 2/mail/oppdatering' AND contact_type = 'annet';
  END IF;
END $$;

DO $$
DECLARE v_contact_id uuid; v_primary_person uuid;
BEGIN
  SELECT id INTO v_contact_id FROM public.contacts WHERE lower(company_name) = lower('A Bygg Entreprenør AS');
  IF v_contact_id IS NOT NULL THEN
    SELECT id INTO v_primary_person FROM public.contact_people WHERE contact_id = v_contact_id AND is_primary = true LIMIT 1;
    UPDATE public.contact_activities
      SET note = 'standard tilbud', contact_type = 'epost', person_id = v_primary_person
      WHERE contact_id = v_contact_id AND occurred_at = '2020-12-07'
        AND note = '1, 2/mail/standard tilbud' AND contact_type = 'annet';
    UPDATE public.contact_activities
      SET note = 'oppdatering', contact_type = 'epost', person_id = v_primary_person
      WHERE contact_id = v_contact_id AND occurred_at = '2021-01-29'
        AND note = '1, 2/mail/oppdatering' AND contact_type = 'annet';
    UPDATE public.contact_activities
      SET note = 'oppdatering', contact_type = 'epost', person_id = v_primary_person
      WHERE contact_id = v_contact_id AND occurred_at = '2021-02-26'
        AND note = '1, 2/mail/oppdatering' AND contact_type = 'annet';
    UPDATE public.contact_activities
      SET note = 'oppdatering', contact_type = 'epost', person_id = v_primary_person
      WHERE contact_id = v_contact_id AND occurred_at = '2021-03-12'
        AND note = '1, 2/mail/oppdatering' AND contact_type = 'annet';
  END IF;
END $$;

DO $$
DECLARE v_contact_id uuid; v_primary_person uuid;
BEGIN
  SELECT id INTO v_contact_id FROM public.contacts WHERE lower(company_name) = lower('Braathen Landskapsentreprenør AS');
  IF v_contact_id IS NOT NULL THEN
    SELECT id INTO v_primary_person FROM public.contact_people WHERE contact_id = v_contact_id AND is_primary = true LIMIT 1;
    UPDATE public.contact_activities
      SET note = 'standard tilbud', contact_type = 'epost', person_id = v_primary_person
      WHERE contact_id = v_contact_id AND occurred_at = '2020-12-07'
        AND note = '1, 2/mail/standard tilbud' AND contact_type = 'annet';
    UPDATE public.contact_activities
      SET note = 'oppdatering', contact_type = 'epost', person_id = v_primary_person
      WHERE contact_id = v_contact_id AND occurred_at = '2021-01-29'
        AND note = '1, 2/mail/oppdatering' AND contact_type = 'annet';
    UPDATE public.contact_activities
      SET note = 'oppdatering', contact_type = 'epost', person_id = v_primary_person
      WHERE contact_id = v_contact_id AND occurred_at = '2021-02-26'
        AND note = '1, 2/mail/oppdatering' AND contact_type = 'annet';
    UPDATE public.contact_activities
      SET note = 'oppdatering', contact_type = 'epost', person_id = v_primary_person
      WHERE contact_id = v_contact_id AND occurred_at = '2021-03-12'
        AND note = '1, 2/mail/oppdatering' AND contact_type = 'annet';
  END IF;
END $$;

DO $$
DECLARE v_contact_id uuid; v_primary_person uuid;
BEGIN
  SELECT id INTO v_contact_id FROM public.contacts WHERE lower(company_name) = lower('LNS AS');
  IF v_contact_id IS NOT NULL THEN
    SELECT id INTO v_primary_person FROM public.contact_people WHERE contact_id = v_contact_id AND is_primary = true LIMIT 1;
    UPDATE public.contact_activities
      SET note = 'standard tilbud', contact_type = 'epost', person_id = v_primary_person
      WHERE contact_id = v_contact_id AND occurred_at = '2020-12-09'
        AND note = '1, 2/mail/standard tilbud' AND contact_type = 'annet';
    UPDATE public.contact_activities
      SET note = 'oppdatering', contact_type = 'epost', person_id = v_primary_person
      WHERE contact_id = v_contact_id AND occurred_at = '2021-01-29'
        AND note = '1, 2/mail/oppdatering' AND contact_type = 'annet';
    UPDATE public.contact_activities
      SET note = 'oppdatering', contact_type = 'epost', person_id = v_primary_person
      WHERE contact_id = v_contact_id AND occurred_at = '2021-02-18'
        AND note = '1, 2/mail/oppdatering' AND contact_type = 'annet';
    UPDATE public.contact_activities
      SET note = 'oppdatering', contact_type = 'epost', person_id = v_primary_person
      WHERE contact_id = v_contact_id AND occurred_at = '2021-03-12'
        AND note = '1, 2/mail/oppdatering' AND contact_type = 'annet';
    UPDATE public.contact_activities
      SET note = 'fastmerker og oppdatering', contact_type = 'epost', person_id = v_primary_person
      WHERE contact_id = v_contact_id AND occurred_at = '2026-03-10'
        AND note = '1.2/mail/fastmerker og oppdatering' AND contact_type = 'annet';
  END IF;
END $$;

DO $$
DECLARE v_contact_id uuid; v_primary_person uuid;
BEGIN
  SELECT id INTO v_contact_id FROM public.contacts WHERE lower(company_name) = lower('Aktiv Veidrift AS');
  IF v_contact_id IS NOT NULL THEN
    SELECT id INTO v_primary_person FROM public.contact_people WHERE contact_id = v_contact_id AND is_primary = true LIMIT 1;
    UPDATE public.contact_activities
      SET note = 'standard tilbud', contact_type = 'epost', person_id = v_primary_person
      WHERE contact_id = v_contact_id AND occurred_at = '2021-01-28'
        AND note = '1, 2/mail/standard tilbud' AND contact_type = 'annet';
  END IF;
END $$;

DO $$
DECLARE v_contact_id uuid; v_primary_person uuid;
BEGIN
  SELECT id INTO v_contact_id FROM public.contacts WHERE lower(company_name) = lower('EIQON Anlegg AS');
  IF v_contact_id IS NOT NULL THEN
    SELECT id INTO v_primary_person FROM public.contact_people WHERE contact_id = v_contact_id AND is_primary = true LIMIT 1;
    UPDATE public.contact_activities
      SET note = 'standard tilbud', contact_type = 'epost', person_id = v_primary_person
      WHERE contact_id = v_contact_id AND occurred_at = '2021-02-18'
        AND note = '1, 2, 3, 4/mail/standard tilbud' AND contact_type = 'annet';
    UPDATE public.contact_activities
      SET note = 'oppdatering', contact_type = 'epost', person_id = v_primary_person
      WHERE contact_id = v_contact_id AND occurred_at = '2021-03-12'
        AND note = '1, 2, 3, 4/mail/oppdatering' AND contact_type = 'annet';
  END IF;
END $$;

DO $$
DECLARE v_contact_id uuid; v_primary_person uuid;
BEGIN
  SELECT id INTO v_contact_id FROM public.contacts WHERE lower(company_name) = lower('KRUSE SMITH');
  IF v_contact_id IS NOT NULL THEN
    SELECT id INTO v_primary_person FROM public.contact_people WHERE contact_id = v_contact_id AND is_primary = true LIMIT 1;
    UPDATE public.contact_activities
      SET note = 'standard tilbud', contact_type = 'epost', person_id = v_primary_person
      WHERE contact_id = v_contact_id AND occurred_at = '2021-03-10'
        AND note = '1, 2/mail/standard tilbud' AND contact_type = 'annet';
    UPDATE public.contact_activities
      SET note = 'oppdatering', contact_type = 'epost', person_id = v_primary_person
      WHERE contact_id = v_contact_id AND occurred_at = '2022-01-20'
        AND note = '1, 2/mail/oppdatering' AND contact_type = 'annet';
  END IF;
END $$;

DO $$
DECLARE v_contact_id uuid; v_primary_person uuid;
BEGIN
  SELECT id INTO v_contact_id FROM public.contacts WHERE lower(company_name) = lower('PS Anlegg AS');
  IF v_contact_id IS NOT NULL THEN
    SELECT id INTO v_primary_person FROM public.contact_people WHERE contact_id = v_contact_id AND is_primary = true LIMIT 1;
    UPDATE public.contact_activities
      SET note = 'standard tilbud', contact_type = 'epost', person_id = v_primary_person
      WHERE contact_id = v_contact_id AND occurred_at = '2021-03-10'
        AND note = '1, 2/mail/standard tilbud' AND contact_type = 'annet';
  END IF;
END $$;

DO $$
DECLARE v_contact_id uuid; v_primary_person uuid;
BEGIN
  SELECT id INTO v_contact_id FROM public.contacts WHERE lower(company_name) = lower('Dpend');
  IF v_contact_id IS NOT NULL THEN
    SELECT id INTO v_primary_person FROM public.contact_people WHERE contact_id = v_contact_id AND is_primary = true LIMIT 1;
    UPDATE public.contact_activities
      SET note = 'produkteksempler', contact_type = 'epost', person_id = v_primary_person
      WHERE contact_id = v_contact_id AND occurred_at = '2021-10-12'
        AND note = '1,2/mail/produkteksempler' AND contact_type = 'annet';
  END IF;
END $$;
