create table public.chapter_titles (
  id uuid default gen_random_uuid() primary key,
  scripture_title text not null,
  chapter_number integer not null check (chapter_number > 0),
  chapter_title text not null
);

alter table public.chapter_titles enable row level security;

create policy "Anyone can read chapter titles."
  on public.chapter_titles
  for select
  using (true);

create policy "Only service role can insert chapter titles."
  on public.chapter_titles
  for insert
  with check (auth.role() = 'service_role');

create policy "Only service role can update chapter titles."
  on public.chapter_titles
  for update
  using (auth.role() = 'service_role')
  with check (auth.role() = 'service_role');

create policy "Only service role can delete chapter titles."
  on public.chapter_titles
  for delete
  using (auth.role() = 'service_role');