-- Migracja 009: poprawka daty dla Hersleth Entreprenør AS (nie usuwanie - to prawdziwy wpis)
--
-- W zrodlowym Excelu ta data byla wpisana jako zwykly TEKST "30.11.0202" (nie prawdziwa data
-- Excela, w przeciwienstwie do sasiednich wierszy) - najpewniej literowka przy recznym
-- wpisywaniu: chronologicznie pasuje idealnie jako 30.11.2020 (miedzy wpisami z 18.11.2020
-- i 26.02.2021). Poniewaz parser przy imporcie (migracja 006) nie rozpoznal tego tekstu jako
-- daty, wpis trafil z dzisiejsza data zamiast prawdziwej. Tutaj poprawiamy date zamiast
-- usuwac wpis (migracja 008 probowala go usunac, ale nie pasowal do warunku - patrz komentarz
-- w tamtym pliku).
--
-- Warunek "occurred_at > 2022-01-01" to zabezpieczenie przed ponownym uruchomieniem: jesli
-- wpis jest juz poprawiony, MAX(occurred_at) dla tej firmy to 2021-10-28 (nie pasuje), wiec
-- migracja bezpiecznie nic nie zrobi.
UPDATE public.contact_activities
SET occurred_at = '2020-11-30'
WHERE contact_id = (SELECT id FROM public.contacts WHERE lower(company_name) = lower('Hersleth Entreprenør AS'))
  AND occurred_at > '2022-01-01'
  AND occurred_at = (
    SELECT MAX(occurred_at) FROM public.contact_activities
    WHERE contact_id = (SELECT id FROM public.contacts WHERE lower(company_name) = lower('Hersleth Entreprenør AS'))
  );
