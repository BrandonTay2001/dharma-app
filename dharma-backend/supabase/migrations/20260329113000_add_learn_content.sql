create table public.learn_articles (
  id uuid default gen_random_uuid() primary key,
  title text not null,
  subtitle text,
  image_name text,
  tags text[] not null default '{}',
  estimated_read_mins integer,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

alter table public.learn_articles enable row level security;

create policy "Anyone can read learn articles."
  on public.learn_articles
  for select
  using (true);

create policy "Only service role can insert learn articles."
  on public.learn_articles
  for insert
  with check (auth.role() = 'service_role');

create policy "Only service role can update learn articles."
  on public.learn_articles
  for update
  using (auth.role() = 'service_role')
  with check (auth.role() = 'service_role');

create policy "Only service role can delete learn articles."
  on public.learn_articles
  for delete
  using (auth.role() = 'service_role');