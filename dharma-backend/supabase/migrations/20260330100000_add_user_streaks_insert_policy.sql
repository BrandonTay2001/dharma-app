-- Allow authenticated users to insert their own streak row
create policy "Users can insert own streaks."
  on public.user_streaks
  for insert
  with check (auth.uid() = user_id);
