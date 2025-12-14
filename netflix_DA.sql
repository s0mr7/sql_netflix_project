-- 1. Count the number of Movies vs TV Shows
select
    type,
    count(*)
from netflix_titles
group by 1;
-- 2. Find the most common rating for movies and TV shows
WITH RatingCounts AS (
    SELECT
        type,
        rating,
        COUNT(*) AS rating_count
    FROM netflix_titles
    GROUP BY type, rating
),
RankedRatings AS (
    SELECT
        type,
        rating,
        rating_count,
        RANK() OVER (PARTITION BY type ORDER BY rating_count DESC) AS rank_1
    FROM RatingCounts
)
SELECT
    type,
    rating AS most_frequent_rating
FROM RankedRatings
WHERE rank_1 = 1;
-- 3. List all movies released in a specific year (2019)
select *
from netflix_titles
where release_year = 2019;
-- 4. Find the top 5 countries with the most content on Netflix
SELECT
    TRIM(SUBSTRING_INDEX(
        SUBSTRING_INDEX(n.country, ',', numbers.n),
        ',',
        -1
    )) AS single_country,
    COUNT(*) AS total_content
FROM
    netflix_titles n
JOIN
    (
        SELECT 1 AS n UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5
    ) AS numbers
ON
    CHAR_LENGTH(n.country) - CHAR_LENGTH(REPLACE(n.country, ',', '')) >= numbers.n - 1
WHERE
    n.country IS NOT NULL
GROUP BY
    single_country
ORDER BY
    total_content DESC
LIMIT 5;
-- 5. Identify the longest movie
SELECT
    *
FROM
    netflix_titles
WHERE
    type = 'Movie'
ORDER BY
    CAST(SUBSTRING_INDEX(duration, ' ', 1) AS UNSIGNED) DESC;
-- 6. Find content added in the last 5 years
SELECT
    *
FROM
    netflix_titles
WHERE
    STR_TO_DATE(date_added, '%M %e, %Y') >=
    DATE_SUB(CURRENT_DATE(), INTERVAL 5 YEAR);
-- 7. Find all the movies/TV shows by director 'Marcus Raboy'!
SELECT
    *
FROM
    netflix_titles
WHERE
    FIND_IN_SET('Marcus Raboy', TRIM(REPLACE(director, ',', ''))) > 0;
-- 8. List all TV shows with more than 5 seasons
SELECT
    *
FROM
    netflix_titles
WHERE
    type = 'TV Show'
    AND
    CAST(SUBSTRING_INDEX(duration, ' ', 1) AS SIGNED) > 5;
-- 9.Find each year and the average numbers of content release in United States on netflix.
-- return top 5 year with highest avg content release!
SELECT
    country,
    release_year,
    COUNT(show_id) AS total_release,
    ROUND(
        (COUNT(show_id) * 100.0) /
        (SELECT COUNT(show_id) FROM netflix_titles WHERE country = 'United States'),
        2
    ) AS avg_release
FROM
    netflix_titles
WHERE
    country = 'United States'
GROUP BY
    country, release_year
ORDER BY
    avg_release DESC
LIMIT 5;
-- 10. List all movies that are documentaries
select *
from netflix_titles
where listed_in like '%Documentaries';
-- 11. Find all content without a director
select *
from netflix_titles
where director is null;
-- 12. Find how many movies actor 'David Attenborough' appeared in last 10 years!
select *
from netflix_titles
where cast = 'avid Attenborough'
  and release_year > year(current_date) - 10;
-- 13. Find the top 10 actors who have appeared in the highest number of movies produced in UnitedStates.
SELECT
    TRIM(SUBSTRING_INDEX(
        SUBSTRING_INDEX(n.cast, ',', numbers.n),
        ',',
        -1
    )) AS actor,
    COUNT(*) AS total_appearances
FROM
    netflix_titles n
JOIN
    (
        SELECT 1 AS n UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5
        UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9 UNION ALL SELECT 10
    ) AS numbers
ON
    CHAR_LENGTH(n.cast) - CHAR_LENGTH(REPLACE(n.cast, ',', '')) >= numbers.n - 1
WHERE
    n.country = 'United States'
    AND n.cast IS NOT NULL
GROUP BY
    actor
ORDER BY
    total_appearances DESC
LIMIT 10;
-- 14. Categorize Content Based on the Presence of 'Kill' and 'Violence' Keywords
SELECT
    category,
    COUNT(*) AS content_count
FROM (
    SELECT
        CASE
            WHEN description LIKE '%kill%' OR description LIKE '%violence%' THEN 'Bad'
            ELSE 'Good'
        END AS category
    FROM netflix_titles
) AS categorized_content
GROUP BY category;
