-- SALES ANALYSIS SQL PROJECT
-- Author: Albert Nimako
-- Tools: SQLite
-- Dataset: Orders + Products (retail sales data)



-- DATA CLEANING
-- Standardize text, handle NULLs, remove duplicates


WITH cleaning_query AS (
SELECT DISTINCT order_id.
TRIM(UPPER (region)) AS region,
COALESCE (TRIM(LOWER (category)). 'uncategorized') AS cal
COALESCE (revenue, 0) AS revenue,
COALESCE (profit, 0) AS profit.
month
FROM Orders
WHERE region IS NOT NULL)
SELECT * FROM cleaning_query;


- Q1: Which regions generate the most revenue and profit?
- Business question: Regional performance breakdown for management reporting

  
WITH cleaning_query AS (
SELECT DISTINCT order_id,
TRIM(UPPER (region)) AS region,
COALESCE (TRIM(LOWER (category)), 'uncategorized') AS category,
COALESCE (revenue, 0) AS revenue, COALESCE (profit, 0) AS profit, month
FROM Orders
WHERE region IS NOT NULL),

earnings AS (
SELECT region,
SUM (revenue) AS total_revenue,SUM(profit) AS total_profit
  From cleanin_query
  GROUP BY region)

SELECT *
FROM earnings
ORDER BY total_revenue DESC;

-- Q2: How is revenue trending month over month?
-- Business question: Month over month growth analysis for FP&A reporting

  
WITH cleaning_query AS (
SELECT DISTINCT order_id,
TRIM (UPPER (region)) AS region,
COALESCE (TRIM (LOWER (category)), 'uncategorized') AS category,
COALESCE (revenue, 0) AS revenue,
COALESCE (profit, 0) AS profit, month
FROM Orders
WHERE region IS NOT NULL),

month_totals AS (SELECT month,SUM (revenue) AS total_revenue,
CASE WHEN month = 'Jan' THEN 1
WHEN month = 'Feb' THEN 2
WHEN month = 'Mar' THEN 3
END AS month_num
FROM cleaning_query
GROUP BY month

monthly_growth AS (
SELECT month, month_num, total revenue,
LAG (total revenue) OVER (ORDER BY month num) AS previous month, total_revenue - LAG(total_revenue) OVER (ORDER BY month_num) AS growth
  FROM month_totals)
  SELECT month, total_revenue, previous_month, growth
  FROM monthly_growth
  ORDER BY month_num;
