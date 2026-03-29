-- Create users table (extends Supabase auth.users)
create table public.users (
  id uuid references auth.users not null primary key,
  email text unique not null,
  display_name text,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  updated_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Protect users table with RLS
alter table public.users enable row level security;
create policy "Users can view own profile." on public.users for select using (auth.uid() = id);
create policy "Users can update own profile." on public.users for update using (auth.uid() = id);

-- Create journal_entries table
create table public.journal_entries (
  id uuid default gen_random_uuid() primary key,
  user_id uuid references public.users(id) on delete cascade not null,
  date date not null,
  content text not null,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  updated_at timestamp with time zone default timezone('utc'::text, now()) not null,
  unique (user_id, date)
);

-- RLS for journal_entries
alter table public.journal_entries enable row level security;
create policy "Users can view own journal entries." on public.journal_entries for select using (auth.uid() = user_id);
create policy "Users can insert own journal entries." on public.journal_entries for insert with check (auth.uid() = user_id);
create policy "Users can update own journal entries." on public.journal_entries for update using (auth.uid() = user_id);
create policy "Users can delete own journal entries." on public.journal_entries for delete using (auth.uid() = user_id);

-- Create daily_verses table (shared across users)
create table public.daily_verses (
  id uuid default gen_random_uuid() primary key,
  date date not null,
  religion text check (religion in ('hindu', 'buddhist')) not null,
  verse_text text not null,
  verse_source text not null,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  unique (date, religion)
);

-- RLS for daily_verses
alter table public.daily_verses enable row level security;
-- Anyone can read the daily verses
create policy "Anyone can read daily verses." on public.daily_verses for select using (true);
-- Only service role (admin) can insert/update/delete verses
create policy "Only service role can manage daily verses." on public.daily_verses for all using (auth.role() = 'service_role');

-- Create user_streaks table
create table public.user_streaks (
  user_id uuid references public.users(id) on delete cascade primary key,
  current_streak integer default 0 not null,
  longest_streak integer default 0 not null,
  last_active_date date
);

-- RLS for user_streaks
alter table public.user_streaks enable row level security;
create policy "Users can view own streaks." on public.user_streaks for select using (auth.uid() = user_id);
create policy "Users can update own streaks." on public.user_streaks for update using (auth.uid() = user_id);

-- Trigger to create a public.users row on auth.users insert
create function public.handle_new_user()
returns trigger as $$
begin
  insert into public.users (id, email)
  values (new.id, new.email);
  return new;
end;
$$ language plpgsql security definer;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();
