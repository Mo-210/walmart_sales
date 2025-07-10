-- ==========================================
-- WALMART SALES ANALYSIS PROJECT
-- Author: Mohammed H | Data Analyst
-- Purpose: Professional Portfolio Project
-- ==========================================

-- ==========================================
-- SECTION 1: DATABASE & TABLE SETUP
-- ==========================================

-- Create the database
CREATE DATABASE walmart_db;

-- Show available databases
SHOW DATABASES;

-- Use the Walmart database
USE walmart_db;

-- Show all tables in the database
SHOW TABLES;

-- Preview all records from the Walmart table
SELECT * FROM walmart;

-- ==========================================
-- SECTION 2: DATA ENRICHMENT - DERIVED COLUMNS
-- ==========================================

-- Add gross_profit to calculate gross profit per transaction
ALTER TABLE walmart ADD COLUMN gross_profit DECIMAL(10,2);
UPDATE walmart 
SET gross_profit = unit_price * quantity * profit_margin;

-- Add discount_rate to simulate discounts up to 20%
ALTER TABLE walmart ADD COLUMN discount_rate DECIMAL(5,2);
UPDATE walmart 
SET discount_rate = ROUND(RAND() * 0.2, 2);

-- Add discounted_total to store final total after discount
ALTER TABLE walmart ADD COLUMN discounted_total DECIMAL(10,2);
UPDATE walmart 
SET discounted_total = total * (1 - discount_rate);

-- Add customer_segment to categorize customers by spend level
ALTER TABLE walmart ADD COLUMN customer_segment VARCHAR(20);
UPDATE walmart
SET customer_segment = CASE
  WHEN total >= 500 THEN 'VIP'
  WHEN total >= 200 THEN 'Regular'
  ELSE 'Occasional'
END;

-- ==========================================
-- SECTION 3: BASIC BUSINESS QUESTIONS 
-- ==========================================

-- Q1: Find distinct payment methods and their transaction counts
SELECT payment_method, COUNT(*) AS no_payments, SUM(quantity) AS no_qty_sold
FROM walmart
GROUP BY payment_method;

-- Q2: Identify highest rated category per branch
SELECT *
FROM (
    SELECT 
        branch,
        category,
        avg_rating,
        RANK() OVER (PARTITION BY branch ORDER BY avg_rating DESC) AS ranking
    FROM (
        SELECT 
            branch,
            category,
            AVG(rating) AS avg_rating
        FROM walmart
        GROUP BY branch, category
    ) AS subquery
) AS ranked
WHERE ranking = 1;

-- Q3: Busiest day for each branch by transaction count
SELECT
    branch,
    day_name,
    no_transactions
FROM (
    SELECT
        branch,
        DAYNAME(STR_TO_DATE(date, '%d/%m/%y')) AS day_name,
        COUNT(*) AS no_transactions,
        RANK() OVER (PARTITION BY branch ORDER BY COUNT(*) DESC) AS ranking
    FROM walmart
    GROUP BY branch, day_name
) AS ranked_days
WHERE ranking = 1
ORDER BY branch;

-- Q4: Total quantity sold per payment method
SELECT payment_method, SUM(quantity) AS no_qty_sold
FROM walmart
GROUP BY payment_method;

-- Q5: Average, min, max product rating per city and category
SELECT 
  city, 
  category, 
  MIN(rating) AS min_rating, 
  MAX(rating) AS max_rating,
  ROUND(AVG(rating), 2) AS avg_rating 
FROM walmart
GROUP BY city, category;

-- Q6: Total profit per category
SELECT 
  category,
  ROUND(SUM(total), 2) AS Revenue,
  ROUND(SUM(total * profit_margin), 2) AS Profit
FROM walmart
GROUP BY category;

-- Q7: Most common payment method per branch
WITH cte AS (
  SELECT 
    branch, 
    payment_method, 
    COUNT(*) AS total_transactions,
    RANK() OVER (PARTITION BY branch ORDER BY COUNT(*) DESC) AS ranking
  FROM walmart
  GROUP BY branch, payment_method
)
SELECT * FROM cte
WHERE ranking = 1;

-- Q8: Categorize sales by shift and count invoices
SELECT
  branch,
  CASE
    WHEN TIME(STR_TO_DATE(time, '%H:%i:%s')) BETWEEN '05:00:00' AND '11:59:59' THEN 'Morning'
    WHEN TIME(STR_TO_DATE(time, '%H:%i:%s')) BETWEEN '12:00:00' AND '16:59:59' THEN 'Afternoon'
    ELSE 'Evening'
  END AS shift,
  COUNT(DISTINCT invoice_id) AS no_of_invoices
FROM walmart
GROUP BY branch, shift
ORDER BY branch, no_of_invoices DESC;

-- Q9: Top 5 branches with highest revenue decrease year over year
SELECT
  branch,
  revenue_2022,
  revenue_2023,
  ROUND(
    ((revenue_2022 - revenue_2023) / revenue_2022) * 100, 
    2
  ) AS decrease_ratio_percent
FROM (
  SELECT
    branch,
    SUM(CASE WHEN YEAR(STR_TO_DATE(date, '%d/%m/%y')) = 2022 THEN total ELSE 0 END) AS revenue_2022,
    SUM(CASE WHEN YEAR(STR_TO_DATE(date, '%d/%m/%y')) = 2023 THEN total ELSE 0 END) AS revenue_2023
  FROM walmart
  GROUP BY branch
) AS yearly_revenue
ORDER BY decrease_ratio_percent DESC
LIMIT 5;

-- ==========================================
-- SECTION 4: ADVANCED ANALYSIS
-- ==========================================

--  Seasonality: Which months generate the highest sales?
SELECT 
  MONTH(STR_TO_DATE(date, '%d/%m/%y')) AS month,
  SUM(total) AS revenue
FROM walmart
GROUP BY month
ORDER BY revenue DESC;

--  Average basket size per branch

SELECT 
  branch,
  SUM(quantity) AS total_quantity,
  COUNT(distinct invoice_id) AS total_invoices,
  ROUND(SUM(quantity) / COUNT(invoice_id), 2) AS avg_basket_size
FROM walmart
GROUP BY branch;

--  Top product categories by total revenue
SELECT 
  category,
  Round(SUM(total),2) AS revenue
FROM walmart
GROUP BY category
ORDER BY revenue DESC;

--  Benchmark branch performance against company average
WITH branch_revenue AS (
  SELECT branch, SUM(total) AS revenue 
  FROM walmart 
  GROUP BY branch
),
avg_revenue AS (
  SELECT AVG(revenue) AS avg_revenue FROM branch_revenue
)
SELECT 
  b.branch,
  b.revenue,
  a.avg_revenue,
  ROUND(((b.revenue - a.avg_revenue)/a.avg_revenue)*100, 2) AS variance_percent
FROM branch_revenue b, avg_revenue a;

--  What-if scenario: What if discounts increase by 5%?
SELECT
  SUM(total) AS original_revenue,
  SUM(discounted_total) AS current_discounted_revenue,
  SUM(total * 0.05) AS extra_discount_amount,
  SUM(total * (1 - (discount_rate + 0.05))) AS new_discounted_revenue
FROM walmart;

--  Customer segments by total revenue contribution
SELECT
  customer_segment,
  COUNT(*) AS num_transactions,
  SUM(total) AS total_revenue,
  ROUND(SUM(total) / (SELECT SUM(total) FROM walmart) * 100, 2) AS percent_of_total
FROM walmart
GROUP BY customer_segment
ORDER BY total_revenue DESC;

--  Peak hours of sales per branch
SELECT
  branch,
  HOUR(STR_TO_DATE(time, '%H:%i:%s')) AS hour,
  COUNT(*) AS transactions
FROM walmart
GROUP BY branch, hour
ORDER BY branch, transactions DESC;

--  Monthly Sales Analysis (Seasonality)
-- Analyze revenue trend by month to detect seasonality or trends
SELECT
  MONTH(STR_TO_DATE(date, '%d/%m/%Y')) AS month,
  ROUND(SUM(total), 2) AS monthly_revenue
FROM walmart
GROUP BY month
ORDER BY month;


--  Profitability Analysis per Branch
-- Calculate total sales, profit and profit margin percentage per branch
SELECT
  branch,
  ROUND(SUM(total), 2) AS total_sales,
  ROUND(SUM(total * profit_margin), 2) AS total_profit,
  ROUND((SUM(total * profit_margin) / SUM(total)) * 100, 2) AS profit_margin_percent
FROM walmart
GROUP BY branch
ORDER BY total_profit DESC;


--  Top 5 Categories by Sales Volume
-- Identify the top 5 categories by total quantity sold and revenue generated
SELECT
  category,
  SUM(quantity) AS total_quantity_sold,
  ROUND(SUM(total), 2) AS total_sales
FROM walmart
GROUP BY category
ORDER BY total_sales DESC;


--  Outlier Transactions (High Value Sales)
-- Detect unusually high-value transactions that exceed average by 2 standard deviations
SELECT *
FROM walmart
WHERE total > (SELECT AVG(total) + 2 * STDDEV(total) FROM walmart)
ORDER BY total DESC;

-- ==========================================
-- 	END OF SCRIPT
--  Thank You
-- ==========================================
