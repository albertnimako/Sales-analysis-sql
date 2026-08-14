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


-- ============================================
-- Q1: Which regions generate the most revenue and profit?
-- Business question: Regional performance breakdown for management reporting
-- ============================================
  
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

-- ============================================
-- Q2: How is revenue trending month over month?
-- Business question: Month over month growth analysis for FP&A reporting
-- ============================================
  
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

-- ============================================
-- Q3: Which product performs best in each region?
-- Business question: Top product per region for sales strategy decisions
-- ============================================

WITH cleaning_query AS (
    SELECT DISTINCT order_id,
    TRIM(UPPER(region)) AS region,
    COALESCE(TRIM(LOWER(category)), 'uncategorized') AS category,
    COALESCE(revenue, 0) AS revenue,
    COALESCE(profit, 0) AS profit,
    month,
    product_id
    FROM Orders
    WHERE region IS NOT NULL
),
ranked_products AS (
    SELECT p.product_name, c.region, c.revenue,
    RANK() OVER (PARTITION BY c.region ORDER BY c.revenue DESC) AS region_rank
    FROM cleaning_query c
    INNER JOIN Products p ON c.product_id = p.product_id
)
SELECT product_name, region, revenue, region_rank
FROM ranked_products
WHERE region_rank = 1
ORDER BY region;


-- ============================================
-- Q4: Which category has the highest profit margin?
-- Business question: Category profitability analysis for pricing decisions
-- ============================================

WITH cleaning_query AS (
    SELECT DISTINCT order_id,
    TRIM(UPPER(region)) AS region,
    COALESCE(TRIM(LOWER(category)), 'uncategorized') AS category,
    COALESCE(revenue, 0) AS revenue,
    COALESCE(profit, 0) AS profit,
    month
    FROM Orders
    WHERE region IS NOT NULL
),
category_pm AS (
    SELECT category,
    SUM(revenue) AS total_revenue,
    SUM(profit) AS total_profit,
    ROUND(SUM(profit) * 100.0 / SUM(revenue), 1) AS profit_margin
    FROM cleaning_query
    GROUP BY category
)
SELECT * FROM category_pm
ORDER BY profit_margin DESC;


-- ============================================
-- Q5: What is the running total of revenue by month across all regions?
-- Business question: Cumulative revenue tracking for financial reporting
-- ============================================

WITH cleaning_query AS (
    SELECT DISTINCT order_id,
    TRIM(UPPER(region)) AS region,
    COALESCE(TRIM(LOWER(category)), 'uncategorized') AS category,
    COALESCE(revenue, 0) AS revenue,
    COALESCE(profit, 0) AS profit,
    month
    FROM Orders
    WHERE region IS NOT NULL
),
month_region_totals AS (
    SELECT month, region,
    SUM(revenue) AS total_revenue,
    CASE WHEN month = 'Jan' THEN 1
         WHEN month = 'Feb' THEN 2
         WHEN month = 'Mar' THEN 3
    END AS month_num
    FROM cleaning_query
    GROUP BY month, region
),
running_total AS (
    SELECT month, region, total_revenue, month_num,
    SUM(total_revenue) OVER (ORDER BY month_num) AS running_total_all_regions,
    SUM(total_revenue) OVER (PARTITION BY region ORDER BY month_num) AS running_total_by_region
    FROM month_region_totals
)
SELECT month, region, total_revenue,
running_total_all_regions,
running_total_by_region
FROM running_total
ORDER BY month_num, region;
