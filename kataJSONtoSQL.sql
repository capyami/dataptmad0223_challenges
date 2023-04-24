SELECT
  data ->> 'first_name' as first_name,
  data ->> 'last_name' as last_name,
  DATE_PART('year', AGE(CURRENT_DATE, TO_DATE(data ->> 'date_of_birth', 'YYYY-MM-DD'))) as age,
CASE
  WHEN data ->> 'private' = 'true' THEN 'Hidden'
  WHEN data ->> 'private' = 'false' AND data -> 'email_addresses' ->> 0 IS NULL THEN 'None'
  ELSE data -> 'email_addresses' ->> 0
  END as email_address
FROM users
ORDER BY first_name, last_name;