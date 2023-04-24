
--Countries Capitals for Trivia Night

select capital 
from countries
where continent like 'Afri%' and country like 'E%'
order by capital
limit 3;

--SQL Bug Fixing: Fix the QUERY - Totaling

select cast(s.transaction_date as date) as day,
d.name as department,
count(s.id) as sale_count
from department as d
inner join sale as s on d.id = s.department_id
group by d.name, day
order by day


--SQL Basics: Group By Day


select cast(created_at as date) as day,
description, 
count(created_at)
from events 
where name = 'trained' 
group by day, description
order by day;