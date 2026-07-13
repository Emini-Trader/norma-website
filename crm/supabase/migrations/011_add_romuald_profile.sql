-- Migracja 011: imię i nazwisko dla nowego użytkownika Romuald (konto już utworzone
-- w Authentication -> Users, ten krok tylko uzupełnia first_name/last_name w profiles).
-- Uruchom w Supabase Dashboard -> SQL Editor -> Run.

update public.profiles set first_name = 'Romuald', last_name = 'Radomski' where email = 'romuald@norma-gs.no';
