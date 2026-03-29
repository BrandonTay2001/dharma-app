alter table public.learn_articles
  add column image_url text;

update public.learn_articles
set image_url = concat('https://picsum.photos/seed/', image_name, '/1200/800')
where image_name is not null
  and image_url is null;

alter table public.learn_articles
  drop column image_name;
