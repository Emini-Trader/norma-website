-- Migracja 009: poprawka migracji 008 dla Hersleth Entreprenør AS
-- Poprzednia proba usuniecia szukala nieprzetworzonego surowego tekstu ("1/mail/oppdatering")
-- z contact_type='annet' - ale ten wpis mial pojedyncze ID w zrodle, wiec zostal poprawnie
-- rozpoznany (note='oppdatering', contact_type='epost') juz przy pierwszym imporcie. Jedynym
-- problemem byla literowka w dacie ("30.11.0202"), przez co wpis trafil z dzisiejsza data.
-- Tutaj usuwamy go po prostu jako wpis z najpozniejsza (nierealna) data dla tej firmy -
-- wszystkie prawdziwe wpisy Hersleth sa z 2020-2021, wiec to jednoznacznie ten sam wpis.

-- Warunek "occurred_at > 2022-01-01" to zabezpieczenie, zeby uruchomienie tej migracji
-- drugi raz (gdy problem jest juz naprawiony) nie usunelo przez pomylke prawdziwego,
-- najnowszego wpisu z 2021 roku.
DELETE FROM public.contact_activities
WHERE contact_id = (SELECT id FROM public.contacts WHERE lower(company_name) = lower('Hersleth Entreprenør AS'))
  AND occurred_at > '2022-01-01'
  AND occurred_at = (
    SELECT MAX(occurred_at) FROM public.contact_activities
    WHERE contact_id = (SELECT id FROM public.contacts WHERE lower(company_name) = lower('Hersleth Entreprenør AS'))
  );
