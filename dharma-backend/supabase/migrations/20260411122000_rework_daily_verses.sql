drop policy if exists "Anyone can read daily verses." on public.daily_verses;
drop policy if exists "Only service role can manage daily verses." on public.daily_verses;

drop table if exists public.daily_verses;

create table public.daily_verse_pool (
  id uuid default gen_random_uuid() primary key,
  scripture_title text not null,
  chapter_number integer not null check (chapter_number > 0),
  verse_number integer not null check (verse_number > 0),
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  unique (scripture_title, chapter_number, verse_number)
);

alter table public.daily_verse_pool enable row level security;

create policy "Anyone can read daily verse pool."
  on public.daily_verse_pool
  for select
  using (true);

create policy "Only service role can insert daily verse pool."
  on public.daily_verse_pool
  for insert
  with check (auth.role() = 'service_role');

create policy "Only service role can update daily verse pool."
  on public.daily_verse_pool
  for update
  using (auth.role() = 'service_role')
  with check (auth.role() = 'service_role');

create policy "Only service role can delete daily verse pool."
  on public.daily_verse_pool
  for delete
  using (auth.role() = 'service_role');