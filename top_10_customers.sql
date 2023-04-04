-- top 10 customers
SELECT 
    c.customer_id, 
    c.email, 
    COUNT(p.payment_id) AS payments_count, 
    CAST(SUM(p.amount) AS FLOAT) AS total_amount 
FROM 
    customer c 
    JOIN payment p ON c.customer_id = p.customer_id 
GROUP BY 
    c.customer_id 
ORDER BY 