-- Run once in the Supabase SQL editor for the LeanFlow/LeanOffice project.
-- Creates the sync table LeanOffice uses (mirrors LeanFlow's leanhq_items pattern:
-- one row per task, tombstone deletes via value = null).

create table if not exists public.leanoffice_sync (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  collection text not null,
  item_id text not null,
  value jsonb,
  updated_at timestamptz not null default now(),
  unique (user_id, collection, item_id)
);

alter table public.leanoffice_sync enable row level security;

create policy "Users manage their own leanoffice rows"
on public.leanoffice_sync
for all
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

create index if not exists leanoffice_sync_user_collection_idx
on public.leanoffice_sync (user_id, collection, updated_at);
