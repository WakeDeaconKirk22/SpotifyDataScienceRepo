--EDA
SELECT COUNT(*) FROM spotify;
SELECT COUNT (DISTINCT artist)FROM spotify;

SELECT DISTINCT album_type FROM spotify;

SELECT MAX(duration_min) FROM spotify;

SELECT MIN(duration_min) FROM spotify;


SELECT * FROM spotify
WHERE duration_min=0;

DELETE FROM spotify
WHERE duration_min=0;
SELECT * FROM spotify
WHERE duration_min = 0;

SELECT DISTINCT channel FROM spotify;

SELECT DISTINCT  most_played_on FROM spotify;

--Buisness Questions

-- Retrieve all the names of songs with more than 11 billion streams--
SELECT * FROM spotify 
WHERE stream > 1000000000;

--List all albums from T
/*SELECT 
     DISTINCT album,artist
FROM spotify
ORDER BY 1
*/
-- Get total number of comments for tracks where licensced =TRUE
SELECT SUM(comments) as total_comments
FROM spotify 
WHERE licensed = 'true';

--Get the total number of comments for tracks that belong to the album type sinhle
SELECT * FROM spotify 
WHERE album_type ILIKE 'single';

-- Count the total number tracks by each artist 
SELECT
   artist, --- 1
   COUNT (*) as total_songs --2
FROM spotify
GROUP BY ARTIST
ORDER BY 2

-- calculate the average danceability
/*
SELECT 
	album,
	avg(danceability) as avg_danceability
FROM spotify 
GROUP BY 1
ORDER BY 2 DESC
*/
-- Find the top 5 tracks with highest energy values
/*
SELECT 
	track,
	MAX(energy)
FROM spotify;
GROUP BY 1 
ORDER BY 2
LIMIT 5
*/

-- List all tracks along with their views and likes where official_video=true
SELECT
	track,
	SUM(views) as total_views,
	SUM(likes) as total_likes
FROM spotify
WHERE official_video = 'true'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5

-- For each album the total_views of all associated tracks
SELECT
	album,
	track,
	SUM(views)
FROM spotify
GROUP BY 1,2
ORDER BY 3 DESC


-- Retrieve the track names that have been streamed on spotify more than Youtube
SELECT * FROM
(SELECT 
	track,
	COALESCE(SUM(CASE WHEN most_played_on = 'Youtube' THEN stream END),0) as streamed_on_youtube,
	COALESCE(SUM(CASE WHEN most_played_on = 'Spotify' THEN stream END),0)as streamed_on_spotify
FROM spotify
GROUP BY 1
) as t1
WHERE 
	streamed_on_spotify > streamed_on_youtube
	AND
	streamed_on_youtube <> 0

-- Finding top 3 most-viewed tracks for each artist using window function
--each artist and total view for each track
--track with highest view for each artist
-- dense rank
--cte and filder rank <=3
WITH ranking_artist
AS
(SELECT 
	artist,
	track,
	SUM(views) as total_view,
	DENSE_RANK() OVER(PARTITION BY artist order by SUM(views)DESC) as rank
FROM spotify 
GROUP BY 1,2
ORDER BY 1,3 DESC
)
SELECT * FROM ranking_artist
WHERE rank <=3

-- a query to find tracks where liveness is above average
SELECT 
  track,
  artist,
  liveness
FROM spotify
WHERE liveness > (SELECT AVG(liveness) FROM spotify)

--Use a WITH clause to calculate the difference between the highest and lowest energy

WITH cte
AS
(SELECT 
	album ,
	MAX(energy) as highest_energy,
	MIN(energy) as lowest_energy
FROM spotify
GROUP BY 1
)
SELECT
	album,
	highest_energy - lowest_energy as energy_diff
FROM cte
ORDER BY 2 DESC