-- =========================================================
-- TMDB Movies Analysis
-- Source: TMDB 5000 Movies (Kaggle)
-- Each query is standalone. Run against `movies` + `movie_genres`.
-- =========================================================

-- Average ROI and absolute profit per genre
SELECT g.genre,
       COUNT(DISTINCT m.id) AS n,
       ROUND(AVG(m.revenue / m.budget), 2) AS avg_roi,
       ROUND(AVG(m.revenue - m.budget)/1000000, 1) AS avg_profit_millions
FROM movies AS m
JOIN movie_genres AS g ON m.id = g.movie_id
WHERE m.budget > 100000 AND m.revenue > 100000
GROUP BY g.genre
HAVING n >= 20
ORDER BY avg_roi DESC;


-- Average absolute profit per genre
SELECT g.genre,
       COUNT(DISTINCT m.id) AS n,
       ROUND(AVG(m.revenue - m.budget)/1000000, 1) AS avg_profit_millions
FROM movies AS m
JOIN movie_genres AS g ON m.id = g.movie_id
WHERE m.budget > 100000 AND m.revenue > 100000
GROUP BY g.genre
HAVING n >= 20
ORDER BY avg_profit_millions DESC;


-- Critical failure rate per genre ("failing" = avg rating < 5.5)
SELECT g.genre,
       COUNT(DISTINCT m.id) AS total,
       SUM(CASE WHEN m.vote_average < 5.5 THEN 1 ELSE 0 END) AS failed,
       ROUND(100.0 * SUM(CASE WHEN m.vote_average < 5.5 THEN 1 ELSE 0 END)
             / COUNT(DISTINCT m.id), 1) AS fail_pct
FROM movies AS m
JOIN movie_genres AS g ON m.id = g.movie_id
GROUP BY g.genre
HAVING total >= 20
ORDER BY fail_pct DESC;


-- Median vs mean ROI per genre (MySQL has no MEDIAN, so computed via ROW_NUMBER)
WITH genre_roi AS (
  SELECT g.genre,
         m.revenue / m.budget AS roi
  FROM movies m
  JOIN movie_genres g ON m.id = g.movie_id
  WHERE m.budget > 100000 AND m.revenue > 100000
),
ranked AS (
  SELECT genre, roi,
         ROW_NUMBER() OVER (PARTITION BY genre ORDER BY roi) AS rn,
         COUNT(*)    OVER (PARTITION BY genre)             AS cnt
  FROM genre_roi
)
SELECT genre,
       cnt AS n,
       ROUND(AVG(roi), 2) AS mean_roi,
       ROUND(AVG(CASE WHEN rn IN (FLOOR((cnt+1)/2), CEIL((cnt+1)/2)) THEN roi END), 2) AS median_roi
FROM ranked
GROUP BY genre, cnt
ORDER BY mean_roi DESC;


-- Critical acclaim rate per genre ("acclaimed" = avg rating >= 7.5)
SELECT g.genre,
       COUNT(DISTINCT m.id) AS total,
       SUM(CASE WHEN m.vote_average >= 7.5 THEN 1 ELSE 0 END) AS acclaimed,
       ROUND(100.0 * SUM(CASE WHEN m.vote_average >= 7.5 THEN 1 ELSE 0 END)
             / COUNT(DISTINCT m.id), 1) AS acclaim_pct
FROM movies AS m
JOIN movie_genres AS g ON m.id = g.movie_id
GROUP BY g.genre
HAVING total >= 20
ORDER BY acclaim_pct DESC;