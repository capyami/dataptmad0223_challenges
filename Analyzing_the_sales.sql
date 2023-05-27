SELECT name AS product_name,
   EXTRACT(YEAR FROM s.date) AS year,
   EXTRACT(MONTH FROM s.date) AS month,
   EXTRACT(DAY FROM s.date) AS day,
   SUM(p.price* sd.count) AS total
FROM products p
JOIN sales_details sd on p.id = sd.product_id
JOIN sales s on s.id = sd.sale_id
GROUP BY ROLLUP(product_name, year, month, day)
ORDER BY product_name, year, month, day
;