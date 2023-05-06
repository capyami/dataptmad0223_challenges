SELECT player_name, 
games,
cast(ROUND(cast(hits as decimal)/cast(at_bats as decimal), 3)as text) AS batting_average
FROM yankees
WHERE at_bats > 100
ORDER BY 3 DESC