WITH cte AS(
SELECT * FROM biking_data.bike_share_yr_0
union all
SELECT * FROM biking_data.bike_share_yr_1 
)
SELECT 
dteday,
season,
a.yr,
weekday,
hr,
rider_type,
riders,
price,
COGS,
riders*price AS revenue,
riders*price - COGS AS profit
FROM cte a
LEFT JOIN biking_data.cost_table b
ON a.yr = b.yr; 
