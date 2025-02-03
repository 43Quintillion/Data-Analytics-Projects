DROP TABLE if exists biking_data.bike_share_yr_1; 
CREATE TABLE biking_data.bike_share_yr_1 (
dteday	DATE,
season INT,
yr INT,
mnth INT,
hr INT,
holiday INT,
weekday INT,
workingday INT, 
weathersit INT,
temp numeric,
atemp numeric,
hum numeric,
windspeed numeric,
rider_type VARCHAR(50),
riders INT
)

DROP TABLE if exists biking_data.bike_share_yr_0; 
CREATE TABLE biking_data.bike_share_yr_0 (
dteday	DATE,
season INT,
yr INT,
mnth INT,
hr INT,
holiday INT,
weekday INT,
workingday INT, 
weathersit INT,
temp numeric,
atemp numeric,
hum numeric,
windspeed numeric,
rider_type VARCHAR(50),
riders INT
)

DROP TABLE if exists biking_data.cost_table;
CREATE TABLE biking_data.cost_table (
yr	INT,
price numeric,
COGS numeric
)