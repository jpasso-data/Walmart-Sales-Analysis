-- Q1: Check for blank values in all columns
-- Result: 0 nulls in Store, Dept, Date, Weekly_Sales, IsHoliday (matches Excel);
SELECT
  COUNTIF(Store IS NULL) AS null_store,
  COUNTIF(Dept IS NULL) AS null_dept,
  COUNTIF(Date IS NULL) AS null_date,
  COUNTIF(Weekly_Sales IS NULL) AS null_weekly_sales,
  COUNTIF(IsHoliday IS NULL) AS null_isholiday
FROM `walmart-sales-project-jpasso.walmart_sales.train`;


-- Q2: Count rows with negative Weekly_Sales
-- Result: 1,285 rows (~0.3%), flagged not deleted, likely return weeks (matches Excel)
SELECT
  COUNT(*) AS negative_rows
FROM `walmart-sales-project-jpasso.walmart_sales.train`
WHERE Weekly_Sales < 0;


-- Q3: Overall average Weekly_Sales
-- Result: $15,981.26 (matches Excel)
SELECT
  ROUND(AVG(Weekly_Sales), 2) AS avg_weekly_sales
FROM `walmart-sales-project-jpasso.walmart_sales.train`;


-- Q4: Department 47 profile
-- Result: 646 rows, 254 negative (39%), avg -$7.68 vs dataset avg +$15,981.26 (matches Excel)
SELECT
  COUNT(*) AS total_rows,
  COUNTIF(Weekly_Sales < 0) AS negative_rows,
  ROUND(AVG(Weekly_Sales), 2) AS avg_weekly_sales
FROM `walmart-sales-project-jpasso.walmart_sales.train`
WHERE Dept = 47;


-- Q5: Dept 47's share of all negative-sales rows
-- Result: 0.1977 (~20%), despite Dept 47 being <1% of all rows (matches Excel)
-- Technique: conditional aggregation, condition inside COUNTIF instead of WHERE
SELECT
  ROUND(COUNTIF(Weekly_Sales < 0 AND Dept = 47) / COUNTIF(Weekly_Sales < 0), 4) AS dept47_share_of_negatives
FROM `walmart-sales-project-jpasso.walmart_sales.train`;


-- Q6: How many stores carry Dept 47?
-- Result: 37 of 45 stores (not universal, not niche) (matches Excel)
SELECT
  COUNT(DISTINCT Store) AS stores_with_dept47
FROM `walmart-sales-project-jpasso.walmart_sales.train`
WHERE Dept = 47;


-- Q7: Average sales, holiday vs non-holiday weeks
-- Result: holiday $17,035.82 vs non-holiday $15,901.45 (~7% difference) (matches Excel)
-- Takeaway: too small to explain the mean/median skew
SELECT
  IsHoliday,
  COUNT(*) AS row_count,
  ROUND(AVG(Weekly_Sales), 2) AS avg_weekly_sales
FROM `walmart-sales-project-jpasso.walmart_sales.train`
GROUP BY IsHoliday;


-- Q8: Quartiles and max of Weekly_Sales
-- Result: Q1 $2,079.65 / Median $7,612.03 / Q3 $20,205.85 / Max $693,099.36 (matches Excel)
-- Takeaway: IQR = $18,126.20; max is ~34x Q3, so skew comes from a few extreme high-volume weeks
-- Technique: window functions with OVER(), DISTINCT collapses identical rows into one
SELECT DISTINCT
  ROUND(PERCENTILE_CONT(Weekly_Sales, 0.25) OVER(), 2) AS q1,
  ROUND(PERCENTILE_CONT(Weekly_Sales, 0.5) OVER(), 2) AS median,
  ROUND(PERCENTILE_CONT(Weekly_Sales, 0.75) OVER(), 2) AS q3,
  ROUND(MAX(Weekly_Sales) OVER(), 2) AS max_weekly_sales
FROM `walmart-sales-project-jpasso.walmart_sales.train`;


-- Q9: Average Weekly_Sales by store Type (first JOIN, new finding beyond Excel)
-- Result: Type A $20,099.57 / Type B $12,237.08 / Type C $9,519.53
-- Takeaway: Type A averages ~2.1x Type C; likely a driver of the right skew found in Q8
SELECT
  s.Type,
  ROUND(AVG(t.Weekly_Sales), 2) AS avg_weekly_sales
FROM `walmart-sales-project-jpasso.walmart_sales.train` AS t
JOIN `walmart-sales-project-jpasso.walmart_sales.stores` AS s
  ON t.Store = s.Store
GROUP BY s.Type
ORDER BY avg_weekly_sales DESC;







