create table public.scriptures (
  id uuid default gen_random_uuid() primary key,
  title text not null,
  tradition text check (tradition in ('Hindu', 'Buddhist')) not null,
  chapter_number integer not null check (chapter_number > 0),
  verse_number integer not null check (verse_number > 0),
  text text not null,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  unique (title, chapter_number, verse_number)
);

create index scriptures_title_chapter_idx
  on public.scriptures (title, chapter_number);

alter table public.scriptures enable row level security;

create policy "Anyone can read scriptures."
  on public.scriptures
  for select
  using (true);

create policy "Only service role can insert scriptures."
  on public.scriptures
  for insert
  with check (auth.role() = 'service_role');

create policy "Only service role can update scriptures."
  on public.scriptures
  for update
  using (auth.role() = 'service_role')
  with check (auth.role() = 'service_role');

create policy "Only service role can delete scriptures."
  on public.scriptures
  for delete
  using (auth.role() = 'service_role');

ALTER TABLE public.scriptures 
DROP CONSTRAINT scriptures_tradition_check;