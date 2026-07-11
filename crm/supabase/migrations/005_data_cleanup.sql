-- Migracja 005: porządkowanie dwóch niechlujnych rekordów z importu Excela
-- Uruchom w Supabase Dashboard -> SQL Editor -> Run.

-- Bygg Design Moldoveanu: "alexandru-iulian-moldoveanu" -> "Alexandru Iulian Moldoveanu"
update public.contact_people
set full_name = 'Alexandru Iulian Moldoveanu'
where full_name = 'alexandru-iulian-moldoveanu'
  and contact_id = (select id from public.contacts where company_name = 'Bygg Design Moldoveanu');

-- STRÅ Arkitekter AS: jedno pole z dwiema osobami rozdzielonymi "and" -> dwa osobne wiersze
update public.contact_people
set full_name = 'Anders Byng Strøm'
where full_name = 'Anders Byng Strøm and Gustav Jerlvall Jeppsson.'
  and contact_id = (select id from public.contacts where company_name = 'STRÅ Arkitekter AS');

insert into public.contact_people (contact_id, full_name, is_primary)
select id, 'Gustav Jerlvall Jeppsson', false
from public.contacts
where company_name = 'STRÅ Arkitekter AS';
