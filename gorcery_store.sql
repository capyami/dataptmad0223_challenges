-- Kata GROCERY STORE: Support Local Products



SELECT count(*) AS PRODUCTS, country
from products
where country in ('United States of America' , 'Canada')

group by country
  
order by products desc;