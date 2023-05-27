SELECT c.id AS category_id,
       c.category,
       p.title,
       p.views,
       p.id AS post_id
FROM categories c
LEFT JOIN LATERAL
  (SELECT id,
          category_id,
          title,
          views
   FROM posts p
   WHERE c.id = p.category_id
   ORDER BY views DESC
   LIMIT 2) p ON c.id = p.category_id
ORDER BY c.category,
         p.views DESC,
         post_id