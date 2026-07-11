-- Migracja 008: usuniecie 3 wpisow historii z literowka w dacie zrodlowej + ujednolicenie
-- nazw firm (CAPS LOCK -> normalna wielkosc liter).
-- Uruchom w Supabase Dashboard -> SQL Editor -> Run.

-- ============================================================
-- A) Wpisy Historikk z literowka w dacie zrodlowej (np. "23.022021" zamiast "23.02.2021",
--    "30.11.0202" zamiast prawdopodobnie 2020) - parser nie rozpoznal daty, wiec przy imporcie
--    (migracja 006) trafily z data importu (dzisiejsza), a poprawka tresci (migracja 007) nie
--    zadzialala dla nich (dopasowanie po occurred_at zawiodlo). Usuwane na wyrazna prosbe -
--    to jedyne 3 takie przypadki w calej bazie (zweryfikowane).
-- ============================================================
DELETE FROM public.contact_activities
WHERE contact_id = (SELECT id FROM public.contacts WHERE lower(company_name) = lower('Metacon AS'))
  AND note = '1, 2/mail/standard tilbud' AND contact_type = 'annet';

DELETE FROM public.contact_activities
WHERE contact_id = (SELECT id FROM public.contacts WHERE lower(company_name) = lower('KAARE MORTENSEN AS'))
  AND note = '1, 2, 3/mail/standard tilbud' AND contact_type = 'annet';

DELETE FROM public.contact_activities
WHERE contact_id = (SELECT id FROM public.contacts WHERE lower(company_name) = lower('Hersleth Entreprenør AS'))
  AND note = '1/mail/oppdatering' AND contact_type = 'annet';

-- ============================================================
-- B) Ujednolicenie nazw firm: CAPS LOCK -> normalna wielkosc liter.
--    Pominieto celowo znane akronimy/marki pisane wielkimi literami z zalozenia
--    (np. NCC, HENT, LNS, NRC, OHLA, STRÅ - typowa konwencja krotkich akronimow
--    w nazwach biur architektonicznych) oraz inicjaly wewnatrz nazw (KN, PS, R3, JR, HI, RS).
--    "SKANSKA Skanska Surwey" poprawiono na "Skanska Survey" (usunieto duplikat + literowka
--    "Surwey" -> "Survey") - to wieksza zmiana niz sama wielkosc liter, do weryfikacji.
-- ============================================================
UPDATE public.contacts SET company_name = 'Anlegg Øst' WHERE company_name = 'ANLEGG ØST';
UPDATE public.contacts SET company_name = 'Asker Entreprenør Ø.M. Fjeld' WHERE company_name = 'ASKER Entreprenør Ø.M. FJELD';
UPDATE public.contacts SET company_name = 'Backe Østfold, Backe AS' WHERE company_name = 'BACKE Østfold, BACKE AS';
UPDATE public.contacts SET company_name = 'Eiqon Anlegg AS' WHERE company_name = 'EIQON Anlegg AS';
UPDATE public.contacts SET company_name = 'Geo Fundamentering & Berboring AS' WHERE company_name = 'GEO fundamentering & berboring AS';
UPDATE public.contacts SET company_name = 'Hæhre, HI Gruppen AS' WHERE company_name = 'Hæhre, HI gruppen AS';
UPDATE public.contacts SET company_name = 'Implenia Norge AS' WHERE company_name = 'IMPLENIA Norge AS';
UPDATE public.contacts SET company_name = 'Insenti' WHERE company_name = 'INSENTI';
UPDATE public.contacts SET company_name = 'Kaare Mortensen AS' WHERE company_name = 'KAARE MORTENSEN AS';
UPDATE public.contacts SET company_name = 'Kjernehuset Arkitektkontor AS' WHERE company_name = 'KJERNEHUSET ARKITEKTKONTOR AS';
UPDATE public.contacts SET company_name = 'Kruse Smith' WHERE company_name = 'KRUSE SMITH';
UPDATE public.contacts SET company_name = 'Kvass Arkitektur AS' WHERE company_name = 'KVASS Arkitektur AS';
UPDATE public.contacts SET company_name = 'Marlow Arkitekter AS' WHERE company_name = 'MARLOW ARKITEKTER AS';
UPDATE public.contacts SET company_name = 'Mo Byggservice AS' WHERE company_name = 'MO BYGGSERVICE AS';
UPDATE public.contacts SET company_name = 'Reiersen Entreprenør' WHERE company_name = 'REIERSEN ENTREPRENØR';
UPDATE public.contacts SET company_name = 'Risa AS' WHERE company_name = 'RISA AS';
UPDATE public.contacts SET company_name = 'Romerike Grunnborring AS' WHERE company_name = 'ROMERIKE GRUNNBORRING AS';
UPDATE public.contacts SET company_name = 'Skanska Survey' WHERE company_name = 'SKANSKA Skanska Surwey';
UPDATE public.contacts SET company_name = 'Stenseth & RS Betongentreprenør AS' WHERE company_name = 'STENSETH & RS Betongentreprenør AS';
UPDATE public.contacts SET company_name = 'Sweco' WHERE company_name = 'SWECO';
UPDATE public.contacts SET company_name = 'Varden Entreprenør' WHERE company_name = 'VARDEN ENTREPRENØR';
UPDATE public.contacts SET company_name = 'Vedal AS' WHERE company_name = 'VEDAL AS';
UPDATE public.contacts SET company_name = 'Veidekke ASA' WHERE company_name = 'VEIDEKKE ASA';
UPDATE public.contacts SET company_name = 'Zenith Survey' WHERE company_name = 'ZENITH Survey';
UPDATE public.contacts SET company_name = 'Øst Byggentreprenør' WHERE company_name = 'Øst byggentreprenør';
