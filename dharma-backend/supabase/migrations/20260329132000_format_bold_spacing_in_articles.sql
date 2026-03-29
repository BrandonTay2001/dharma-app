-- Normalize spacing around bolded markdown section headers in article content:
-- Ensure exactly 2 newlines before and 1 newline after any **bold** text.
UPDATE public.learn_articles
SET content = regexp_replace(
  regexp_replace(
    content,
    '\n+(\*\*[^*\n][^\n]*\*\*)',
    E'\n\n\\1',
    'g'
  ),
  '(\*\*[^*\n][^\n]*\*\*)\n+',
  E'\\1\n',
  'g'
)
WHERE content ~ '\*\*';
