-- Track dates on which a user completed all daily tasks
create table public.daily_completions (
  user_id uuid references public.users(id) on delete cascade not null,
  completed_date date not null,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  primary key (user_id, completed_date)
);

-- RLS for daily_completions
alter table public.daily_completions enable row level security;

create policy "Users can view own completions."
  on public.daily_completions for select
  using (auth.uid() = user_id);

create policy "Users can insert own completions."
  on public.daily_completions for insert
  with check (auth.uid() = user_id);
