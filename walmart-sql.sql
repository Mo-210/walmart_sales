
create database walmart_db;
SHOW DATABASES;

use walmart_db;
show tables;

select * from walmart;

select distinct payment_method from walmart;

select payment_method,count(*) from walmart
group by payment_method;


select count(distinct branch) branch from walmart;



select max(quantity),min(quantity) from walmart;

-- Business Problms
-- Q1  find the different payment method and the number of transactions, number of qty sold
select payment_method, count(*) as no_payments,sum(quantity) as no_qty_sold
 from walmart
group by payment_method;

-- Q2 Identify the highest rated category in each branch display the branch the category
-- and the average rating

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

-- Q3  Identify the busiest day for each branch based on the number of transactions 


select * from walmart;

SELECT
    branch,
    day_name,
    no_transactions,
    ranking
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

-- Q4: calculate the total quantity of item sold per payment method list the payment 
-- method and the total quantity sold

select * from walmart;
select payment_method, sum(quantity) as no_qty_sold
 from walmart
group by payment_method;


-- Q5: determine the average, minimum and the maximum rating of product for each City. list the
-- city average rating minimum rating and the maximum rating 

select city, category, min(rating) as min_rating,max(rating) as max_rating,
Round(avg(rating),2) as avg_rating from walmart
group by 1,2;

-- Q6: calculate the total profit for each category by considering
-- the total profit as unit price times quantity times profit margin
-- ist the category and the total profit and the ordered 
-- from highest to lowest profit 

select * from walmart;
select 
	category,
    round(sum(total),2) as Revenue,
	round(sum(total*profit_margin),2) as Profit
from walmart
group by 1;


-- Q7:  determine the most common payment method for each each
-- branch. display the branch and the preferred method.

with cte as
(SELECT 
    branch, 
    payment_method, 
    COUNT(*) AS total_transactions,
    RANK() OVER (PARTITION BY branch ORDER BY COUNT(*) DESC) AS ranking
FROM walmart
GROUP BY 1,2)
select * from cte
where ranking =1;


-- categorize sales into three group morning afternoon and the evening
-- find out which of this shift and the number of the invoices 

select *, Hour(convert(time, Time))  from walmart;

-- Or

select*,cast(time as Time)  from walmart;


SELECT
  branch,
  CASE
    WHEN TIME(STR_TO_DATE(time, '%H:%i:%s')) BETWEEN '05:00:00' AND '11:59:59' THEN 'Morning'
    WHEN TIME(STR_TO_DATE(time, '%H:%i:%s')) BETWEEN '12:00:00' AND '16:59:59' THEN 'Afternoon'
    ELSE 'Evening'
  END AS shift,
  COUNT(DISTINCT invoice_id) AS no_of_invoices
FROM walmart
GROUP BY branch,shift
order by 1,3 DESC;



-- Q9: Identify the five branchs with the highest decrease ratio in Revenue
-- compared to the last year so the current year is 2023 the last year was 2022

-- To make it simple to learn:: 
SELECT branch, sum(total) as revenue FROM walmart
group by 1;

-- The answer:

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
