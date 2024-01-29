-- Data from kaggle.com, www.kaggle.com/datasets/gregorut/videogamesales
SELECT * FROM vgsales;
--Data cleaning and transformation
DELETE FROM vgsales WHERE EU_Sales = 'Misc';

DELETE FROM vgsales
WHERE ISNUMERIC(NA_Sales) = 0;

ALTER TABLE vgsales
ALTER COLUMN NA_Sales FLOAT;

ALTER TABLE vgsales
ALTER COLUMN EU_Sales FLOAT;

ALTER TABLE vgsales
ALTER COLUMN JP_Sales FLOAT;

ALTER TABLE vgsales
ALTER COLUMN Other_Sales FLOAT;

ALTER TABLE vgsales
ALTER COLUMN Global_Sales FLOAT;

SELECT *
FROM vgsales
WHERE TRY_CAST(EU_Sales AS FLOAT) IS NULL
   AND EU_Sales IS NOT NULL;

----SQL Queries 

--Which gaming platforms have the highest average global sales?
SELECT Platform, ROUND(AVG(Global_Sales), 2) AS Average_Sales
FROM vgsales
GROUP BY Platform
ORDER BY Average_Sales DESC;

--Which gaming platforms have average global sales greater than the overall average game count for platforms?
SELECT Platform, ROUND(AVG(Global_Sales), 2) AS 'Average Sales (in $m)'
FROM vgsales
GROUP BY Platform
HAVING COUNT(Name) > (
	SELECT AVG(GameCount) 
	FROM (
		SELECT Platform, COUNT(Name) AS GameCount 
		FROM vgsales 
		GROUP BY Platform
) 
	AS PlatformGameCount
)
ORDER BY 'Average Sales (in $m)' DESC;

--What is the distribution of sales in 8th gen consoles?
SELECT 
    Platform,
    SUM(NA_Sales) AS 'Total North America Sales (in $m)',
    SUM(EU_Sales) AS 'Total Europe Sales (in $m)',
    SUM(JP_Sales) AS 'Total Japan Sales (in $m)',
    ROUND(SUM(Other_Sales), 2) AS 'Total Rest of World Sales (in $m)'
FROM
    vgsales
WHERE 
    Platform IN ('WiiU', 'XOne', 'PS4', '3DS')
GROUP BY 
    Platform
ORDER BY 
    Platform;


--Can you analyze the dynamic market share of each gaming platform over the years? 
WITH PlatformMarketShare AS (
    SELECT
        TRY_CAST(Year AS INT) AS Year,  -- Use TRY_CAST to handle 'N/A'
        Platform,
        SUM(Global_Sales) AS PlatformSales,
        SUM(SUM(Global_Sales)) OVER (PARTITION BY TRY_CAST(Year AS INT)) AS TotalSalesPerYear
    FROM
        vgsales
	WHERE
        Platform IN ('3DS', 'WiiU', 'PS4', 'XOne') -- Focus on specific platforms
    GROUP BY
        TRY_CAST(Year AS INT), Platform
)
SELECT
    Year,
    Platform,
    ROUND(PlatformSales, 2) AS '8th Gen Sales (in $m)',
    ROUND((PlatformSales / NULLIF(TotalSalesPerYear, 0)) * 100, 2) AS 'Market Share Percentage (%)' -- Rounded to two decimal places
FROM
    PlatformMarketShare
WHERE
    Year > 2011 AND Year < 2017 --Release of the Wii U was 2012
ORDER BY
    Year, 'Market Share Percentage (%)' DESC;

--What were the top-selling games and their publishers on the main 3 companies' platforms?
-- Wii U
SELECT TOP 20 
    Name AS Title, 
    Publisher, 
    Global_Sales AS 'Sales (in $m)',
    Genre
FROM vgsales 
WHERE Platform = 'WiiU'
ORDER BY 'Sales (in $m)' DESC;

-- Xbox One
SELECT TOP 20 
    Name AS Title, 
    Publisher, 
    Global_Sales AS 'Sales (in $m)',
    Genre
FROM vgsales 
WHERE Platform = 'XOne'
ORDER BY 'Sales (in $m)' DESC;

-- PS4
SELECT TOP 20 
    Name AS Title, 
    Publisher, 
    Global_Sales AS 'Sales (in $m)',
    Genre
FROM vgsales 
WHERE Platform = 'PS4'
ORDER BY 'Sales (in $m)' DESC;

-- 3DS
SELECT TOP 20 
    Name AS Title, 
    Publisher, 
    Global_Sales AS 'Sales (in $m)',
    Genre
FROM vgsales 
WHERE Platform = '3DS'
ORDER BY 'Sales (in $m)' DESC;

-- Wii
SELECT TOP 20 
    Name AS Title, 
    Publisher, 
    Global_Sales AS 'Sales (in $m)',
    Genre
FROM vgsales 
WHERE Platform = 'Wii'
ORDER BY 'Sales (in $m)' DESC;

--Genre
SELECT Genre, ROUND(SUM(Global_Sales), 2) as 'Total Sales (in $m)'
FROM vgsales
WHERE Platform IN ('WiiU', '3DS', 'Wii', 'DS')
GROUP BY Genre
ORDER BY 'Total Sales (in $m)' DESC;

SELECT Genre, ROUND(SUM(Global_Sales), 2) as 'Total Sales (in $m)'
FROM vgsales
WHERE Platform IN ('XOne', 'X360')
GROUP BY Genre
ORDER BY 'Total Sales (in $m)' DESC;

SELECT Genre, ROUND(SUM(Global_Sales), 2) as 'Total Sales (in $m)'
FROM vgsales
WHERE Platform IN ('PS4', 'PS3', 'PSV', 'PSP')
GROUP BY Genre
ORDER BY 'Total Sales (in $m)' DESC;

--What are the top shooting games on the 8th gen consoles?
SELECT TOP 10 Name, ROUND(SUM(Global_Sales), 2) as 'Sales (in $m)'
FROM vgsales
WHERE Platform IN ('WiiU') AND Genre = 'Shooter'
GROUP BY Name
ORDER BY 'Sales (in $m)' DESC;

SELECT TOP 10 Name, ROUND(SUM(Global_Sales), 2) as 'Sales (in $m)'
FROM vgsales
WHERE Platform IN ('XOne') AND Genre = 'Shooter'
GROUP BY Name
ORDER BY 'Sales (in $m)' DESC;

SELECT TOP 10 Name, ROUND(SUM(Global_Sales), 2) as 'Sales (in $m)'
FROM vgsales
WHERE Platform IN ('PS4') AND Genre = 'Shooter'
GROUP BY Name
ORDER BY 'Sales (in $m)' DESC;
--How did Call of Duty: Black Ops II on the different platforms it was released in?
SELECT Name, Platform, Global_Sales as 'Sales (in $m)'
FROM vgsales
WHERE Name = 'Call of Duty: Black Ops II';


--How successful were FIFA games on the Xbox One (XOne) and PlayStation 4 (PS4) platforms?
SELECT
    Platform,
    COUNT(CASE WHEN Name LIKE '%FIFA%' AND Publisher = 'Electronic Arts' THEN 1 END) AS 'Number of FIFA Games',
    SUM(CASE WHEN Name LIKE '%FIFA%' AND Publisher = 'Electronic Arts' THEN Global_Sales END) AS 'Total Sales from FIFA Games (in $m)',
    SUM(Global_Sales) AS 'Total Platform Sales',
    ROUND((SUM(CASE WHEN Name LIKE '%FIFA%' AND Publisher = 'Electronic Arts' THEN Global_Sales END) / SUM(Global_Sales)) * 100, 2) AS 'Percentage Contribution of FIFA Sales (%)'
FROM
    vgsales
WHERE
    Platform IN ('XOne', 'PS4')
GROUP BY
    Platform;


----unused queries
WITH PlatformPublishers AS (
    SELECT
        Platform,
        COUNT(DISTINCT Publisher) AS UniquePublishers,
        COUNT(*) AS TotalGames
    FROM
        vgsales
    WHERE
        Platform IN ('3DS', 'Wii', 'WiiU', 'X360', 'XOne', 'PS3', 'PS4', 'PSV')
    GROUP BY
        Platform
)

SELECT
    p.Platform,
    p.UniquePublishers,
    p.TotalGames,
    CAST((p.UniquePublishers * 1.0 / NULLIF(p.TotalGames, 0)) * 100 AS DECIMAL(10, 2)) AS PublisherRatio
FROM
    PlatformPublishers p
ORDER BY
    p.Platform;


--How did the sales of Wii U games evolve over the years compared to competitors?
WITH PlatformSales AS (
    SELECT
        Year,
        Platform,
        SUM(Global_Sales) AS PlatformSales
    FROM
        vgsales
    WHERE
        Platform IN ('WiiU', 'PS4', 'XOne')
    GROUP BY
        Year, Platform
),
IndustrySales AS (
    SELECT
        Year,
        SUM(Global_Sales) AS TotalIndustrySales
    FROM
        vgsales
    GROUP BY
        Year
)
SELECT
    p.Year,
    p.Platform,
    p.PlatformSales,
    ROUND(i.TotalIndustrySales, 2) AS TotalIndustrySales,
    ROUND((p.PlatformSales / NULLIF(i.TotalIndustrySales, 0)) * 100, 2) AS MarketSharePercentage
FROM
    PlatformSales p
JOIN
    IndustrySales i ON p.Year = i.Year
ORDER BY
    p.Year, p.Platform;

--Which genres performed the best and worst on the Wii U in terms of sales?
SELECT Genre, SUM(Global_Sales) AS TotalSales
FROM vgsales
WHERE Platform = 'WiiU'
GROUP BY Genre
ORDER BY TotalSales DESC;

--Did specific publishers have a significant impact on Wii U game sales?
SELECT Publisher, SUM(Global_Sales) AS TotalSales
FROM vgsales
WHERE Platform = 'WiiU'
GROUP BY Publisher
ORDER BY TotalSales DESC;

--How did Wii U game sales vary across different regions (NA, EU, JP, Other)?
SELECT Name AS Title, NA_Sales, EU_Sales, JP_Sales, Other_Sales
FROM vgsales
WHERE Platform = 'WiiU';





