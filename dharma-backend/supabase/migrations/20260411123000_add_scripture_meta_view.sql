create view public.scripture_meta as
  select distinct title, tradition
  from public.scriptures;
