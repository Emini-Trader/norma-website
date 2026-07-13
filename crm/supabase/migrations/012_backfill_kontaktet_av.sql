-- Migracja 012: uzupełnienie "Kontaktet av" (created_by) dla WSZYSTKICH istniejących
-- wpisów Historikk, wg daty (occurred_at) - dotychczas puste/losowe dla importowanych wpisów.
-- Uruchom PO 011_add_romuald_profile.sql (potrzebuje jej wiersza w profiles).
-- Uruchom w Supabase Dashboard -> SQL Editor -> Run.
--
-- Reguła:
--   po 2026-06-01                    -> Joanna
--   2026-02-01 do 2026-05-31 (włącznie) -> Tomasz
--   reszta (przed 2026-02-01)        -> Romuald

update public.contact_activities
set created_by = (select id from public.profiles where email = 'joanna@norma-gs.no')
where occurred_at > date '2026-06-01';

update public.contact_activities
set created_by = (select id from public.profiles where email = 'tomasz@norma-gs.no')
where occurred_at >= date '2026-02-01' and occurred_at <= date '2026-05-31';

update public.contact_activities
set created_by = (select id from public.profiles where email = 'romuald@norma-gs.no')
where occurred_at < date '2026-02-01';
