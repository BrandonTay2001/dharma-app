create table public.observances (
  id uuid default gen_random_uuid() primary key,
  observance_date date not null,
  title text not null,
  tradition text check (tradition in ('buddhist', 'hindu', 'shared')) not null,
  summary text not null,
  suggested_practice text not null,
  ritual_steps text[] not null check (coalesce(array_length(ritual_steps, 1), 0) > 0),
  why_it_matters text not null,
  is_major_observance boolean not null default false,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  unique (observance_date, title)
);

create index observances_date_idx
  on public.observances (observance_date);

alter table public.observances enable row level security;

create policy "Anyone can read observances."
  on public.observances
  for select
  using (true);

create policy "Only service role can insert observances."
  on public.observances
  for insert
  with check (auth.role() = 'service_role');

create policy "Only service role can update observances."
  on public.observances
  for update
  using (auth.role() = 'service_role')
  with check (auth.role() = 'service_role');

create policy "Only service role can delete observances."
  on public.observances
  for delete
  using (auth.role() = 'service_role');