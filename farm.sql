create database agriculture_db;
use agriculture_db;

RENAME TABLE farmer.farmers       TO agriculture_db.farmers,
             farmer.crops         TO agriculture_db.crops,
             farmer.cultivation   TO agriculture_db.cultivation,
             farmer.transactions  TO agriculture_db.transactions;





-- Farmers table
SELECT
  SUM(farmer_id IS NULL) AS farmer_id_nulls,
  SUM(farmer_name IS NULL) AS farmer_name_nulls,
  SUM(email IS NULL) AS email_nulls,
  SUM(state IS NULL) AS state_nulls
FROM farmers;

-- Cultivation table
SELECT
  SUM(cultivation_id IS NULL) AS cultivation_id_nulls,
  SUM(farmer_id IS NULL) AS farmer_id_nulls,
  SUM(crop_id IS NULL) AS crop_id_nulls,
  SUM(year IS NULL) AS year_nulls,
  SUM(area_hectare IS NULL) AS area_nulls,
  SUM(production_tons IS NULL) AS production_nulls,
  SUM(fertilizer_used IS NULL) AS fertilizer_nulls
FROM cultivation;



-- -- Crops table
SELECT
  SUM(crop_id IS NULL) AS crop_id_nulls,
  SUM(crop_name IS NULL) AS crop_name_nulls,
  SUM(season IS NULL) AS season_nulls
FROM crops;



-- Transactions table
SELECT
  SUM(transaction_id IS NULL) AS transaction_id_nulls,
  SUM(cultivation_id IS NULL) AS cultivation_id_nulls,
  SUM(buyer_name IS NULL) AS buyer_nulls,
  SUM(transaction_date IS NULL) AS date_nulls
FROM transactions;



## Joining tables

-- Join Farmers & Cultivation Data
SELECT f.farmer_id,
       f.farmer_name,
       f.state,
       cu.cultivation_id,
       cu.year,
       cu.area_hectare,
       cu.production_tons
FROM farmers f
JOIN cultivation cu ON f.farmer_id = cu.farmer_id;


-- Join Crops with Farmers & Cultivation
SELECT f.farmer_name,
       f.state,
       c.crop_name,
       cu.year,
       cu.production_tons
FROM farmers f
JOIN cultivation cu ON f.farmer_id = cu.farmer_id
JOIN crops c ON cu.crop_id = c.crop_id;

-- Join Transactions with Farmers & Crops
SELECT t.transaction_id,
       t.buyer_name,
       t.transaction_date,
       f.farmer_name,
       c.crop_name,
       cu.production_tons
FROM transactions t
JOIN cultivation cu ON t.cultivation_id = cu.cultivation_id
JOIN farmers f ON cu.farmer_id = f.farmer_id
JOIN crops c ON cu.crop_id = c.crop_id;


-- Create New Feature – Yield (tons per hectare)
SELECT cu.cultivation_id,
       f.farmer_name,
       c.crop_name,
       cu.year,
       (cu.production_tons / cu.area_hectare) AS yield_per_hectare
FROM cultivation cu
JOIN farmers f ON cu.farmer_id = f.farmer_id
JOIN crops c ON cu.crop_id = c.crop_id
LIMIT 10;



-- Aggregate – Total Production per State
SELECT f.state,
       SUM(cu.production_tons) AS total_production
FROM cultivation cu
JOIN farmers f ON cu.farmer_id = f.farmer_id
GROUP BY f.state
ORDER BY total_production DESC;


-- Filter – Farmers Who Haven’t Sold Anything
SELECT DISTINCT f.farmer_id, f.farmer_name, f.state
FROM farmers f
LEFT JOIN cultivation cu ON f.farmer_id = cu.farmer_id
LEFT JOIN transactions t ON cu.cultivation_id = t.cultivation_id
WHERE t.transaction_id IS NULL;



-- ---------- Questions---------------


-- Total Number of Farmers

SELECT COUNT(*) AS total_farmers
FROM farmers;


-- Most Common Fertilizer

SELECT fertilizer_used, COUNT(*) AS usage_count
FROM cultivation
GROUP BY fertilizer_used
ORDER BY usage_count DESC
LIMIT 1;


-- State-wise Production

SELECT f.state, SUM(cu.production_tons) AS total_production
FROM cultivation cu
JOIN farmers f ON cu.farmer_id = f.farmer_id
GROUP BY f.state
ORDER BY total_production DESC;




-- Crop-wise Yield

SELECT c.crop_name, 
       AVG(cu.production_tons / cu.area_hectare) AS avg_yield
FROM cultivation cu
JOIN crops c ON cu.crop_id = c.crop_id
GROUP BY c.crop_name
ORDER BY avg_yield DESC;



-- Yearly Trend of Production

SELECT year, SUM(production_tons) AS yearly_prod
FROM cultivation
GROUP BY year
ORDER BY year;


-- Top 3 Crops by Production

SELECT c.crop_name, SUM(cu.production_tons) AS total_prod
FROM cultivation cu
JOIN crops c ON cu.crop_id = c.crop_id
GROUP BY c.crop_name
ORDER BY total_prod DESC
LIMIT 3;

-- Crop Contribution (%)

SELECT c.crop_name,
       ROUND(SUM(cu.production_tons) * 100.0 / 
             (SELECT SUM(production_tons) FROM cultivation),2) AS pct_contribution
FROM cultivation cu
JOIN crops c ON cu.crop_id = c.crop_id
GROUP BY c.crop_name;




-- Fertilizer vs Yield

SELECT fertilizer_used,
       AVG(production_tons / area_hectare) AS avg_yield
FROM cultivation
GROUP BY fertilizer_used
ORDER BY avg_yield DESC;




-- Farmers Without Transactions

SELECT DISTINCT f.farmer_name
FROM farmers f
LEFT JOIN cultivation cu ON f.farmer_id = cu.farmer_id
LEFT JOIN transactions t ON cu.cultivation_id = t.cultivation_id
WHERE t.transaction_id IS NULL;


-- Cumulative Production (Window Function)

SELECT 
    year,
    SUM(yearly_prod) OVER (ORDER BY year) AS cumulative_prod
FROM (
    SELECT year, SUM(production_tons) AS yearly_prod
    FROM cultivation
    GROUP BY year
) AS yearly_data
ORDER BY year;


select * from transactions;
select * from farmers;



SELECT email, COUNT(*) 
FROM farmers 
GROUP BY email 
HAVING COUNT(*) > 1;











