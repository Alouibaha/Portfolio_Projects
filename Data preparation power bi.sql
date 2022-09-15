
-------------------------------------------------------------------------------------------------------------
WITH Hotels AS (
SELECT * FROM [2018]
UNION
SELECT * FROM [2019]
UNION
SELECT * FROM [2020])

SELECT arrival_date_year, hotel,
ROUND(SUM((stays_in_week_nights + stays_in_weekend_nights) * adr), 2)AS revenue  -- adr = Average Daily Rate
FROM Hotels
GROUP BY arrival_date_year, hotel
--------------------------------------------------------------------------------------------------------------

SELECT * FROM market_segment 

-----------------------------------------------------------------------------------------------------------------

-- Preparing data for visualization

-- Renaming Columns

SP_RENAME 'market_segments.market_segment', 'MarketSegments', 'Column'
GO

SP_RENAME 'meal_cost.meal', 'Meal_Type', 'Column'
GO

-- Joining tables

WITH Hotels AS (
SELECT * FROM [2018]
UNION
SELECT * FROM [2019]
UNION
SELECT * FROM [2020])

SELECT * FROM Hotels h
LEFT JOIN market_segments ms
ON h.market_segment = ms.MarketSegments
LEFT JOIN meal_cost mc
ON h.meal = mc.Meal_Type