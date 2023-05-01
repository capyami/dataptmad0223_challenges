SELECT
  RANK() OVER(ORDER BY SUM(points) DESC) AS rank,
  CASE
    WHEN clan = '' THEN '[no clan specified]'
    ELSE clan
  END as clan,
  SUM(points) AS total_points,
  COUNT(clan) AS total_people
FROM people
GROUP BY 2