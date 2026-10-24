-- One-time migration for signed license responses
-- Run: supabase db push

create extension if not exists pgcrypto;

create table if not exists public.license_signing_keys (
  kid text primary key,
  alg text not null default 'Ed25519',
  public_key_base64 text not null,
  is_active boolean not null default true,
  created_at timestamptz not null default now()
);

alter table public.license_signing_keys enable row level security;

do $$
begin
  if not exists (
    select 1 from pg_policies
    where schemaname = 'public'
      and tablename = 'license_signing_keys'
      and policyname = 'deny_all_license_signing_keys'
  ) then
    create policy deny_all_license_signing_keys
    on public.license_signing_keys
    for all
    using (false)
    with check (false);
  end if;
end $$;
