-- Migracja 013: Vedlegg (załączniki) do wpisów Historikk - np. treść maila jako plik .msg
-- z Outlooka. Metadane w tabeli, same pliki w Supabase Storage (bucket "activity-attachments").
-- Uruchom w Supabase Dashboard -> SQL Editor -> Run.

create table if not exists public.contact_activity_attachments (
  id uuid primary key default gen_random_uuid(),
  activity_id uuid not null references public.contact_activities(id) on delete cascade,
  file_name text not null,
  storage_path text not null,
  content_type text,
  size_bytes bigint,
  created_at timestamptz not null default now(),
  created_by uuid references public.profiles(id)
);

create index if not exists contact_activity_attachments_activity_id_idx
  on public.contact_activity_attachments(activity_id);

drop trigger if exists trg_activity_attachments_audit on public.contact_activity_attachments;
create trigger trg_activity_attachments_audit
  before insert on public.contact_activity_attachments
  for each row execute function public.set_activity_audit_fields();

alter table public.contact_activity_attachments enable row level security;

drop policy if exists "authenticated can read attachments" on public.contact_activity_attachments;
create policy "authenticated can read attachments" on public.contact_activity_attachments
  for select to authenticated using (true);

drop policy if exists "authenticated can insert attachments" on public.contact_activity_attachments;
create policy "authenticated can insert attachments" on public.contact_activity_attachments
  for insert to authenticated with check (true);

drop policy if exists "authenticated can delete attachments" on public.contact_activity_attachments;
create policy "authenticated can delete attachments" on public.contact_activity_attachments
  for delete to authenticated using (true);

-- Storage: privat bucket, tilgang kun for innloggede brukere (nedlasting via signerte URL-er,
-- se app.js) - maks 25 MB per fil, ingen begrensning på filtype (mest .msg, men også pdf/eml/bilder etc.).
insert into storage.buckets (id, name, public, file_size_limit)
values ('activity-attachments', 'activity-attachments', false, 26214400)
on conflict (id) do nothing;

drop policy if exists "authenticated can read activity attachments" on storage.objects;
create policy "authenticated can read activity attachments" on storage.objects
  for select to authenticated using (bucket_id = 'activity-attachments');

drop policy if exists "authenticated can upload activity attachments" on storage.objects;
create policy "authenticated can upload activity attachments" on storage.objects
  for insert to authenticated with check (bucket_id = 'activity-attachments');

drop policy if exists "authenticated can delete activity attachments" on storage.objects;
create policy "authenticated can delete activity attachments" on storage.objects
  for delete to authenticated using (bucket_id = 'activity-attachments');
